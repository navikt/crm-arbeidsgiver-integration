public inherited sharing class ArbeidsgiverKontaktSkjemaHandler extends KafkaMessageProcessor implements IKafkaMessageConsumer {
    private List<ArbeidsgiverKontaktSkjema> models = new List<ArbeidsgiverKontaktSkjema>();
    private static final Id INCLUSION_RECORD_TYPE = Schema.SObjectType.CustomOpportunity__c.getRecordTypeInfosByDeveloperName()
        .get('Inclusion')
        .getRecordTypeId();

    public void processMessages(List<KafkaMessage__c> messages) {
        for (KafkaMessage__c message : messages) {
            try {
                ArbeidsgiverKontaktSkjema model = (ArbeidsgiverKontaktSkjema) parse(
                    ArbeidsgiverKontaktSkjema.class,
                    message
                );
                orgNumbers.add(model.organisationNumber);
                models.add(model);
                message.CRM_Status__c = KafkaMessageService.STATUS_PROCESSED;
            } catch (Exception e) {
                message.CRM_Status__c = KafkaMessageService.STATUS_ERROR;
                message.CRM_ErrorMessage__c = e.getMessage() + ' (' + e.getLineNumber() + ')';
            }
        }
        convertAndInsertOpportunities(messages);
    }

    private void convertAndInsertOpportunities(List<KafkaMessage__c> messages) {
        try {
            List<CustomOpportunity__c> opportunities = toCustomOpportunity(models);
            insert opportunities;
            sendEmailReceipts(opportunities);
        } catch (Exception e) {
            String errorRef = logError(e.getMessage() + '/n' + e.getStackTraceString());
            setMessageErrors(messages, errorRef);
        }
    }

    private List<CustomOpportunity__c> toCustomOpportunity(List<ArbeidsgiverKontaktSkjema> models) {
        List<CustomOpportunity__c> opportunities = new List<CustomOpportunity__c>();
        Map<String, Account> accountMap = getOrgNumberAccountMap();
        Map<String, Contact> contactMap = getContactMap(models, accountMap);

        for (ArbeidsgiverKontaktSkjema model : models) {
            CustomOpportunity__c opp = new CustomOpportunity__c(
                TAG_OrganizationNameFromForm__c = model.organisationName,
                INT_MunicipalityNumber__c = model.municipalityCode,
                InquiryCategory__c = getType(model.type),
                INT_RegionNumber__c = model.regionCode,
                RecordTypeId = INCLUSION_RECORD_TYPE,
                InclusionStage__c = 'Ny henvendelse',
                Source__c = 'Kontaktskjema',
                JsonPayload__c = model.jsonPayload
            );

            if (contactMap.containsKey(model.email.toLowerCase())) {
                opp.Contact__c = contactMap.get(model.email.toLowerCase()).Id;
            }

            if (accountMap.containsKey(model.organisationNumber)) {
                opp.Account__c = accountMap.get(model.organisationNumber).Id;
            }
            opportunities.add(opp);
        }

        return opportunities;
    }

    private void sendEmailReceipts(List<CustomOpportunity__c> opportunities) {
        List<EmailQueue__c> emails = new List<EmailQueue__c>();
        try {
            for (CustomOpportunity__c co : opportunities) {
                if (co.Contact__c != null) {
                    emails.add(generateDraftEmailReceipt(co));
                }
            }
            insert emails;
        } catch (Exception e) {
            logError('Failed to send email confirmations' + e.getMessage() + '/n' + e.getStackTraceString());
        }
    }

    private EmailQueue__c generateDraftEmailReceipt(CustomOpportunity__c opportunity) {
        String templateName = opportunity.InquiryCategory__c == 'Forebygge sykefravær'
            ? 'kontaktskjemaSykefravaerReceipt'
            : 'kontaktskjemaRekrutteringReceipt';
        EmailQueue__c email = new EmailQueue__c();
        email.TemplateName__c = templateName;
        email.TargetObjectId__c = opportunity.Contact__c;
        email.WhatId__c = opportunity.Id;
        email.Priority__c = '5';
        email.Status__c = 'Queued';
        email.SaveAsActivity__c = true;

        return email;
    }

    public Map<String, Contact> getContactMap(
        List<ArbeidsgiverKontaktSkjema> formSubmissions,
        Map<String, Account> accountMap
    ) {
        List<SharedFunctions_ContactModel> contactWrappers = new List<SharedFunctions_ContactModel>();

        for (ArbeidsgiverKontaktSkjema submission : formSubmissions) {
            SharedFunctions_ContactModel wrapper = new SharedFunctions_ContactModel();

            wrapper.email = submission.email == null ? '' : submission.email; // if null, make it empty to avoid bug in SharedFunctions.fetchOrCreateContact
            wrapper.companyNumber = submission.organisationNumber;
            wrapper.phone = submission.phoneNumber;
            wrapper.email = submission.email;
            wrapper.source = 'Kontaktskjema';
            setName(wrapper, submission);
            contactWrappers.add(wrapper);
        }

        return SharedFunctions.fetchOrCreateContact(contactWrappers, accountMap);
    }

    private void setName(SharedFunctions_ContactModel wrapper, ArbeidsgiverKontaktSkjema model) {
        if (!String.isEmpty(model.fullName)) {
            List<String> fullName = model.fullName.split(' ');
            String lastNameSplitted = fullName[fullName.size() - 1];
            String firstNameSplitted = model.fullName.removeEnd(' ' + lastNameSplitted);
            wrapper.firstName = firstNameSplitted;
            wrapper.lastName = lastNameSplitted;
        }
    }

    private String getType(String val) {
        switch on val {
            when 'REKRUTTERING' {
                return 'Skal ansette';
            }
            when 'FOREBYGGE_SYKEFRAVÆR' {
                return 'Forebygge sykefravær';
            }
            when else {
                return null;
            }
        }
    }
}
