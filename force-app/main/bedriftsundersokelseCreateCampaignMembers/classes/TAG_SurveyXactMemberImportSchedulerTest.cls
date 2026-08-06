@IsTest
private class TAG_SurveyXactMemberImportSchedulerTest {
    private class MockResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('respnokk;bedrnr\n');
            return res;
        }
    }

    @IsTest
    static void schedulerEnqueuesImport() {
        Test.setMock(HttpCalloutMock.class, new MockResponse());

        Test.startTest();
        String jobId = System.schedule(
            'SurveyXact Member Import Test',
            '0 0 2 1 2 ?',
            new TAG_SurveyXactMemberImportScheduler()
        );
        Test.stopTest();

        CronTrigger scheduledJob = [SELECT Id, CronExpression FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals('0 0 2 1 2 ?', scheduledJob.CronExpression, 'Scheduled with the given cron expression');
    }
}
