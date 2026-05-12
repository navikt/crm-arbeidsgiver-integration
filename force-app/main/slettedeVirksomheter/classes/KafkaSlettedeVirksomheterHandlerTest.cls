@IsTest
private without sharing class KafkaSlettedeVirksomheterHandlerTest {
    @IsTest
    private static void testNewKafkaMessages() {
        KafkaEnhetFilter.bypassFilter = true;

        Account acc = new Account(
            Name = 'Test Employer 1',
            INT_OrganizationNumber__c = '99999999',
            NumberOfEmployees = 100,
            CRM_NumberOfEmployeesGrouped__c = '51-100',
            INT_HasEmployees__c = true
        );
        insert acc;

        Account acc2 = new Account(
            Name = 'Test Employer 2',
            INT_OrganizationNumber__c = '77777777',
            NumberOfEmployees = 100,
            CRM_NumberOfEmployeesGrouped__c = '51-100',
            INT_HasEmployees__c = true
        );
        insert acc2;

        List<Account> accts = [SELECT Id FROM Account WHERE IsDeletedEmployer__c = TRUE];
        System.assertEquals(0, accts.size(), 'No accounts deleted');

        List<KafkaMessage__c> messages = new List<KafkaMessage__c>();
        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'public-ereg-cache-org-tombstones';
        msg1.CRM_Key__c = '99999999';
        msg1.CRM_Value__c = '99999999';
        messages.add(msg1);

        KafkaMessage__c msg2 = new KafkaMessage__c();
        msg2.CRM_Topic__c = 'public-ereg-cache-org-tombstones';
        msg2.CRM_Key__c = '77777777';
        msg2.CRM_Value__c = '77777777';
        messages.add(msg2);

        insert messages;

        Test.startTest();
        AsyncRequestSchedulable.enqueueAsyncJobs();
        Test.stopTest();

        accts = [
            SELECT Id, EmployerDeletedDate__c, INT_HasEmployees__c, CRM_NumberOfEmployeesGrouped__c, NumberOfEmployees
            FROM Account
            WHERE IsDeletedEmployer__c = TRUE
        ];
        Assert.areEqual(2, accts.size(), 'two accounts deleted');
        Assert.areEqual(Date.today(), accts[0].EmployerDeletedDate__c, 'deleted date is today');
        Assert.isNull(accts[0].CRM_NumberOfEmployeesGrouped__c, 'Should clear number of employees group when deleted');
        Assert.isNull(accts[0].NumberOfEmployees, 'Should clear number of employees when deleted');
        Assert.isFalse(accts[0].INT_HasEmployees__c, 'Should set has employees to false when deleted');
    }
}
