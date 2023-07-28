public without sharing class KafkaFiaDeliveryHandler extends KafkaMessageProcessor implements IKafkaMessageConsumer{
    Map<String, KafkaFiaDelivery_Model> keyToFiaDelivery = new Map<String, KafkaFiaDelivery_Model>();
    public Set<String> caseNumbers;

    public void processMessages(List<KafkaMessage__c> messages) {
       
     }
}