@IsTest
private class TAG_SurveyXactDatasetSyncTest {
    private static final String STATUS_COMPLETED = 'Gjennomført';
    private static final String STATUS_NOT_COMPLETED = 'Ikke gjennomført';
    private static final String STATUS_NEW = 'Ny';

    private static final String KEY_DONE_BLANK = 'DONE_BLANK';
    private static final String KEY_DONE_IKKE = 'DONE_IKKE';
    private static final String KEY_DONE_ALREADY = 'DONE_ALREADY';
    private static final String KEY_NOT_DONE = 'NOT_DONE';

    private static String buildCsv() {
        return 'survey;respnokk;response;offnavn\n' +
            '123456;' +
            KEY_DONE_BLANK +
            ';1;Acme\n' +
            '123456;' +
            KEY_DONE_IKKE +
            ';1;Beta\n' +
            '123456;' +
            KEY_DONE_ALREADY +
            ';1;Gamma\n' +
            '123456;' +
            KEY_NOT_DONE +
            ';0;Delta\n';
    }

    @TestSetup
    static void setup() {
        insert new List<CustomCampaignMember__c>{
            new CustomCampaignMember__c(Key__c = KEY_DONE_BLANK),
            new CustomCampaignMember__c(Key__c = KEY_DONE_IKKE, Status__c = STATUS_NOT_COMPLETED),
            new CustomCampaignMember__c(Key__c = KEY_DONE_ALREADY, Status__c = STATUS_COMPLETED),
            new CustomCampaignMember__c(Key__c = KEY_NOT_DONE, Status__c = STATUS_NOT_COMPLETED)
        };
    }

    @IsTest
    static void promotesOnlyEligibleCompletedMembers() {
        Test.startTest();
        TAG_SurveyXactDatasetSync.SyncResult result = TAG_SurveyXactDatasetSync.syncFromCsv(buildCsv());
        Test.stopTest();

        System.assertEquals(4, result.rowsParsed, 'Four data rows parsed');
        System.assertEquals(3, result.completedRespondents, 'Three respondents completed');
        System.assertEquals(2, result.membersUpdated, 'Only non-completed completed members updated');

        Map<String, CustomCampaignMember__c> byKey = keyMap();
        System.assertEquals(STATUS_COMPLETED, byKey.get(KEY_DONE_BLANK).Status__c, 'Ny + completed -> Gjennomført');
        System.assertEquals(STATUS_COMPLETED, byKey.get(KEY_DONE_IKKE).Status__c, 'Ikke + completed -> Gjennomført');
        System.assertEquals(STATUS_COMPLETED, byKey.get(KEY_DONE_ALREADY).Status__c, 'Already done stays Gjennomført');
        System.assertEquals(STATUS_NOT_COMPLETED, byKey.get(KEY_NOT_DONE).Status__c, 'Not completed left untouched');
    }

    @IsTest
    static void noCompletedRespondentsDoesNothing() {
        String csv = 'respnokk;response\n' + KEY_DONE_BLANK + ';0\n';

        Test.startTest();
        TAG_SurveyXactDatasetSync.SyncResult result = TAG_SurveyXactDatasetSync.syncFromCsv(csv);
        Test.stopTest();

        System.assertEquals(0, result.completedRespondents, 'No completed respondents');
        System.assertEquals(0, result.membersUpdated, 'Nothing updated');
        System.assertEquals(STATUS_NEW, keyMap().get(KEY_DONE_BLANK).Status__c, 'Member remains at default Ny');
    }

    private static Map<String, CustomCampaignMember__c> keyMap() {
        Map<String, CustomCampaignMember__c> byKey = new Map<String, CustomCampaignMember__c>();
        for (CustomCampaignMember__c m : [SELECT Id, Key__c, Status__c FROM CustomCampaignMember__c]) {
            byKey.put(m.Key__c, m);
        }
        return byKey;
    }
}
