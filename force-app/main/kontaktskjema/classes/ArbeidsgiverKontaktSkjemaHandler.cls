public inherited sharing class ArbeidsgiverKontaktSkjemaHandler implements IKafkaMessageConsumer {
    private static final Id INCLUSION_RECORD_TYPE = Schema.SObjectType.CustomOpportunity__c.getRecordTypeInfosByDeveloperName()
        .get('Inclusion')
        .getRecordTypeId();

    private LoggerUtility logger;

    public ArbeidsgiverKontaktSkjemaHandler() {
        this.logger = new LoggerUtility();
    }

    public void processMessages(List<KafkaMessage__c> messages) {
        List<ArbeidsgiverKontaktSkjema> models = new List<ArbeidsgiverKontaktSkjema>();
        List<CustomOpportunity__c> opportunities = new List<CustomOpportunity__c>();
        try {
            for (KafkaMessage__c message : messages) {
                try {
                    models.add(convertToKontaktSkjema(message));
                    message.CRM_Status__c = KafkaMessageService.STATUS_PROCESSED;
                } catch (Exception e) {
                    message.CRM_Status__c = KafkaMessageService.STATUS_ERROR;
                    message.CRM_ErrorMessage__c = e.getMessage() + ' (' + e.getLineNumber() + ')';
                    logger.error(e.getMessage() + '\n ' + e.getStackTraceString(), null);
                    logger.publish();
                }
            }
            opportunities = toCustomOpportunity(models);
            insert opportunities;
            sendEmailReceipts(opportunities);
        } catch (Exception e) {
            logger.error(e.getMessage() + '\n ' + e.getStackTraceString(), null);
            logger.publish();
            throw e;
        }
    }

    private ArbeidsgiverKontaktSkjema convertToKontaktSkjema(KafkaMessage__c message) {
        String decodedValue = KafkaMessageUtils.base64ULSafeDecode(message.CRM_Value__c).toString();

        return ArbeidsgiverKontaktSkjema.parse(decodedValue);
    }

    private static List<CustomOpportunity__c> toCustomOpportunity(List<ArbeidsgiverKontaktSkjema> models) {
        List<CustomOpportunity__c> opportunities = new List<CustomOpportunity__c>();
        Map<String, Account> accountMap = getAccountMap(models);
        Map<String, Contact> contactMap = getContactMap(models);

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

    private static void sendEmailReceipts(List<CustomOpportunity__c> opportunities) {
        List<EmailQueue__c> emails = new List<EmailQueue__c>();

        for (CustomOpportunity__c co : opportunities) {
            if (co.Contact__c != null) {
                String templateName = co.InquiryCategory__c == 'Forebygge sykefravær'
                    ? 'kontaktskjemaSykefravaerReceipt'
                    : 'kontaktskjemaRekrutteringReceipt';
                EmailQueue__c email = new EmailQueue__c();
                email.TemplateName__c = templateName;
                email.TargetObjectId__c = co.Contact__c;
                email.WhatId__c = co.Id;
                email.Priority__c = '5';
                email.Status__c = 'Queued';
                email.SaveAsActivity__c = true;

                emails.add(email);
            }
        }
        insert emails;
    }

    private static Map<String, Account> getAccountMap(List<ArbeidsgiverKontaktSkjema> formSubmissions) {
        List<String> orgnaizationNumbers = new List<String>();

        for (ArbeidsgiverKontaktSkjema fs : formSubmissions) {
            if (fs.organisationNumber != null) {
                orgnaizationNumbers.add(fs.organisationNumber);
            }
        }

        return SharedFunctions.fetchAccounts(orgnaizationNumbers);
    }

    public static Map<String, Contact> getContactMap(List<ArbeidsgiverKontaktSkjema> formSubmissions) {
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

        return SharedFunctions.fetchOrCreateContact(contactWrappers, getAccountMap(formSubmissions));
    }

    private static void setName(SharedFunctions_ContactModel wrapper, ArbeidsgiverKontaktSkjema model) {
        if (!String.isEmpty(model.fullName)) {
            List<String> fullName = model.fullName.split(' ');
            String lastNameSplitted = fullName[fullName.size() - 1];
            String firstNameSplitted = model.fullName.removeEnd(' ' + lastNameSplitted);
            wrapper.firstName = firstNameSplitted;
            wrapper.lastName = lastNameSplitted;
        }
    }

    private static String getType(String val) {
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
