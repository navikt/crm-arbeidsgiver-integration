@IsTest
private class TAG_SurveyXactDatasetSchedulerTest {
    private class MockResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('survey;respnokk;response\n');
            return res;
        }
    }

    @IsTest
    static void scheduleEnqueuesJob() {
        Test.setMock(HttpCalloutMock.class, new MockResponse());

        Test.startTest();
        String jobId = System.schedule(
            'SurveyXact Dataset Sync Test',
            '0 0 22 * * ?',
            new TAG_SurveyXactDatasetScheduler()
        );
        Test.stopTest();

        CronTrigger ct = [SELECT CronExpression FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals('0 0 22 * * ?', ct.CronExpression, 'Job scheduled with expected cron');
    }
}
