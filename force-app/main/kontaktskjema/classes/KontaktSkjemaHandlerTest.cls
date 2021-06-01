@isTest
private without sharing class KontaktSkjemaHandlerTest {
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- //
    // ----------------------------------------------------------------------------------------------------------- MAKE DATA ---------------------------------------------------------------------------------------------------------------------- //
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- //

    @TestSetup
    static void makeData() {
        TAG_TestDataFactory.assignPermissionSet('test@nav.apextest', 'KontaktskjemaIntBruker');

        EmailTemplate et1 = new EmailTemplate(
            DeveloperName = 'kontaktskjemaSykefravaerReceipt',
            Name = 'kontaktskjemaSykefravaerReceipt',
            IsActive = true,
            FolderId = UserInfo.getOrganizationId(),
            UiType = 'sfx',
            TemplateType = 'custom',
            Subject = 'Temp Test',
            HtmlValue = '<html><head></head><body><p>Hei {{{Recipient.Name}}}! NAV har mottatt meldingen din om:{{{CustomOpportunity__c.InquiryCategory__c}}}.</p></body></html>'
        );

        EmailTemplate et2 = new EmailTemplate(
            DeveloperName = 'kontaktskjemaRekrutteringReceipt',
            Name = 'kontaktskjemaRekrutteringReceipt',
            IsActive = true,
            FolderId = UserInfo.getOrganizationId(),
            UiType = 'sfx',
            TemplateType = 'custom',
            Subject = 'Temp Test',
            HtmlValue = '<html><head></head><body><p>Hei {{{Recipient.Name}}}! NAV har mottatt meldingen din om:{{{CustomOpportunity__c.InquiryCategory__c}}}.</p></body></html>'
        );
    }

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- //
    // ------------------------------------------------------------------------------------------------------------- ACCOUNT ---------------------------------------------------------------------------------------------------------------------- //
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- //

    @isTest // ! tests the Opportunity process to make sure contacts receive an account after adding an account manually to the opty (happens if a user does not input org number in the web form)
    private static void account_addingAccountAfterReuqestReceived() {
        createTestAccounts();
        createPostRequest(
            '{ "type":"FOREBYGGE_SYKEFRAVÆR","municipalityCode":"3033","organisationName":"Finstadtunet","firstName":"TestNavn","lastName":"TestEtternavn","email":"test@nav.no","phoneNo":"90080900","RegionCode":"0200" }'
        );

        Test.startTest();
        KontaktSkjemaHandler.doPost();
        Test.stopTest();

        List<CustomOpportunity__c> CustomOpportunities = [
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

        Id accId = [SELECT Id FROM Account WHERE INT_OrganizationNumber__c = '960507878' LIMIT 1].Id;

        customOpportunities[0].Account__c = accId;

        System.assertEquals(
            accId,
            customOpportunities[0].Contact__r.AccountId,
            'Dummy account on contact as no account on opty'
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
            accId,
            customOpportunities[0].Contact__r.AccountId,
            'Original account should be on contact as account added on opty'
        );
    }

    @isTest
    private static void account_noAccount() {
        createTestAccounts();
        createPostRequest(
            '{ "type":"ARBEIDSTRENING","municipalityCode":"3033","organisationName":"Finstadtunet","organisationNumber":"960507871","firstName":"TestNavn","lastName":"TestEtternavn","email":"test@nav.no","phoneNo":"90080900","RegionCode":"0200" }'
        );

        Test.startTest();
        KontaktSkjemaHandler.doPost();
        Test.stopTest();

        List<CustomOpportunity__c> CustomOpportunities = [
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
    private static void account_noOrgNumber() {
        createTestAccounts();
        createPostRequest(
            '{ "type":"FOREBYGGE_SYKEFRAVÆR","municipalityCode":"3033","organisationName":"Finstadtunet","firstName":"TestNavn","lastName":"TestEtternavn","email":"test@nav.no","phoneNo":"90080900","RegionCode":"0200" }'
        );

        Test.startTest();
        KontaktSkjemaHandler.doPost();
        Test.stopTest();

        List<CustomOpportunity__c> CustomOpportunities = [
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

        Id dummyAccount = [SELECT Id FROM Account WHERE INT_OrganizationNumber__c = '960507872' LIMIT 1].Id;

        System.assertEquals(1, CustomOpportunities.size(), 'Size should be one after insert');
        System.assertEquals(
            null,
            CustomOpportunities[0].Account__c,
            'Account is null as no org number was added to the request'
        );
        System.assertEquals(
            dummyAccount,
            CustomOpportunities[0].Contact__r.AccountId,
            'Dummy account set on contact as no org number was added to the request'
        );
    }

    @isTest
    private static void account_IsEmptyWhenOrgNoMissing() {
        createTestAccounts();
        createPostRequest(
            '{ "type":"REKRUTTERING","municipalityCode":"3033","organisationName":"Finstadtunet","organisationNumber":"","firstName":"TestNavn","lastName":"TestEtternavn","email":"","phoneNo":"90080900","RegionCode":"0200" }'
        );

        Test.startTest();
        KontaktSkjemaHandler.doPost();
        Test.stopTest();

        List<CustomOpportunity__c> CustomOpportunities = [SELECT Id, Account__c FROM CustomOpportunity__c];
        System.assertEquals(1, CustomOpportunities.size(), 'Size should be one after insert');
        System.assertEquals(null, CustomOpportunities[0].Account__c, 'Account should be null');
    }

    @isTest
    private static void account_isAddedToOpty() {
        createTestAccounts();
        createPostRequest(
            '{ "type":"REKRUTTERING","municipalityCode":"3033","organisationName":"Finstadtunet","organisationNumber":"960507878","firstName":"TestNavn","lastName":"TestEtternavn","email":"","phoneNo":"90080900","RegionCode":"0200" }'
        );

        Test.startTest();
        KontaktSkjemaHandler.doPost();
        Test.stopTest();

        Id accId = [SELECT Id FROM Account WHERE INT_OrganizationNumber__c = '960507878' LIMIT 1].Id;

        List<CustomOpportunity__c> CustomOpportunities = [SELECT Id, Account__c FROM CustomOpportunity__c];
        System.assertEquals(1, CustomOpportunities.size(), 'Size should be one after insert');
        System.assertEquals(accId, CustomOpportunities[0].Account__c, 'Account should be set');
    }

    @isTest
    private static void account_setDummyAccountWhenOrgNoMissing() {
        createTestAccounts();
        createPostRequest(
            '{ "type":"REKRUTTERING","municipalityCode":"3033","organisationName":"Finstadtunet","organisationNumber":"","firstName":"TestNavn","lastName":"TestEtternavn","email":"","phoneNo":"90080900","RegionCode":"0200" }'
        );

        System.assertEquals(0, [SELECT Id FROM Contact].size(), 'zero contacts before');

        Test.startTest();
        KontaktSkjemaHandler.doPost();
        Test.stopTest();

        Id dummyAccount = [SELECT Id FROM Account WHERE INT_OrganizationNumber__c = '960507872' LIMIT 1].Id;

        List<Contact> contacts = [SELECT Id, AccountId FROM Contact];
        System.assertEquals(1, contacts.size(), 'one contact after');
        System.assertEquals(dummyAccount, contacts[0].AccountId, 'same contact');
    }

    @isTest
    private static void account_dontAddDummyAccountOnExistingContact() {
        createTestAccounts();
        Id accId = [SELECT Id FROM Account WHERE INT_OrganizationNumber__c = '960507878' LIMIT 1].Id;
        Contact con = new Contact(
            TAG_Informed__c = true,
            lastName = 'testerson',
            Email = 'test.testerson@nav.no',
            AccountId = accId
        );
        insert con;

        createPostRequest(
            '{ "type":"REKRUTTERING","municipalityCode":"3033","organisationName":"Finstadtunet","organisationNumber":"","firstName":"TestNavn","lastName":"TestEtternavn","email":"","phoneNo":"90080900","RegionCode":"0200" }'
        );

        System.assertEquals(0, [SELECT Id FROM Contact].size(), 'zero contacts before');

        Test.startTest();
        KontaktSkjemaHandler.doPost();
        Test.stopTest();

        List<Contact> contacts = [SELECT Id, AccountId FROM Contact];
        System.assertEquals(1, contacts.size(), 'one contact after');
        System.assertEquals(
            accId,
            contacts[0].AccountId,
            'samme account from before, hasnt changed because contact sent in opty without org no'
        );
    }

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- //
    // ------------------------------------------------------------------------------------------------------------- CONTACT ---------------------------------------------------------------------------------------------------------------------- //
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- //

    @isTest
    private static void contact_contactAlreadyExists() {
        Contact con = new Contact(TAG_Informed__c = true, lastName = 'TestEtternavn', Email = 'test@nav.no');
        insert con;
        createTestAccounts();
        createPostRequest(
            '{ "type":"ARBEIDSTRENING","municipalityCode":"3033","organisationName":"Finstadtunet","organisationNumber":"960507878","firstName":"TestNavn","lastName":"TestEtternavn","email":"test@nav.no","phoneNo":"90080900","RegionCode":"0200" }'
        );

        Test.startTest();
        KontaktSkjemaHandler.doPost();
        Test.stopTest();

        List<CustomOpportunity__c> CustomOpportunities = [
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

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- //
    // ------------------------------------------------------------------------------------------------------------- DOPOST ----------------------------------------------------------------------------------------------------------------------- //
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- //

    @isTest
    private static void doPost_municipalityAgder() {
        createTestAccounts();
        createPostRequest(
            '{ "type":"ARBEIDSTRENING","municipalityCode":"4202","organisationName":"Finstadtunet","organisationNumber":"960507878","firstName":"TestNavn","lastName":"TestEtternavn","email":"test@nav.no","phoneNo":"90080900","RegionCode":"1000" }'
        );

        Test.startTest();
        String result = KontaktSkjemaHandler.doPost();
        Test.stopTest();

        List<CustomOpportunity__c> CustomOpportunities = [
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
        createTestAccounts();
        createPostRequest(
            '{ "type":"ARBEIDSTRENING","municipalityCode":"3032","organisationName":"Finstadtunet","organisationNumber":"960507878","firstName":"TestNavn","lastName":"TestEtternavn","email":"test@nav.no","phoneNo":"90080900","RegionCode":"1000" }'
        );

        Test.startTest();
        String result = KontaktSkjemaHandler.doPost();
        Test.stopTest();

        List<CustomOpportunity__c> CustomOpportunities = [
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
        createTestAccounts();
        createPostRequest(
            '{ "type":"ARBEIDSTRENING","municipalityCode":"3428","organisationName":"Finstadtunet","organisationNumber":"960507878","firstName":"TestNavn","lastName":"TestEtternavn","email":"test@nav.no","phoneNo":"90080900","RegionCode":"0400" }'
        );

        Test.startTest();
        String result = KontaktSkjemaHandler.doPost();
        Test.stopTest();

        List<CustomOpportunity__c> CustomOpportunities = [
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
        createTestAccounts();
        createPostRequest(
            '{ "type":"ARBEIDSTRENING","municipalityCode":"1820","organisationName":"Finstadtunet","organisationNumber":"960507878","firstName":"TestNavn","lastName":"TestEtternavn","email":"test@nav.no","phoneNo":"90080900","RegionCode":"1800" }'
        );

        Test.startTest();
        String result = KontaktSkjemaHandler.doPost();
        Test.stopTest();

        List<CustomOpportunity__c> CustomOpportunities = [
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
        createTestAccounts();
        createPostRequest(
            '{ "type":"ARBEIDSTRENING","municipalityCode":"1525","organisationName":"Finstadtunet","organisationNumber":"960507878","firstName":"TestNavn","lastName":"TestEtternavn","email":"test@nav.no","phoneNo":"90080900","RegionCode":"1500" }'
        );

        Test.startTest();
        String result = KontaktSkjemaHandler.doPost();
        Test.stopTest();

        List<CustomOpportunity__c> CustomOpportunities = [
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
        createTestAccounts();
        createPostRequest(
            '{ "type":"ARBEIDSTRENING","municipalityCode":"3033","organisationName":"Finstadtunet","organisationNumber":"960507878","firstName":"TestNavn","lastName":"TestEtternavn","email":"test@nav.no","phoneNo":"90080900","RegionCode":"0200" }'
        );

        Test.startTest();
        KontaktSkjemaHandler.doPost();
        Test.stopTest();

        List<CustomOpportunity__c> CustomOpportunities = [
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
        createTestAccounts();
        createPostRequest(
            '{ "type":"FOREBYGGE_SYKEFRAVÆR","municipalityCode":"3033","organisationName":"Finstadtunet","organisationNumber":"960507878","firstName":"TestNavn","lastName":"TestEtternavn","email":"test@nav.no","phoneNo":"90080900","RegionCode":"0200" }'
        );

        Test.startTest();
        KontaktSkjemaHandler.doPost();
        Test.stopTest();

        List<CustomOpportunity__c> CustomOpportunities = [
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
        createTestAccounts();
        createPostRequest(
            '{ "type":"FOREBYGGE_SYKEFRAVÆR","municipalityCode":"3033","organisationName":"Finstadtunet","organisationNumber":"960507878","name":"TestNavn Test Etternavn","email":"Test@nav.no","phoneNo":"90080900","RegionCode":"0200" }'
        );

        Test.startTest();
        KontaktSkjemaHandler.doPost();
        Test.stopTest();

        List<CustomOpportunity__c> CustomOpportunities = [
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
        createTestAccounts();
        createPostRequest(
            '{ "type":"FOREBYGGE_SYKEFRAVÆR","municipalityCode":"3033","organisationName":"Finstadtunet","organisationNumber":"960507878","firstName":"TestNavn","lastName":"TestEtternavn","email":"Test@nav.no","phoneNo":"90080900","RegionCode":"0200" }'
        );

        Test.startTest();
        KontaktSkjemaHandler.doPost();
        Test.stopTest();

        List<CustomOpportunity__c> CustomOpportunities = [
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
        createTestAccounts();
        createPostRequest(
            '{ "type":"FOREBYGGE_SYKEFRAVÆR","municipalityCode":"3033","organisationName":"Finstadtunet","organisationNumber":"960507878","firstName":"TestNavn","lastName":"TestEtternavn","email":"test@@nav.no","phoneNo":"90080900","RegionCode":"0200" }'
        );

        Test.startTest();
        KontaktSkjemaHandler.doPost();
        Test.stopTest();

        List<CustomOpportunity__c> CustomOpportunities = [
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
        createTestAccounts();
        createPostRequest(
            '{ "type":"REKRUTTERING","municipalityCode":"3033","organisationName":"Finstadtunet","organisationNumber":"960507878","firstName":"TestNavn","lastName":"TestEtternavn","email":"test@nav.no","phoneNo":"90080900","RegionCode":"0200" }'
        );

        Test.startTest();
        KontaktSkjemaHandler.doPost();
        Test.stopTest();

        List<CustomOpportunity__c> CustomOpportunities = [
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
        createTestAccounts();
        createPostRequest(
            '{ "type":"REKRUTTERING_MED_TILRETTELEGGING","municipalityCode":"3033","organisationName":"Finstadtunet","organisationNumber":"960507878","firstName":"TestNavn","lastName":"TestEtternavn","email":"test@nav.no","phoneNo":"90080900","RegionCode":"0200" }'
        );

        Test.startTest();
        KontaktSkjemaHandler.doPost();
        Test.stopTest();

        List<CustomOpportunity__c> CustomOpportunities = [
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

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- //
    // ------------------------------------------------------------------------------------------------------------- EMAIL ------------------------------------------------------------------------------------------------------------------------ //
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- //

    @isTest
    private static void email_sendSykefravaer() {
        createTestAccounts();
        System.runAs(getTestUser()) {
            List<CustomOpportunity__c> CustomOpportunities = [SELECT Id FROM CustomOpportunity__c];
            System.assertEquals(0, CustomOpportunities.size(), 'Size should be zero before');

            List<EmailQueue__c> emailsQueueBefore = [SELECT Id FROM EmailQueue__c];
            System.assertEquals(0, emailsQueueBefore.size(), 'Should be no queue before sendEmail');

            createPostRequest(
                '{ "type":"FOREBYGGE_SYKEFRAVÆR","municipalityCode":"3033","organisationName":"Finstadtunet","organisationNumber":"960507878","firstName":"TestNavn","lastName":"TestEtternavn","email":"test@nav.no","phoneNo":"90080900","RegionCode":"0200" }'
            );

            Test.startTest();
            KontaktSkjemaHandler.doPost();
            Test.stopTest();

            CustomOpportunities = [SELECT Id FROM CustomOpportunity__c];
            System.assertEquals(1, CustomOpportunities.size(), 'Size should be one after insert');

            List<EmailQueue__c> emailsQueueAfter = [SELECT Id FROM EmailQueue__c];
            System.assertEquals(1, emailsQueueAfter.size(), 'Should be one queue after insert');

            EmailQueue__c eq = [SELECT Id, TemplateId__c, TemplateName__c FROM EmailQueue__c LIMIT 1];
            System.assertEquals(
                'kontaktskjemaSykefravaerReceipt',
                eq.TemplateName__c,
                'It should be sykafravær template for Forebygge Sykefravær type'
            );
        }
    }

    @isTest
    private static void email_sendRekruttering() {
        createTestAccounts();
        System.runAs(getTestUser()) {
            List<CustomOpportunity__c> CustomOpportunities = [SELECT Id FROM CustomOpportunity__c];
            System.assertEquals(0, CustomOpportunities.size(), 'Size should be zero before');

            List<EmailQueue__c> emailsQueueBefore = [SELECT Id FROM EmailQueue__c];
            System.assertEquals(0, emailsQueueBefore.size(), 'Should be no queue before sendEmail');

            createPostRequest(
                '{ "type":"REKRUTTERING","municipalityCode":"3033","organisationName":"Finstadtunet","organisationNumber":"960507878","firstName":"TestNavn","lastName":"TestEtternavn","email":"test@nav.no","phoneNo":"90080900","RegionCode":"0200" }'
            );

            Test.startTest();
            KontaktSkjemaHandler.doPost();
            Test.stopTest();

            CustomOpportunities = [SELECT Id FROM CustomOpportunity__c];
            System.assertEquals(1, CustomOpportunities.size(), 'Size should be one after insert');

            List<EmailQueue__c> emailsQueueAfter = [SELECT Id FROM EmailQueue__c];
            System.assertEquals(1, emailsQueueAfter.size(), 'Should be one queue after insert');

            EmailQueue__c eq = [SELECT Id, TemplateId__c, TemplateName__c FROM EmailQueue__c LIMIT 1];
            System.assertEquals(
                'kontaktskjemaRekrutteringReceipt',
                eq.TemplateName__c,
                'It should be rekruttering template for Rekruttering type'
            );
        }
    }

    @isTest
    private static void email_notSendNoEmail() {
        createTestAccounts();
        System.runAs(getTestUser()) {
            List<CustomOpportunity__c> CustomOpportunities = [SELECT Id FROM CustomOpportunity__c];
            System.assertEquals(0, CustomOpportunities.size(), 'Size should be zero before');

            List<EmailMessage> emailsBefore = [SELECT Id FROM EmailMessage];
            System.assertEquals(0, emailsBefore.size(), 'Should be no Emails before insert');

            createPostRequest(
                '{ "type":"REKRUTTERING","municipalityCode":"3033","organisationName":"Finstadtunet","organisationNumber":"960507878","firstName":"TestNavn","lastName":"TestEtternavn","email":"","phoneNo":"90080900","RegionCode":"0200" }'
            );

            Test.startTest();
            KontaktSkjemaHandler.doPost();
            Test.stopTest();

            CustomOpportunities = [SELECT Id FROM CustomOpportunity__c];
            System.assertEquals(1, CustomOpportunities.size(), 'Size should be one after insert');

            List<EmailQueue__c> emailsQueue = [SELECT Id FROM EmailQueue__c];
            System.assertEquals(0, emailsQueue.size(), 'Should be no queue because missing Email Address');
        }
    }

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- //
    // ------------------------------------------------------------------------------------------------------------- OTHER ------------------------------------------------------------------------------------------------------------------------ //
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- //

    @isTest
    private static void other_nullType() {
        createTestAccounts();
        createPostRequest(
            '{ "type":"SOMETHING_WRONG","municipalityCode":"3033","organisationName":"Finstadtunet","organisationNumber":"960507878","firstName":"TestNavn","lastName":"TestEtternavn","email":"test@nav.no","phoneNo":"90080900","RegionCode":"0200" }'
        );

        Test.startTest();
        KontaktSkjemaHandler.doPost();
        Test.stopTest();

        List<CustomOpportunity__c> CustomOpportunities = [SELECT Id, InquiryCategory__c FROM CustomOpportunity__c];
        System.assertEquals(1, CustomOpportunities.size(), 'Size should be one after insert');
        System.assertEquals(null, CustomOpportunities[0].InquiryCategory__c, 'should have empty category');
    }

    // -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- //
    // -------------------------------------------------------------------------------------------------------- HELPER FUNCTIONS ------------------------------------------------------------------------------------------------------------------ //
    // -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- //

    public static void createPostRequest(String body) {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/ContactForm';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(body);
        RestContext.request = req;
        RestContext.response = res;
    }

    private static User getTestUser() {
        return [SELECT Id FROM User WHERE UserName = 'test@nav.apextest'];
    }

    public static void createTestAccounts() {
        insert new Account(name = 'test', INT_OrganizationNumber__c = '960507878');
        insert new Account(name = 'Kontakter uten konto', INT_OrganizationNumber__c = '960507872');
    }
}
