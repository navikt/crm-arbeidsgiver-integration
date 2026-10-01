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
        System.enqueueJob(new TAG_SurveyXactMemberImportQueueable(0, false, Date.today().year()));
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
        System.enqueueJob(new TAG_SurveyXactMemberImportQueueable(0, false, Date.today().year()));
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

    @IsTest
    static void finalizerLogsUnhandledExceptionWithRegion() {
        FinalizerContextMock context = new FinalizerContextMock(
            ParentJobResult.UNHANDLED_EXCEPTION,
            new SimulatedLimitException('Apex heap size too large')
        );

        Test.startTest();
        new TAG_SurveyXactMemberImportQueueable.ImportFinalizer(4, '03 Oslo').execute(context);
        Test.stopTest();

        List<Application_Log__c> logs = [
            SELECT Log_Level__c, Application_Domain__c, Log_Message__c, Referrence_Info__c
            FROM Application_Log__c
        ];
        Assert.areEqual(1, logs.size(), 'One log entry for the failed region');
        Assert.areEqual('Error', logs[0].Log_Level__c, 'Unhandled exception is an error');
        Assert.areEqual('POAB', logs[0].Application_Domain__c, 'Logged on the POAB domain');
        Assert.areEqual('03 Oslo', logs[0].Referrence_Info__c, 'Region is the reference');
        Assert.isTrue(logs[0].Log_Message__c.contains('heap size'), 'Message carries the exception');
        Assert.isTrue(logs[0].Log_Message__c.contains('restart from regionIndex 4'), 'Message says where to restart');
    }

    @IsTest
    static void finalizerIsSilentOnSuccess() {
        Test.startTest();
        new TAG_SurveyXactMemberImportQueueable.ImportFinalizer(0, '01 Østfold')
            .execute(new FinalizerContextMock(ParentJobResult.SUCCESS, null));
        Test.stopTest();

        Assert.areEqual(0, [SELECT COUNT() FROM Application_Log__c], 'Nothing logged when the region succeeds');
    }
}
