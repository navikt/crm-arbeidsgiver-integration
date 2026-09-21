@IsTest
private class TAG_SurveyXactDatasetSyncTest {
    private static final String STATUS_COMPLETED = 'Gjennomført';
    private static final String STATUS_NOT_COMPLETED = 'Ikke gjennomført';
    private static final String STATUS_NEW = 'Ny';

    private static final String KEY_DONE_BLANK = 'DONE_BLANK';
    private static final String KEY_DONE_IKKE = 'DONE_IKKE';
    private static final String KEY_DONE_ALREADY = 'DONE_ALREADY';
    private static final String KEY_NOT_DONE = 'NOT_DONE';

    private static final Integer CAMPAIGN_YEAR = Date.today().year();

    private static String buildCsv() {
        return 'survey;respnokk;c_1;offnavn\n' +
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
            ';2;Delta\n';
    }

    // Same rows, with the base questionnaire columns filled in.
    private static String buildCsvWithAnswers() {
        return 'survey;respnokk;c_1;ans_idag;ans_1aar;problem\n' +
            '123456;' +
            KEY_DONE_BLANK +
            ';1;12;1;3\n' +
            '123456;' +
            KEY_DONE_ALREADY +
            ';1;40;2;3\n' +
            '123456;' +
            KEY_NOT_DONE +
            ';2;5;1;3\n';
    }

    @TestSetup
    static void setup() {
        CustomCampaign__c campaign = new CustomCampaign__c(
            Name = 'BU ' + CAMPAIGN_YEAR + ' Test',
            Type__c = 'Bedriftsundersøkelse',
            StartDate__c = Date.newInstance(CAMPAIGN_YEAR, 1, 15)
        );
        insert campaign;

        insert new List<CustomCampaignMember__c>{
            new CustomCampaignMember__c(Key__c = KEY_DONE_BLANK, CustomCampaign__c = campaign.Id),
            new CustomCampaignMember__c(
                Key__c = KEY_DONE_IKKE,
                Status__c = STATUS_NOT_COMPLETED,
                CustomCampaign__c = campaign.Id
            ),
            new CustomCampaignMember__c(
                Key__c = KEY_DONE_ALREADY,
                Status__c = STATUS_COMPLETED,
                CustomCampaign__c = campaign.Id
            ),
            new CustomCampaignMember__c(
                Key__c = KEY_NOT_DONE,
                Status__c = STATUS_NOT_COMPLETED,
                CustomCampaign__c = campaign.Id
            )
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
        String csv = 'respnokk;c_1\n' + KEY_DONE_BLANK + ';2\n';

        Test.startTest();
        TAG_SurveyXactDatasetSync.SyncResult result = TAG_SurveyXactDatasetSync.syncFromCsv(csv);
        Test.stopTest();

        System.assertEquals(0, result.completedRespondents, 'No completed respondents');
        System.assertEquals(0, result.membersUpdated, 'Nothing updated');
        System.assertEquals(STATUS_NEW, keyMap().get(KEY_DONE_BLANK).Status__c, 'Member remains at default Ny');
    }

    @IsTest
    static void writesAnswersForCompletedRespondents() {
        Test.startTest();
        TAG_SurveyXactDatasetSync.SyncResult result = TAG_SurveyXactDatasetSync.syncFromCsv(buildCsvWithAnswers());
        Test.stopTest();

        System.assertEquals(2, result.answersWritten, 'Answers written for both completed respondents');

        Map<String, CustomCampaignMember__c> byKey = keyMap();
        System.assert(
            byKey.get(KEY_DONE_BLANK).TAG_BUAnswers__c.contains('Flere enn i dag'),
            'Answer text is stored on the member'
        );
        System.assert(
            byKey.get(KEY_DONE_ALREADY).TAG_BUAnswers__c.contains('Like mange som i dag'),
            'Already completed member still gets its answers'
        );
        System.assertEquals(null, byKey.get(KEY_NOT_DONE).TAG_BUAnswers__c, 'Not completed gets no answers');
    }

    @IsTest
    static void writesStructuredFieldsAndRawJson() {
        Test.startTest();
        TAG_SurveyXactDatasetSync.syncFromCsv(buildCsvWithAnswers());
        Test.stopTest();

        CustomCampaignMember__c member = keyMap().get(KEY_DONE_BLANK);
        System.assertEquals(12, member.TAG_BUEmployeesToday__c, 'Employee count is written to the number field');
        System.assertEquals(
            'Flere enn i dag',
            member.TAG_BUEmployeeOutlookOneYear__c,
            'Outlook is written to the picklist'
        );
        System.assertNotEquals(null, member.TAG_BUJSONAnswers__c, 'Raw response is stored as JSON');
        System.assert(member.TAG_BUJSONAnswers__c.startsWith('{'), 'Raw response is a JSON object');
    }

    @IsTest
    static void doesNotOverwriteExistingAnswers() {
        CustomCampaignMember__c member = [
            SELECT Id
            FROM CustomCampaignMember__c
            WHERE Key__c = :KEY_DONE_BLANK
            LIMIT 1
        ];
        member.TAG_BUAnswers__c = 'Lagret tidligere';
        update member;

        Test.startTest();
        TAG_SurveyXactDatasetSync.SyncResult result = TAG_SurveyXactDatasetSync.syncFromCsv(buildCsvWithAnswers());
        Test.stopTest();

        System.assertEquals(1, result.answersWritten, 'Only the member without answers is written to');
        System.assertEquals(
            'Lagret tidligere',
            keyMap().get(KEY_DONE_BLANK).TAG_BUAnswers__c,
            'Existing answers are kept'
        );
    }

    @IsTest
    static void completedWithoutAnswersIsNotUpdated() {
        Test.startTest();
        TAG_SurveyXactDatasetSync.SyncResult result = TAG_SurveyXactDatasetSync.syncFromCsv(buildCsv());
        Test.stopTest();

        System.assertEquals(0, result.answersWritten, 'Export without answer columns writes nothing');
        System.assertEquals(null, keyMap().get(KEY_DONE_ALREADY).TAG_BUAnswers__c, 'Field stays blank');
    }

    @IsTest
    static void leavesMemberFromEarlierYearUntouched() {
        // Same respondent key as this year, already completed but without
        // answers, which is how members synced before the answer fields existed
        // look.
        CustomCampaign__c earlier = new CustomCampaign__c(
            Name = 'BU ' + (CAMPAIGN_YEAR - 1) + ' Test',
            Type__c = 'Bedriftsundersøkelse',
            StartDate__c = Date.newInstance(CAMPAIGN_YEAR - 1, 1, 15)
        );
        insert earlier;
        insert new CustomCampaignMember__c(
            Key__c = KEY_DONE_BLANK,
            Status__c = STATUS_COMPLETED,
            CustomCampaign__c = earlier.Id
        );

        Test.startTest();
        TAG_SurveyXactDatasetSync.SyncResult result = TAG_SurveyXactDatasetSync.syncFromCsv(buildCsvWithAnswers());
        Test.stopTest();

        System.assertEquals(2, result.answersWritten, 'Only this year\'s members get answers');

        CustomCampaignMember__c earlierMember = [
            SELECT TAG_BUAnswers__c, TAG_BUEmployeesToday__c
            FROM CustomCampaignMember__c
            WHERE CustomCampaign__c = :earlier.Id
            LIMIT 1
        ];
        System.assertEquals(null, earlierMember.TAG_BUAnswers__c, 'Member from an earlier year keeps no answers');
        System.assertEquals(null, earlierMember.TAG_BUEmployeesToday__c, 'No structured fields either');
    }

    private static Map<String, CustomCampaignMember__c> keyMap() {
        Map<String, CustomCampaignMember__c> byKey = new Map<String, CustomCampaignMember__c>();
        for (CustomCampaignMember__c m : [
            SELECT
                Id,
                Key__c,
                Status__c,
                TAG_BUAnswers__c,
                TAG_BUJSONAnswers__c,
                TAG_BUEmployeesToday__c,
                TAG_BUEmployeeOutlookOneYear__c
            FROM CustomCampaignMember__c
        ]) {
            byKey.put(m.Key__c, m);
        }
        return byKey;
    }
}
