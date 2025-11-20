@IsTest
public with sharing class TAG_DeleteKafkaMessagesBatchJobTest {
    /*@isTest
    static void executeBatch() {
        KafkaMessage__c kafkaMessageTiltak1 = new KafkaMessage__c(
            CRM_Status__c = 'Processed',
            CRM_Topic__c = 'arbeidsgiver.tiltak-avtale-hendelse',
            CRM_Key__c = '1234'
        );
        KafkaMessage__c kafkaMessageTiltak2 = new KafkaMessage__c(
            CRM_Status__c = 'Processed',
            CRM_Topic__c = 'arbeidsgiver.tiltak-avtale-hendelse',
            CRM_Key__c = '1234'
        );
        KafkaMessage__c kafkaMessageTiltakPending = new KafkaMessage__c(
            CRM_Status__c = 'Pending',
            CRM_Topic__c = 'arbeidsgiver.tiltak-avtale-hendelse',
            CRM_Key__c = '1234'
        );

        KafkaMessage__c kafkaMessageStilling1 = new KafkaMessage__c(
            CRM_Status__c = 'Processed',
            CRM_Topic__c = 'teampam.stilling-ekstern-1',
            CRM_Key__c = '1235'
        );
        KafkaMessage__c kafkaMessageStilling2 = new KafkaMessage__c(
            CRM_Status__c = 'Processed',
            CRM_Topic__c = 'teampam.stilling-ekstern-1',
            CRM_Key__c = '1235'
        );
        KafkaMessage__c kafkaMessageStillingPending = new KafkaMessage__c(
            CRM_Status__c = 'Pending',
            CRM_Topic__c = 'teampam.stilling-ekstern-1',
            CRM_Key__c = '1235'
        );

        KafkaMessage__c kafkaMessagePiaSak1 = new KafkaMessage__c(
            CRM_Status__c = 'Processed',
            CRM_Topic__c = 'pia.ia-sak-v1',
            CRM_Key__c = '1236'
        );
        KafkaMessage__c kafkaMessagePiaSak2 = new KafkaMessage__c(
            CRM_Status__c = 'Processed',
            CRM_Topic__c = 'pia.ia-sak-v1',
            CRM_Key__c = '1236'
        );
        KafkaMessage__c kafkaMessagePiaSakError = new KafkaMessage__c(
            CRM_Status__c = 'Error',
            CRM_Topic__c = 'pia.ia-sak-v1',
            CRM_Key__c = '1236'
        );

        KafkaMessage__c kafkaMessageNks1 = new KafkaMessage__c(
            CRM_Status__c = 'Processed',
            CRM_Topic__c = 'teamnks.nks-sf-pdl-v3',
            CRM_Key__c = '1236'
        );
        KafkaMessage__c kafkaMessageNks2 = new KafkaMessage__c(
            CRM_Status__c = 'Processed',
            CRM_Topic__c = 'teamnks.nks-sf-pdl-v3',
            CRM_Key__c = '1236'
        );
        KafkaMessage__c kafkaMessageNksError = new KafkaMessage__c(
            CRM_Status__c = 'Error',
            CRM_Topic__c = 'teamnks.nks-sf-pdl-v3',
            CRM_Key__c = '1236'
        );

        List<KafkaMessage__c> kafkaMessageList = new List<KafkaMessage__c>{
            //kafkaMessageTiltak1,
            //kafkaMessageTiltak2,
            kafkaMessageTiltakPending,
            //kafkaMessageStilling1,
            //kafkaMessageStilling2,
            kafkaMessageStillingPending,
            //kafkaMessagePiaSak1,
            //kafkaMessagePiaSak2,
            kafkaMessagePiaSakError,
            kafkaMessageNks1,
            kafkaMessageNks2,
            kafkaMessageNksError
        };

        insert kafkaMessageList;

        Test.startTest();
        TAG_DeleteKafkaMessagesBatchJob btch = new TAG_DeleteKafkaMessagesBatchJob();
        Database.executeBatch(btch, 10000);
        Test.stopTest();

        List<KafkaMessage__c> kafkaMessagesNotDeleted = [SELECT Id FROM KafkaMessage__c];

        System.assertEquals(6, kafkaMessagesNotDeleted.size(), 'Should be 6 kafka messages that are not deleted');
    }*/
}
