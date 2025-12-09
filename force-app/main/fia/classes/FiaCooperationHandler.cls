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

        // Identify deletions before merging
        List<String> cooperationIdsToDelete = getDeletedCooperationIds(fiaCooperations);
        List<String> themeIdsToDelete = getDeletedThemeIds(fiaCooperations);

        // Merge multiple updates for same cooperation
        Map<String, FiaCooperation> mergedCooperations = combineMessageData(fiaCooperations);

        // Remove cooperations marked for deletion from merged map
        for (String cooperationId : cooperationIdsToDelete) {
            mergedCooperations.remove(cooperationId);
        }

        // Execute deletions and upserts
        handleDeletions(cooperationIdsToDelete, themeIdsToDelete);
        handleUpserts(mergedCooperations.values());

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
    @testVisible
    public List<FiaCooperation> extractData(List<KafkaMessage__c> kafkaMessages) {
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
     * @description Executes deletion of IA Cooperation and IA Theme records.
     * @param cooperationIdsToDelete List of cooperation IDs to delete
     * @param themeIdsToDelete List of theme IDs to delete
     */
    private void handleDeletions(List<String> cooperationIdsToDelete, List<String> themeIdsToDelete) {
        if (!themeIdsToDelete.isEmpty()) {
            List<IATheme__c> iaThemesToDelete = [
                SELECT Id
                FROM IATheme__c
                WHERE ThemeId__c = :themeIdsToDelete
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
                    if (hasRelatedActivities(iaCoop)) {
                        throw new FiaCooperationHandlerException(
                            'IA Cooperation has related tasks or events and cannot be deleted: ' + iaCoop.Id
                        );
                    }
                    iaCooperationToDelete.add(iaCoop);
                } catch (Exception e) {
                    String errorRef = logger.logError(iaCoop.Id, e.getMessage(), e.getStackTraceString());
                }
            }
            deleteRecords(iaCooperationToDelete);
        }
    }

    /**
     * @description Checks if cooperation has related tasks or events.
     */
    private Boolean hasRelatedActivities(IACooperation__c cooperation) {
        return cooperation.Tasks.size() > 0 || cooperation.Events.size() > 0;
    }

    /**
     * @description Builds and upserts sObjects from merged FiaCooperation data.
     * @param mergedCooperations Collection of merged FiaCooperation objects to process
     */
    private void handleUpserts(List<FiaCooperation> mergedCooperations) {
        buildSObjectsFromCooperations(mergedCooperations);

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
     * @description Responsible for creating a map where multiple updates on same cooperation are combined.
     * Simulate database updates by replacing existing values with values from new message, applying same logic as an upsert operation.
     * Assumes that messages are processed in the order they are received.
     * Assumes samarbeid element can have partial updates, so each field is updated individually.
     * Assumes a plan element will either be null or complete with temaer and undertemaer, so whole element can be updated.
     * Json and hash are wrapped in tokens so we can trace multiple messages.
     * If samarbeid status indicate it is deleted, the update is skipped and the cooperation will be removed later.
     * If plan status indicate it is deleted, plan values are updated but the plan's tema and undertema is skipped and removed later.
     * @param allFiaCooperationUpdates List of FiaCooperation objects to be processed.
     * @return A map containing FiaCooperation objects keyed by their unique identifier.
     */
    @testVisible
    public Map<String, FiaCooperation> combineMessageData(List<FiaCooperation> allFiaCooperationUpdates) {
        Map<String, FiaCooperation> fiaSamarbeidMap = new Map<String, FiaCooperation>();
        for (FiaCooperation fiaUpdate : allFiaCooperationUpdates) {
            if (isCooperationDeleted(fiaUpdate)) {
                continue;
            }

            FiaCooperation fiaData = fiaSamarbeidMap.containsKey(fiaUpdate.samarbeid.id)
                ? fiaSamarbeidMap.get(fiaUpdate.samarbeid.id)
                : new FiaCooperation();
            fiaData.orgnr = fiaUpdate.orgnr;
            fiaData.saksnummer = fiaUpdate.saksnummer;
            fiaData.key = fiaUpdate.key;
            fiaData.jsonPayload = mergeTrackingField(fiaData.jsonPayload, fiaUpdate.jsonPayload);
            fiaData.hash = mergeTrackingField(fiaData.hash, fiaUpdate.hash);

            fiaData.samarbeid = mergeSamarbeidFields(fiaData.samarbeid, fiaUpdate.samarbeid);
            fiaData.cooperationLastModified = fiaUpdate.cooperationLastModified != null
                ? fiaUpdate.cooperationLastModified
                : fiaData.cooperationLastModified;

            if (fiaUpdate.plan != null) {
                fiaData.plan = mergePlanFields(fiaData.plan, fiaUpdate.plan);
                fiaData.planLastModified = fiaUpdate.planLastModified;
            }
            fiaSamarbeidMap.put(fiaData.samarbeid.id, fiaData);
        }
        return fiaSamarbeidMap;
    }

    /**
     * Helper method to merge tracking fields with delimiter.
     */
    private String mergeTrackingField(String existing, String newValue) {
        if (String.isBlank(existing)) {
            return newValue + ' #END# ';
        }
        return existing + newValue + ' #END# ';
    }

    /**
     * Helper method to merge samarbeid fields, applying null-safe updates.
     */
    private FiaCooperation.Samarbeid mergeSamarbeidFields(
        FiaCooperation.Samarbeid stashed,
        FiaCooperation.Samarbeid newData
    ) {
        if (stashed == null) {
            stashed = new FiaCooperation.Samarbeid();
        }
        stashed.id = newData.id != null ? newData.id : stashed.id;
        stashed.navn = newData.navn != null ? newData.navn : stashed.navn;
        stashed.status = newData.status != null ? newData.status : stashed.status;
        stashed.startDato = newData.startDato != null ? newData.startDato : stashed.startDato;
        stashed.sluttDato = newData.sluttDato != null ? newData.sluttDato : stashed.sluttDato;
        stashed.endretTidspunkt = newData.endretTidspunkt != null ? newData.endretTidspunkt : stashed.endretTidspunkt;
        return stashed;
    }
    private FiaCooperation.Plan mergePlanFields(FiaCooperation.Plan stashed, FiaCooperation.Plan newData) {
        if (stashed == null) {
            stashed = new FiaCooperation.Plan();
        }
        stashed.id = newData.id != null ? newData.id : stashed.id;
        stashed.status = newData.status != null ? newData.status : stashed.status;
        stashed.sistEndret = newData.sistEndret != null ? newData.sistEndret : stashed.sistEndret;
        stashed.sistPublisert = newData.sistPublisert != null ? newData.sistPublisert : stashed.sistPublisert;
        // Replace entire plan if new plan exists (atomic update)
        if (newData.status != STATUS_DELETED) {
            stashed.temaer = newData.temaer;
        }
        return stashed;
    }

    /**
     * @description Checks if a cooperation is marked as deleted.
     */
    @testVisible
    private Boolean isCooperationDeleted(FiaCooperation cooperation) {
        return cooperation?.samarbeid?.status == STATUS_DELETED;
    }

    /**
     * @description Checks if a plan is marked as deleted.
     */
    @testVisible
    private Boolean isPlanDeleted(FiaCooperation cooperation) {
        return cooperation?.plan?.status == STATUS_DELETED;
    }

    /**
     * @description Extracts cooperation IDs marked for deletion.
     */
    @testVisible
    private List<String> getDeletedCooperationIds(List<FiaCooperation> cooperations) {
        List<String> deletedIds = new List<String>();
        for (FiaCooperation cooperation : cooperations) {
            if (isCooperationDeleted(cooperation)) {
                deletedIds.add(cooperation.samarbeid.id);
            }
        }
        return deletedIds;
    }

    /**
     * @description Extracts theme IDs from plans marked for deletion.
     */
    @testVisible
    private List<String> getDeletedThemeIds(List<FiaCooperation> cooperations) {
        List<String> deletedIds = new List<String>();
        for (FiaCooperation cooperation : cooperations) {
            if (isPlanDeleted(cooperation) && cooperation.plan.temaer != null) {
                for (FiaCooperation.Tema tema : cooperation.plan.temaer) {
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
    private void buildSObjectsFromCooperations(List<FiaCooperation> fiaCooperations) {
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
                if (fiaCooperation.plan?.temaer == null || isPlanDeleted(fiaCooperation)) {
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
