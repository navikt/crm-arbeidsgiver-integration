@IsTest
private class TAG_SurveyXactRegionCalloutServiceTest {
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
    static void buildExpressionCombinesPtype1AndRegion() {
        String expr = TAG_SurveyXactRegionCalloutService.buildExpression('390264940', '01 Østfold');

        System.assertEquals(
            '[background/ptype1]=390264940 and [background/ptype2t]="01 Østfold"',
            expr,
            'Combines survey year and region'
        );
    }

    @IsTest
    static void buildExpressionOmitsBlankPtype1() {
        String expr = TAG_SurveyXactRegionCalloutService.buildExpression('  ', '03 Oslo');

        System.assertEquals('[background/ptype2t]="03 Oslo"', expr, 'Only the region clause remains');
    }

    @IsTest
    static void regionsCoverEveryFylke() {
        System.assertEquals(17, TAG_SurveyXactRegionCalloutService.REGIONS.size(), 'All ptype2t values are listed');
        System.assertEquals(
            '01 Østfold',
            TAG_SurveyXactRegionCalloutService.REGIONS[0],
            'The chain starts at the first fylke'
        );
    }

    @IsTest
    static void buildEndpointEncodesExpression() {
        String endpoint = TAG_SurveyXactRegionCalloutService.buildEndpoint(
            '123456',
            '[background/ptype1]=390264940 and [background/ptype2t]="01 Østfold"'
        );

        System.assert(
            endpoint.startsWith('callout:SurveyXact/surveys/123456/export/dataset'),
            'Uses named credential and path'
        );
        System.assert(endpoint.contains('format=EU'), 'Includes format');
        System.assert(endpoint.contains('expression=%5Bbackground'), 'Expression is URL encoded');
        System.assert(!endpoint.contains('expression=[background'), 'Raw brackets are not present');
    }

    @IsTest
    static void getRegionDatasetPerformsCallout() {
        Test.setMock(HttpCalloutMock.class, new MockResponse(200, 'respnokk;bedrnr\nABC;123456789\n'));
        TAG_SurveyXactDataset_Config__mdt config = new TAG_SurveyXactDataset_Config__mdt(
            SurveyId__c = '123456',
            Ptype1__c = '390264940'
        );

        Test.startTest();
        String body = TAG_SurveyXactRegionCalloutService.getRegionDataset(config, '01 Østfold');
        Test.stopTest();

        System.assert(body.contains('ABC;123456789'), 'CSV body returned');
    }

    @IsTest
    static void getRegionDatasetThrowsWhenSurveyIdMissing() {
        TAG_SurveyXactDataset_Config__mdt config = new TAG_SurveyXactDataset_Config__mdt(Ptype1__c = '390264940');

        Test.startTest();
        try {
            TAG_SurveyXactRegionCalloutService.getRegionDataset(config, '01 Østfold');
            System.assert(false, 'Expected CalloutException for missing survey id');
        } catch (TAG_SurveyXactRegionCalloutService.CalloutException e) {
            System.assert(e.getMessage().contains('survey id'), 'Message mentions survey id');
        }
        Test.stopTest();
    }

    @IsTest
    static void getDatasetThrowsOnNon200() {
        Test.setMock(HttpCalloutMock.class, new MockResponse(500, 'error'));

        Test.startTest();
        try {
            TAG_SurveyXactRegionCalloutService.getDataset('123456', '[background/ptype2t]="01 Østfold"');
            System.assert(false, 'Expected CalloutException');
        } catch (TAG_SurveyXactRegionCalloutService.CalloutException e) {
            System.assert(e.getMessage().contains('500'), 'Message mentions status code');
        }
        Test.stopTest();
    }
}
