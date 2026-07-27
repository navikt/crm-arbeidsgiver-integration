/**
 * Updates CustomCampaignMember__c records based on SurveyXact respondent status.
 * Promotes a member to 'Gjennomført' when the respondent has answered
 * (collect status is anything other than 'no answers'). Any member that is not
 * already 'Gjennomført' is eligible; members that have not answered, or that are
 * already 'Gjennomført', are left untouched.
 * !! TODO: when confirmed responce when status "asnwered", change logic to update only
 * when <collectstatus> is 'answered' (not just any no-answers value)
 * !! TODO2: This is just a mockup class, to be replaced with the real implementation when
 * the GET Respondents endpoint is confirmed to be used- callout service remains to be implemented.
 */
public with sharing class TAG_SurveyXactSync {
    @TestVisible
    private static final String STATUS_COMPLETED = 'Gjennomført';

    // Sample respondents XML used by runWithMock() for local verification.
    @TestVisible
    private static final String MOCK_RESPONDENTS_XML =
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
        '<respondents>' +
        '  <respondent>' +
        '    <id>42</id>' +
        '    <externalkey>ABCDEFGH1234</externalkey>' +
        '    <collectstatus>no answers</collectstatus>' +
        '  </respondent>' +
        '  <respondent>' +
        '    <id>43</id>' +
        '    <externalkey>ABCDEFGH2345</externalkey>' +
        '    <collectstatus>some answers</collectstatus>' +
        '  </respondent>' +
        '</respondents>';

    // Summary of a sync run.
    public class SyncResult {
        public Integer respondentsParsed = 0;
        public Integer answeredRespondents = 0;
        public Integer membersUpdated = 0;

        public override String toString() {
            return 'SurveyXact sync: parsed=' +
                respondentsParsed +
                ', answered=' +
                answeredRespondents +
                ', membersUpdated=' +
                membersUpdated;
        }
    }

    // Runs the sync against the built-in sample XML, performing real DML.
    public static SyncResult runWithMock() {
        return syncFromXml(MOCK_RESPONDENTS_XML);
    }

    // Parses the respondents XML and promotes matching members to 'Gjennomført'.
    public static SyncResult syncFromXml(String xmlBody) {
        SyncResult result = new SyncResult();

        List<TAG_SurveyXactRespondentParser.Respondent> respondents = TAG_SurveyXactRespondentParser.parse(xmlBody);
        result.respondentsParsed = respondents.size();

        Set<String> answeredKeys = new Set<String>();
        for (TAG_SurveyXactRespondentParser.Respondent r : respondents) {
            if (r.hasAnswered()) {
                answeredKeys.add(r.externalKey);
            }
        }
        result.answeredRespondents = answeredKeys.size();

        if (answeredKeys.isEmpty()) {
            return result;
        }

        List<CustomCampaignMember__c> toUpdate = new List<CustomCampaignMember__c>();
        for (CustomCampaignMember__c member : [
            SELECT Id, Status__c
            FROM CustomCampaignMember__c
            WHERE Key__c IN :answeredKeys AND (Status__c = NULL OR Status__c != :STATUS_COMPLETED)
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
