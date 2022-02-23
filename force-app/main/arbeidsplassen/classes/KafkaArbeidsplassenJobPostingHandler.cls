/**
 * Created by jordanmathews on 23/02/2022.
 */

public with sharing class KafkaArbeidsplassenJobPostingHandler implements IKafkaMessageConsumer {
    public void processMessages(List<KafkaMessage__c> messages) {
        //List<JobPosting__c> activities = new List<JobPost__c>();

        for (KafkaMessage__c msg : messages) {
            try {
                ArbeidsplassenJobPosting jobPosting = convertMessageToJobPosting(msg);
                msg.CRM_Status__c = KafkaMessageService.STATUS_PROCESSED;
            } catch (Exception e) {
                msg.CRM_Status__c = KafkaMessageService.STATUS_ERROR;
                msg.CRM_ErrorMessage__c = e.getMessage() + ' (' + e.getLineNumber() + ')';
            }
        }
    }

    private ArbeidsplassenJobPosting convertMessageToJobPosting(KafkaMessage__c message) {
        String decodedValue = KafkaMessageUtils.base64ULSafeDecode(message.CRM_Value__c).toString();

        ArbeidsplassenJobPosting model = ArbeidsplassenJobPosting.parse(
            decodedValue,
            message.CRM_Key__c,
            message.CRM_Value__c
        );
        return model;
    }
}
