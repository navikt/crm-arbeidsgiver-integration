/**
 * This batch job is a cleanup mechanism for orphaned Absence__c records.
 * The job deletes Absence__c records that don't belong to any organizations in the org (i.e., CRM_Account__c is NULL and CRM_AbsenceCategory__c = 'VIRKSOMHET').
 * Intended to run only when needed. Problem with orphaned sick leave has been addressed in source app/system.
 */
public with sharing class SickLeaveDeleterScheduledBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
    @TestVisible
    private Integer failedDeletionCount = 0;
    @TestVisible
    private String firstFailureMessage;

    /**
     * Initializes the batch job for deleting orphaned Absence__c records.
     */
    public void execute(SchedulableContext sc) {
        Database.executeBatch(this, 2000);
    }

    /**
     * Called when the scheduled job is executed and triggers the batch execution for deleting Absence__c records.
     * The records to delete are Absence__c records that don't belong to any organizations in the org (i.e., CRM_Account__c is NULL and CRM_AbsenceCategory__c = 'VIRKSOMHET').
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            [
                SELECT Id
                FROM Absence__c
                WHERE CRM_AbsenceCategory__c = 'VIRKSOMHET' AND CRM_Account__c = NULL
            ]
        );
    }

    /**
     * Called for each batch of records to be deleted.
     * It attempts to delete the records and tracks any failures.
     */
    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        Database.DeleteResult[] results = Database.delete(scope, false, AccessLevel.SYSTEM_MODE);
        for (Database.DeleteResult result : results) {
            if (!result.isSuccess()) {
                failedDeletionCount++;
                if (failedDeletionCount == 1 && result.getErrors().size() > 0) {
                    Database.Error error = result.getErrors()[0];
                    firstFailureMessage = String.valueOf(error.getStatusCode()) + ': ' + error.getMessage();
                }
            }
        }
    }

    /**
     * Called after all batches are processed.
     * It creates an error in the application log containing the number of failed deletions and the first failure message if any deletions failed.
     */
    public void finish(Database.BatchableContext bc) {
        if (failedDeletionCount > 0) {
            logError('Number of failed deletions: ' + failedDeletionCount, firstFailureMessage);
            failedDeletionCount = 0;
            firstFailureMessage = null;
        }
    }

    private static void logError(String message, String errorRef) {
        LoggerUtility logger = new LoggerUtility();
        logger.logMessage(
            LoggerUtility.LogLevel.Error,
            '',
            '',
            message,
            errorRef,
            null,
            CRM_ApplicationDomain.Domain.POAB
        );
        logger.publish();
    }
}
