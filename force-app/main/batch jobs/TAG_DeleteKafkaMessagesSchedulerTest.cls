@isTest
public with sharing class TAG_DeleteKafkaMessagesSchedulerTest {
    private static final String CRON_EXP = '0 0 0 15 3 ? 2030';
    @isTest
    static void execute() {
        KafkaMessage__c kafkaMessageKontaktskjema = new KafkaMessage__c(CRM_Status__c = 'Processed', CRM_Topic__c = 'team-innhold.arbeidsgiver-kontaktskjema', CRM_Key__c = '1234');
        insert kafkaMessageKontaktskjema;
        Test.startTest();
        String jobId = System.schedule('ScheduledApexTest', CRON_EXP, new TAG_DeleteKafkaMessagesScheduler());
        Test.stopTest();
        List<AsyncApexJob> jobsScheduled = [
            SELECT Id, ApexClassID, ApexClass.Name, Status, JobType
            FROM AsyncApexJob
            WHERE JobType = 'ScheduledApex'
        ];
        System.assertEquals(1, jobsScheduled.size(), 'One job scheduled.');
        System.assertEquals('TAG_DeleteKafkaMessagesScheduler', jobsScheduled[0].ApexClass.Name, 'Scheduled the job.');
    }
    @isTest
    static void batchSubmission() {
        Test.startTest();
        String jobId = System.schedule('ScheduledApexTest', CRON_EXP, new TAG_DeleteKafkaMessagesScheduler());
        Test.stopTest();
        List<AsyncApexJob> jobsApexBatch = [
            SELECT Id, ApexClassID, ApexClass.Name, Status, JobType
            FROM AsyncApexJob
            WHERE JobType = 'BatchApex'
        ];
        System.assertEquals(1, jobsApexBatch.size(), 'One job scheduled.');
        System.assertEquals('TAG_DeleteKafkaMessagesBatchJob', jobsApexBatch[0].ApexClass.Name, 'Batch job submitted.');
    }
}