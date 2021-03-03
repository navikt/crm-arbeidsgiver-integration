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

    public static RequestWrapper deserializeData( RestRequest request ) {
        String requestString = RestContext.request.requestBody.toString();
        RequestWrapper rw = (RequestWrapper) JSON.deserialize(requestString, RequestWrapper.class);
        rw.jsonPayload = requestString;

        return rw;
    }

    @HttpPost
    global static String doPost() {

        RequestWrapper rw = deserializeData(RestContext.request);

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

        Id accountId = getAccount( rw.organisationNumber );
        Id contactId = getContact( new List<String>{ rw.organisationNumber }, wrapperList, rw.email);

        CustomOpportunity__c co = createOpportunity(accountId, contactId, rw);

        sendEmailReceipt( rw, co );

        return [SELECT Name FROM CustomOpportunity__c WHERE Id = :co.Id LIMIT 1].Name;
    }

    public static Id getAccount(
        String organisationNumber
        ) {
        Map<String, Account> accountMap = SharedFunctions.fetchAccounts( new List<String>{ organisationNumber } );
        Id accountId = accountMap.containsKey( organisationNumber ) ? accountMap.get( organisationNumber ).Id : null;

        return accountId;
        
    }

    public static Id getContact(
        List<String> orgNo,
        List<SharedFunctions_ContactModel> wrapperList,
        String email
    ) {
        Map<String, Account> accountMap = SharedFunctions.fetchAccounts( orgNo );
        Map<String, Contact> contactMap = SharedFunctions.fetchOrCreateContact(wrapperList, accountMap);
        Id contactId = contactMap.containsKey(email.toLowerCase())
            ? contactMap.get(email.toLowerCase()).Id
            : null;

        return contactId;
    }

    public static CustomOpportunity__c createOpportunity(
        Id accountId,
        Id contactId,
        RequestWrapper rw ) 
    {
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

        return co;
    }

    public static void sendEmailReceipt( 
        RequestWrapper rw,
        CustomOpportunity__c co ) 
        {
        if ( rw.email != '') {

            String templateName = co.InquiryCategory__c == 'Forebygge sykefravær' ? 'kontaktskjemaSykefravaerReceipt' : 'kontaktskjemaRekrutteringReceipt';
            EmailQueue__c email = new EmailQueue__c();
            email.TemplateName__c = templateName;
            email.TargetObjectId__c = co.Contact__c;
            email.WhatId__c = co.Id;
            email.Status__c = 'Instant';
            email.SaveAsActivity__c = true;
            
            insert email;
        }
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
