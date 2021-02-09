@IsTest
public class KafkaSykefravaerHandlerTest {
    @IsTest
    public static void testHandleMessages() {
        // Arrange
        // Create 3 Accounts - two with org. nr. matching contents of messages and one without
        List<Account> accounts = new List<Account>();
        Account a1 = new Account();
        a1.Name = 'Test Employer 1';
        a1.INT_OrganizationNumber__c = '987633999';
        accounts.add(a1);

        Account a2 = new Account();
        a2.Name = 'Test Employer 2';
        a2.INT_OrganizationNumber__c = '999654999';
        accounts.add(a2);

        Account a3 = new Account();
        a3.Name = 'Test Employer 3';
        a3.INT_OrganizationNumber__c = '999111999';
        accounts.add(a3);

        insert accounts;

        // Create two KafkaMessages with Base64 encoded JSON-payloads matching two of the three inserted accounts
        List<KafkaMessage__c> messages = new List<KafkaMessage__c>();
        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'public-sykefravarsstatistikk-crm';
        msg1.CRM_Key__c = 'd60775ed-249f-49e6-bd15-ff790b56cc07';
        msg1.CRM_Value__c = 'eyJvcmduciI6Ijk4NzYzMzk5OSIsInBvdGVuc2llbGxlRGFnc3ZlcmsiOjk5LCJtdWxpZ2VEYWdzdmVyayI6NzksInRhcHRlRGFnc3ZlcmsiOjIzfQ==';
        messages.add(msg1);

        KafkaMessage__c msg2 = new KafkaMessage__c();
        msg2.CRM_Topic__c = 'public-sykefravarsstatistikk-crm';
        msg2.CRM_Key__c = '27a3cca9-0b2e-486a-8632-3a95391dfc18';
        msg2.CRM_Value__c = 'eyJvcmduciI6Ijk5OTY1NDk5OSIsInBvdGVuc2llbGxlRGFnc3ZlcmsiOjEwLCJtdWxpZ2VEYWdzdmVyayI6MTAsInRhcHRlRGFnc3ZlcmsiOjEwfQ==';
        messages.add(msg2);

        insert messages;

        // Verify that no INT_PotentialMandays__c field has been set yet
        for (Account acc : [SELECT INT_PotentialMandays__c FROM Account]) {
            System.assertEquals(null, acc.INT_PotentialMandays__c);
        }

        // Act
        Test.startTest();
        new KafkaMessageService(messages).handleMessages();
        Test.stopTest();

        // Assert
        // Verify that two accounts have been updated with the correct PotentialManDays, and that the last Account has not been updated
        a1 = [
            SELECT Id, INT_PotentialMandays__c
            FROM Account
            WHERE Id = :a1.Id
        ];
        System.assertEquals(99, a1.INT_PotentialMandays__c);
        a2 = [
            SELECT Id, INT_PotentialMandays__c
            FROM Account
            WHERE Id = :a2.Id
        ];
        System.assertEquals(10, a2.INT_PotentialMandays__c);
        a3 = [
            SELECT Id, INT_PotentialMandays__c
            FROM Account
            WHERE Id = :a3.Id
        ];
        System.assertEquals(null, a3.INT_PotentialMandays__c);
    }
}
