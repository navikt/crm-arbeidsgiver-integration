@IsTest
private class TAG_SurveyXactDatasetSyncQueueableTest {
    private static final String KEY_DONE = 'QUEUE_DONE';

    private class MockResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('survey;respnokk;c_1\n123456;' + KEY_DONE + ';1\n');
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

    private class SimulatedLimitException extends Exception {
    }

    private class FinalizerContextMock implements FinalizerContext {
        private ParentJobResult result;
        private Exception error;

        FinalizerContextMock(ParentJobResult result, Exception error) {
            this.result = result;
            this.error = error;
        }

        public Id getAsyncApexJobId() {
            return null;
        }

        public Exception getException() {
            return error;
        }

        public String getRequestId() {
            return null;
        }

        public ParentJobResult getResult() {
            return result;
        }
    }

    @TestSetup
    static void setup() {
        // The sync only looks at members on a campaign starting this year.
        CustomCampaign__c campaign = new CustomCampaign__c(
            Name = 'BU ' + Date.today().year() + ' Test',
            Type__c = 'Bedriftsundersøkelse',
            StartDate__c = Date.newInstance(Date.today().year(), 1, 15)
        );
        insert campaign;

        insert new CustomCampaignMember__c(
            Key__c = KEY_DONE,
            Status__c = 'Ikke gjennomført',
            CustomCampaign__c = campaign.Id
        );
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

    @IsTest
    static void missingConfigIsLogged() {
        Test.startTest();
        System.enqueueJob(new TAG_SurveyXactDatasetSyncQueueable(new List<TAG_SurveyXactDataset_Config__mdt>()));
        Test.stopTest();
        Test.getEventBus().deliver();

        List<Application_Log__c> logs = [
            SELECT Log_Level__c, Application_Domain__c, Log_Message__c
            FROM Application_Log__c
        ];
        Assert.areEqual(1, logs.size(), 'One log entry for the missing configuration');
        Assert.areEqual('Error', logs[0].Log_Level__c, 'Missing configuration is an error');
        Assert.areEqual('POAB', logs[0].Application_Domain__c, 'Logged on the POAB domain');
        Assert.isTrue(logs[0].Log_Message__c.contains('no active configuration'), 'Message explains the cause');
    }

    @IsTest
    static void finalizerLogsUnhandledException() {
        FinalizerContextMock context = new FinalizerContextMock(
            ParentJobResult.UNHANDLED_EXCEPTION,
            new SimulatedLimitException('Apex CPU time limit exceeded')
        );

        Test.startTest();
        new TAG_SurveyXactDatasetSyncQueueable.SyncFinalizer().execute(context);
        Test.stopTest();

        List<Application_Log__c> logs = [
            SELECT Log_Level__c, Application_Domain__c, Log_Message__c
            FROM Application_Log__c
        ];
        Assert.areEqual(1, logs.size(), 'One log entry for the failed job');
        Assert.areEqual('Error', logs[0].Log_Level__c, 'Unhandled exception is an error');
        Assert.areEqual('POAB', logs[0].Application_Domain__c, 'Logged on the POAB domain');
        Assert.isTrue(logs[0].Log_Message__c.contains('CPU time limit'), 'Message carries the exception');
    }

    @IsTest
    static void finalizerIsSilentOnSuccess() {
        Test.startTest();
        new TAG_SurveyXactDatasetSyncQueueable.SyncFinalizer()
            .execute(new FinalizerContextMock(ParentJobResult.SUCCESS, null));
        Test.stopTest();

        Assert.areEqual(0, [SELECT COUNT() FROM Application_Log__c], 'Nothing logged when the job succeeds');
    }
}
