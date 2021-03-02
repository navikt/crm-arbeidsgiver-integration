@isTest
private without sharing class KontaktSkjemaHandlerTest {
    @isTest
    private static void doPost_municipalityAgder() {
        insert new Account(name = 'test', INT_OrganizationNumber__c = '960507878');

        List<CustomOpportunity__c> CustomOpportunities = [SELECT Id FROM CustomOpportunity__c];
        System.assertEquals(0, CustomOpportunities.size(), 'Size should be zero before');

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/ContactForm';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(
            '{ "type":"ARBEIDSTRENING","municipalityCode":"4202","organisationName":"Finstadtunet","organisationNumber":"960507878","firstName":"TestNavn","lastName":"TestEtternavn","email":"test@nav.no","phoneNo":"90080900","RegionCode":"1000" }'
        );
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        String result = KontaktSkjemaHandler.doPost();
        Test.stopTest();

        CustomOpportunities = [
            SELECT
                Id,
                InquiryCategory__c,
                RecordTypeId,
                INT_RegionNumber__c,
                INT_MunicipalityNumber__c,
                TAG_OrganizationNameFromForm__c,
                Contact__r.FirstName,
                Contact__r.LastName,
                Contact__r.Email,
                Contact__r.MobilePhone,
                Account__r.INT_OrganizationNumber__c
            FROM CustomOpportunity__c
        ];
        System.assertEquals(1, CustomOpportunities.size(), 'Size should be one after insert');

        System.assertNotEquals(null, result, 'Returned value should not be null, as Agder is not in the pilot');
    }

    @isTest
    private static void doPost_municipalityViken() {
        insert new Account(name = 'test', INT_OrganizationNumber__c = '960507878');

        List<CustomOpportunity__c> CustomOpportunities = [SELECT Id FROM CustomOpportunity__c];
        System.assertEquals(0, CustomOpportunities.size(), 'Size should be zero before');

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/ContactForm';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(
            '{ "type":"ARBEIDSTRENING","municipalityCode":"3032","organisationName":"Finstadtunet","organisationNumber":"960507878","firstName":"TestNavn","lastName":"TestEtternavn","email":"test@nav.no","phoneNo":"90080900","RegionCode":"1000" }'
        );
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        String result = KontaktSkjemaHandler.doPost();
        Test.stopTest();

        CustomOpportunities = [
            SELECT
                Id,
                InquiryCategory__c,
                RecordTypeId,
                INT_RegionNumber__c,
                INT_MunicipalityNumber__c,
                TAG_OrganizationNameFromForm__c,
                Contact__r.FirstName,
                Contact__r.LastName,
                Contact__r.Email,
                Contact__r.MobilePhone,
                Account__r.INT_OrganizationNumber__c
            FROM CustomOpportunity__c
        ];
        System.assertEquals(1, CustomOpportunities.size(), 'Size should be one after insert');

        System.assertNotEquals(null, result, 'Returned value should NOT be null, as Agder is not in the pilot');
    }

    @isTest
    private static void doPost_regionInnlandet() {
        insert new Account(name = 'test', INT_OrganizationNumber__c = '960507878');

        List<CustomOpportunity__c> CustomOpportunities = [SELECT Id FROM CustomOpportunity__c];
        System.assertEquals(0, CustomOpportunities.size(), 'Size should be zero before');

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/ContactForm';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(
            '{ "type":"ARBEIDSTRENING","municipalityCode":"3428","organisationName":"Finstadtunet","organisationNumber":"960507878","firstName":"TestNavn","lastName":"TestEtternavn","email":"test@nav.no","phoneNo":"90080900","RegionCode":"0400" }'
        );
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        String result = KontaktSkjemaHandler.doPost();
        Test.stopTest();

        CustomOpportunities = [
            SELECT
                Id,
                InquiryCategory__c,
                RecordTypeId,
                INT_RegionNumber__c,
                INT_MunicipalityNumber__c,
                TAG_OrganizationNameFromForm__c,
                Contact__r.FirstName,
                Contact__r.LastName,
                Contact__r.Email,
                Contact__r.MobilePhone,
                Account__r.INT_OrganizationNumber__c
            FROM CustomOpportunity__c
        ];
        System.assertEquals(1, CustomOpportunities.size(), 'Size should be one after insert');

        System.assertNotEquals(null, result, 'Returned value should NOT be null, as Agder is not in the pilot');
    }

    @isTest
    private static void doPost_regionNordland() {
        insert new Account(name = 'test', INT_OrganizationNumber__c = '960507878');

        List<CustomOpportunity__c> CustomOpportunities = [SELECT Id FROM CustomOpportunity__c];
        System.assertEquals(0, CustomOpportunities.size(), 'Size should be zero before');

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/ContactForm';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(
            '{ "type":"ARBEIDSTRENING","municipalityCode":"1820","organisationName":"Finstadtunet","organisationNumber":"960507878","firstName":"TestNavn","lastName":"TestEtternavn","email":"test@nav.no","phoneNo":"90080900","RegionCode":"1800" }'
        );
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        String result = KontaktSkjemaHandler.doPost();
        Test.stopTest();

        CustomOpportunities = [
            SELECT
                Id,
                InquiryCategory__c,
                RecordTypeId,
                INT_RegionNumber__c,
                INT_MunicipalityNumber__c,
                TAG_OrganizationNameFromForm__c,
                Contact__r.FirstName,
                Contact__r.LastName,
                Contact__r.Email,
                Contact__r.MobilePhone,
                Account__r.INT_OrganizationNumber__c
            FROM CustomOpportunity__c
        ];
        System.assertEquals(1, CustomOpportunities.size(), 'Size should be one after insert');

        System.assertNotEquals(null, result, 'Returned value should NOT be null, as Nordland is in the pilot');
    }

    @isTest
    private static void doPost_regionMoreOgRomsdal() {
        insert new Account(name = 'test', INT_OrganizationNumber__c = '960507878');

        List<CustomOpportunity__c> CustomOpportunities = [SELECT Id FROM CustomOpportunity__c];
        System.assertEquals(0, CustomOpportunities.size(), 'Size should be zero before');

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/ContactForm';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(
            '{ "type":"ARBEIDSTRENING","municipalityCode":"1525","organisationName":"Finstadtunet","organisationNumber":"960507878","firstName":"TestNavn","lastName":"TestEtternavn","email":"test@nav.no","phoneNo":"90080900","RegionCode":"1500" }'
        );
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        String result = KontaktSkjemaHandler.doPost();
        Test.stopTest();

        CustomOpportunities = [
            SELECT
                Id,
                InquiryCategory__c,
                RecordTypeId,
                INT_RegionNumber__c,
                INT_MunicipalityNumber__c,
                TAG_OrganizationNameFromForm__c,
                Contact__r.FirstName,
                Contact__r.LastName,
                Contact__r.Email,
                Contact__r.MobilePhone,
                Account__r.INT_OrganizationNumber__c
            FROM CustomOpportunity__c
        ];
        System.assertEquals(1, CustomOpportunities.size(), 'Size should be one after insert');

        System.assertNotEquals(null, result, 'Returned value should NOT be null, as Møre og Romsdal is in the pilot');
    }

    @isTest
    private static void doPost_arbeidstrening() {
        insert new Account(name = 'test', INT_OrganizationNumber__c = '960507878');

        List<CustomOpportunity__c> CustomOpportunities = [SELECT Id FROM CustomOpportunity__c];
        System.assertEquals(0, CustomOpportunities.size(), 'Size should be zero before');

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/ContactForm';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(
            '{ "type":"ARBEIDSTRENING","municipalityCode":"3033","organisationName":"Finstadtunet","organisationNumber":"960507878","firstName":"TestNavn","lastName":"TestEtternavn","email":"test@nav.no","phoneNo":"90080900","RegionCode":"0200" }'
        );
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        KontaktSkjemaHandler.doPost();
        Test.stopTest();

        CustomOpportunities = [
            SELECT
                Id,
                InquiryCategory__c,
                RecordTypeId,
                INT_RegionNumber__c,
                INT_MunicipalityNumber__c,
                TAG_OrganizationNameFromForm__c,
                Contact__r.FirstName,
                Contact__r.LastName,
                Contact__r.Email,
                Contact__r.MobilePhone,
                Account__r.INT_OrganizationNumber__c
            FROM CustomOpportunity__c
        ];
        System.assertEquals(1, CustomOpportunities.size(), 'Size should be one after insert');

        System.assertEquals(
            'Arbeidstrening',
            CustomOpportunities[0].InquiryCategory__c,
            '"Type" should be "Arbeidstrening"'
        );
        System.assertEquals(
            'TestNavn',
            CustomOpportunities[0].Contact__r.FirstName,
            '"Contact__r.FirstName" should be "TestNavn"'
        );
        System.assertEquals(
            'TestEtternavn',
            CustomOpportunities[0].Contact__r.LastName,
            '"Contact__r.LastName" should be "TestEtternavn"'
        );
        System.assertEquals(
            null,
            CustomOpportunities[0].INT_RegionNumber__c,
            'Region code should be null on non-IA optys'
        );
        System.assertEquals(
            '3033',
            CustomOpportunities[0].INT_MunicipalityNumber__c,
            'Region code should be null on non-IA optys'
        );
        System.assertEquals(
            'Finstadtunet',
            CustomOpportunities[0].TAG_OrganizationNameFromForm__c,
            'Name of company should be set as Finstadtunet'
        );
        System.assertEquals(
            'test@nav.no',
            CustomOpportunities[0].Contact__r.Email,
            '"Contact__r.Email" should be "test@nav.no"'
        );
        System.assertEquals(
            '90080900',
            CustomOpportunities[0].Contact__r.MobilePhone,
            '"Contact__r.MobilePhone" should be "90080900"'
        );
        System.assertEquals(
            '960507878',
            CustomOpportunities[0].Account__r.INT_OrganizationNumber__c,
            '"Account__r.INT_OrganizationNumber__c" should be "960507878"'
        );
    }

    @isTest
    private static void doPost_forebyggeSykefravaer() {
        insert new Account(name = 'test', INT_OrganizationNumber__c = '960507878');

        List<CustomOpportunity__c> CustomOpportunities = [SELECT Id FROM CustomOpportunity__c];
        System.assertEquals(0, CustomOpportunities.size(), 'Size should be zero before');

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/ContactForm';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(
            '{ "type":"FOREBYGGE_SYKEFRAVÆR","municipalityCode":"3033","organisationName":"Finstadtunet","organisationNumber":"960507878","firstName":"TestNavn","lastName":"TestEtternavn","email":"test@nav.no","phoneNo":"90080900","RegionCode":"0200" }'
        );
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        KontaktSkjemaHandler.doPost();
        Test.stopTest();

        CustomOpportunities = [
            SELECT
                Id,
                InquiryCategory__c,
                RecordTypeId,
                INT_RegionNumber__c,
                INT_MunicipalityNumber__c,
                TAG_OrganizationNameFromForm__c,
                Contact__r.FirstName,
                Contact__r.LastName,
                Contact__r.Email,
                Contact__r.MobilePhone,
                Account__r.INT_OrganizationNumber__c
            FROM CustomOpportunity__c
        ];
        System.assertEquals(1, CustomOpportunities.size(), 'Size should be one after insert');

        System.assertEquals(
            'Forebygge sykefravær',
            CustomOpportunities[0].InquiryCategory__c,
            '"Type" should be "Forebygge sykefravær"'
        );
        System.assertEquals(
            'TestNavn',
            CustomOpportunities[0].Contact__r.FirstName,
            '"Contact__r.FirstName" should be "TestNavn"'
        );
        System.assertEquals(
            'TestEtternavn',
            CustomOpportunities[0].Contact__r.LastName,
            '"Contact__r.LastName" should be "TestEtternavn"'
        );
        System.assertEquals(
            '0200',
            CustomOpportunities[0].INT_RegionNumber__c,
            'Region code should be null on non-IA optys'
        );
        System.assertEquals(
            '3033',
            CustomOpportunities[0].INT_MunicipalityNumber__c,
            'Region code should be null on non-IA optys'
        );
        System.assertEquals(
            'Finstadtunet',
            CustomOpportunities[0].TAG_OrganizationNameFromForm__c,
            'Name of company should be set as Finstadtunet'
        );
        System.assertEquals(
            'test@nav.no',
            CustomOpportunities[0].Contact__r.Email,
            '"Contact__r.Email" should be "test@nav.no"'
        );
        System.assertEquals(
            '90080900',
            CustomOpportunities[0].Contact__r.MobilePhone,
            '"Contact__r.MobilePhone" should be "90080900"'
        );
        System.assertEquals(
            '960507878',
            CustomOpportunities[0].Account__r.INT_OrganizationNumber__c,
            '"Account__r.INT_OrganizationNumber__c" should be "960507878"'
        );
    }
    //
    @isTest
    private static void doPost_contactName() {
        insert new Account(name = 'test', INT_OrganizationNumber__c = '960507878');

        List<CustomOpportunity__c> CustomOpportunities = [SELECT Id FROM CustomOpportunity__c];
        System.assertEquals(0, CustomOpportunities.size(), 'Size should be zero before');

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/ContactForm';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(
            '{ "type":"FOREBYGGE_SYKEFRAVÆR","municipalityCode":"3033","organisationName":"Finstadtunet","organisationNumber":"960507878","name":"TestNavn Test Etternavn","email":"Test@nav.no","phoneNo":"90080900","RegionCode":"0200" }'
        );
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        KontaktSkjemaHandler.doPost();
        Test.stopTest();

        CustomOpportunities = [
            SELECT
                Id,
                InquiryCategory__c,
                RecordTypeId,
                INT_RegionNumber__c,
                INT_MunicipalityNumber__c,
                TAG_OrganizationNameFromForm__c,
                Contact__r.FirstName,
                Contact__r.LastName,
                Contact__r.Email,
                Contact__r.MobilePhone,
                Account__r.INT_OrganizationNumber__c
            FROM CustomOpportunity__c
        ];
        System.assertEquals(1, CustomOpportunities.size(), 'Size should be one after insert');

        System.assertEquals(
            'TestNavn Test',
            CustomOpportunities[0].Contact__r.FirstName,
            '"Contact__r.FirstName" should be "TestNavn"'
        );
        System.assertEquals(
            'Etternavn',
            CustomOpportunities[0].Contact__r.LastName,
            '"Contact__r.LastName" should be "Test Etternavn"'
        );
    }

    @isTest
    private static void doPost_upperCaseEmail() {
        insert new Account(name = 'test', INT_OrganizationNumber__c = '960507878');

        List<CustomOpportunity__c> CustomOpportunities = [SELECT Id FROM CustomOpportunity__c];
        System.assertEquals(0, CustomOpportunities.size(), 'Size should be zero before');

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/ContactForm';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(
            '{ "type":"FOREBYGGE_SYKEFRAVÆR","municipalityCode":"3033","organisationName":"Finstadtunet","organisationNumber":"960507878","firstName":"TestNavn","lastName":"TestEtternavn","email":"Test@nav.no","phoneNo":"90080900","RegionCode":"0200" }'
        );
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        KontaktSkjemaHandler.doPost();
        Test.stopTest();

        CustomOpportunities = [
            SELECT
                Id,
                InquiryCategory__c,
                RecordTypeId,
                INT_RegionNumber__c,
                INT_MunicipalityNumber__c,
                TAG_OrganizationNameFromForm__c,
                Contact__r.FirstName,
                Contact__r.LastName,
                Contact__r.Email,
                Contact__r.MobilePhone,
                Account__r.INT_OrganizationNumber__c
            FROM CustomOpportunity__c
        ];
        System.assertEquals(1, CustomOpportunities.size(), 'Size should be one after insert');

        System.assertEquals(
            'TestNavn',
            CustomOpportunities[0].Contact__r.FirstName,
            '"Contact__r.FirstName" should be "TestNavn"'
        );
        System.assertEquals(
            'TestEtternavn',
            CustomOpportunities[0].Contact__r.LastName,
            '"Contact__r.LastName" should be "TestEtternavn"'
        );
        System.assertEquals(
            'test@nav.no',
            CustomOpportunities[0].Contact__r.Email,
            '"Contact__r.Email" should be "test@nav.no"'
        );
    }

    @isTest
    private static void doPost_forebyggeSykefravaer_invalidEmail() {
        insert new Account(name = 'test', INT_OrganizationNumber__c = '960507878');

        List<CustomOpportunity__c> CustomOpportunities = [SELECT Id FROM CustomOpportunity__c];
        System.assertEquals(0, CustomOpportunities.size(), 'Size should be zero before');

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/ContactForm';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(
            '{ "type":"FOREBYGGE_SYKEFRAVÆR","municipalityCode":"3033","organisationName":"Finstadtunet","organisationNumber":"960507878","firstName":"TestNavn","lastName":"TestEtternavn","email":"test@@nav.no","phoneNo":"90080900","RegionCode":"0200" }'
        );
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        KontaktSkjemaHandler.doPost();
        Test.stopTest();

        CustomOpportunities = [
            SELECT
                Id,
                InquiryCategory__c,
                RecordTypeId,
                INT_RegionNumber__c,
                INT_MunicipalityNumber__c,
                TAG_OrganizationNameFromForm__c,
                Contact__r.FirstName,
                Contact__r.LastName,
                Contact__r.Email,
                Contact__r.InvalidEmail__c,
                Contact__r.MobilePhone,
                Account__r.INT_OrganizationNumber__c
            FROM CustomOpportunity__c
        ];
        System.assertEquals(1, CustomOpportunities.size(), 'Size should be one after insert');

        System.assertEquals(
            null,
            CustomOpportunities[0].Contact__r.Email,
            '"Contact__r.Email" should be "test@nav.no"'
        );
        System.assertEquals(
            'test@@nav.no',
            CustomOpportunities[0].Contact__r.InvalidEmail__c,
            '"Contact__r.Email" should be "test@nav.no"'
        );
    }

    @isTest
    private static void doPost_rekruttering() {
        insert new Account(name = 'test', INT_OrganizationNumber__c = '960507878');

        List<CustomOpportunity__c> CustomOpportunities = [SELECT Id FROM CustomOpportunity__c];
        System.assertEquals(0, CustomOpportunities.size(), 'Size should be zero before');

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/ContactForm';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(
            '{ "type":"REKRUTTERING","municipalityCode":"3033","organisationName":"Finstadtunet","organisationNumber":"960507878","firstName":"TestNavn","lastName":"TestEtternavn","email":"test@nav.no","phoneNo":"90080900","RegionCode":"0200" }'
        );
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        KontaktSkjemaHandler.doPost();
        Test.stopTest();

        CustomOpportunities = [
            SELECT
                Id,
                InquiryCategory__c,
                RecordTypeId,
                INT_RegionNumber__c,
                INT_MunicipalityNumber__c,
                TAG_OrganizationNameFromForm__c,
                Contact__r.FirstName,
                Contact__r.LastName,
                Contact__r.Email,
                Contact__r.MobilePhone,
                Account__r.INT_OrganizationNumber__c
            FROM CustomOpportunity__c
        ];
        System.assertEquals(1, CustomOpportunities.size(), 'Size should be one after insert');

        System.assertEquals(
            'Rekruttering',
            CustomOpportunities[0].InquiryCategory__c,
            '"Type" should be "Rekruttering"'
        );
        System.assertEquals(
            'TestNavn',
            CustomOpportunities[0].Contact__r.FirstName,
            '"Contact__r.FirstName" should be "TestNavn"'
        );
        System.assertEquals(
            'TestEtternavn',
            CustomOpportunities[0].Contact__r.LastName,
            '"Contact__r.LastName" should be "TestEtternavn"'
        );
        System.assertEquals(
            null,
            CustomOpportunities[0].INT_RegionNumber__c,
            'Region code should be null on non-IA optys'
        );
        System.assertEquals(
            '3033',
            CustomOpportunities[0].INT_MunicipalityNumber__c,
            'Region code should be null on non-IA optys'
        );
        System.assertEquals(
            'Finstadtunet',
            CustomOpportunities[0].TAG_OrganizationNameFromForm__c,
            'Name of company should be set as Finstadtunet'
        );
        System.assertEquals(
            'test@nav.no',
            CustomOpportunities[0].Contact__r.Email,
            '"Contact__r.Email" should be "test@nav.no"'
        );
        System.assertEquals(
            '90080900',
            CustomOpportunities[0].Contact__r.MobilePhone,
            '"Contact__r.MobilePhone" should be "90080900"'
        );
        System.assertEquals(
            '960507878',
            CustomOpportunities[0].Account__r.INT_OrganizationNumber__c,
            '"Account__r.INT_OrganizationNumber__c" should be "960507878"'
        );
    }

    @isTest
    private static void doPost_rekrutteringMedTilrettelegging() {
        insert new Account(name = 'test', INT_OrganizationNumber__c = '960507878');

        List<CustomOpportunity__c> CustomOpportunities = [SELECT Id FROM CustomOpportunity__c];
        System.assertEquals(0, CustomOpportunities.size(), 'Size should be zero before');

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/ContactForm';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(
            '{ "type":"REKRUTTERING_MED_TILRETTELEGGING","municipalityCode":"3033","organisationName":"Finstadtunet","organisationNumber":"960507878","firstName":"TestNavn","lastName":"TestEtternavn","email":"test@nav.no","phoneNo":"90080900","RegionCode":"0200" }'
        );
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        KontaktSkjemaHandler.doPost();
        Test.stopTest();

        CustomOpportunities = [
            SELECT
                Id,
                InquiryCategory__c,
                RecordTypeId,
                INT_RegionNumber__c,
                INT_MunicipalityNumber__c,
                TAG_OrganizationNameFromForm__c,
                Contact__r.FirstName,
                Contact__r.LastName,
                Contact__r.Email,
                Contact__r.MobilePhone,
                Account__r.INT_OrganizationNumber__c
            FROM CustomOpportunity__c
        ];
        System.assertEquals(1, CustomOpportunities.size(), 'Size should be one after insert');

        System.assertEquals(
            'Rekruttering med tilrettelegging',
            CustomOpportunities[0].InquiryCategory__c,
            '"Type" should be "Rekruttering med tilrettelegging"'
        );
        System.assertEquals(
            'TestNavn',
            CustomOpportunities[0].Contact__r.FirstName,
            '"Contact__r.FirstName" should be "TestNavn"'
        );
        System.assertEquals(
            'TestEtternavn',
            CustomOpportunities[0].Contact__r.LastName,
            '"Contact__r.LastName" should be "TestEtternavn"'
        );
        System.assertEquals(
            null,
            CustomOpportunities[0].INT_RegionNumber__c,
            'Region code should be null on non-IA optys'
        );
        System.assertEquals(
            '3033',
            CustomOpportunities[0].INT_MunicipalityNumber__c,
            'Region code should be null on non-IA optys'
        );
        System.assertEquals(
            'Finstadtunet',
            CustomOpportunities[0].TAG_OrganizationNameFromForm__c,
            'Name of company should be set as Finstadtunet'
        );
        System.assertEquals(
            'test@nav.no',
            CustomOpportunities[0].Contact__r.Email,
            '"Contact__r.Email" should be "test@nav.no"'
        );
        System.assertEquals(
            '90080900',
            CustomOpportunities[0].Contact__r.MobilePhone,
            '"Contact__r.MobilePhone" should be "90080900"'
        );
        System.assertEquals(
            '960507878',
            CustomOpportunities[0].Account__r.INT_OrganizationNumber__c,
            '"Account__r.INT_OrganizationNumber__c" should be "960507878"'
        );
    }

    @isTest
    private static void other_contactAlreadyExists() {
        insert new Account(name = 'test', INT_OrganizationNumber__c = '960507878');
        Contact con = new Contact(TAG_Informed__c = true, lastName = 'TestEtternavn', Email = 'test@nav.no');
        insert con;

        List<CustomOpportunity__c> CustomOpportunities = [SELECT Id FROM CustomOpportunity__c];
        System.assertEquals(0, CustomOpportunities.size(), 'Size should be zero before');

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/ContactForm';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(
            '{ "type":"ARBEIDSTRENING","municipalityCode":"3033","organisationName":"Finstadtunet","organisationNumber":"960507878","firstName":"TestNavn","lastName":"TestEtternavn","email":"test@nav.no","phoneNo":"90080900","RegionCode":"0200" }'
        );
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        KontaktSkjemaHandler.doPost();
        Test.stopTest();

        CustomOpportunities = [
            SELECT
                Id,
                InquiryCategory__c,
                RecordTypeId,
                Contact__r.FirstName,
                Contact__r.LastName,
                Contact__r.Email,
                Contact__r.MobilePhone,
                Account__r.INT_OrganizationNumber__c
            FROM CustomOpportunity__c
        ];
        System.assertEquals(1, CustomOpportunities.size(), 'Size should be one after insert');

        System.assertEquals(con.Id, CustomOpportunities[0].Contact__c, 'Should find the existing contact');
    }

    @isTest // ! tests the Opportunity process to make sure contacts receive an account after adding an account manually to the opty (happens if a user does not input org number in the web form)
    private static void other_addingAccountAfterReuqestReceived() {
        Account acc = new Account(name = 'test', INT_OrganizationNumber__c = '960507878');
        insert acc;

        List<CustomOpportunity__c> customOpportunities = [SELECT Id FROM CustomOpportunity__c];
        System.assertEquals(0, customOpportunities.size(), 'Size should be zero before');

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/ContactForm';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(
            '{ "type":"FOREBYGGE_SYKEFRAVÆR","municipalityCode":"3033","organisationName":"Finstadtunet","firstName":"TestNavn","lastName":"TestEtternavn","email":"test@nav.no","phoneNo":"90080900","RegionCode":"0200" }'
        );
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        KontaktSkjemaHandler.doPost();
        Test.stopTest();

        customOpportunities = [
            SELECT
                Id,
                InquiryCategory__c,
                RecordTypeId,
                INT_RegionNumber__c,
                INT_MunicipalityNumber__c,
                TAG_OrganizationNameFromForm__c,
                Contact__r.FirstName,
                Contact__r.LastName,
                Contact__r.Email,
                Contact__r.AccountId,
                Contact__r.MobilePhone,
                Account__r.INT_OrganizationNumber__c
            FROM CustomOpportunity__c
            LIMIT 1
        ];
        customOpportunities[0].Account__c = acc.Id;

        System.assertEquals(
            null,
            customOpportunities[0].Contact__r.AccountId,
            'No account on contact as no account on opty'
        );

        update customOpportunities;

        customOpportunities = [
            SELECT
                Id,
                InquiryCategory__c,
                RecordTypeId,
                INT_RegionNumber__c,
                INT_MunicipalityNumber__c,
                TAG_OrganizationNameFromForm__c,
                Contact__r.FirstName,
                Contact__r.LastName,
                Contact__r.Email,
                Contact__r.AccountId,
                Contact__r.MobilePhone,
                Account__r.INT_OrganizationNumber__c
            FROM CustomOpportunity__c
            LIMIT 1
        ];
        System.assertEquals(
            acc.Id,
            customOpportunities[0].Contact__r.AccountId,
            'Original account should be on contact as account added on opty'
        );
    }

    @isTest
    private static void other_noAccount() {
        List<CustomOpportunity__c> CustomOpportunities = [SELECT Id FROM CustomOpportunity__c];
        System.assertEquals(0, CustomOpportunities.size(), 'Size should be zero before');

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/ContactForm';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(
            '{ "type":"ARBEIDSTRENING","municipalityCode":"3033","organisationName":"Finstadtunet","organisationNumber":"960507878","firstName":"TestNavn","lastName":"TestEtternavn","email":"test@nav.no","phoneNo":"90080900","RegionCode":"0200" }'
        );
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        KontaktSkjemaHandler.doPost();
        Test.stopTest();

        CustomOpportunities = [
            SELECT
                Id,
                InquiryCategory__c,
                RecordTypeId,
                Contact__r.FirstName,
                Contact__r.LastName,
                Contact__r.Email,
                Contact__r.MobilePhone,
                Account__r.INT_OrganizationNumber__c
            FROM CustomOpportunity__c
        ];
        System.assertEquals(1, CustomOpportunities.size(), 'Size should be one after insert');

        System.assertEquals(
            null,
            CustomOpportunities[0].Account__c,
            'Should have null, as the account doesn\'t exist from before'
        );
    }

    @isTest
    private static void other_noOrgNumber() {
        insert new Account(name = 'test', INT_OrganizationNumber__c = '960507878');

        List<CustomOpportunity__c> CustomOpportunities = [SELECT Id FROM CustomOpportunity__c];
        System.assertEquals(0, CustomOpportunities.size(), 'Size should be zero before');

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/ContactForm';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(
            '{ "type":"FOREBYGGE_SYKEFRAVÆR","municipalityCode":"3033","organisationName":"Finstadtunet","firstName":"TestNavn","lastName":"TestEtternavn","email":"test@nav.no","phoneNo":"90080900","RegionCode":"0200" }'
        );
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        KontaktSkjemaHandler.doPost();
        Test.stopTest();

        CustomOpportunities = [
            SELECT
                Id,
                InquiryCategory__c,
                RecordTypeId,
                INT_RegionNumber__c,
                INT_MunicipalityNumber__c,
                TAG_OrganizationNameFromForm__c,
                Contact__r.FirstName,
                Contact__r.LastName,
                Contact__r.AccountId,
                Contact__r.Email,
                Contact__r.MobilePhone,
                Account__r.INT_OrganizationNumber__c
            FROM CustomOpportunity__c
        ];
        System.assertEquals(1, CustomOpportunities.size(), 'Size should be one after insert');

        System.assertEquals(
            'Forebygge sykefravær',
            CustomOpportunities[0].InquiryCategory__c,
            '"Type" should be "Forebygge sykefravær"'
        );
        System.assertEquals(
            'TestNavn',
            CustomOpportunities[0].Contact__r.FirstName,
            '"Contact__r.FirstName" should be "TestNavn"'
        );
        System.assertEquals(
            'TestEtternavn',
            CustomOpportunities[0].Contact__r.LastName,
            '"Contact__r.LastName" should be "TestEtternavn"'
        );
        System.assertEquals(
            '0200',
            CustomOpportunities[0].INT_RegionNumber__c,
            'Region code should be null on non-IA optys'
        );
        System.assertEquals(
            '3033',
            CustomOpportunities[0].INT_MunicipalityNumber__c,
            'Region code should be null on non-IA optys'
        );
        System.assertEquals(
            'Finstadtunet',
            CustomOpportunities[0].TAG_OrganizationNameFromForm__c,
            'Name of company should be set as Finstadtunet'
        );
        System.assertEquals(
            'test@nav.no',
            CustomOpportunities[0].Contact__r.Email,
            '"Contact__r.Email" should be "test@nav.no"'
        );
        System.assertEquals(
            '90080900',
            CustomOpportunities[0].Contact__r.MobilePhone,
            '"Contact__r.MobilePhone" should be "90080900"'
        );
        System.assertEquals(
            null,
            CustomOpportunities[0].Account__c,
            'Account is null as no org number was added to the request'
        );
        System.assertEquals(
            null,
            CustomOpportunities[0].Contact__r.AccountId,
            'Account is null as no org number was added to the request'
        );
    }

    @isTest
    private static void other_nullType() {
        List<CustomOpportunity__c> CustomOpportunities = [SELECT Id FROM CustomOpportunity__c];
        System.assertEquals(0, CustomOpportunities.size(), 'Size should be zero before');

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/ContactForm';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(
            '{ "type":"SOMETHING_WRONG","municipalityCode":"3033","organisationName":"Finstadtunet","organisationNumber":"960507878","firstName":"TestNavn","lastName":"TestEtternavn","email":"test@nav.no","phoneNo":"90080900","RegionCode":"0200" }'
        );
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        KontaktSkjemaHandler.doPost();
        Test.stopTest();

        CustomOpportunities = [
            SELECT
                Id,
                InquiryCategory__c,
                RecordTypeId,
                Contact__r.FirstName,
                Contact__r.LastName,
                Contact__r.Email,
                Contact__r.MobilePhone,
                Account__r.INT_OrganizationNumber__c
            FROM CustomOpportunity__c
        ];
        System.assertEquals(1, CustomOpportunities.size(), 'Size should be one after insert');

        System.assertEquals(null, CustomOpportunities[0].InquiryCategory__c, 'Should find the existing contact');
    }

    @testSetup
    private static void setup() {

        TAG_TestDataFactory.assignPermissionSet('test@nav.apextest', 'KontaktskjemaIntBruker');
    }
    
    @isTest
    private static void emailSend() {
        System.runAs(getTestUser()) {

            insert new Account(name = 'test', INT_OrganizationNumber__c = '960507878');

            List<CustomOpportunity__c> CustomOpportunities = [SELECT Id FROM CustomOpportunity__c];
            System.assertEquals(0, CustomOpportunities.size(), 'Size should be zero before');

            List<EmailMessage> emailsBefore = [SELECT Id FROM EmailMessage];
            System.assertEquals(0, emailsBefore.size(), 'Should be no Emails before insert');

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();

            req.requestURI = '/services/apexrest/ContactForm';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(
                '{ "type":"ARBEIDSTRENING","municipalityCode":"3033","organisationName":"Finstadtunet","organisationNumber":"960507878","firstName":"TestNavn","lastName":"TestEtternavn","email":"test@nav.no","phoneNo":"90080900","RegionCode":"0200" }'
            );
            RestContext.request = req;
            RestContext.response = res;

            Test.startTest();
            KontaktSkjemaHandler.doPost();
            Test.stopTest();

            CustomOpportunities = [
                SELECT Id FROM CustomOpportunity__c
            ];
            System.assertEquals(1, CustomOpportunities.size(), 'Size should be one after insert');

            List<EmailMessage> emailsAfter = [SELECT Id FROM EmailMessage];
            System.assertEquals(1, emailsAfter.size(), 'Should be one Email sent');

            EmailMessage em = [SELECT Id, ToAddress FROM EmailMessage];
            System.assertEquals('test@nav.no', em.ToAddress, 'ToAddress should be test@nav.no');
            
        }
    }

    @isTest
    private static void emailNotSendNoEmail() {
        System.runAs(getTestUser()) {

            insert new Account(name = 'test', INT_OrganizationNumber__c = '960507878');

            List<CustomOpportunity__c> CustomOpportunities = [SELECT Id FROM CustomOpportunity__c];
            System.assertEquals(0, CustomOpportunities.size(), 'Size should be zero before');

            List<EmailMessage> emailsBefore = [SELECT Id FROM EmailMessage];
            System.assertEquals(0, emailsBefore.size(), 'Should be no Emails before insert');

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();

            req.requestURI = '/services/apexrest/ContactForm';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(
                '{ "type":"ARBEIDSTRENING","municipalityCode":"3033","organisationName":"Finstadtunet","organisationNumber":"960507878","firstName":"TestNavn","lastName":"TestEtternavn","email":"","phoneNo":"90080900","RegionCode":"0200" }'
            );
            RestContext.request = req;
            RestContext.response = res;

            Test.startTest();
            KontaktSkjemaHandler.doPost();
            Test.stopTest();

            CustomOpportunities = [
                SELECT Id FROM CustomOpportunity__c
            ];
            System.assertEquals(1, CustomOpportunities.size(), 'Size should be one after insert');

            List<EmailQueue__c> emailsQueue = [SELECT Id FROM EmailQueue__c];
            System.assertEquals(0, emailsQueue.size(), 'Should be no queue because missing Email Address');
            
            List<EmailMessage> emailsAfter = [SELECT Id FROM EmailMessage];
            System.assertEquals(0, emailsAfter.size(), 'Should be no email sent because missing Email Address');
            
        }
    }

    private static User getTestUser() {
        return [SELECT Id FROM User WHERE UserName = 'test@nav.apextest'];
    }
}
