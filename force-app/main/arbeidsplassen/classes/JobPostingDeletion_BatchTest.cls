@isTest
public with sharing class JobPostingDeletion_BatchTest {
    @isTest
    static void executeBatch() {
        JobPosting__c activeJobPosting = new JobPosting__c(Status__c = 'ACTIVE');

        JobPosting__c inactiveJobPosting = new JobPosting__c(Status__c = 'INACTIVE');

        JobPosting__c stoppedJobPosting = new JobPosting__c(Status__c = 'STOPPED');

        JobPosting__c deletedJobPosting = new JobPosting__c(Status__c = 'DELETED');

        JobPosting__c rejectedJobPosting = new JobPosting__c(Status__c = 'REJECTED');

        List<JobPosting__c> jobPostings = new List<JobPosting__c>{
            activeJobPosting,
            inactiveJobPosting,
            stoppedJobPosting,
            deletedJobPosting,
            rejectedJobPosting
        };

        insert jobPostings;

        Test.startTest();
        JobPostingDeletion_Batch btch = new JobPostingDeletion_Batch();
        Database.executeBatch(btch, 2000);
        Test.stopTest();

        List<JobPosting__c> updatedJobPostings = [SELECT Id FROM JobPosting__c];

        System.assertEquals(2, updatedJobPostings.size(), 'All job postings deleted except for active and inactive');
    }
}
