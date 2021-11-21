public inherited sharing class KafkaKontaktSkjemaHandler implements IKafkaMessageConsumer{
    public void processMessages(List<KafkaMessage__c> messages) {
        List<KafkaKontaktSkjemaHandler_Model> kontaktskjema = KafkaKontaktSkjemaHandler_Helper.convertKafkaToOpportunity(
            messages
        );
    List<CustomOpportunity__c> opportunities = KafkaKontaktSkjemaHandler_Helper.convertKontaktskjemaToOpportunity(kontaktskjema);
    KafkaKontaktSkjemaHandler_Helper.sendEmailReceipt(opportunities);
    }
}
