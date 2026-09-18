/**
 * Updates CustomCampaignMember__c records from a SurveyXact dataset CSV export.
 * A respondent counts as completed when the 'c_1' column equals '1'. Such
 * members are promoted to 'Gjennomført' and get their answers written to the
 * TAG_BU fields. Answers are only written while TAG_BUAnswers__c is blank, so a
 * respondent who edits their reply later does not overwrite what was stored.
 * Running repeatedly is safe (idempotent).
 *
 * Only members on a campaign that starts in the survey year are touched. A
 * respondent key can appear again in a later survey, and without that guard the
 * answers would also be written to the member from the earlier year.
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
        public Integer answersWritten = 0;

        // Answer codes that are not in the codebook, as 'column=code'.
        public List<String> unknownValues = new List<String>();

        public override String toString() {
            return 'SurveyXact dataset sync: rowsParsed=' +
                rowsParsed +
                ', completed=' +
                completedRespondents +
                ', membersUpdated=' +
                membersUpdated +
                ', answersWritten=' +
                answersWritten;
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

        Map<String, TAG_SurveyXactDatasetParser.Row> completedRows = new Map<String, TAG_SurveyXactDatasetParser.Row>();
        for (TAG_SurveyXactDatasetParser.Row row : rows) {
            if (COMPLETED_CODE.equals(row.completionStatus) && String.isNotBlank(row.externalKey)) {
                completedRows.put(row.externalKey, row);
            }
        }
        result.completedRespondents = completedRows.size();

        if (completedRows.isEmpty()) {
            return result;
        }

        Set<String> completedKeys = completedRows.keySet();
        Date yearStart = Date.newInstance(campaignYear, 1, 1);
        Date yearEnd = Date.newInstance(campaignYear, 12, 31);
        List<CustomCampaignMember__c> toUpdate = new List<CustomCampaignMember__c>();

        // TAG_BUAnswers__c is a long text area and cannot be filtered in SOQL,
        // so members already holding answers are skipped in the loop instead.
        for (CustomCampaignMember__c member : [
            SELECT Id, Key__c, Status__c, TAG_BUAnswers__c
            FROM CustomCampaignMember__c
            WHERE
                Key__c IN :completedKeys
                AND CustomCampaign__r.StartDate__c >= :yearStart
                AND CustomCampaign__r.StartDate__c <= :yearEnd
        ]) {
            Boolean changed = false;

            if (!STATUS_COMPLETED.equals(member.Status__c)) {
                member.Status__c = STATUS_COMPLETED;
                changed = true;
            }

            if (
                String.isBlank(member.TAG_BUAnswers__c) &&
                applyAnswers(member, completedRows.get(member.Key__c), result)
            ) {
                result.answersWritten++;
                changed = true;
            }

            if (changed) {
                toUpdate.add(member);
            }
        }

        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }
        result.membersUpdated = toUpdate.size();

        return result;
    }

    // Returns true when the row held answers that were written to the member.
    private static Boolean applyAnswers(
        CustomCampaignMember__c member,
        TAG_SurveyXactDatasetParser.Row row,
        SyncResult result
    ) {
        if (row == null) {
            return false;
        }

        TAG_SurveyXactAnswerFormatter.Answers answers = TAG_SurveyXactAnswerFormatter.build(
            row.values,
            result.unknownValues
        );
        if (answers.isEmpty()) {
            return false;
        }

        member.TAG_BUAnswers__c = answers.answers;
        member.TAG_BUJSONAnswers__c = answers.rawJson;
        member.TAG_BUEmployeesToday__c = answers.employeesToday;
        member.TAG_BUEmployeeOutlookOneYear__c = answers.employeeOutlookOneYear;
        member.TAG_BUFailedRecruitment__c = answers.failedRecruitment;
        member.TAG_BUFailedRecruitmentCause__c = answers.failedRecruitmentCause;
        member.TAG_BUUnfilledPositions__c = answers.unfilledPositions;
        member.TAG_BUAiUsage__c = answers.aiUsage;
        member.TAG_BUAiNotUsedReason__c = answers.aiNotUsedReason;
        return true;
    }
}
