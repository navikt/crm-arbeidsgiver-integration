public without sharing class KafkaSlettedeVirksomheterHandler implements IKafkaMessageConsumer {
    public void processMessages(List<KafkaMessage__c> messages) {
        Set<String> orgNrs = convertKafka(messages);
        accountsToUpdate(orgNrs);
    }

    public Set<String> convertKafka(List<KafkaMessage__c> messages) {
        Set<String> orgNrs = new Set<String>();

        for (KafkaMessage__c msg : messages) {
            msg.CRM_Status__c = 'Processed';
            orgNrs.add(msg.CRM_Key__c);
        }

        return orgNrs;
    }

    public void accountsToUpdate(Set<String> orgNrs) {
        List<Account> acts = [
            SELECT Id
            FROM Account
            WHERE INT_OrganizationNumber__c IN :orgNrs AND TAG_IsDeleted__c = FALSE
        ];
        for (Account act : acts) {
            act.IsDeletedEmployer__c = true;
            act.TAG_DeletedDate__c = Date.today();
        }

        update acts;
    }
}
