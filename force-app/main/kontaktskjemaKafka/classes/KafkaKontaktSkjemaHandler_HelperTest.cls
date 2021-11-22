@isTest
private without sharing class KafkaKontaktSkjemaHandler_HelperTest {
    @TestSetup
    static void makeData() {
        insert new Account(name = 'test', INT_OrganizationNumber__c = '960507878');
    }

    @isTest
    private static void testFetchOrCreateContact() {
        KafkaKontaktSkjemaHandler_Model submission = KafkaKontaktSkjemaHandler_Model.parse(
            '{ \"type\":\"REKRUTTERING\",\"municipalityCode\":\"3033\",\"organisationName\":\"Finstadtunet\",\"organisationNumber\":\"960507878\",\"firstName\":\"TestNavn\",\"lastName\":\"TestEtternavn\",\"email\":\"test@test.no\",\"phoneNo\":\"90080900\",\"RegionCode\":\"0200\" }'
        );

        Test.StartTest();
        Map<String, Contact> contactId = KafkaKontaktSkjemaHandler_Helper.getContactMap(
            new List<KafkaKontaktSkjemaHandler_Model>{ submission }
        );
        Test.StopTest();

        Id accId = [SELECT Id FROM Account WHERE INT_OrganizationNumber__c = '960507878' LIMIT 1].Id;
        List<Contact> con = [SELECT Id, FirstName, LastName, AccountId FROM Contact];
        System.assertEquals(1, con.size(), 'one contact inserted');
        System.assertEquals('TestNavn', con[0].FirstName, 'correctly set first name');
        System.assertEquals('TestEtternavn', con[0].LastName, 'correctly set last name');
        System.assertEquals(accId, con[0].AccountId, 'correctly set account');
    }

    @isTest
    private static void testFetchOrCreateContact_emptyOrgNo() {
        KafkaKontaktSkjemaHandler_Model submission = KafkaKontaktSkjemaHandler_Model.parse(
            '{ \"type\":\"REKRUTTERING\",\"municipalityCode\":\"3033\",\"organisationName\":\"Finstadtunet\",\"organisationNumber\":\"\",\"firstName\":\"TestNavn\",\"lastName\":\"TestEtternavn\",\"email\":\"test@test.no\",\"phoneNo\":\"90080900\",\"RegionCode\":\"0200\" }'
        );

        System.assertEquals(0, [SELECT Id FROM Contact].size(), 'zero contacts before');

        Test.StartTest();
        Map<String, Contact> contactId = KafkaKontaktSkjemaHandler_Helper.getContactMap(
            new List<KafkaKontaktSkjemaHandler_Model>{ submission }
        );
        Test.StopTest();

        List<Contact> con = [SELECT Id, AccountId, Email FROM Contact];
        System.assertEquals(1, con.size(), 'one contact after');
        System.assertEquals(null, con[0].AccountId, 'should be null as accountId');
        System.assertEquals('test@test.no', con[0].Email, 'correctly set email');
    }

    @isTest
    private static void testFetchOrCreateContact_existingContact() {
        Id accId = [SELECT Id FROM Account WHERE INT_OrganizationNumber__c = '960507878' LIMIT 1].Id;
        Contact con = new Contact(
            TAG_Informed__c = true,
            lastName = 'testerson',
            Email = 'test.testerson@nav.no',
            AccountId = accId
        );
        insert con;

        KafkaKontaktSkjemaHandler_Model submission = KafkaKontaktSkjemaHandler_Model.parse(
            '{ \"type\":\"REKRUTTERING\",\"municipalityCode\":\"3033\",\"organisationName\":\"Finstadtunet\",\"organisationNumber\":\"\",\"firstName\":\"test\",\"lastName\":\"testerson\",\"email\":\"test.testerson@nav.no\",\"phoneNo\":\"90080900\",\"RegionCode\":\"0200\" }'
        );

        System.assertEquals(1, [SELECT Id FROM Contact].size(), 'one contact before');

        Test.StartTest();
        Map<String, Contact> contactId = KafkaKontaktSkjemaHandler_Helper.getContactMap(
            new List<KafkaKontaktSkjemaHandler_Model>{ submission }
        );
        Test.StopTest();

        List<Contact> contacts = [SELECT Id, AccountId FROM Contact];
        System.assertEquals(1, contacts.size(), 'one contact after');
        System.assertEquals(con.Id, contacts[0].Id, 'same contact');
        System.assertEquals(accId, contacts[0].AccountId, 'uses the real account, and not the dummy account');
    }

    @isTest
    private static void testGetAccount() {
        Account expectedAccount = [
            SELECT Id, INT_OrganizationNumber__c
            FROM Account
            WHERE INT_OrganizationNumber__c = '960507878'
            LIMIT 1
        ];
        KafkaKontaktSkjemaHandler_Model submission = KafkaKontaktSkjemaHandler_Model.parse(
            '{ \"type\":\"REKRUTTERING\",\"municipalityCode\":\"3033\",\"organisationName\":\"Finstadtunet\",\"organisationNumber\":\"960507878\",\"firstName\":\"TestNavn\",\"lastName\":\"TestEtternavn\",\"email\":\"test@test.no\",\"phoneNo\":\"90080900\",\"RegionCode\":\"0200\" }'
        );

        Test.StartTest();
        Map<String, Account> accountmap = KafkaKontaktSkjemaHandler_Helper.getAccountMap(
            new List<KafkaKontaktSkjemaHandler_Model>{ submission }
        );
        Test.StopTest();

        System.assertEquals(
            expectedAccount.Id,
            accountMap.get(expectedAccount.INT_OrganizationNumber__c).Id,
            'account exists, and should be fetched'
        );
    }

    @isTest
    private static void testGetAccount_empty() {
        KafkaKontaktSkjemaHandler_Model submission = KafkaKontaktSkjemaHandler_Model.parse(
            '{ \"type\":\"REKRUTTERING\",\"municipalityCode\":\"3033\",\"organisationName\":\"Finstadtunet\",\"organisationNumber\":\"\",\"firstName\":\"TestNavn\",\"lastName\":\"TestEtternavn\",\"email\":\"test@test.no\",\"phoneNo\":\"90080900\",\"RegionCode\":\"0200\" }'
        );
        Test.StartTest();
        Map<String, Account> accountmap = KafkaKontaktSkjemaHandler_Helper.getAccountMap(
            new List<KafkaKontaktSkjemaHandler_Model>{ submission }
        );
        Test.StopTest();

        System.assertEquals(true, accountmap.isEmpty(), 'cant find empty org number, and should not be fetched');
    }

    @isTest
    private static void testCreateOpportunity() {
        Id inclusionRecordType = Schema.SObjectType.CustomOpportunity__c.getRecordTypeInfosByDeveloperName()
            .get('Inclusion')
            .getRecordTypeId();

        List<KafkaKontaktSkjemaHandler_Model> kontaktskjema = new List<KafkaKontaktSkjemaHandler_Model>();
        KafkaKontaktSkjemaHandler_Model s = KafkaKontaktSkjemaHandler_Model.parse(
            '{ \"type\":\"REKRUTTERING\",\"municipalityCode\":\"3033\",\"organisationName\":\"Finstadtunet\",\"organisationNumber\":\"960507878\",\"firstName\":\"test\",\"lastName\":\"testerson\",\"email\":\"test.testerson@nav.no\",\"phoneNo\":\"90080900\",\"RegionCode\":\"0200\" }'
        );
        kontaktskjema.add(s);

        Test.StartTest();
        KafkaKontaktSkjemaHandler_Helper.convertKontaktskjemaToOpportunity(kontaktskjema);
        Test.StopTest();

        List<CustomOpportunity__c> optys = [
            SELECT
                Id,
                Account__c,
                Contact__c,
                Source__c,
                TAG_OrganizationNameFromForm__c,
                INT_MunicipalityNumber__c,
                InquiryCategory__c,
                RecordTypeId,
                InclusionStage__c
            FROM CustomOpportunity__c
        ];

        Account acct = [SELECT Id FROM Account WHERE INT_OrganizationNumber__c = '960507878'];
        Contact con = [SELECT ID FROM Contact WHERE Email = 'test.testerson@nav.no'];

        System.assertEquals(1, optys.size(), 'should be 1 optys after');
        System.assertEquals(acct.Id, optys[0].Account__c, 'Account__c should be set');
        System.assertEquals(con.Id, optys[0].Contact__c, 'Contact__c should be set');
        System.assertEquals('Kontaktskjema', optys[0].Source__c, 'Source__c should be Kontaktskjema');
        System.assertEquals('Finstadtunet', optys[0].TAG_OrganizationNameFromForm__c, 'should be test');
        System.assertEquals('3033', optys[0].INT_MunicipalityNumber__c, 'INT_MunicipalityNumber__c should be 3033');
        System.assertEquals('Skal ansette', optys[0].InquiryCategory__c, 'InquiryCategory__c should be Skal ansette');
        System.assertEquals(inclusionRecordType, optys[0].RecordTypeId, 'RecordTypeId should be set');
        System.assertEquals(
            'Ny henvendelse',
            optys[0].InclusionStage__c,
            'InclusionStage__c should be "Ny henvendelse"'
        );
    }

    @isTest
    private static void testSendEmailReceipt() {
        List<KafkaKontaktSkjemaHandler_Model> kontaktskjema = new List<KafkaKontaktSkjemaHandler_Model>();
        KafkaKontaktSkjemaHandler_Model s = KafkaKontaktSkjemaHandler_Model.parse(
            '{ \"type\":\"REKRUTTERING\",\"municipalityCode\":\"3033\",\"organisationName\":\"Finstadtunet\",\"organisationNumber\":\"960507878\",\"firstName\":\"test\",\"lastName\":\"testerson\",\"email\":\"test.testerson@nav.no\",\"phoneNo\":\"90080900\",\"RegionCode\":\"0200\" }'
        );
        kontaktskjema.add(s);

        List<CustomOpportunity__c> optys = KafkaKontaktSkjemaHandler_Helper.convertKontaktskjemaToOpportunity(
            kontaktskjema
        );

        System.assertEquals(0, [SELECT Id FROM EmailQueue__c].size(), 'should be no emails before');

        Test.StartTest();
        KafkaKontaktSkjemaHandler_Helper.sendEmailReceipt(optys);
        Test.StopTest();

        System.assertEquals(1, [SELECT Id FROM CustomOpportunity__c].size(), 'should be one opportunity after');
        System.assertEquals(1, [SELECT Id FROM EmailQueue__c].size(), 'should be one email after');
    }
}
