@isTest
private without sharing class KontaktSkjemaHelperTest {
    @TestSetup
    static void makeData() {
        insert new Account(name = 'test', INT_OrganizationNumber__c = '960507878');
    }

    @isTest
    private static void testGetContact() {
        KontaktSkjemaModel rw = new KontaktSkjemaModel();
        rw.name = 'test testerson';
        rw.phoneNo = '90080900';
        rw.email = 'test.testerson@nav.no';
        rw.organisationNumber = '960507878';

        System.assertEquals(0, [SELECT Id FROM Contact].size(), 'zero contacts before');

        Test.StartTest();
        Id contactId = KontaktSkjemaHelper.fetchOrCreateContact(rw);
        Test.StopTest();

        System.assertEquals(1, [SELECT Id FROM Contact].size(), 'one contact after');
        System.assertEquals(contactId, [SELECT Id FROM Contact LIMIT 1].Id, 'same contact');
    }

    @isTest
    private static void testGetContact_existingContact() {
        Contact con = new Contact(TAG_Informed__c = true, lastName = 'testerson', Email = 'test.testerson@nav.no');
        insert con;

        KontaktSkjemaModel rw = new KontaktSkjemaModel();
        rw.name = 'test testerson';
        rw.phoneNo = '90080900';
        rw.email = 'test.testerson@nav.no';
        rw.organisationNumber = '960507878';

        System.assertEquals(1, [SELECT Id FROM Contact].size(), 'one contact before');

        Test.StartTest();
        Id contactId = KontaktSkjemaHelper.fetchOrCreateContact(rw);
        Test.StopTest();

        System.assertEquals(1, [SELECT Id FROM Contact].size(), 'one contact after');
        System.assertEquals(contactId, [SELECT Id FROM Contact LIMIT 1].Id, 'same contact');
        System.assertEquals(contactId, con.Id, 'same contact');
    }

    @isTest
    private static void testGetDummyAccount() {
        Test.StartTest();
        // KontaktSkjemaHelper.getDummyAccount();
        Test.StopTest();
    }

    @isTest
    private static void testUpdateContactWithNewAccount() {
        Test.StartTest();
        // KontaktSkjemaHelper.updateContactWithNewAccount();
        Test.StopTest();
    }

    @isTest
    private static void testGetAccount() {
        Test.StartTest();
        // KontaktSkjemaHelper.getAccount();
        Test.StopTest();
    }

    @isTest
    private static void testCreateOpportunity() {
        Test.StartTest();
        // KontaktSkjemaHelper.createOpportunity();
        Test.StopTest();
    }

    @isTest
    private static void testSendEmailReceipt() {
        Test.StartTest();
        // KontaktSkjemaHelper.sendEmailReceipt();
        Test.StopTest();
    }

    @isTest
    private static void testGetRecordType() {
        Test.StartTest();
        // KontaktSkjemaHelper.getRecordType();
        Test.StopTest();
    }

    @isTest
    private static void testGetType() {
        Test.StartTest();
        // KontaktSkjemaHelper.getType();
        Test.StopTest();
    }
}
