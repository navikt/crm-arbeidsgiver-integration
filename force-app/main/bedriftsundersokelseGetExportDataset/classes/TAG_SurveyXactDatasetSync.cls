/**
 * Updates CustomCampaignMember__c records from a SurveyXact dataset CSV export.
 * A respondent counts as completed when the 'response' column equals '1'. Such
 * members are promoted to 'Gjennomført'. Any member that is not already
 * 'Gjennomført' is eligible; members that have not completed, or that are
 * already 'Gjennomført', are left untouched. Running repeatedly is safe (idempotent).
 */
public with sharing class TAG_SurveyXactDatasetSync {
    // Value of the 'response' column that means the respondent completed the survey.
    @TestVisible
    private static final String RESPONSE_COMPLETED = '1';

    // Status set on members whose respondent has completed. Held as a constant because
    // CustomCampaignMember__c lives in a dependency package.
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
    public static SyncResult syncFromCsv(String csvBody) {
        SyncResult result = new SyncResult();

        List<TAG_SurveyXactDatasetParser.Row> rows = TAG_SurveyXactDatasetParser.parse(csvBody);
        result.rowsParsed = rows.size();

        Set<String> completedKeys = new Set<String>();
        for (TAG_SurveyXactDatasetParser.Row row : rows) {
            if (RESPONSE_COMPLETED.equals(row.responseStatus) && String.isNotBlank(row.externalKey)) {
                completedKeys.add(row.externalKey);
            }
        }
        result.completedRespondents = completedKeys.size();

        if (completedKeys.isEmpty()) {
            return result;
        }

        List<CustomCampaignMember__c> toUpdate = new List<CustomCampaignMember__c>();
        for (CustomCampaignMember__c member : [
            SELECT Id, Status__c
            FROM CustomCampaignMember__c
            WHERE Key__c IN :completedKeys AND (Status__c = NULL OR Status__c != :STATUS_COMPLETED)
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
