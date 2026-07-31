@IsTest
private class TAG_SurveyXactMemberImportServiceTest {
    private static final String ORG_MATCHED = '973871714';
    private static final String ORG_NO_NAV_UNIT = '928366561';
    private static final String ORG_UNKNOWN = '999999999';

    private static final String KEY_NEW = 'KEYNEW000001';
    private static final String KEY_EXISTING = 'KEYEXISTING1';
    private static final String KEY_NO_ACCOUNT = 'KEYNOACCOUNT';
    private static final String KEY_NO_NAV_UNIT = 'KEYNONAVUNIT';

    private static Integer campaignYear {
        get {
            return Date.today().year();
        }
    }

    @TestSetup
    static void setup() {
        NavUnit__c navUnit = new NavUnit__c(Name = 'NAV Testenhet', INT_UnitNumber__c = '1234');
        insert navUnit;

        insert new CustomCampaign__c(Name = 'BU ' + Date.today().year() + ' NAV Testenhet', NAV_Unit__c = navUnit.Id);

        insert new List<Account>{
            new Account(Name = 'Matched', INT_OrganizationNumber__c = ORG_MATCHED, TAG_NavUnit__c = navUnit.Id),
            new Account(Name = 'No nav unit', INT_OrganizationNumber__c = ORG_NO_NAV_UNIT)
        };
    }

    @IsTest
    static void createsMemberForMatchedRespondent() {
        String csv = 'respnokk;bedrnr\n' + KEY_NEW + ';' + ORG_MATCHED + '\n';
        List<String> skipReasons = new List<String>();

        Test.startTest();
        TAG_SurveyXactMemberImportService.ImportResult result = TAG_SurveyXactMemberImportService.importFromCsv(
            csv,
            campaignYear,
            false,
            skipReasons
        );
        Test.stopTest();

        System.assertEquals(1, result.respondentsParsed, 'One respondent parsed');
        System.assertEquals(1, result.membersCreated, 'One member created');
        System.assertEquals(0, result.totalSkipped(), 'Nothing skipped');

        CustomCampaignMember__c member = [
            SELECT Key__c, Status__c, Campaign_type__c, Account__c, CustomCampaign__c, NAV_Unit__c
            FROM CustomCampaignMember__c
            WHERE Key__c = :KEY_NEW
        ];
        System.assertEquals('Ikke gjennomført', member.Status__c, 'Status is Ikke gjennomført');
        System.assertEquals('Bedriftsundersøkelse', member.Campaign_type__c, 'Campaign type is set');
        System.assertNotEquals(null, member.Account__c, 'Account is linked');
        System.assertNotEquals(null, member.CustomCampaign__c, 'Campaign is linked');
        System.assertNotEquals(null, member.NAV_Unit__c, 'NAV unit is set');
    }

    @IsTest
    static void skipsRespondentWithoutAccount() {
        String csv = 'respnokk;bedrnr\n' + KEY_NO_ACCOUNT + ';' + ORG_UNKNOWN + '\n';
        List<String> skipReasons = new List<String>();

        Test.startTest();
        TAG_SurveyXactMemberImportService.ImportResult result = TAG_SurveyXactMemberImportService.importFromCsv(
            csv,
            campaignYear,
            false,
            skipReasons
        );
        Test.stopTest();

        System.assertEquals(0, result.membersCreated, 'No member created');
        System.assertEquals(1, result.skippedNoAccount, 'Counted as missing account');
        System.assertEquals(1, skipReasons.size(), 'One skip reason logged');
        System.assert(skipReasons[0].contains(ORG_UNKNOWN), 'Reason names the organisation number');
    }

    @IsTest
    static void skipsAccountWithoutNavUnit() {
        String csv = 'respnokk;bedrnr\n' + KEY_NO_NAV_UNIT + ';' + ORG_NO_NAV_UNIT + '\n';
        List<String> skipReasons = new List<String>();

        Test.startTest();
        TAG_SurveyXactMemberImportService.ImportResult result = TAG_SurveyXactMemberImportService.importFromCsv(
            csv,
            campaignYear,
            false,
            skipReasons
        );
        Test.stopTest();

        System.assertEquals(0, result.membersCreated, 'No member created');
        System.assertEquals(1, result.skippedNoNavUnit, 'Counted as missing NAV unit');
    }

    @IsTest
    static void skipsExistingMemberByDefault() {
        String csv = 'respnokk;bedrnr\n' + KEY_EXISTING + ';' + ORG_MATCHED + '\n';
        List<String> skipReasons = new List<String>();

        insert new CustomCampaignMember__c(Key__c = KEY_EXISTING);

        Test.startTest();
        TAG_SurveyXactMemberImportService.ImportResult result = TAG_SurveyXactMemberImportService.importFromCsv(
            csv,
            campaignYear,
            false,
            skipReasons
        );
        Test.stopTest();

        System.assertEquals(0, result.membersCreated, 'No duplicate created');
        System.assertEquals(1, result.skippedExisting, 'Counted as already existing');
        System.assertEquals(
            1,
            [SELECT COUNT() FROM CustomCampaignMember__c WHERE Key__c = :KEY_EXISTING],
            'Still only one member with that key'
        );
    }

    @IsTest
    static void skipsRowWithoutKeyOrOrganizationNumber() {
        String csv = 'respnokk;bedrnr\n' + ';' + ORG_MATCHED + '\n' + KEY_NEW + ';\n';
        List<String> skipReasons = new List<String>();

        Test.startTest();
        TAG_SurveyXactMemberImportService.ImportResult result = TAG_SurveyXactMemberImportService.importFromCsv(
            csv,
            campaignYear,
            false,
            skipReasons
        );
        Test.stopTest();

        System.assertEquals(0, result.membersCreated, 'No member created');
        System.assertEquals(2, result.skippedInvalidRow, 'Both rows counted as invalid');
    }

    @IsTest
    static void skipsWhenNoCampaignForYear() {
        String csv = 'respnokk;bedrnr\n' + KEY_NEW + ';' + ORG_MATCHED + '\n';
        List<String> skipReasons = new List<String>();

        Test.startTest();
        TAG_SurveyXactMemberImportService.ImportResult result = TAG_SurveyXactMemberImportService.importFromCsv(
            csv,
            campaignYear + 5,
            false,
            skipReasons
        );
        Test.stopTest();

        System.assertEquals(0, result.membersCreated, 'No member created');
        System.assertEquals(1, result.skippedNoCampaign, 'Counted as missing campaign');
    }

    @IsTest
    static void handlesEmptyExport() {
        List<String> skipReasons = new List<String>();

        Test.startTest();
        TAG_SurveyXactMemberImportService.ImportResult result = TAG_SurveyXactMemberImportService.importFromCsv(
            'respnokk;bedrnr\n',
            campaignYear,
            false,
            skipReasons
        );
        Test.stopTest();

        System.assertEquals(0, result.respondentsParsed, 'No respondents parsed');
        System.assertEquals(0, result.membersCreated, 'Nothing created');
    }

    @IsTest
    static void createsMembersInBulk() {
        List<String> lines = new List<String>{ 'respnokk;bedrnr' };
        for (Integer i = 0; i < 200; i++) {
            lines.add('BULKKEY' + String.valueOf(i).leftPad(5, '0') + ';' + ORG_MATCHED);
        }
        List<String> skipReasons = new List<String>();

        Test.startTest();
        TAG_SurveyXactMemberImportService.ImportResult result = TAG_SurveyXactMemberImportService.importFromCsv(
            String.join(lines, '\n'),
            campaignYear,
            false,
            skipReasons
        );
        Test.stopTest();

        System.assertEquals(200, result.membersCreated, 'All members created in one DML statement');
    }
}
