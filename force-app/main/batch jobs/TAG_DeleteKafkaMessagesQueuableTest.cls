@isTest
public with sharing class TAG_DeleteKafkaMessagesQueuableTest {
    @testSetup
    static void createMessages() {
        List<KafkaMessage__c> messagesToInsert = new List<KafkaMessage__c>();

        for (Integer i = 0; i < 4998; i++) {
            KafkaMessage__c k = new KafkaMessage__c(
                CRM_Status__c = 'Processed',
                CRM_Topic__c = 'arbeidsgiver.sykefravarsstatistikk-v1',
                CRM_Key__c = '12' + i
            );
            messagesToInsert.add(k);
        }
        insert messagesToInsert;

        KafkaMessage__c kafkaMessageTiltakPending = new KafkaMessage__c(
            CRM_Status__c = 'Pending',
            CRM_Topic__c = 'arbeidsgiver.tiltak-avtale-hendelse',
            CRM_Key__c = '1234'
        );
        insert kafkaMessageTiltakPending;

        KafkaMessage__c kafkaMessageStilling1 = new KafkaMessage__c(
            CRM_Status__c = 'Processed',
            CRM_Topic__c = 'teampam.stilling-ekstern-1',
            CRM_Key__c = '1235'
        );
        insert kafkaMessageStilling1;
    }

    @isTest
    static void testQueueable() {
        Integer countMessage = [SELECT COUNT() FROM KafkaMessage__c];
        System.assertEquals(5000, countMessage, 'Should be 5000 kafka messages totalt before queueable delete');

        Test.startTest();
        AsyncOptions options = new AsyncOptions();
        options.MaximumQueueableStackDepth = 1000;
        System.enqueueJob(new TAG_DeleteKafkaMessagesQueuable(), options);
        Test.stopTest();
        //Impossible to test with more than 10000 DML operations, that is why only 5000 records (+ trigger)
        //It has been positiv tested self-chaining by setting LIMIT to 20 for query inside TAG_DeleteKafkaMessagesQueuable execute method

        Integer countMessageAfter = [SELECT COUNT() FROM KafkaMessage__c];
        System.assertEquals(5000, countMessageAfter, 'Should be 5000 kafka messages totalt after queueable delete');
    }
}
