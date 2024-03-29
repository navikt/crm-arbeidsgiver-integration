@isTest
private without sharing class KontaktSkjemaHelperTest {
    @TestSetup
    static void makeData() {
        insert new Account(name = 'test', INT_OrganizationNumber__c = '960507878');
        insert new Account(name = 'Kontakter uten konto', INT_OrganizationNumber__c = 'AG_DEFAULT');
    }

    @isTest
    private static void testFetchOrCreateContact() {
        KontaktSkjemaModel rw = new KontaktSkjemaModel();
        rw.name = 'test testerson';
        rw.phoneNo = '90080900';
        rw.email = 'test.testerson@nav.no';
        rw.organisationNumber = '960507878';

        System.assertEquals(0, [SELECT Id FROM Contact].size(), 'zero contacts before');

        Test.StartTest();
        Id contactId = KontaktSkjemaHelper.fetchOrCreateContact(rw);
        Test.StopTest();

        Id accId = [SELECT Id FROM Account WHERE INT_OrganizationNumber__c = '960507878' LIMIT 1].Id;
        List<Contact> con = [SELECT Id, FirstName, LastName, AccountId FROM Contact];
        System.assertEquals(1, con.size(), 'one contact after');
        System.assertEquals('test', con[0].FirstName, 'correctly set first name');
        System.assertEquals('testerson', con[0].LastName, 'correctly set last name');
        System.assertEquals(accId, con[0].AccountId, 'correctly set account');
    }

    @isTest
    private static void testFetchOrCreateContact_addDummyAccount() {
        KontaktSkjemaModel rw = new KontaktSkjemaModel();
        rw.name = 'test testerson';
        rw.phoneNo = '90080900';
        rw.email = 'test.testerson@nav.no';
        rw.organisationNumber = '960507869'; // non-existing account

        System.assertEquals(0, [SELECT Id FROM Contact].size(), 'zero contacts before');

        Test.StartTest();
        Id contactId = KontaktSkjemaHelper.fetchOrCreateContact(rw);
        Test.StopTest();

        List<Contact> con = [SELECT Id, AccountId FROM Contact];
        System.assertEquals(1, con.size(), 'one contact after');

        Id dummyAccountId = [SELECT Id FROM Account WHERE INT_OrganizationNumber__c = 'AG_DEFAULT' LIMIT 1].Id;
        System.assertEquals(dummyAccountId, con[0].AccountId, 'should have automatically set dummy account');
    }

    @isTest
    private static void testFetchOrCreateContact_nullOrgNo() {
        KontaktSkjemaModel rw = new KontaktSkjemaModel();
        rw.name = 'test testerson';
        rw.phoneNo = '90080900';
        rw.email = 'test.testerson@nav.no';
        rw.organisationNumber = null;

        System.assertEquals(0, [SELECT Id FROM Contact].size(), 'zero contacts before');

        Test.StartTest();
        Id contactId = KontaktSkjemaHelper.fetchOrCreateContact(rw);
        Test.StopTest();

        List<Contact> con = [SELECT Id, AccountId FROM Contact];
        System.assertEquals(1, con.size(), 'one contact after');

        Id dummyAccountId = [SELECT Id FROM Account WHERE INT_OrganizationNumber__c = 'AG_DEFAULT' LIMIT 1].Id;
        System.assertEquals(dummyAccountId, con[0].AccountId, 'should have automatically set dummy account');
    }

    @isTest
    private static void testFetchOrCreateContact_emptyOrgNo() {
        KontaktSkjemaModel rw = new KontaktSkjemaModel();
        rw.name = 'test testerson';
        rw.phoneNo = '90080900';
        rw.email = 'test.testerson@nav.no';
        rw.organisationNumber = '';

        System.assertEquals(0, [SELECT Id FROM Contact].size(), 'zero contacts before');

        Test.StartTest();
        Id contactId = KontaktSkjemaHelper.fetchOrCreateContact(rw);
        Test.StopTest();

        List<Contact> con = [SELECT Id, AccountId FROM Contact];
        System.assertEquals(1, con.size(), 'one contact after');

        Id dummyAccountId = [SELECT Id FROM Account WHERE INT_OrganizationNumber__c = 'AG_DEFAULT' LIMIT 1].Id;
        System.assertEquals(dummyAccountId, con[0].AccountId, 'should have automatically set dummy account');
    }

    @isTest
    private static void testFetchOrCreateContact_separateNameFieldsUsed() {
        KontaktSkjemaModel rw = new KontaktSkjemaModel();
        rw.firstName = 'test';
        rw.lastName = 'testerson';
        rw.phoneNo = '90080900';
        rw.email = 'test.testerson@nav.no';
        rw.organisationNumber = '960507878';

        System.assertEquals(0, [SELECT Id FROM Contact].size(), 'zero contacts before');

        Test.StartTest();
        Id contactId = KontaktSkjemaHelper.fetchOrCreateContact(rw);
        Test.StopTest();

        List<Contact> con = [SELECT Id, FirstName, LastName FROM Contact];
        System.assertEquals(1, con.size(), 'one contact after');
        System.assertEquals('test', con[0].FirstName, 'correctly set first name');
        System.assertEquals('testerson', con[0].LastName, 'correctly set first name');
    }

    @isTest
    private static void testFetchOrCreateContact_nullEmail() {
        KontaktSkjemaModel rw = new KontaktSkjemaModel();
        rw.name = 'test testerson';
        rw.phoneNo = '90080900';
        rw.email = null;
        rw.organisationNumber = '960507878';

        System.assertEquals(0, [SELECT Id FROM Contact].size(), 'zero contacts before');

        Test.StartTest();
        Id contactId = KontaktSkjemaHelper.fetchOrCreateContact(rw);
        Test.StopTest();

        System.assertEquals(1, [SELECT Id FROM Contact].size(), 'one contact after');
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

        KontaktSkjemaModel rw = new KontaktSkjemaModel();
        rw.name = 'test testerson';
        rw.phoneNo = '90080900';
        rw.email = 'test.testerson@nav.no';

        System.assertEquals(1, [SELECT Id FROM Contact].size(), 'one contact before');

        Test.StartTest();
        Id contactId = KontaktSkjemaHelper.fetchOrCreateContact(rw);
        Test.StopTest();

        List<Contact> contacts = [SELECT Id, AccountId FROM Contact];
        System.assertEquals(1, contacts.size(), 'one contact after');
        System.assertEquals(contacts[0].Id, contactId, 'same contact');
        System.assertEquals(con.Id, contactId, 'same contact');
        System.assertEquals(accId, contacts[0].AccountId, 'uses the real account, and not the dummy account');
    }

    @isTest
    private static void testSetName_fullName() {
        KontaktSkjemaModel rw = new KontaktSkjemaModel();
        rw.name = 'test testerson';
        rw.phoneNo = '90080900';
        rw.email = 'test.testerson@nav.no';
        rw.organisationNumber = '960507878';

        SharedFunctions_ContactModel wrapper = new SharedFunctions_ContactModel();

        Test.StartTest();
        KontaktSkjemaHelper.setName(wrapper, rw);
        Test.StopTest();

        System.assertEquals('test', wrapper.firstName, 'firstName should have been correctly set to "test');
        System.assertEquals('testerson', wrapper.lastName, 'lastName should have been correctly set to "testerson');
    }

    @isTest
    private static void testSetName_separateName() {
        KontaktSkjemaModel rw = new KontaktSkjemaModel();
        rw.firstName = 'test';
        rw.lastName = 'testerson';
        rw.phoneNo = '90080900';
        rw.email = 'test.testerson@nav.no';
        rw.organisationNumber = '960507878';

        SharedFunctions_ContactModel wrapper = new SharedFunctions_ContactModel();

        Test.StartTest();
        KontaktSkjemaHelper.setName(wrapper, rw);
        Test.StopTest();

        System.assertEquals('test', wrapper.firstName, 'firstName should have been correctly set to "test');
        System.assertEquals('testerson', wrapper.lastName, 'lastName should have been correctly set to "testerson');
    }

    @isTest
    private static void testGetDummyAccount() {
        Id dummyAccount = [SELECT Id FROM Account WHERE INT_OrganizationNumber__c = 'AG_DEFAULT' LIMIT 1].Id;

        Test.StartTest();
        Id accountId = KontaktSkjemaHelper.getDummyAccount();
        Test.StopTest();

        System.assertEquals(dummyAccount, accountId, 'Account exists, thus the ID is returned');
    }

    @isTest
    private static void testGetAccount() {
        Id expectedAccount = [SELECT Id FROM Account WHERE INT_OrganizationNumber__c = '960507878' LIMIT 1].Id;

        Test.StartTest();
        Id accountId = KontaktSkjemaHelper.getAccount('960507878');
        Test.StopTest();

        System.assertEquals(expectedAccount, accountId, 'account exists, and should be fetched');
    }

    @isTest
    private static void testGetAccount_doesNotExist() {
        Test.StartTest();
        Id accountId = KontaktSkjemaHelper.getAccount('960507871');
        Test.StopTest();

        System.assertEquals(null, accountId, 'account does not exist, and should not be fetched');
    }

    @isTest
    private static void testGetAccount_empty() {
        Test.StartTest();
        Id accountId = KontaktSkjemaHelper.getAccount('');
        Test.StopTest();

        System.assertEquals(null, accountId, 'cant find empty org number, and should not be fetched');
    }

    @isTest
    private static void testGetAccount_null() {
        Test.StartTest();
        Id accountId = KontaktSkjemaHelper.getAccount(null);
        Test.StopTest();

        System.assertEquals(null, accountId, 'cant find empty org number, and should not be fetched');
    }

    @isTest
    private static void testCreateOpportunity() {
        Id inclusionRecordType = Schema.SObjectType.CustomOpportunity__c.getRecordTypeInfosByDeveloperName()
            .get('Inclusion')
            .getRecordTypeId();

        KontaktSkjemaModel rw = getDummyModel();

        Id contactId = KontaktSkjemaHelper.fetchOrCreateContact(rw);
        Id accountId = KontaktSkjemaHelper.getAccount('960507878');

        System.assertEquals(0, [SELECT Id FROM CustomOpportunity__c].size(), 'should be 0 optys before');

        Test.StartTest();
        KontaktSkjemaHelper.createOpportunity(accountId, contactId, rw);
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
        System.assertEquals(1, optys.size(), 'should be 1 optys after');

        System.assertEquals(accountId, optys[0].Account__c, 'Account__c should be set');
        System.assertEquals(contactId, optys[0].Contact__c, 'Contact__c should be set');
        System.assertEquals('Kontaktskjema', optys[0].Source__c, 'Source__c should be Kontaktskjema');
        System.assertEquals('test', optys[0].TAG_OrganizationNameFromForm__c, 'should be test');
        System.assertEquals('3033', optys[0].INT_MunicipalityNumber__c, 'INT_MunicipalityNumber__c should be 3033');
        System.assertEquals(
            'Skal ansette',
            optys[0].InquiryCategory__c,
            'InquiryCategory__c should be Skal ansette'
        );
        System.assertEquals(inclusionRecordType, optys[0].RecordTypeId, 'RecordTypeId should be set');
        System.assertEquals(
            'Ny henvendelse',
            optys[0].InclusionStage__c,
            'InclusionStage__c should be "Ny henvendelse"'
        );
    }

    @isTest
    private static void testSendEmailReceipt() {
        KontaktSkjemaModel rw = getDummyModel();
        Id contactId = KontaktSkjemaHelper.fetchOrCreateContact(rw);
        Id accountId = KontaktSkjemaHelper.getAccount('960507878');
        CustomOpportunity__c opty = KontaktSkjemaHelper.createOpportunity(accountId, contactId, rw);

        System.assertEquals(0, [SELECT Id FROM EmailQueue__c].size(), 'should be no emails before');

        Test.StartTest();
        KontaktSkjemaHelper.sendEmailReceipt(rw, opty);
        Test.StopTest();

        System.assertEquals(1, [SELECT Id FROM EmailQueue__c].size(), 'should be one email after');
    }

    @isTest
    private static void testSendEmailReceipt_nullEmail() {
        KontaktSkjemaModel rw = getDummyModel();
        rw.email = null;
        Id contactId = KontaktSkjemaHelper.fetchOrCreateContact(rw);
        Id accountId = KontaktSkjemaHelper.getAccount('960507878');
        CustomOpportunity__c opty = KontaktSkjemaHelper.createOpportunity(accountId, contactId, rw);

        System.assertEquals(0, [SELECT Id FROM EmailQueue__c].size(), 'should be no emails before');

        Test.StartTest();
        KontaktSkjemaHelper.sendEmailReceipt(rw, opty);
        Test.StopTest();

        System.assertEquals(0, [SELECT Id FROM EmailQueue__c].size(), 'should be no emails after, because null email');
    }

    @isTest
    private static void testSendEmailReceipt_emptyEmail() {
        KontaktSkjemaModel rw = getDummyModel();
        rw.email = '';
        Id contactId = KontaktSkjemaHelper.fetchOrCreateContact(rw);
        Id accountId = KontaktSkjemaHelper.getAccount('960507878');
        CustomOpportunity__c opty = KontaktSkjemaHelper.createOpportunity(accountId, contactId, rw);

        System.assertEquals(0, [SELECT Id FROM EmailQueue__c].size(), 'should be no emails before');

        Test.StartTest();
        KontaktSkjemaHelper.sendEmailReceipt(rw, opty);
        Test.StopTest();

        System.assertEquals(0, [SELECT Id FROM EmailQueue__c].size(), 'should be no emails after, because empty email');
    }

    @isTest
    private static void testIsIA() {
        Test.StartTest();
        Boolean result = KontaktSkjemaHelper.isIA('FOREBYGGE_SYKEFRAVÆR');
        Test.StopTest();

        System.assertEquals(true, result, 'Should be IA type, so correct result is true');
    }

    @isTest
    private static void testIsIA_isNotIsa() {
        Test.StartTest();
        Boolean result = KontaktSkjemaHelper.isIA('REKRUTTERING');
        Test.StopTest();

        System.assertEquals(false, result, 'Should not be IA type, so correct result is false');
    }

    @isTest
    private static void testGetType_REKRUTTERING() {
        Test.StartTest();
        String result = KontaktSkjemaHelper.getType('REKRUTTERING');
        Test.StopTest();

        System.assertEquals('Skal ansette', result, 'should have returned "Skal ansette"');
    }

    @isTest
    private static void testGetType_FOREBYGGE_SYKEFRAVAER() {
        Test.StartTest();
        String result = KontaktSkjemaHelper.getType('FOREBYGGE_SYKEFRAVÆR');
        Test.StopTest();

        System.assertEquals('Forebygge sykefravær', result, 'should have returned "Forebygge sykefravær"');
    }

    // helper functions
    // ----------------------------------------

    public static KontaktSkjemaModel getDummyModel() {
        KontaktSkjemaModel rw = new KontaktSkjemaModel();
        rw.name = 'test testerson';
        rw.phoneNo = '90080900';
        rw.email = 'test.testerson@nav.no';
        rw.organisationNumber = '960507878';
        rw.organisationName = 'test';
        rw.type = 'REKRUTTERING';
        rw.municipalityCode = '3033';
        rw.regionCode = '0200';

        return rw;
    }
}
