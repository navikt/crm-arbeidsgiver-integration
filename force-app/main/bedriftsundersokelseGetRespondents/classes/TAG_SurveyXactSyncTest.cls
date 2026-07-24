@IsTest
private class TAG_SurveyXactSyncTest {
    private static final String STATUS_COMPLETED = 'Gjennomført';
    private static final String STATUS_NOT_COMPLETED = 'Ikke gjennomført';
    private static final String STATUS_NEW = 'Ny';

    private static final String KEY_ANSWERED_BLANK = 'ANSWERED_BLANK';
    private static final String KEY_ANSWERED_IKKE = 'ANSWERED_IKKE';
    private static final String KEY_ANSWERED_DONE = 'ANSWERED_DONE';
    private static final String KEY_NOT_ANSWERED = 'NOT_ANSWERED';

    private static String buildXml() {
        return '<respondents>' +
            respondentNode(KEY_ANSWERED_BLANK, 'some answers') +
            respondentNode(KEY_ANSWERED_IKKE, 'partial') +
            respondentNode(KEY_ANSWERED_DONE, 'all answers') +
            respondentNode(KEY_NOT_ANSWERED, 'no answers') +
            '</respondents>';
    }

    private static String respondentNode(String externalKey, String collectStatus) {
        return '<respondent>' +
            '<externalkey>' +
            externalKey +
            '</externalkey>' +
            '<collectstatus>' +
            collectStatus +
            '</collectstatus>' +
            '</respondent>';
    }

    @TestSetup
    static void setup() {
        List<CustomCampaignMember__c> members = new List<CustomCampaignMember__c>{
            new CustomCampaignMember__c(Key__c = KEY_ANSWERED_BLANK),
            new CustomCampaignMember__c(Key__c = KEY_ANSWERED_IKKE, Status__c = STATUS_NOT_COMPLETED),
            new CustomCampaignMember__c(Key__c = KEY_ANSWERED_DONE, Status__c = STATUS_COMPLETED),
            new CustomCampaignMember__c(Key__c = KEY_NOT_ANSWERED, Status__c = STATUS_NOT_COMPLETED)
        };
        insert members;
    }

    @IsTest
    static void promotesOnlyEligibleAnsweredMembers() {
        Test.startTest();
        TAG_SurveyXactSync.SyncResult result = TAG_SurveyXactSync.syncFromXml(buildXml());
        Test.stopTest();

        System.assertEquals(4, result.respondentsParsed, 'All four respondents parsed');
        System.assertEquals(3, result.answeredRespondents, 'Three respondents have answered');
        System.assertEquals(2, result.membersUpdated, 'Only non-completed answered members updated');

        Map<String, CustomCampaignMember__c> byKey = keyMap();

        System.assertEquals(STATUS_COMPLETED, byKey.get(KEY_ANSWERED_BLANK).Status__c, 'Ny + answered -> Gjennomført');
        System.assertEquals(STATUS_COMPLETED, byKey.get(KEY_ANSWERED_IKKE).Status__c, 'Ikke + answered -> Gjennomført');
        System.assertEquals(STATUS_COMPLETED, byKey.get(KEY_ANSWERED_DONE).Status__c, 'Already done stays Gjennomført');
        System.assertEquals(STATUS_NOT_COMPLETED, byKey.get(KEY_NOT_ANSWERED).Status__c, 'Not answered left untouched');
    }

    @IsTest
    static void noAnsweredRespondentsDoesNothing() {
        String xml = '<respondents>' + respondentNode(KEY_ANSWERED_BLANK, 'no answers') + '</respondents>';

        Test.startTest();
        TAG_SurveyXactSync.SyncResult result = TAG_SurveyXactSync.syncFromXml(xml);
        Test.stopTest();

        System.assertEquals(0, result.answeredRespondents, 'No answered respondents');
        System.assertEquals(0, result.membersUpdated, 'Nothing updated');
        System.assertEquals(STATUS_NEW, keyMap().get(KEY_ANSWERED_BLANK).Status__c, 'Member remains at default Ny');
    }

    @IsTest
    static void runWithMockExecutesWithoutError() {
        Test.startTest();
        TAG_SurveyXactSync.SyncResult result = TAG_SurveyXactSync.runWithMock();
        Test.stopTest();

        System.assertNotEquals(null, result, 'Mock run returns a result');
        System.assertEquals(2, result.respondentsParsed, 'Mock XML has two respondents');
    }

    private static Map<String, CustomCampaignMember__c> keyMap() {
        Map<String, CustomCampaignMember__c> byKey = new Map<String, CustomCampaignMember__c>();
        for (CustomCampaignMember__c m : [SELECT Id, Key__c, Status__c FROM CustomCampaignMember__c]) {
            byKey.put(m.Key__c, m);
        }
        return byKey;
    }
}
