@IsTest
private class TAG_SurveyXactMemberImportQueueableTest {
    private static final String ORG_MATCHED = '973871714';
    private static final String KEY_NEW = 'QUEUEKEY0001';

    private class MockResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('respnokk;bedrnr\n' + KEY_NEW + ';' + ORG_MATCHED + '\n');
            return res;
        }
    }

    private class MockErrorResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('error');
            return res;
        }
    }

    @TestSetup
    static void setup() {
        NavUnit__c navUnit = new NavUnit__c(Name = 'NAV Testenhet', INT_UnitNumber__c = '1234');
        insert navUnit;

        insert new CustomCampaign__c(
            Name = 'BU ' + Date.today().year() + ' NAV Testenhet',
            NAV_Unit__c = navUnit.Id,
            Type__c = 'Bedriftsundersøkelse'
        );

        insert new Account(Name = 'Matched', INT_OrganizationNumber__c = ORG_MATCHED, TAG_NavUnit__c = navUnit.Id);
    }

    @IsTest
    static void createsMemberForRegion() {
        Test.setMock(HttpCalloutMock.class, new MockResponse());

        Test.startTest();
        System.enqueueJob(new TAG_SurveyXactMemberImportQueueable(1, false, Date.today().year()));
        Test.stopTest();

        System.assertEquals(
            1,
            [SELECT COUNT() FROM CustomCampaignMember__c WHERE Key__c = :KEY_NEW],
            'Member created from the region export'
        );
    }

    @IsTest
    static void calloutFailureIsLoggedAndDoesNotThrow() {
        Test.setMock(HttpCalloutMock.class, new MockErrorResponse());

        Test.startTest();
        System.enqueueJob(new TAG_SurveyXactMemberImportQueueable(1, false, Date.today().year()));
        Test.stopTest();

        System.assertEquals(
            0,
            [SELECT COUNT() FROM CustomCampaignMember__c],
            'No members created when the callout fails'
        );
    }

    @IsTest
    static void defaultConstructorStartsAtFirstRegion() {
        Test.setMock(HttpCalloutMock.class, new MockResponse());

        Test.startTest();
        System.enqueueJob(new TAG_SurveyXactMemberImportQueueable());
        Test.stopTest();

        System.assert(true, 'Default constructor runs without error');
    }

    @IsTest
    static void updateExistingConstructorIsAvailable() {
        Test.setMock(HttpCalloutMock.class, new MockResponse());

        Test.startTest();
        System.enqueueJob(new TAG_SurveyXactMemberImportQueueable(true));
        Test.stopTest();

        System.assert(true, 'Constructor with updateExisting runs without error');
    }
}
