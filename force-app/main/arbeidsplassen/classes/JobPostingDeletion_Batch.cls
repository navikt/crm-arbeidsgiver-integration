public class JobPostingDeletion_Batch implements Database.Batchable<SObject> {
    private static final String JOB_POSTING_QUERY = 'SELECT Id FROM JobPosting__c WHERE Status__c = \'REJECTED\' OR Status__c = \'DELETED\' OR (Status__c = \'STOPPED\' AND TAG_EmploymentPlacement__c = false)';

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(JOB_POSTING_QUERY);
    }

    public void execute(Database.BatchableContext BC, List<JobPosting__c> records) {
        delete records;
    }

    public void finish(Database.BatchableContext BC) {
        return;
    }
}
