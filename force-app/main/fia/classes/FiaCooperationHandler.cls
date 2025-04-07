/**
 * @description Handler class to process inbound Kafka messages and create IA Cooperation records, IA Themes and IA Subthemes.
 * Contains functions to parse data from messages, create records and upsert them.
 */
public without sharing class FiaCooperationHandler extends KafkaMessageProcessor implements IKafkaMessageConsumer {
    private Map<String, KafkaMessage__c> keyToKafkaMessageMap = new Map<String, KafkaMessage__c>();
    private List<IACooperation__c> iaCooperationsToUpsert = new List<IACooperation__c>();
    private List<IATheme__c> iaThemesToUpsert = new List<IATheme__c>();
    private List<IA_Subtheme__c> iaSubthemesToUpsert = new List<IA_Subtheme__c>();

    /**
     * @description Implementation of processMessages-method from IKafkaMessageConsumer
     * @param messages List of kafka message records
     */
    public void processMessages(List<KafkaMessage__c> messages) {
        List<FiaCooperation> fiaCooperations = extractData(messages);
        if (fiaCooperations.isEmpty()) {
            return;
        }

        List<String> cooperationIdsToDelete = getDeletedCooperationIds(fiaCooperations);
        List<String> themesIdsToDelete = getDeletedThemeIds(fiaCooperations);
        Map<String, FiaCooperation> updates = getNewestUpdates(fiaCooperations);

        // Remove deleted cooperations from map with updates (can't do both)
        for (String cooperationId : getDeletedCooperationIds(fiaCooperations)) {
            if (updates.containsKey(cooperationId)) {
                updates.remove(cooperationId);
            }
        }
        createRecords(updates.values());

        // Do deletes
        if (!themesIdsToDelete.isEmpty()) {
            List<IATheme__c> iaThemesToDelete = [
                SELECT Id, (SELECT id FROM Tasks), (SELECT id FROM Events)
                FROM IATheme__c
                WHERE ThemeId__c = :themesIdsToDelete
            ];
            for (IATheme__c iaTheeme : iaThemesToDelete) {
                if (iaTheeme.Tasks.size() > 0 || iaTheeme.Events.size() > 0) {
                    throw new FiaCooperationHandlerException(
                        'IA Theme has related tasks or events and cannot be deleted: ' + iaTheeme.Id
                    );
                }
            }
            delete iaThemesToDelete;
        }
        if (!cooperationIdsToDelete.isEmpty()) {
            List<IACooperation__c> iaCooperationToDelete = [
                SELECT Id, (SELECT id FROM Tasks), (SELECT id FROM Events)
                FROM IACooperation__c
                WHERE CooperationId__c = :cooperationIdsToDelete
            ];
            for (IACooperation__c iaCoop : iaCooperationToDelete) {
                if (iaCoop.Tasks.size() > 0 || iaCoop.Events.size() > 0) {
                    throw new FiaCooperationHandlerException(
                        'IA Cooperation has related tasks or events and cannot be deleted: ' + iaCoop.Id
                    );
                }
            }
            delete iaCooperationToDelete;
        }

        //do upserts
        if (!iaCooperationsToUpsert.isEmpty()) {
            upsertRecords(iaCooperationsToUpsert, IACooperation__c.CooperationId__c);
        }
        if (!iaThemesToUpsert.isEmpty()) {
            upsertRecords(iaThemesToUpsert, IATheme__c.ThemeId__c);
            upsertRecords(iaSubthemesToUpsert, IA_Subtheme__c.SubthemeId__c);
        }

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
                //mark kafka message as prosessed
                kafkaMessage.CRM_Status__c = KafkaMessageService.STATUS_PROCESSED;
            } catch (Exception e) {
                handleError(null, e.getMessage(), e.getStackTraceString(), kafkaMessage);
            }
        }
        return allFiaCooperationUpdates;
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
            // Add or replace entry in the cooperation map
            FiaCooperation existing = fiaSamarbeidMap.get(fiaCooperation.samarbeid.id);
            Boolean isNewerCooperation = (existing == null ||
            existing.samarbeid.endretTidspunkt < fiaCooperation.samarbeid.endretTidspunkt);
            if (!fiaSamarbeidMap.containsKey(cooperationId) || isNewerCooperation) {
                fiaSamarbeidMap.put(cooperationId, fiaCooperation);
            }
            if (fiaCooperation.plan != null) {
                // Add or replace entry in the plan map
                FiaCooperation.Plan existingPlan = fiaPlanMap.get(fiaCooperation.samarbeid.id);
                Boolean isNewerPlan = (existingPlan == null ||
                existingPlan.sistEndret < fiaCooperation.plan.sistEndret);
                if (!fiaPlanMap.containsKey(cooperationId) || isNewerPlan) {
                    fiaPlanMap.put(cooperationId, fiaCooperation.plan);
                }
            }
        }
        //have map with most recent of each type, now combine in one map and return it as list.
        for (String cooperationId : fiaSamarbeidMap.keySet()) {
            if (fiaPlanMap.containsKey(cooperationId)) {
                fiaSamarbeidMap.get(cooperationId).plan = fiaPlanMap.get(cooperationId);
            }
        }
        return fiaSamarbeidMap;
    }

    // Loop all messages and create list of deletes
    private List<String> getDeletedCooperationIds(List<FiaCooperation> allFiaCooperationUpdates) {
        List<String> deletedCooperations = new List<String>();
        for (FiaCooperation fiaCooperation : allFiaCooperationUpdates) {
            if (fiaCooperation.samarbeid.status == 'SLETTET') {
                deletedCooperations.add(fiaCooperation.samarbeid.id);
            }
        }
        return deletedCooperations;
    }

    // Loop all messages and create list of deletes
    private List<String> getDeletedThemeIds(List<FiaCooperation> allFiaCooperationUpdates) {
        List<String> deletedThemes = new List<String>();
        for (FiaCooperation fiaCooperation : allFiaCooperationUpdates) {
            if (fiaCooperation.samarbeid.status == 'SLETTET') {
                continue;
            }
            if (fiaCooperation.plan != null && fiaCooperation.plan.status == 'SLETTET') {
                for (FiaCooperation.Tema tema : fiaCooperation.plan.temaer) {
                    deletedThemes.add(tema.id);
                }
            }
        }
        return deletedThemes;
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
                createThemesAndSubthemes(fiaCooperation);
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

    // Helper method that creates themes and subthemes
    private void createThemesAndSubthemes(FiaCooperation fiaCooperation) {
        if (fiaCooperation.plan == null || fiaCooperation.plan.temaer == null) {
            return;
        }
        for (FiaCooperation.Tema tema : fiaCooperation.plan.temaer) {
            IATheme__c iaTheme = createTheme(tema, fiaCooperation);
            iaThemesToUpsert.add(iaTheme);

            //Continue to next iteration if undertemaer is null
            if (tema.undertemaer == null) {
                continue;
            }

            for (FiaCooperation.Undertema undertema : tema.undertemaer) {
                handleSubthemeV1(undertema, tema.id, fiaCooperation);
            }
        }
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
        //Set values for plan
        if (fiaCooperation.plan != null) {
            iaCooperation.PlanId__c = fiaCooperation.plan.id;
            iaCooperation.IncludedArbeidsmiljo__c = fiaCooperation.includesArbeidsmiljo();
            iaCooperation.IncludedPartssamarbeid__c = fiaCooperation.includesPartssamarbeid();
            iaCooperation.IncludedSykefravaersarbeid__c = fiaCooperation.includesSykefravaersarbeid();
            iaCooperation.PlanLastModified__c = fiaCooperation.plan.sistEndret;
            iaCooperation.PlanLastPublished__c = fiaCooperation.plan.sistPublisert;
            iaCooperation.PlanLastPublished__c = fiaCooperation.plan.sistPublisert;
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

    private void handleSubthemeV1(
        FiaCooperation.Undertema undertema,
        String iaThemeReference,
        FiaCooperation fiaCooperation
    ) {
        IA_Subtheme__c iaSubtheme = createSubtheme(undertema, iaThemeReference, fiaCooperation);
        iaSubthemesToUpsert.add(iaSubtheme);
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
        System.debug(stackTrace);
        String errorRef = logger.logError(referenceInfo, message, stackTrace);
        logger.setMessageErrors(kafkaMessages, errorRef);
    }

    /**
     * @description Custom exception class for FiaCooperationHandler. Created so exceptions can be manually thrown in code.
     */
    public class FiaCooperationHandlerException extends Exception {
    }
}
