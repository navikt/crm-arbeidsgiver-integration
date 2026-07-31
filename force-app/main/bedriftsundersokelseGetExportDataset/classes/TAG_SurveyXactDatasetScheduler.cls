/**
 * Schedulable that enqueues the SurveyXact dataset sync. Intended to run once
 * per hour during the survey period.
 *
 * Schedule from Execute Anonymous, for example hourly between 07:00 and 17:00:
 *   System.schedule('SurveyXact Dataset Sync',
 *       '0 0 7-17 * * ?', new TAG_SurveyXactDatasetScheduler());
 */
public with sharing class TAG_SurveyXactDatasetScheduler implements Schedulable {
    public void execute(SchedulableContext context) {
        System.enqueueJob(new TAG_SurveyXactDatasetSyncQueueable());
    }
}
