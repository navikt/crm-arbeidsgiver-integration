/**
 * @description Handler class to process inbound Kafka messages and create IA Cooperation records, IA Themes and IA Subthemes.
 * Contains functions to parse data from messages, create records and upsert them.
 */
public without sharing class FiaCooperationHandler extends KafkaMessageProcessor implements IKafkaMessageConsumer {
    private Map<String, KafkaMessage__c> keyToKafkaMessageMap = new Map<String, KafkaMessage__c>();
    private List<IACooperation__c> iaCooperationsToUpsert = new List<IACooperation__c>();
    private List<IACooperation__c> iaPlansToUpsert = new List<IACooperation__c>();
    private List<IATheme__c> iaThemesToUpsert = new List<IATheme__c>();
    private List<IA_Subtheme__c> iaSubthemesToUpsert = new List<IA_Subtheme__c>();
    Map<String, FiaCooperation> fiaSamarbeidMap = new Map<String, FiaCooperation>();
    Map<String, FiaCooperation.Plan> fiaPlanMap = new Map<String, FiaCooperation.Plan>();

    /**
     * @description Implementation of processMessages-method from IKafkaMessageConsumer
     * @param messages List of kafka message records
     */
    public void processMessages(List<KafkaMessage__c> messages) {
        List<FiaCooperation> fiaCooperations = extractData(messages);
        //traverse kafka messages
        //parse json to object
        //mark kafka message as prosessed
        //track kafka messages that that involves further handling
        keyToKafkaMessageMap = mapKeyToKafkaMessages(messages);

        //determine handling for objects
        for (FiaCooperation fiaCooperation : fiaCooperations) {
            System.debug('Prosessing ' + fiaCooperation.samarbeid.navn);
            if (!fiaSamarbeidMap.containsKey(fiaCooperation.samarbeid.id)) {
                fiaSamarbeidMap.put(fiaCooperation.samarbeid.id, fiaCooperation);
                System.debug('added in fiaSamarbeidMap: ' + fiaCooperation.samarbeid.navn);
            } else if (fiaCooperation.samarbeid.endretTidspunkt != null) {
                if (
                    !(fiaSamarbeidMap.get(fiaCooperation.samarbeid.id)?.samarbeid?.endretTidspunkt >
                    fiaCooperation.samarbeid.endretTidspunkt)
                ) {
                    fiaSamarbeidMap.put(fiaCooperation.samarbeid.id, fiaCooperation);
                    System.debug('replaced in fiaSamarbeidMap: ' + fiaCooperation.samarbeid.navn);
                }
            }

            if (fiaCooperation.plan != null) {
                if (!fiaPlanMap.containsKey(fiaCooperation.samarbeid.id)) {
                    fiaPlanMap.put(fiaCooperation.samarbeid.id, fiaCooperation.plan);
                    System.debug('added in fiaPlanMap: ' + fiaCooperation.samarbeid.navn);
                } else if (
                    !(fiaPlanMap.get(fiaCooperation.samarbeid.id)?.sistEndret > fiaCooperation.plan.sistEndret)
                ) {
                    fiaPlanMap.put(fiaCooperation.samarbeid.id, fiaCooperation.plan);
                    System.debug('replaced to fiaPlanMap: ' + fiaCooperation.samarbeid.navn);
                }
            }
        }
        //have map with most recent of each type, now combine to one list.
        for (String cooperationId : fiaSamarbeidMap.keySet()) {
            if (fiaPlanMap.containsKey(cooperationId)) {
                fiaSamarbeidMap.get(cooperationId).plan = fiaPlanMap.get(cooperationId);
            }
        }

        //handle objects
        if (!fiaSamarbeidMap.isEmpty()) {
            createRecords(fiaSamarbeidMap.values());
        }
        System.debug('iaCooperationsToUpsert: ' + iaCooperationsToUpsert);
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
     * @description Creates a map with provided list of records
     * @param kafkaMessages List of Kafka messages
     * @return New map with CRM Key and Kafka Message
     */
    private Map<String, KafkaMessage__c> mapKeyToKafkaMessages(List<KafkaMessage__c> kafkaMessages) {
        Map<String, KafkaMessage__c> keyToKafkaMessageMap = new Map<String, KafkaMessage__c>();
        for (KafkaMessage__c kafkaMessage : kafkaMessages) {
            keyToKafkaMessageMap.put(kafkaMessage.CRM_Key__c, kafkaMessage);
        }
        return keyToKafkaMessageMap;
    }

    /**
     * @description Processes a list of Kafka Message records and extracts FiaCooperation objects, organizing them
     *  into a map keyed by their unique identifier. Each message is parsed into a FiaCooperation object, and only
     *  the most recent entry (based on the 'sistEndret' timestamp) is stored in the map. If an object with a newer
     *  timestamp already exists in the map, the message is marked as processed but not added to the map.
     * The corresponding Kafka Message is also added to a secondary map to allow for status updates in case of
     *  exceptions during subsequent sObject creation. All messages that are successfully parsed, regardless of
     *  whether they are added to the map, will have their status updated to 'processed'.
     *
     * @param kafkaMessages List of Kafka Message records to be processed.
     * @return A map containing FiaCooperation objects keyed by their unique identifier.
     */
    private List<FiaCooperation> extractData(List<KafkaMessage__c> kafkaMessages) {
        List<FiaCooperation> fiaCooperations = new List<FiaCooperation>();
        for (KafkaMessage__c kafkaMessage : kafkaMessages) {
            try {
                FiaCooperation fiaCooperation = (FiaCooperation) parse(FiaCooperation.class, kafkaMessage);
                fiaCooperations.add(fiaCooperation);
                kafkaMessage.CRM_Status__c = KafkaMessageService.STATUS_PROCESSED;
            } catch (Exception e) {
                String errorRef = logger.logError(e.getMessage() + '/n' + e.getStackTraceString());
                logger.setMessageErrors(new List<KafkaMessage__c>{ kafkaMessage }, errorRef);
            }
        }
        return fiaCooperations;
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
                    String errorRef = logger.logError(
                        upsertResults[i].getErrors()[0].getMessage() +
                            ' - FiaCooperationHandler.upsertRecords() could not upsert record. Key: ' +
                            kafkaKey
                    );
                    logger.setMessageErrors(new List<KafkaMessage__c>{ keyToKafkaMessageMap.get(kafkaKey) }, errorRef);
                }
            }
        } catch (Exception e) {
            String errorRef = logger.logError(e.getMessage() + '/n' + e.getStackTraceString());
            logger.setMessageErrors(keyToKafkaMessageMap.values(), errorRef);
        }
    }

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

    /**
     * @description Creates records from parsed FiaCooperation data.
     * @param fiaCooperations List with FiaCooperation objects
     */
    private void createRecords(List<FiaCooperation> fiaCooperations) {
        Set<String> existingCasenumbers = getExistingCases(fiaCooperations);

        for (FiaCooperation fiaCooperation : fiaCooperations) {
            System.debug('createRecords: ' + fiaCooperation.samarbeid.navn);
            try {
                if (!existingCasenumbers.Contains(fiaCooperation.saksnummer)) {
                    throw new FiaCooperationHandlerException(
                        'IA Case not found in Salesforce: ' + fiaCooperation.saksnummer
                    );
                }
                //create samarbeid
                IACooperation__c iaCooperation = createIACooperation(fiaCooperation);
                iaCooperationsToUpsert.add(iaCooperation);
                System.debug('createIACooperation: ' + iaCooperation.Name);

                for (FiaCooperation.Tema tema : fiaCooperation.plan?.temaer) {
                    IATheme__c iaTheme = createTheme(tema, fiaCooperation);
                    iaThemesToUpsert.add(iaTheme);
                    for (FiaCooperation.Undertema undertema : tema.undertemaer) {
                        if (undertema.inkludert == true) {
                            // ToDo: Legg til logikk for fjernede undertema
                            //Ikke opprettet: inkludert false og status blank,
                            //Opprettet og fjernet: inkludert false og status SLETTET
                            IA_Subtheme__c iaSubtheme = createSubtheme(undertema, tema.id, fiaCooperation);
                            iaSubthemesToUpsert.add(iaSubtheme);
                        }
                    }
                }
            } catch (Exception e) {
                String errorRef = logger.logError(e.getMessage() + '/n' + e.getStackTraceString());
                logger.setMessageErrors(
                    new List<KafkaMessage__c>{ keyToKafkaMessageMap.get(fiaCooperation.key) },
                    errorRef
                );
            }
        }
    }

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
        }
        return iaCooperation;
    }

    // Helper method to set a field only if the value is not blank
    private void setFieldIfNotBlank(SObject obj, String fieldName, String value) {
        if (!String.isBlank(value)) {
            obj.put(fieldName, value);
        }
    }
    private void setFieldIfNotBlank(SObject obj, String fieldName, Date value) {
        if (value != null) {
            obj.put(fieldName, value);
        }
    }
    private void setFieldIfNotBlank(SObject obj, String fieldName, Datetime value) {
        if (value != null) {
            obj.put(fieldName, value);
        }
    }

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

    /**
     * @description Custom exception class for FiaCooperationHandler. Created so exceptions can be manually thrown in code.
     */
    public class FiaCooperationHandlerException extends Exception {
    }
}
