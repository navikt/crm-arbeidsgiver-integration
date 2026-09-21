/**
 * Starts the yearly campaign member import. Runs once - at most twice - a year,
 * when the respondents are ready in SurveyXact.
 *
 * Schedule from Execute Anonymous, for example 1 February at 02:00:
 *   System.schedule('SurveyXact Member Import',
 *       '0 0 2 1 2 ?', new TAG_SurveyXactMemberImportScheduler());
 *
 * Remember to delete the scheduled job afterwards - it is not meant to keep
 * running.
 */
public with sharing class TAG_SurveyXactMemberImportScheduler implements Schedulable {
    public void execute(SchedulableContext context) {
        System.enqueueJob(new TAG_SurveyXactMemberImportQueueable());
    }
}
