/**
 * Queueable that fetches the SurveyXact dataset export and updates
 * CustomCampaignMember__c statuses. One callout is made per active survey
 * configuration. Runs as a Queueable so the callout uses the async governor
 * limits and can be chained if more surveys are added later.
 */
public with sharing class TAG_SurveyXactDatasetSyncQueueable implements Queueable, Database.AllowsCallouts {
    private List<TAG_SurveyXactDataset_Config__mdt> configs;
    private LoggerUtility logger;

    public TAG_SurveyXactDatasetSyncQueueable() {
        this(activeConfigs());
    }

    @TestVisible
    private TAG_SurveyXactDatasetSyncQueueable(List<TAG_SurveyXactDataset_Config__mdt> configs) {
        this.configs = configs;
        this.logger = new LoggerUtility();
    }

    public void execute(QueueableContext context) {
        System.attachFinalizer(new SyncFinalizer());

        if (configs.isEmpty()) {
            logger.logMessage(
                LoggerUtility.LogLevel.Error,
                '',
                null,
                'SurveyXact dataset sync: no active configuration found.',
                null,
                null,
                CRM_ApplicationDomain.Domain.POAB
            );
            logger.publish();
            return;
        }

        for (TAG_SurveyXactDataset_Config__mdt config : configs) {
            try {
                String csv = TAG_SurveyXactDatasetCalloutService.getRecentDataset(config);
                TAG_SurveyXactDatasetSync.syncFromCsv(csv);
            } catch (Exception e) {
                logger.logMessage(
                    LoggerUtility.LogLevel.Error,
                    '',
                    config != null ? config.SurveyId__c : null,
                    'SurveyXact dataset sync failed: ' + e.getMessage(),
                    e.getStackTraceString(),
                    null,
                    CRM_ApplicationDomain.Domain.POAB
                );
            }
        }
        logger.publish();
    }

    private static List<TAG_SurveyXactDataset_Config__mdt> activeConfigs() {
        return [
            SELECT SurveyId__c, LookbackDays__c, Ptype1__c, Active__c
            FROM TAG_SurveyXactDataset_Config__mdt
            WHERE Active__c = TRUE
        ];
    }

    // Logs CPU/heap limits and other unhandled exceptions, which the job itself cannot catch.
    @TestVisible
    private class SyncFinalizer implements Finalizer {
        public void execute(FinalizerContext context) {
            if (context.getResult() != ParentJobResult.UNHANDLED_EXCEPTION) {
                return;
            }

            Exception e = context.getException();
            LoggerUtility finalizerLogger = new LoggerUtility();
            finalizerLogger.logMessage(
                LoggerUtility.LogLevel.Error,
                context.getAsyncApexJobId(),
                null,
                'SurveyXact dataset sync failed with an unhandled exception: ' +
                e.getTypeName() +
                ' - ' +
                e.getMessage(),
                e.getStackTraceString(),
                null,
                CRM_ApplicationDomain.Domain.POAB
            );
            finalizerLogger.publish();
        }
    }
}
