/**
 * @description Handler class to process inbound Kafka messages and create IA Cooperation records, IA Themes and IA Subthemes.
 * Contains functions to parse data from messages, create records and upsert them.
 */
public without sharing class FiaCooperationHandler extends KafkaMessageProcessor implements IKafkaMessageConsumer {
    private Map<String, KafkaMessage__c> keyToKafkaMessageMap;
    private List<IACooperation__c> iaCooperationsToUpsert = new List<IACooperation__c>();
    private List<IATheme__c> iaThemesToUpsert = new List<IATheme__c>();
    private List<IA_Subtheme__c> iaSubthemesToUpsert = new List<IA_Subtheme__c>();

    /**
     * @description Implementation of processMessages-method from IKafkaMessageConsumer
     * @param messages List of kafka message records
     */
    public void processMessages(List<KafkaMessage__c> messages) {
        keyToKafkaMessageMap = mapKeyToKafkaMessages(messages);
        Map<String, FiaCooperation> keyToObjectMap = extractData(messages);

        createRecords(keyToObjectMap.values(), messages);

        //Upsert cooperations
        upsertRecords(iaCooperationsToUpsert, messages, IACooperation__c.CooperationId__c);
        //Upsert themes
        upsertRecords(iaThemesToUpsert, messages, IATheme__c.ThemeId__c);
        //Upsert subthemes
        upsertRecords(iaSubthemesToUpsert, messages, IA_Subtheme__c.SubthemeId__c);

        logger.publish();
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
     * @description Extract data, parse messages and store in map
     * @param messages List of Kafka message records
     * @return New map with extracted FiaCooperation
     */
    private Map<String, FiaCooperation> extractData(List<KafkaMessage__c> messages) {
        Map<String, FiaCooperation> keyToObjectMap = new Map<String, FiaCooperation>();
        for (KafkaMessage__c msg : messages) {
            try {
                FiaCooperation fiaCooperation = (FiaCooperation) parse(FiaCooperation.class, msg);
                keyToObjectMap.put(fiaCooperation.key, fiaCooperation);
                msg.CRM_Status__c = KafkaMessageService.STATUS_PROCESSED;
            } catch (Exception e) {
                String errorRef = logger.logError(e.getMessage() + '/n' + e.getStackTraceString());
                logger.setMessageErrors(new List<KafkaMessage__c>{ msg }, errorRef);
            }
        }
        return keyToObjectMap;
    }

    /**
     * @description Upserts records and handles errors.
     * @param records List of records to upsert
     * @param kafkaMessages List of Kafka message records
     * @param externalId Field to use as external id during upsert
     */
    private void upsertRecords(
        List<sObject> records,
        List<KafkaMessage__c> kafkaMessages,
        Schema.SObjectField externalId
    ) {
        try {
            Database.UpsertResult[] upsertResults = Database.upsert(records, externalId, false);
            for (Integer i = 0; i < upsertResults.size(); i++) {
                if (!upsertResults[i].isSuccess()) {
                    String kafkaKey = (String) records[i].get('KafkaId__c');
                    String errorRef = logger.logError(
                        upsertResults[i].getErrors()[0].getMessage() +
                            '/nFiaCooperationHandler.upsertRecords() could not upsert record. Key: ' +
                            kafkaKey
                    );
                    logger.setMessageErrors(new List<KafkaMessage__c>{ keyToKafkaMessageMap.get(kafkaKey) }, errorRef);
                }
            }
        } catch (Exception e) {
            String errorRef = logger.logError(e.getMessage() + '/n' + e.getStackTraceString());
            logger.setMessageErrors(kafkaMessages, errorRef);
        }
    }

    /**
     * @description Creates records from parsed FiaCooperation data.
     * @param fiaCooperations List with FiaCooperation objects
     * @param kafkaMessages List of Kafka message records
     */
    private void createRecords(List<FiaCooperation> fiaCooperations, List<KafkaMessage__c> kafkaMessages) {
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
                    IATheme__c iaTheme = createTheme(tema, fiaCooperation.key);
                    iaThemesToUpsert.add(iaTheme);

                    for (FiaCooperation.Undertema undertema : tema.undertemaer) {
                        IA_Subtheme__c iaSubtheme = createSubtheme(undertema, tema.id, fiaCooperation.key);
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
        IACase__c caseReference = new IACase__c(Name = fiaCooperation.saksnummer);
        Account accountReference = new Account(INT_OrganizationNumber__c = fiaCooperation.orgnr);
        IACooperation__c iaCooperation = new IACooperation__c(
            CooperationId__c = fiaCooperation.samarbeid.id,
            Name = fiaCooperation.samarbeid.navn,
            IACase__r = caseReference,
            Account__r = accountReference,
            PlanId__c = fiaCooperation.plan.id,
            Status__c = fiaCooperation.samarbeid.status,
            PlanLastModified__c = fiaCooperation.plan.sistEndret,
            PlanLastPublished__c = fiaCooperation.plan.sistPublisert,
            StartDate__c = fiaCooperation.samarbeid.startDato,
            EndDate__c = fiaCooperation.samarbeid.sluttDato,
            KafkaId__c = fiaCooperation.key,
            KafkaHash__c = fiaCooperation.hash,
            JsonPayload__c = fiaCooperation.jsonPayload,
            IncludedArbeidsmiljo__c = fiaCooperation.includesArbeidsmiljo(),
            IncludedPartssamarbeid__c = fiaCooperation.includesPartssamarbeid(),
            IncludedSykefravaersarbeid__c = fiaCooperation.includesSykefravaersarbeid()
        );
        return iaCooperation;
    }

    private IATheme__c createTheme(FiaCooperation.Tema tema, String fiaCooperationReference) {
        IACooperation__c cooperationReference = new IACooperation__c(KafkaId__c = fiaCooperationReference);
        IATheme__c iaTheme = new IATheme__c(
            ThemeId__c = tema.id,
            Name = tema.navn,
            IsPlanned__c = tema.inkludert,
            IACooperation__r = cooperationReference,
            KafkaId__c = fiaCooperationReference
        );
        return iaTheme;
    }

    private IA_Subtheme__c createSubtheme(
        FiaCooperation.Undertema undertema,
        String iaThemeReference,
        String iaCooperationReference
    ) {
        IATheme__c themeReference = new IATheme__c(ThemeId__c = iaThemeReference);
        IACooperation__c cooperationReference = new IACooperation__c(KafkaId__c = iaCooperationReference);
        IA_Subtheme__c iaSubtheme = new IA_Subtheme__c(
            SubthemeId__c = undertema.id,
            Name = undertema.navn,
            Goal__c = undertema.malsetning,
            IsPlanned__c = undertema.inkludert,
            Status__c = undertema.status,
            StartDate__c = undertema.startDato,
            EndDate__c = undertema.sluttDato,
            IATheme__r = themeReference,
            IA_CooperationTheme__r = cooperationReference,
            KafkaId__c = iaCooperationReference
        );
        return iaSubtheme;
    }

    /**
     * @description Creates a map with CRM_Key__c and Kafka Message and returns it.
     * @param kafkaMessages List of Kafka messages
     * @return New map with CRM Key and Kafka Message
     */
    private Map<String, KafkaMessage__c> mapKeyToKafkaMessages(List<KafkaMessage__c> kafkaMessages) {
        keyToKafkaMessageMap = new Map<String, KafkaMessage__c>();
        for (KafkaMessage__c kafkaMessage : kafkaMessages) {
            keyToKafkaMessageMap.put(kafkaMessage.CRM_Key__c, kafkaMessage);
        }
        return keyToKafkaMessageMap;
    }

    /**
     * @description Custom exception class for FiaCooperationHandler. Created so exceptions can be manually thrown in code.
     */
    public class FiaCooperationHandlerException extends Exception {
    }
}
