/**
 * Importerer kampanjemedlemmer for en region av gangen og kjører seg selv videre
 * til neste region (1-15).
 *
 * Hele uttrekket er for stort for en callout, så hver region hentes og
 * behandles i sin egen transaksjon. Da holder heap, SOQL og DML seg godt
 * innenfor grensene uansett hvor mange respondenter det er totalt.
 *
 * Startes fra Execute Anonymous:
 *   System.enqueueJob(new TAG_SurveyXactMemberImportQueueable());
 */
public with sharing class TAG_SurveyXactMemberImportQueueable implements Queueable, Database.AllowsCallouts {
    private Integer region;
    private Boolean updateExisting;
    private Integer campaignYear;
    private LoggerUtility logger;

    public TAG_SurveyXactMemberImportQueueable() {
        this(TAG_SurveyXactRegionCalloutService.FIRST_REGION, false, Date.today().year());
    }

    public TAG_SurveyXactMemberImportQueueable(Boolean updateExisting) {
        this(TAG_SurveyXactRegionCalloutService.FIRST_REGION, updateExisting, Date.today().year());
    }

    public TAG_SurveyXactMemberImportQueueable(Integer region, Boolean updateExisting, Integer campaignYear) {
        this.region = region;
        this.updateExisting = updateExisting;
        this.campaignYear = campaignYear;
        this.logger = new LoggerUtility();
    }

    public void execute(QueueableContext context) {
        TAG_SurveyXactDataset_Config__mdt config = activeConfig();

        if (config == null) {
            logger.logMessage(
                LoggerUtility.LogLevel.Error,
                '',
                String.valueOf(region),
                'SurveyXact member import: no active configuration found.',
                null,
                null,
                CRM_ApplicationDomain.Domain.POAB
            );
            logger.publish();
            return;
        }

        try {
            String csv = TAG_SurveyXactRegionCalloutService.getRegionDataset(config, region);
            List<String> skipReasons = new List<String>();
            TAG_SurveyXactMemberImportService.ImportResult result = TAG_SurveyXactMemberImportService.importFromCsv(
                csv,
                campaignYear,
                updateExisting,
                skipReasons
            );

            for (String reason : skipReasons) {
                logger.logMessage(
                    LoggerUtility.LogLevel.Warning,
                    '',
                    'Region ' + region,
                    'SurveyXact member import skipped respondent. ' + reason,
                    null,
                    null,
                    CRM_ApplicationDomain.Domain.POAB
                );
            }

            logger.logMessage(
                LoggerUtility.LogLevel.Info,
                '',
                'Region ' + region,
                'SurveyXact member import finished for region ' +
                region +
                ': ' +
                result,
                null,
                null,
                CRM_ApplicationDomain.Domain.POAB
            );
        } catch (Exception e) {
            logger.logMessage(
                LoggerUtility.LogLevel.Error,
                '',
                'Region ' + region,
                'SurveyXact member import failed for region ' +
                region +
                ': ' +
                e.getMessage(),
                e.getStackTraceString(),
                null,
                CRM_ApplicationDomain.Domain.POAB
            );
        }

        logger.publish();
        chainNextRegion();
    }

    // En region som feiler stopper ikke kjeden, slik at én dårlig region ikke
    // blokkerer resten.
    private void chainNextRegion() {
        if (region >= TAG_SurveyXactRegionCalloutService.LAST_REGION) {
            return;
        }
        if (Test.isRunningTest()) {
            return;
        }
        System.enqueueJob(new TAG_SurveyXactMemberImportQueueable(region + 1, updateExisting, campaignYear));
    }

    private static TAG_SurveyXactDataset_Config__mdt activeConfig() {
        List<TAG_SurveyXactDataset_Config__mdt> configs = [
            SELECT SurveyId__c, LookbackDays__c, Ptype1__c, Active__c
            FROM TAG_SurveyXactDataset_Config__mdt
            WHERE Active__c = TRUE
            LIMIT 1
        ];
        return configs.isEmpty() ? null : configs[0];
    }
}
