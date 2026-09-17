/**
 * Updates CustomCampaignMember__c statuses from a SurveyXact dataset CSV export.
 * A respondent counts as completed when the 'c_1' column equals '1', and such
 * members are promoted to 'Gjennomført'. Running repeatedly is safe (idempotent).
 *
 * Only members on a campaign that starts in the survey year are touched. A
 * respondent key can appear again in a later survey, and without that guard an
 * earlier year's member would be updated too.
 *
 * Storing the respondents' answers is built but parked, see
 * parked/bedriftsundersokelse-questions/REACTIVATION.md.
 */
public with sharing class TAG_SurveyXactDatasetSync {
    // Value of the 'c_1' column that means the respondent completed the survey.
    // 2 = ikke gjennomført and 3 = frafalt/konkurs are ignored.
    @TestVisible
    private static final String COMPLETED_CODE = '1';

    @TestVisible
    private static final String STATUS_COMPLETED = 'Gjennomført';

    public class SyncResult {
        public Integer rowsParsed = 0;
        public Integer completedRespondents = 0;
        public Integer membersUpdated = 0;

        public override String toString() {
            return 'SurveyXact dataset sync: rowsParsed=' +
                rowsParsed +
                ', completed=' +
                completedRespondents +
                ', membersUpdated=' +
                membersUpdated;
        }
    }

    // Parses the dataset CSV and promotes matching members to 'Gjennomført'.
    // The survey runs early in the year the campaigns belong to.
    public static SyncResult syncFromCsv(String csvBody) {
        return syncFromCsv(csvBody, Date.today().year());
    }

    public static SyncResult syncFromCsv(String csvBody, Integer campaignYear) {
        SyncResult result = new SyncResult();

        List<TAG_SurveyXactDatasetParser.Row> rows = TAG_SurveyXactDatasetParser.parse(csvBody);
        result.rowsParsed = rows.size();

        Set<String> completedKeys = new Set<String>();
        for (TAG_SurveyXactDatasetParser.Row row : rows) {
            if (COMPLETED_CODE.equals(row.completionStatus) && String.isNotBlank(row.externalKey)) {
                completedKeys.add(row.externalKey);
            }
        }
        result.completedRespondents = completedKeys.size();

        if (completedKeys.isEmpty()) {
            return result;
        }

        Date yearStart = Date.newInstance(campaignYear, 1, 1);
        Date yearEnd = Date.newInstance(campaignYear, 12, 31);

        List<CustomCampaignMember__c> toUpdate = new List<CustomCampaignMember__c>();
        for (CustomCampaignMember__c member : [
            SELECT Id, Key__c, Status__c
            FROM CustomCampaignMember__c
            WHERE
                Key__c IN :completedKeys
                AND Status__c != :STATUS_COMPLETED
                AND CustomCampaign__r.StartDate__c >= :yearStart
                AND CustomCampaign__r.StartDate__c <= :yearEnd
        ]) {
            member.Status__c = STATUS_COMPLETED;
            toUpdate.add(member);
        }

        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }
        result.membersUpdated = toUpdate.size();

        return result;
    }
}
