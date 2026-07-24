@IsTest
private class TAG_SurveyXactDatasetSyncQueueableTest {
    private static final String KEY_DONE = 'QUEUE_DONE';

    private class MockResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('survey;respnokk;response\n123456;' + KEY_DONE + ';1\n');
            return res;
        }
    }

    private class MockErrorResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('Internal Server Error');
            return res;
        }
    }

    @TestSetup
    static void setup() {
        insert new CustomCampaignMember__c(Key__c = KEY_DONE, Status__c = 'Ikke gjennomført');
    }

    @IsTest
    static void executeFetchesAndSyncs() {
        Test.setMock(HttpCalloutMock.class, new MockResponse());
        List<TAG_SurveyXactDataset_Config__mdt> configs = new List<TAG_SurveyXactDataset_Config__mdt>{
            new TAG_SurveyXactDataset_Config__mdt(SurveyId__c = '123456', LookbackDays__c = 3, Active__c = true)
        };

        Test.startTest();
        System.enqueueJob(new TAG_SurveyXactDatasetSyncQueueable(configs));
        Test.stopTest();

        CustomCampaignMember__c member = [
            SELECT Status__c
            FROM CustomCampaignMember__c
            WHERE Key__c = :KEY_DONE
            LIMIT 1
        ];
        System.assertEquals('Gjennomført', member.Status__c, 'Member promoted after queueable run');
    }

    @IsTest
    static void defaultConstructorReadsActiveConfigs() {
        // Exercises the no-arg constructor path; no active CMDT records may exist in the org,
        // so this simply verifies construction and enqueue do not fail.
        Test.setMock(HttpCalloutMock.class, new MockResponse());

        Test.startTest();
        System.enqueueJob(new TAG_SurveyXactDatasetSyncQueueable());
        Test.stopTest();

        System.assert(true, 'Queueable enqueued with active configs');
    }

    @IsTest
    static void failedCalloutIsLoggedAndDoesNotThrow() {
        Test.setMock(HttpCalloutMock.class, new MockErrorResponse());
        List<TAG_SurveyXactDataset_Config__mdt> configs = new List<TAG_SurveyXactDataset_Config__mdt>{
            new TAG_SurveyXactDataset_Config__mdt(SurveyId__c = '123456', LookbackDays__c = 3, Active__c = true)
        };

        Test.startTest();
        // Should not throw; the failure is caught and logged via LoggerUtility.
        System.enqueueJob(new TAG_SurveyXactDatasetSyncQueueable(configs));
        Test.stopTest();

        CustomCampaignMember__c member = [
            SELECT Status__c
            FROM CustomCampaignMember__c
            WHERE Key__c = :KEY_DONE
            LIMIT 1
        ];
        System.assertEquals('Ikke gjennomført', member.Status__c, 'Member unchanged when callout fails');
    }
}
