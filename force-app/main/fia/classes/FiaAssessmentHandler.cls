/**
 * @description Handler class to process inbound Kafka messages and create Fia Assessments.
 * Contains functions to parse data from messages, create IADelivery__c records and upsert them.
 */
public without sharing class FiaAssessmentHandler extends KafkaMessageProcessor implements IKafkaMessageConsumer {
    private static final string IA_DELIVERY_TYPE = 'Assessment';
    /**
     * @description Implementation of processMessages-method from IKafkaMessageConsumer
     * @param messages List of kafka message records
     */
    public void processMessages(List<KafkaMessage__c> messages) {
        Map<String, FiaAssessment> keyToFiaAssessmentMap = extractFiaAssessmentData(messages);

        List<IADelivery__c> iaDeliveryRecords = createIADeliveryRecords(keyToFiaAssessmentMap, messages);
        // Perform database operations on records
        upsertIADeliveryRecords(iaDeliveryRecords, messages);
        logger.publish();
    }

    /**
     * @description Extract data, parse messages and store in map
     * @param messages List of Kafka message records
     * @return New map with extracted FiaAssessments
     */
    @TestVisible
    private Map<String, FiaAssessment> extractFiaAssessmentData(List<KafkaMessage__c> messages) {
        Map<String, FiaAssessment> keyToFiaAssessmentMap = new Map<String, FiaAssessment>();

        for (KafkaMessage__c msg : messages) {
            try {
                FiaAssessment fiaAssessment = (FiaAssessment) parse(FiaAssessment.class, msg);
                keyToFiaAssessmentMap.put(fiaAssessment.key, fiaAssessment);
                msg.CRM_Status__c = KafkaMessageService.STATUS_PROCESSED;
            } catch (Exception e) {
                String errorRef = logger.logError(e.getMessage() + '/n' + e.getStackTraceString());
                logger.setMessageErrors(new List<KafkaMessage__c>{ msg }, errorRef);
            }
        }
        return keyToFiaAssessmentMap;
    }

    /**
     * @description Creates IADelivery__c records from parsed FiaAssessment data.
     * @param keyToFiaAssessmentMap Map of FiaAssessment objects
     * @param kafkaMessages List of Kafka message records
     * @return List of IADelivery__c records
     */
    @TestVisible
    private List<IADelivery__c> createIADeliveryRecords(
        Map<String, FiaAssessment> keyToFiaAssessmentMap,
        List<KafkaMessage__c> kafkaMessages
    ) {
        List<IADelivery__c> iaDeliveryRecords = new List<IADelivery__c>();
        Map<String, KafkaMessage__c> keyToKafkaMessageMap = mapKeyToKafkaMessages(kafkaMessages);

        Set<String> existingCooperations = getExistingCooperations(keyToFiaAssessmentMap.values());
        Set<String> existingCasenumbers = getExistingCases(keyToFiaAssessmentMap.values());

        for (FiaAssessment fa : keyToFiaAssessmentMap.values()) {
            try {
                if (!String.isBlank(fa.prosessId)) {
                    //Check if process id is in set
                    //if not, throw error
                    if (!existingCooperations.Contains(fa.prosessId)) {
                        throw new FiaAssessmentHandlerException(
                            'IA Cooperation not found in Salesforce: ' + fa.prosessId
                        );
                    }
                    //if true, create new ia cooperation reference
                    //new IACooperation__c(CooperationId__c =fa.prosessId)
                    // also create new case reference
                    // new IACase__c(Name = fa.saksnummer)
                    // then create new record
                    IADelivery__c iad = createIADeliveryRecord(
                        fa,
                        new IACooperation__c(CooperationId__c = fa.prosessId),
                        new IACase__c(Name = fa.saksnummer)
                    );
                    iaDeliveryRecords.add(iad);
                } else if (!String.isBlank(fa.saksnummer)) {
                    //Check if case id is in set
                    //if not, throw error
                    if (!existingCasenumbers.Contains(fa.saksnummer)) {
                        throw new FiaAssessmentHandlerException('IA Case not found in Salesforce: ' + fa.saksnummer);
                    }
                    //if true, create new ia case reference
                    // then create new record
                    IADelivery__c iad = createIADeliveryRecord(
                        fa,
                        new IACooperation__c(CooperationId__c = null),
                        new IACase__c(Name = fa.saksnummer)
                    );
                    iaDeliveryRecords.add(iad);
                } else {
                    //throw error about no ids provided.
                    throw new FiaAssessmentHandlerException(
                        'No parent id was provided in message for ' + fa.behovsvurderingId
                    );
                }
            } catch (Exception e) {
                String errorRef = logger.logError(e.getMessage() + '/n' + e.getStackTraceString());
                logger.setMessageErrors(new List<KafkaMessage__c>{ keyToKafkaMessageMap.get(fa.key) }, errorRef);
            }
        }

        return iaDeliveryRecords;
    }

    /**
     * @description Upserts IADelivery__c records and handles errors.
     * @param iaDeliveryRecords List of IADelivery__c records
     * @param kafkaMessages List of Kafka message records
     */
    @TestVisible
    private void upsertIADeliveryRecords(List<IADelivery__c> iaDeliveryRecords, List<KafkaMessage__c> kafkaMessages) {
        Map<String, KafkaMessage__c> keyToKafkaMessageMap = mapKeyToKafkaMessages(kafkaMessages);

        try {
            Schema.SObjectField f = IADelivery__c.Fields.KafkaId__c;
            Database.UpsertResult[] upsertResults = Database.upsert(iaDeliveryRecords, f, false);

            for (Integer i = 0; i < upsertResults.size(); i++) {
                if (!upsertResults[i].isSuccess()) {
                    String errorRef = logger.logError(upsertResults[i].getErrors()[0].getMessage());
                    logger.setMessageErrors(
                        new List<KafkaMessage__c>{ keyToKafkaMessageMap.get(iaDeliveryRecords[i].KafkaId__c) },
                        errorRef
                    );
                }
            }
        } catch (Exception e) {
            String errorRef = logger.logError(e.getMessage() + '/n' + e.getStackTraceString());
            logger.setMessageErrors(kafkaMessages, errorRef);
        }
    }

    /** createIADeliveryRecord(fa,new IACooperation__c(CooperationId__c =null), new IACase__c(Name = fa.saksnummer)
     * @description Creates a single IADelivery__c record from a FiaAssessment object.
     * @param fiaAssessment FiaAssessment object
     * @param caseId Related IACase__c ID
     * @return IADelivery__c record
     */
    private IADelivery__c createIADeliveryRecord(
        FiaAssessment fiaAssessment,
        IACooperation__c iaCooperationReference,
        IACase__c iaCaseReference
    ) {
        IADelivery__c iad = new IADelivery__c();
        iad.Name = String.valueOf(fiaAssessment.behovsvurderingId);
        iad.IACase__r = iaCaseReference;
        iad.IA_Cooperation__r = iaCooperationReference;
        if (!String.isBlank(fiaAssessment.fullfortTidspunkt)) {
            iad.CompletedDate__c = dateTimeValue(fiaAssessment.fullfortTidspunkt);
        }
        iad.Type__c = IA_DELIVERY_TYPE;
        iad.KafkaId__c = fiaAssessment.key;
        iad.KafkaHash__c = fiaAssessment.hash;
        iad.JsonPayload__c = fiaAssessment.jsonPayload;
        return iad;
    }

    /**
     * @description Query existing IACase__c records from database and return new map with case numbers and IACase__c records.
     * @param keyToFiaAssessmentMap Map with fia assessments objects
     * @return Map of case number to IACase__c records
     */
    private Map<String, IACase__c> mapCaseNumbersToIACases(Map<String, FiaAssessment> keyToFiaAssessmentMap) {
        Map<String, IACase__c> caseNumberToIACaseMap = new Map<String, IACase__c>();
        Set<String> caseNumbers = new Set<String>();

        for (FiaAssessment fa : keyToFiaAssessmentMap.values()) {
            caseNumbers.add(fa.saksnummer);
        }

        for (IACase__c iaCase : [SELECT Id, Name FROM IACase__c WHERE Name IN :caseNumbers]) {
            caseNumberToIACaseMap.put(iaCase.Name, iaCase);
        }

        return caseNumberToIACaseMap;
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

    private boolean hasProcessId(FiaAssessment fiaAssesment) {
        if (String.isBlank(fiaAssesment.prosessId)) {
            return false;
        }
        return true;
    }

    private Set<String> getExistingCooperations(List<FiaAssessment> fiaAssessment) {
        Set<String> prosessIds = new Set<String>();
        for (FiaAssessment fa : fiaAssessment) {
            prosessIds.add(fa.prosessId);
        }
        Set<String> existingCooperationIds = new Set<String>();
        for (IACase__c iaCooperation : [
            SELECT CooperationId__c
            FROM IACooperation__c
            WHERE CooperationId__c IN :prosessIds
            WITH SECURITY_ENFORCED
        ]) {
            existingCooperationIds.add(iaCooperation.CooperationId__c);
        }
        return existingCooperationIds;
    }

    private Set<String> getExistingCases(List<FiaAssessment> fiaAssessment) {
        Set<String> caseNumbers = new Set<String>();
        for (FiaAssessment fa : fiaAssessment) {
            caseNumbers.add(fa.saksnummer);
        }
        Set<String> existingCaseNumbers = new Set<String>();
        for (IACase__c iaCase : [SELECT Name FROM IACase__c WHERE Name IN :caseNumbers WITH SECURITY_ENFORCED]) {
            existingCaseNumbers.add(iaCase.Name);
        }
        return existingCaseNumbers;
    }

    public class FiaAssessmentHandlerException extends Exception {
    }
}
