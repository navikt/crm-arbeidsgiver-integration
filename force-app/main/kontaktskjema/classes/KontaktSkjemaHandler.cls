@RestResource(urlMapping='/ContactForm/*')
global with sharing class KontaktSkjemaHandler {
    public static Id inclusionRecordType = Schema.SObjectType.CustomOpportunity__c.getRecordTypeInfosByDeveloperName()
        .get('Inclusion')
        .getRecordTypeId();
    public static Id IARecordType = Schema.SObjectType.CustomOpportunity__c.getRecordTypeInfosByDeveloperName()
        .get('Inclusive_Employment')
        .getRecordTypeId();

    public class RequestWrapper {
        String type;
        String municipalityCode;
        String regionCode;
        String organisationName;
        String organisationNumber;
        String name;
        String firstName;
        String lastName;
        String email;
        String phoneNo;
        String jsonPayload;
    }

    @HttpPost
    global static String doPost() {
        String requestString = RestContext.request.requestBody.toString();
        RequestWrapper rw = (RequestWrapper) JSON.deserialize(requestString, RequestWrapper.class);
        rw.jsonPayload = requestString;

        SharedFunctions_ContactModel wrapper = new SharedFunctions_ContactModel();
        
        if(rw.name != null) {
            List<String> fullName = rw.name.split(' ');
            String lastNameSplitted = fullName[fullName.size() - 1];
            String firstNameSplitted = rw.name.removeEnd(' ' + lastNameSplitted);
            wrapper.firstName = firstNameSplitted;
            wrapper.lastName = lastNameSplitted;

        } else {
            wrapper.firstName = rw.firstName;
            wrapper.lastName = rw.lastName;
        }
        
        wrapper.phone = rw.phoneNo;
        wrapper.email = rw.email;
        wrapper.source = 'Kontaktskjema';
        wrapper.companyNumber = rw.organisationNumber;
        List<SharedFunctions_ContactModel> wrapperList = new List<SharedFunctions_ContactModel>{ wrapper };

        Map<String, Account> accountMap = SharedFunctions.fetchAccounts(new List<String>{ rw.organisationNumber });
        Id accountId = accountMap.containsKey(rw.organisationNumber) ? accountMap.get(rw.organisationNumber).Id : null;
        Map<String, Contact> contactMap = SharedFunctions.fetchOrCreateContact(wrapperList, accountMap);
        Id contactId = contactMap.containsKey(rw.email.toLowerCase())
            ? contactMap.get(rw.email.toLowerCase()).Id
            : null;

        CustomOpportunity__c co = new CustomOpportunity__c(
            Account__c = accountId,
            Contact__c = contactId,
            Source__c = 'Kontaktskjema',
            TAG_OrganizationNameFromForm__c = rw.organisationName,
            INT_MunicipalityNumber__c = rw.municipalityCode,
            InquiryCategory__c = getType(rw.type),
            RecordTypeId = inclusionRecordType,
            // RecordTypeId = getRecordType( rw.type ),
            InclusionStage__c = 'Ny henvendelse',
            JsonPayload__c = rw.jsonPayload
        );

        if (isIA(rw.type)) {
            co.INT_RegionNumber__c = rw.regionCode;
        }

        insert co;

        //if ( co.Contact__r.Email != '') {
       if ( rw.email != '') {
            EmailQueue__c email = new EmailQueue__c();
            email.TemplateName__c = 'kontaktskjemaReceipt';
            email.TargetObjectId__c = co.Contact__c;
            email.WhatId__c = co.Id;
            email.Status__c = 'Instant';
            email.SaveAsActivity__c = true;
    
            insert email;

        }

        return [SELECT Name FROM CustomOpportunity__c WHERE Id = :co.Id LIMIT 1].Name;
    }

    public static Id getRecordType(String val) {
        if (val == 'FOREBYGGE_SYKEFRAVÆR') {
            return IARecordType;
        } else {
            return inclusionRecordType;
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
