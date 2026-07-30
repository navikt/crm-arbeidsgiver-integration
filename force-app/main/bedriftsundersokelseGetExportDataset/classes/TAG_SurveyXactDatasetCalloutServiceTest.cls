@IsTest
private class TAG_SurveyXactDatasetCalloutServiceTest {
    private class MockResponse implements HttpCalloutMock {
        private Integer statusCode;
        private String body;

        MockResponse(Integer statusCode, String body) {
            this.statusCode = statusCode;
            this.body = body;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(statusCode);
            res.setBody(body);
            return res;
        }
    }

    @IsTest
    static void getDatasetReturnsBodyOn200() {
        Test.setMock(HttpCalloutMock.class, new MockResponse(200, 'respnokk;c_1\nABC;1\n'));

        Test.startTest();
        String body = TAG_SurveyXactDatasetCalloutService.getDataset(
            '123456',
            '[respondent/closeTime] > datetime("2026-07-19 00:00:00")'
        );
        Test.stopTest();

        System.assert(body.contains('ABC;1'), 'CSV body returned');
    }

    @IsTest
    static void getDatasetThrowsOnNon200() {
        Test.setMock(HttpCalloutMock.class, new MockResponse(500, 'error'));

        Test.startTest();
        try {
            TAG_SurveyXactDatasetCalloutService.getDataset('123456', null);
            System.assert(false, 'Expected CalloutException');
        } catch (TAG_SurveyXactDatasetCalloutService.CalloutException e) {
            System.assert(e.getMessage().contains('500'), 'Message mentions status code');
        }
        Test.stopTest();
    }

    @IsTest
    static void buildEndpointEncodesExpression() {
        String expr = '[respondent/closeTime] > datetime("2026-07-19 00:00:00")';
        String endpoint = TAG_SurveyXactDatasetCalloutService.buildEndpoint('123456', expr);

        System.assert(
            endpoint.startsWith('callout:SurveyXact/surveys/123456/export/dataset'),
            'Uses named credential + path'
        );
        System.assert(endpoint.contains('format=EU'), 'Includes format');
        System.assert(endpoint.contains('lang=en'), 'Includes lang');
        System.assert(endpoint.contains('expression=%5Brespondent'), 'Expression is URL encoded');
        System.assert(!endpoint.contains('expression=[respondent'), 'Raw brackets are not present');
    }

    @IsTest
    static void buildCloseTimeExpressionUsesWindow() {
        String expr = TAG_SurveyXactDatasetCalloutService.buildCloseTimeExpression(3);

        System.assert(expr.startsWith('[respondent/closeTime] > datetime("'), 'Expression shape');
        Date expected = Date.today().addDays(-3);
        String expectedDate =
            expected.year() +
            '-' +
            String.valueOf(expected.month()).leftPad(2, '0') +
            '-' +
            String.valueOf(expected.day()).leftPad(2, '0');
        System.assert(expr.contains(expectedDate), 'Contains the cutoff date');
        System.assert(expr.contains(expectedDate + ' 00:00:00'), 'Cutoff is floored to midnight');
    }

    @IsTest
    static void getRecentDatasetThrowsWhenSurveyIdMissing() {
        TAG_SurveyXactDataset_Config__mdt config = new TAG_SurveyXactDataset_Config__mdt(LookbackDays__c = 3);

        Test.startTest();
        try {
            TAG_SurveyXactDatasetCalloutService.getRecentDataset(config);
            System.assert(false, 'Expected CalloutException for missing survey id');
        } catch (TAG_SurveyXactDatasetCalloutService.CalloutException e) {
            System.assert(e.getMessage().contains('survey id'), 'Message mentions survey id');
        }
        Test.stopTest();
    }

    @IsTest
    static void getRecentDatasetPerformsCallout() {
        Test.setMock(HttpCalloutMock.class, new MockResponse(200, 'respnokk;c_1\nABC;1\n'));
        TAG_SurveyXactDataset_Config__mdt config = new TAG_SurveyXactDataset_Config__mdt(
            SurveyId__c = '123456',
            LookbackDays__c = 3
        );

        Test.startTest();
        String body = TAG_SurveyXactDatasetCalloutService.getRecentDataset(config);
        Test.stopTest();

        System.assert(body.contains('ABC;1'), 'CSV body returned');
    }
}
