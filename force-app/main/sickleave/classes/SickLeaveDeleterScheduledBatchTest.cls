@IsTest(SeeAllData=false)
private class SickLeaveDeleterScheduledBatchTest {
    private static final String CRON_EXP = '0 0 0 15 3 ? 2030';

    @TestSetup
    static void setup() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        List<Absence__c> absences = new List<Absence__c>();
        // should not be deleted - has account
        absences.add(new Absence__c(CRM_AbsenceCategory__c = 'VIRKSOMHET', CRM_Account__c = testAccount.id));

        // should not be deleted - missing category
        absences.add(new Absence__c(CRM_AbsenceCategory__c = null, CRM_Account__c = null));
        // should be deleted
        for (Integer i = 0; i < 2000; i++) {
            absences.add(new Absence__c(CRM_AbsenceCategory__c = 'VIRKSOMHET', CRM_Account__c = null));
        }
        insert absences;
    }

    @IsTest
    static void batchDeletesOnlyAbsencesWithoutAccount() {
        Test.startTest();
        Database.executeBatch(new SickLeaveDeleterScheduledBatch(), 2000);
        Test.stopTest();

        Assert.areEqual(
            0,
            [SELECT COUNT() FROM Absence__c WHERE CRM_AbsenceCategory__c = 'VIRKSOMHET' AND CRM_Account__c = NULL],
            'All matching absences should be deleted'
        );
        Assert.areEqual(
            1,
            [SELECT COUNT() FROM Absence__c WHERE CRM_AbsenceCategory__c = 'VIRKSOMHET' AND CRM_Account__c != NULL],
            'Absences linked to an account should remain'
        );
        Assert.areEqual(
            1,
            [SELECT COUNT() FROM Absence__c WHERE CRM_AbsenceCategory__c = NULL],
            'Absences without a category should remain'
        );
    }

    @IsTest
    static void schedulerSubmitsBatch() {
        Test.startTest();
        String scheduledJobId = System.schedule(
            'SickLeaveDeleterScheduledBatchTest',
            CRON_EXP,
            new SickLeaveDeleterScheduledBatch()
        );
        Test.stopTest();

        Assert.isNotNull(scheduledJobId, 'The scheduled job should be created');
        Assert.areEqual(
            1,
            [SELECT COUNT() FROM CronTrigger WHERE Id = :scheduledJobId],
            'The scheduled job should be registered'
        );
    }

    @IsTest
    static void shouldHandleFailures() {
        Absence__c absence = new Absence__c(CRM_AbsenceCategory__c = null, CRM_Account__c = null);
        insert absence;

        List<SObject> scope = new List<SObject>{ new Absence__c(Id = absence.Id) };
        delete absence;

        SickLeaveDeleterScheduledBatch batch = new SickLeaveDeleterScheduledBatch();
        batch.execute(null, scope);

        Assert.areEqual(1, batch.failedDeletionCount, 'Failed deletion count should be incremented');
        Assert.isNotNull(batch.firstFailureMessage, 'First failure message should be set');

        batch.finish(null);
        Assert.areEqual(0, batch.failedDeletionCount, 'Failed deletion count should be reset after finish');
        Assert.isNull(batch.firstFailureMessage, 'First failure message should be reset after finish');
    }
}
