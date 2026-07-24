/**
 * Schedulable that enqueues the SurveyXact dataset sync. Intended to run once
 * daily in the evening during the survey period.
 *
 * Schedule from Execute Anonymous, for example at 22:00 every day:
 *   System.schedule('SurveyXact Dataset Sync',
 *       '0 0 22 * * ?', new TAG_SurveyXactDatasetScheduler());
 */
public with sharing class TAG_SurveyXactDatasetScheduler implements Schedulable {
    public void execute(SchedulableContext context) {
        System.enqueueJob(new TAG_SurveyXactDatasetSyncQueueable());
    }
}
