/**
 * @description Handler class to process inbound Kafka messages and create IA Cooperation records, IA Themes and IA Subthemes.
 * Contains functions to parse data from messages, create records and upsert them.
 */
public without sharing class FiaCooperationHandler extends KafkaMessageProcessor implements IKafkaMessageConsumer {
    private Map<String, KafkaMessage__c> keyToKafkaMessageMap = new Map<String, KafkaMessage__c>();
    private List<IACooperation__c> iaCooperationsToUpsert = new List<IACooperation__c>();
    private List<IATheme__c> iaThemesToUpsert = new List<IATheme__c>();
    private List<IA_Subtheme__c> iaSubthemesToUpsert = new List<IA_Subtheme__c>();
    public static final String STATUS_DELETED = 'SLETTET';
    private static final Integer AGE_THRESHOLD_MINUTES = 15;
    /**
     * @description Implementation of processMessages-method from IKafkaMessageConsumer
     * @param messages List of kafka message records
     */
    public void processMessages(List<KafkaMessage__c> messages) {
        List<FiaCooperation> fiaCooperations = extractData(messages);
        if (fiaCooperations.isEmpty()) {
            return;
        }

        handleDeletions(fiaCooperations);
        handleUpserts(fiaCooperations);
        logTimeDeviations(fiaCooperations);
        logger.publish();
    }

    /**
     * @description Processes a list of Kafka Message records and extracts FiaCooperation objects.
     * The Kafka Message is also added to a map to allow for status updates should exceptions occur
     * during subsequent sObject creation.      *
     * @param kafkaMessages List of Kafka Message records to be processed.
     * @return A list of FiaCooperation objects.
     */
    private List<FiaCooperation> extractData(List<KafkaMessage__c> kafkaMessages) {
        List<FiaCooperation> allFiaCooperationUpdates = new List<FiaCooperation>();
        for (KafkaMessage__c kafkaMessage : kafkaMessages) {
            try {
                FiaCooperation fiaCooperation = (FiaCooperation) parse(FiaCooperation.class, kafkaMessage);
                allFiaCooperationUpdates.add(fiaCooperation);
                keyToKafkaMessageMap.put(kafkaMessage.CRM_Key__c, kafkaMessage);
                kafkaMessage.CRM_Status__c = KafkaMessageService.STATUS_PROCESSED;
            } catch (Exception e) {
                handleError(null, e.getMessage(), e.getStackTraceString(), kafkaMessage);
            }
        }
        return allFiaCooperationUpdates;
    }

    /**
     * @description Handles deletions of IA Cooperation and IA Theme records based on the provided FiaCooperation objects.
     * @param fiaCooperations List of FiaCooperation objects to process for deletions.
     */
    private void handleDeletions(List<FiaCooperation> fiaCooperations) {
        List<String> cooperationIdsToDelete = getDeletedIds(fiaCooperations, 'cooperation');
        List<String> themesIdsToDelete = getDeletedIds(fiaCooperations, 'theme');

        if (!themesIdsToDelete.isEmpty()) {
            List<IATheme__c> iaThemesToDelete = [
                SELECT Id
                FROM IATheme__c
                WHERE ThemeId__c = :themesIdsToDelete
            ];

            deleteRecords(iaThemesToDelete);
        }

        if (!cooperationIdsToDelete.isEmpty()) {
            List<IACooperation__c> existingIaCooperations = [
                SELECT Id, CooperationId__c, (SELECT id FROM Tasks), (SELECT id FROM Events)
                FROM IACooperation__c
                WHERE CooperationId__c = :cooperationIdsToDelete
            ];
            List<IACooperation__c> iaCooperationToDelete = new List<IACooperation__c>();
            for (IACooperation__c iaCoop : existingIaCooperations) {
                try {
                    if (iaCoop.Tasks.size() > 0 || iaCoop.Events.size() > 0) {
                        System.debug(
                            LoggingLevel.ERROR,
                            'IA Cooperation has related tasks or events and cannot be deleted: ' + iaCoop.Id
                        );
                        throw new FiaCooperationHandlerException(
                            'IA Cooperation has related tasks or events and cannot be deleted: ' + iaCoop.Id
                        );
                    } else {
                        iaCooperationToDelete.add(iaCoop);
                    }
                } catch (Exception e) {
                    String errorRef = logger.logError(iaCoop.Id, e.getMessage(), e.getStackTraceString());
                }
            }
            deleteRecords(iaCooperationToDelete);
        }
    }

    private void handleUpserts(List<FiaCooperation> fiaCooperations) {
        Map<String, FiaCooperation> updates = getNewestUpdates(fiaCooperations);
        // Remove deleted cooperations from map with updates (can't do both)
        for (String cooperationId : getDeletedIds(fiaCooperations, 'cooperation')) {
            updates.remove(cooperationId);
        }

        createRecords(updates.values());

        if (!iaCooperationsToUpsert.isEmpty()) {
            upsertRecords(iaCooperationsToUpsert, IACooperation__c.CooperationId__c);
        }
        if (!iaThemesToUpsert.isEmpty()) {
            upsertRecords(iaThemesToUpsert, IATheme__c.ThemeId__c);
            upsertRecords(iaSubthemesToUpsert, IA_Subtheme__c.SubthemeId__c);
        }
    }

    // Log message ages for monitoring purposes
    @testVisible
    private void logTimeDeviations(List<FiaCooperation> fiaCooperations) {
        DateTime batchProcessingTime = DateTime.now(); // Calculate once per batch
        ReportingDataBuilder ageLogger = new ReportingDataBuilder();

        for (FiaCooperation fiaCooperation : fiaCooperations) {
            Integer ageInMinutes = fiaCooperation.getMessageAge(batchProcessingTime);
            if (ageInMinutes != null && ageInMinutes > AGE_THRESHOLD_MINUTES) {
                String topic = this.keyToKafkaMessageMap.get(fiaCooperation.key)?.CRM_Topic__c;
                ageLogger.logTimeDeviation(topic, fiaCooperation.key, ageInMinutes);
            }
        }
        ageLogger.saveReportingDataEntries();
    }

    /**
     * @description Processes a list of FiaCooperation objects, organizing them
     *  into a map keyed by their unique identifier. Each message is parsed into a FiaCooperation object, and only
     *  the most recent entry (based on the 'sistEndret' or 'endretTidspunkt' timestamp) is stored in the map.
     * @param allFiaCooperationUpdates List of FiaCooperation objects to be processed.
     * @return A map containing FiaCooperation objects keyed by their unique identifier.
     */
    private Map<String, FiaCooperation> getNewestUpdates(List<FiaCooperation> allFiaCooperationUpdates) {
        Map<String, FiaCooperation> fiaSamarbeidMap = new Map<String, FiaCooperation>();
        Map<String, FiaCooperation.Plan> fiaPlanMap = new Map<String, FiaCooperation.Plan>();
        for (FiaCooperation fiaCooperation : allFiaCooperationUpdates) {
            String cooperationId = fiaCooperation.samarbeid.id;
            // Determine the newest cooperation
            FiaCooperation existingCooperation = fiaSamarbeidMap.get(cooperationId);
            if (isNewerCooperation(existingCooperation, fiaCooperation)) {
                fiaSamarbeidMap.put(cooperationId, fiaCooperation);
            }
            // Determine the newest plan
            if (fiaCooperation.plan != null) {
                FiaCooperation.Plan existingPlan = fiaPlanMap.get(cooperationId);
                if (isNewerPlan(existingPlan, fiaCooperation.plan)) {
                    fiaPlanMap.put(cooperationId, fiaCooperation.plan);
                }
            }
        }
        // Combine cooperation and plan maps
        return combineCooperationAndPlanMaps(fiaSamarbeidMap, fiaPlanMap);
    }

    /**
     * @description Determines if the given cooperation is newer than the existing one.
     * @param existingCooperation The existing cooperation object.
     * @param newCooperation The new cooperation object.
     * @return True if the new cooperation is newer, false otherwise.
     */
    @testVisible
    private static Boolean isNewerCooperation(FiaCooperation existingCooperation, FiaCooperation newCooperation) {
        Datetime existingCooperationTime = existingCooperation?.samarbeid?.getLastModifiedDate();
        Datetime newCooperationTime = newCooperation?.samarbeid?.getLastModifiedDate();

        if (existingCooperationTime == null && newCooperationTime == null) {
            return true; // Both are null, consider them equal
        }
        if (existingCooperationTime == null) {
            return true; // Existing is null, new is newer
        }
        if (newCooperationTime == null) {
            return false; // New is null, existing is newer
        }
        return existingCooperationTime < newCooperationTime; // Compare timestamps
    }

    /**
     * @description Determines if the given plan is newer than the existing one.
     * @param existingPlan The existing plan object.
     * @param newPlan The new plan object.
     * @return True if the new plan is newer, false otherwise.
     */
    @testVisible
    private static Boolean isNewerPlan(FiaCooperation.Plan existingPlan, FiaCooperation.Plan newPlan) {
        return existingPlan == null || existingPlan.getLastModifiedDate() < newPlan.getLastModifiedDate();
    }

    /**
     * @description Combines the cooperation and plan maps into a single map.
     * @param cooperationMap Map of cooperation objects.
     * @param planMap Map of plan objects.
     * @return Combined map of cooperation objects with their plans.
     */
    @testVisible
    private static Map<String, FiaCooperation> combineCooperationAndPlanMaps(
        Map<String, FiaCooperation> cooperationMap,
        Map<String, FiaCooperation.Plan> planMap
    ) {
        for (String cooperationId : cooperationMap.keySet()) {
            if (planMap.containsKey(cooperationId)) {
                cooperationMap.get(cooperationId).plan = planMap.get(cooperationId);
            }
        }
        return cooperationMap;
    }
    /**
     * @description Creates a list of deleted IDs based on the provided FiaCooperation objects.
     * @param updates List of FiaCooperation objects to process for deletions.
     * @param type Type of deletion ('cooperation' or 'theme').
     * @return A list of deleted IDs.
     */
    private List<String> getDeletedIds(List<FiaCooperation> updates, String type) {
        List<String> deletedIds = new List<String>();
        for (FiaCooperation fiaCooperation : updates) {
            if (type == 'cooperation' && fiaCooperation.samarbeid.status == STATUS_DELETED) {
                deletedIds.add(fiaCooperation.samarbeid.id);
            } else if (type == 'theme' && fiaCooperation.plan != null && fiaCooperation.plan.status == STATUS_DELETED) {
                for (FiaCooperation.Tema tema : fiaCooperation.plan.temaer) {
                    deletedIds.add(tema.id);
                }
            }
        }
        return deletedIds;
    }

    /**
     * @description Creates records from parsed FiaCooperation data.
     * @param fiaCooperations List with FiaCooperation objects
     */
    private void createRecords(List<FiaCooperation> fiaCooperations) {
        Set<String> existingCasenumbers = getExistingCases(fiaCooperations);
        for (FiaCooperation fiaCooperation : fiaCooperations) {
            try {
                if (!existingCasenumbers.Contains(fiaCooperation.saksnummer)) {
                    throw new FiaCooperationHandlerException(
                        'IA Case not found in Salesforce: ' + fiaCooperation.saksnummer
                    );
                }

                IACooperation__c iaCooperation = createIACooperation(fiaCooperation);
                iaCooperationsToUpsert.add(iaCooperation);
                if (fiaCooperation.plan?.temaer == null || fiaCooperation.plan?.status == STATUS_DELETED) {
                    continue;
                }
                for (FiaCooperation.Tema tema : fiaCooperation.plan.temaer) {
                    IATheme__c iaTheme = createTheme(tema, fiaCooperation);
                    iaThemesToUpsert.add(iaTheme);
                    if (tema.undertemaer == null) {
                        continue;
                    }
                    for (FiaCooperation.Undertema undertema : tema.undertemaer) {
                        IA_Subtheme__c iaSubtheme = createSubtheme(undertema, tema.id, fiaCooperation);
                        iaSubthemesToUpsert.add(iaSubtheme);
                    }
                }
            } catch (Exception e) {
                handleError(
                    fiaCooperation.key,
                    e.getMessage(),
                    e.getStackTraceString(),
                    keyToKafkaMessageMap.get(fiaCooperation.key)
                );
            }
        }
    }

    // Helper method to get Case Id for existing IA Cases
    private Set<String> getExistingCases(List<FiaCooperation> fiaCooperations) {
        Set<String> caseNumbers = new Set<String>();
        for (FiaCooperation fa : fiaCooperations) {
            caseNumbers.add(fa.saksnummer);
        }
        Set<String> existingCaseNumbers = new Set<String>();
        for (IACase__c iaCase : [SELECT Name FROM IACase__c WHERE Name IN :caseNumbers WITH SECURITY_ENFORCED]) {
            existingCaseNumbers.add(iaCase.Name);
        }
        return existingCaseNumbers;
    }

    // Helper method to create new instance of an IACooperation__c sObject
    private IACooperation__c createIACooperation(FiaCooperation fiaCooperation) {
        IACooperation__c iaCooperation = new IACooperation__c(
            CooperationId__c = fiaCooperation.samarbeid.id,
            KafkaId__c = fiaCooperation.key,
            KafkaHash__c = fiaCooperation.hash,
            JsonPayload__c = fiaCooperation.jsonPayload
        );
        //Set reference for related sObjects
        iaCooperation.IACase__r = new IACase__c(Name = fiaCooperation.saksnummer);
        iaCooperation.Account__r = new Account(INT_OrganizationNumber__c = fiaCooperation.orgnr);

        //Set values for samarbeid
        setFieldIfNotBlank(iaCooperation, 'Name', fiaCooperation.samarbeid.navn);
        setFieldIfNotBlank(iaCooperation, 'Status__c', fiaCooperation.samarbeid.status);
        setFieldIfNotBlank(iaCooperation, 'StartDate__c', fiaCooperation.samarbeid.startDato);
        setFieldIfNotBlank(iaCooperation, 'EndDate__c', fiaCooperation.samarbeid.sluttDato);
        setFieldIfNotBlank(iaCooperation, 'CooperationLastModified__c', fiaCooperation.samarbeid.getLastModifiedDate());
        //Set values for plan
        if (fiaCooperation.plan != null) {
            iaCooperation.PlanId__c = fiaCooperation.plan.id;
            iaCooperation.IncludedArbeidsmiljo__c = fiaCooperation.includesArbeidsmiljo();
            iaCooperation.IncludedPartssamarbeid__c = fiaCooperation.includesPartssamarbeid();
            iaCooperation.IncludedSykefravaersarbeid__c = fiaCooperation.includesSykefravaersarbeid();
            iaCooperation.PlanLastModified__c = fiaCooperation.plan.getLastModifiedDate();
            iaCooperation.PlanStatus__c = fiaCooperation.plan.status;
        }
        return iaCooperation;
    }

    // Helper method to create new instance of a IATheme__c sObject
    private IATheme__c createTheme(FiaCooperation.Tema tema, FiaCooperation fiaCooperation) {
        IATheme__c iaTheme = new IATheme__c(
            ThemeId__c = tema.id,
            Name = tema.navn,
            IsPlanned__c = tema.inkludert,
            KafkaId__c = fiaCooperation.key,
            IACooperation__r = new IACooperation__c(CooperationId__c = fiaCooperation.samarbeid.id)
        );
        return iaTheme;
    }
    // Helper method to create new instance of a IA_Subtheme__c sObject
    private IA_Subtheme__c createSubtheme(
        FiaCooperation.Undertema undertema,
        String iaThemeReference,
        FiaCooperation fiaCooperation
    ) {
        IA_Subtheme__c iaSubtheme = new IA_Subtheme__c(
            SubthemeId__c = undertema.id,
            Name = undertema.navn,
            Goal__c = undertema.malsetning,
            IsPlanned__c = undertema.inkludert,
            Status__c = undertema.status,
            StartDate__c = undertema.startDato,
            EndDate__c = undertema.sluttDato,
            KafkaId__c = fiaCooperation.key,
            IATheme__r = new IATheme__c(ThemeId__c = iaThemeReference),
            IA_CooperationTheme__r = new IACooperation__c(CooperationId__c = fiaCooperation.samarbeid.id)
        );
        return iaSubtheme;
    }

    // Helper method to set a field only if the value is not blank
    private void setFieldIfNotBlank(SObject obj, String fieldName, Object value) {
        if (value instanceof String && !String.isBlank((String) value)) {
            obj.put(fieldName, value);
        } else if (value instanceof Date && value != null) {
            obj.put(fieldName, value);
        } else if (value instanceof Datetime && value != null) {
            obj.put(fieldName, value);
        }
    }

    /**
     * @description Deletes records and handles errors.
     * @param records List of records to delete
     */
    @testVisible
    private void deleteRecords(List<sObject> records) {
        Database.DeleteResult[] deleteResult = Database.delete(records, false);
        for (Integer i = 0; i < deleteResult.size(); i++) {
            if (!deleteResult[i].isSuccess()) {
                //String kafkaKey = (String) records[i].get('KafkaId__c');
                Database.Error e = deleteResult[i].getErrors()[0];
                String errorRef = logger.logError(
                    deleteResult[i].getId(),
                    e.getMessage(),
                    'Class.FiaCooperationHandler.deleteRecords'
                );
                //handleError(deleteResult[i].getId(), e.getMessage(), stackTrace, null);
            }
        }
    }

    /**
     * @description Upserts records and handles errors.
     * @param records List of records to upsert
     * @param externalId Field to use as external id during upsert
     */
    private void upsertRecords(List<sObject> records, Schema.SObjectField externalId) {
        try {
            Database.UpsertResult[] upsertResults = Database.upsert(records, externalId, false);
            for (Integer i = 0; i < upsertResults.size(); i++) {
                if (!upsertResults[i].isSuccess()) {
                    String kafkaKey = (String) records[i].get('KafkaId__c');
                    Database.Error e = upsertResults[i].getErrors()[0];
                    String stackTrace =
                        'Class.FiaCooperationHandler.upsertRecords, ' +
                        e.getStatusCode() +
                        ', ' +
                        e.getFields();
                    handleError(kafkaKey, e.getMessage(), stackTrace, keyToKafkaMessageMap.get(kafkaKey));
                }
            }
        } catch (Exception e) {
            handleError(null, e.getMessage(), e.getStackTraceString(), keyToKafkaMessageMap.values());
        }
    }

    // Helper method to handle exceptions
    private void handleError(String referenceInfo, String message, String stackTrace, KafkaMessage__c kafkaMessage) {
        handleError(referenceInfo, message, stackTrace, new List<KafkaMessage__c>{ kafkaMessage });
    }
    // Helper method to handle exceptions
    private void handleError(
        String referenceInfo,
        String message,
        String stackTrace,
        List<KafkaMessage__c> kafkaMessages
    ) {
        String errorRef = logger.logError(referenceInfo, message, stackTrace);
        logger.setMessageErrors(kafkaMessages, errorRef);
    }

    /**
     * @description Custom exception class for FiaCooperationHandler. Created so exceptions can be manually thrown in code.
     */
    public class FiaCooperationHandlerException extends Exception {
    }
}
