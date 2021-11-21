public with sharing class KafkaKontaktSkjemaHandler_Helper {
    public static Id inclusionRecordType = Schema.SObjectType.CustomOpportunity__c.getRecordTypeInfosByDeveloperName()
    .get('Inclusion')
    .getRecordTypeId();

    
    public static List<KafkaKontaktSkjemaHandler_Model> convertKafkaToOpportunity(List<KafkaMessage__c> messages) {
        List<KafkaKontaktSkjemaHandler_Model> kontaktskjema = new List<KafkaKontaktSkjemaHandler_Model>();
        for (KafkaMessage__c msg : messages) {
            try {
                msg.CRM_Status__c = 'Processed';
                String decodedValue = KafkaMessageUtils.base64ULSafeDecode(msg.CRM_Value__c).toString();
                KafkaKontaktSkjemaHandler_Model o = KafkaKontaktSkjemaHandler_Model.parse(decodedValue);
                kontaktskjema.add(o);
            } catch (Exception e) {
                msg.CRM_ErrorMessage__c = e.getMessage() + ' (' + e.getLineNumber() + ')';
            }
        }
        return kontaktskjema;
    }

    public static List<CustomOpportunity__c> convertKontaktskjemaToOpportunity(
        List<KafkaKontaktSkjemaHandler_Model> kontaktskjema
    ) {
        List<CustomOpportunity__c> opportunity = new List<CustomOpportunity__c>();
        for (KafkaKontaktSkjemaHandler_Model k : kontaktskjema) {
            Id contactId = fetchOrCreateContact(k);
            Id accountId = getAccount(k.organisationNumber);
            opportunity.add(jsonToOpportunity(accountId, contactId, k));
        }
        insert opportunity;
        return opportunity;
    }

    public static CustomOpportunity__c jsonToOpportunity(Id accountId, Id contactId, KafkaKontaktSkjemaHandler_Model k) {
        CustomOpportunity__c co = new CustomOpportunity__c(
            Account__c = accountId,
            Contact__c = contactId,
            Source__c = 'Kontaktskjema',
            TAG_OrganizationNameFromForm__c = k.organisationName,
            INT_MunicipalityNumber__c = k.municipalityCode,
            InquiryCategory__c = getType(k.type),
            RecordTypeId = inclusionRecordType,
            InclusionStage__c = 'Ny henvendelse',
            JsonPayload__c = k.jsonPayload
        );

        if (isIA(k.type)) {
            co.INT_RegionNumber__c = k.regionCode;
        }

        return co;
    }

    public static Id fetchOrCreateContact(KafkaKontaktSkjemaHandler_Model rw) {
        SharedFunctions_ContactModel wrapper = new SharedFunctions_ContactModel();
        rw.email = rw.email == null ? '' : rw.email; // if null, make it empty to avoid bug in SharedFunctions.fetchOrCreateContact

        setName(wrapper, rw);
        wrapper.phone = rw.phoneNo;
        wrapper.email = rw.email;
        wrapper.source = 'Kontaktskjema';
        wrapper.companyNumber = rw.organisationNumber;

        List<SharedFunctions_ContactModel> wrapperList = new List<SharedFunctions_ContactModel>{ wrapper };
        List<String> orgNo = new List<String>{ rw.organisationNumber };

        Map<String, Account> accountMap = SharedFunctions.fetchAccounts(orgNo);
        Map<String, Contact> contactMap = SharedFunctions.fetchOrCreateContact(wrapperList, accountMap);
        Id contactId = contactMap.containsKey(rw.email.toLowerCase())
            ? contactMap.get(rw.email.toLowerCase()).Id
            : null;

        return contactId;
    }

    public static void setName(SharedFunctions_ContactModel wrapper, KafkaKontaktSkjemaHandler_Model rw) {
        if (!String.isEmpty(rw.name)) {
            List<String> fullName = rw.name.split(' ');
            String lastNameSplitted = fullName[fullName.size() - 1];
            String firstNameSplitted = rw.name.removeEnd(' ' + lastNameSplitted);
            wrapper.firstName = firstNameSplitted;
            wrapper.lastName = lastNameSplitted;
        } else {
            wrapper.firstName = rw.firstName;
            wrapper.lastName = rw.lastName;
        }
    }

    public static Id getAccount(String organisationNumber) {
        Map<String, Account> accountMap = SharedFunctions.fetchAccounts(new List<String>{ organisationNumber });
        Id accountId = accountMap.containsKey(organisationNumber) ? accountMap.get(organisationNumber).Id : null;

        return accountId;
    }

    public static Boolean isIA(String val) {
        return val == 'FOREBYGGE_SYKEFRAVÆR';
    }

    public static String getType(String val) {
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

    public static void sendEmailReceipt(List<CustomOpportunity__c> opportunities) {
        List<EmailQueue__c> emails = new List<EmailQueue__c>();
        for(CustomOpportunity__c co: opportunities) {
            if (co.Contact__c != null) {
                String templateName = co.InquiryCategory__c == 'Forebygge sykefravær'
                    ? 'kontaktskjemaSykefravaerReceipt'
                    : 'kontaktskjemaRekrutteringReceipt';
                EmailQueue__c email = new EmailQueue__c();
                email.TemplateName__c = templateName;
                email.TargetObjectId__c = co.Contact__c;
                email.WhatId__c = co.Id;
                email.Status__c = 'Instant';
                email.SaveAsActivity__c = true;

                emails.add(email);
            }
        }
        insert emails;
    }
}
