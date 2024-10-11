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

        upsertIADeliveryRecords(iaDeliveryRecords, messages);
        logger.publish();
    }

    /**
     * @description Extract data, parse messages and store in map
     * @param messages List of Kafka message records
     * @return New map with extracted FiaAssessments
     */
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
     * @description Creates IADelivery__c records from parsed FiaAssessment data. Method verifies that at least one of either processId or saksnummer is provided and exists in SF.
     * @param keyToFiaAssessmentMap Map of FiaAssessment objects
     * @param kafkaMessages List of Kafka message records
     * @return List of IADelivery__c records
     */
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
                IACooperation__c cooperationReference = existingCooperations.Contains(fa.prosessId)
                    ? new IACooperation__c(CooperationId__c = fa.prosessId)
                    : null;
                IACase__c caseReference = existingCasenumbers.Contains(fa.saksnummer)
                    ? new IACase__c(Name = fa.saksnummer)
                    : null;
                //Check if either processId or saksnummer is provided and exists in set. If not, throw error.
                if (cooperationReference == null && caseReference == null) {
                    throw new FiaAssessmentHandlerException('No related records not found in Salesforce');
                }
                IADelivery__c iad = createIADeliveryRecord(fa, cooperationReference, caseReference);
                iaDeliveryRecords.add(iad);
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

    /** @description Creates a single IADelivery__c record from a FiaAssessment object.
     * @param fiaAssessment FiaAssessment object
     * @param iaCooperationReference Record referencing related IA Cooperation
     * @param iaCaseReference Record referencing related IA Case
     * @return New IADelivery__c record
     */
    private IADelivery__c createIADeliveryRecord(
        FiaAssessment fiaAssessment,
        IACooperation__c iaCooperationReference,
        IACase__c iaCaseReference
    ) {
        IADelivery__c iad = new IADelivery__c(
            Name = fiaAssessment.behovsvurderingId,
            Type__c = IA_DELIVERY_TYPE,
            KafkaId__c = fiaAssessment.key,
            KafkaHash__c = fiaAssessment.hash,
            JsonPayload__c = fiaAssessment.jsonPayload
        );
        if (!String.isBlank(fiaAssessment.fullfortTidspunkt)) {
            iad.CompletedDate__c = dateTimeValue(fiaAssessment.fullfortTidspunkt);
        }
        if (iaCooperationReference != null) {
            iad.IA_Cooperation__r = iaCooperationReference;
        }
        if (iaCaseReference != null) {
            iad.IACase__r = iaCaseReference;
        }
        return iad;
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
     * @description Queries existing IACooperation__c records based on provided objects.
     * @param fiaAssessment List with fia assessments objects to check
     * @return Set with FiaAssessment.prosessId that exists in Salesforce
     */
    private Set<String> getExistingCooperations(List<FiaAssessment> fiaAssessment) {
        Set<String> prosessIds = new Set<String>();
        for (FiaAssessment fa : fiaAssessment) {
            prosessIds.add(fa.prosessId);
        }
        Set<String> existingCooperationIds = new Set<String>();
        for (IACooperation__c iaCooperation : [
            SELECT CooperationId__c
            FROM IACooperation__c
            WHERE CooperationId__c IN :prosessIds
            WITH SECURITY_ENFORCED
        ]) {
            existingCooperationIds.add(iaCooperation.CooperationId__c);
        }
        return existingCooperationIds;
    }

    /**
     * @description Queries existing IACase__c records based on provided objects.
     * @param fiaAssessment List with fia assessments objects to check
     * @return Set with FiaAssessment.saksnummer that exists in Salesforce
     */
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

    /**
     * @description Custom exception class for FiaAssessmentHandler. Created so exceptions can be manually thrown in code.
     */
    public class FiaAssessmentHandlerException extends Exception {
    }
}
