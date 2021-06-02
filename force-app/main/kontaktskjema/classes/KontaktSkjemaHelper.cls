public with sharing class KontaktSkjemaHelper {
    public static Id inclusionRecordType = Schema.SObjectType.CustomOpportunity__c.getRecordTypeInfosByDeveloperName()
        .get('Inclusion')
        .getRecordTypeId();

    public static Id fetchOrCreateContact(KontaktSkjemaModel rw) {
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

    public static Map<String, Account> getAccountMap(String orgNo) {
        if (String.isEmpty(orgNo)) {
        }
        return null;
    }

    public static void setName(SharedFunctions_ContactModel wrapper, KontaktSkjemaModel rw) {
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

    public static Id getDummyAccount() {
        List<Account> dummyAccount = [SELECT ID FROM Account WHERE Name = 'Kontakter uten konto'];
        Id accountId = dummyAccount.size() > 0 ? dummyAccount[0].Id : null;

        return accountId;
    }

    public static Id getAccount(String organisationNumber) {
        Map<String, Account> accountMap = SharedFunctions.fetchAccounts(new List<String>{ organisationNumber });
        Id accountId = accountMap.containsKey(organisationNumber) ? accountMap.get(organisationNumber).Id : null;

        return accountId;
    }

    public static CustomOpportunity__c createOpportunity(Id accountId, Id contactId, KontaktSkjemaModel rw) {
        CustomOpportunity__c co = new CustomOpportunity__c(
            Account__c = accountId,
            Contact__c = contactId,
            Source__c = 'Kontaktskjema',
            TAG_OrganizationNameFromForm__c = rw.organisationName,
            INT_MunicipalityNumber__c = rw.municipalityCode,
            InquiryCategory__c = getType(rw.type),
            RecordTypeId = inclusionRecordType,
            InclusionStage__c = 'Ny henvendelse',
            JsonPayload__c = rw.jsonPayload
        );

        if (isIA(rw.type)) {
            co.INT_RegionNumber__c = rw.regionCode;
        }

        insert co;

        return co;
    }

    public static void sendEmailReceipt(KontaktSkjemaModel rw, CustomOpportunity__c co) {
        if (!String.isEmpty(rw.email) && SharedFunctions_FetchOrCreateContact.checkIfValidEmail(rw.email)) {
            String templateName = co.InquiryCategory__c == 'Forebygge sykefravær'
                ? 'kontaktskjemaSykefravaerReceipt'
                : 'kontaktskjemaRekrutteringReceipt';
            EmailQueue__c email = new EmailQueue__c();
            email.TemplateName__c = templateName;
            email.TargetObjectId__c = co.Contact__c;
            email.WhatId__c = co.Id;
            email.Status__c = 'Instant';
            email.SaveAsActivity__c = true;

            insert email;
        }
    }

    public static Boolean isIA(String val) {
        return val == 'FOREBYGGE_SYKEFRAVÆR';
    }

    public static String getType(String val) {
        switch on val {
            when 'REKRUTTERING' {
                return 'Rekruttering';
            }
            when 'REKRUTTERING_MED_TILRETTELEGGING' {
                return 'Rekruttering med tilrettelegging';
            }
            when 'ARBEIDSTRENING' {
                return 'Arbeidstrening';
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
