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
        Map<String, FiaCooperation> keyToObjectMap = extractData(messages);

        createRecords(keyToObjectMap.values());

        //Upsert cooperations
        upsertRecords(iaCooperationsToUpsert, IACooperation__c.CooperationId__c);
        //Upsert themes
        upsertRecords(iaThemesToUpsert, IATheme__c.ThemeId__c);
        //Upsert subthemes
        upsertRecords(iaSubthemesToUpsert, IA_Subtheme__c.SubthemeId__c);

        logger.publish();
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
    private Map<String, FiaCooperation> extractData(List<KafkaMessage__c> kafkaMessages) {
        Map<String, FiaCooperation> fiaCooperationMap = new Map<String, FiaCooperation>();

        for (KafkaMessage__c kafkaMessage : kafkaMessages) {
            try {
                FiaCooperation fiaCooperation = (FiaCooperation) parse(FiaCooperation.class, kafkaMessage);
                // Check if a object with a newer date already exists
                if (fiaCooperationMap.get(fiaCooperation.key)?.plan.sistEndret > fiaCooperation.plan.sistEndret) {
                    kafkaMessage.CRM_Status__c = KafkaMessageService.STATUS_PROCESSED;
                } else {
                    // Either no record exists, or the existing record is older
                    fiaCooperationMap.put(fiaCooperation.key, fiaCooperation);

                    // Add the message to keyToKafkaMessageMap to handle later exceptions
                    keyToKafkaMessageMap.put(kafkaMessage.CRM_Key__c, kafkaMessage);
                    kafkaMessage.CRM_Status__c = KafkaMessageService.STATUS_PROCESSED;
                }
            } catch (Exception e) {
                String errorRef = logger.logError(e.getMessage() + '/n' + e.getStackTraceString());
                logger.setMessageErrors(new List<KafkaMessage__c>{ kafkaMessage }, errorRef);
            }
        }
        return fiaCooperationMap;
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
            try {
                if (!existingCasenumbers.Contains(fiaCooperation.saksnummer)) {
                    throw new FiaCooperationHandlerException(
                        'IA Case not found in Salesforce: ' + fiaCooperation.saksnummer
                    );
                }
                IACooperation__c iaCooperation = createIACooperation(fiaCooperation);
                iaCooperationsToUpsert.add(iaCooperation);

                for (FiaCooperation.Tema tema : fiaCooperation.plan.temaer) {
                    IATheme__c iaTheme = createTheme(tema, fiaCooperation);
                    iaThemesToUpsert.add(iaTheme);

                    for (FiaCooperation.Undertema undertema : tema.undertemaer) {
                        IA_Subtheme__c iaSubtheme = createSubtheme(undertema, tema.id, fiaCooperation);
                        iaSubthemesToUpsert.add(iaSubtheme);
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
            Name = fiaCooperation.samarbeid.navn,
            CooperationId__c = fiaCooperation.samarbeid.id,
            Status__c = fiaCooperation.samarbeid.status,
            StartDate__c = fiaCooperation.samarbeid.startDato,
            EndDate__c = fiaCooperation.samarbeid.sluttDato,
            PlanId__c = fiaCooperation.plan.id,
            PlanLastModified__c = fiaCooperation.plan.sistEndret,
            PlanLastPublished__c = fiaCooperation.plan.sistPublisert,
            KafkaId__c = fiaCooperation.key,
            KafkaHash__c = fiaCooperation.hash,
            JsonPayload__c = fiaCooperation.jsonPayload,
            IACase__r = new IACase__c(Name = fiaCooperation.saksnummer),
            Account__r = new Account(INT_OrganizationNumber__c = fiaCooperation.orgnr),
            IncludedArbeidsmiljo__c = fiaCooperation.includesArbeidsmiljo(),
            IncludedPartssamarbeid__c = fiaCooperation.includesPartssamarbeid(),
            IncludedSykefravaersarbeid__c = fiaCooperation.includesSykefravaersarbeid()
        );
        return iaCooperation;
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
