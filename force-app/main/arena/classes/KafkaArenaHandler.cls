public without sharing class KafkaArenaHandler extends KafkaMessageProcessor implements IKafkaMessageConsumer {
    public void processMessages(List<KafkaMessage__c> messages) {
        List<KafkaArenaHandler_Model> arenaModels = KafkaArenaHandler_Helper.convertKafkaToArenaModel(messages);

        try {
            List<String> orgNumbers = KafkaArenaHandler_Helper.getOrgNumbers(arenaModels);
            Map<String, Account> accountMap = SharedFunctions.fetchAccounts(orgNumbers);

            Set<String> kafkaIds = KafkaArenaHandler_Helper.getKafkaIds(arenaModels);
            Map<String, ArenaActivity__c> existingActivities = KafkaArenaHandler_Helper.getArenaActivity(kafkaIds);

            List<ArenaActivity__c> arenaActivities = KafkaArenaHandler_Helper.convertArenaModelToSObject(
                arenaModels,
                accountMap,
                existingActivities
            );
            arenaActivities = KafkaArenaHandler_Helper.removeDuplicates(arenaActivities);

            upsert arenaActivities ArenaActivity__c.KafkaId__c;
        } catch (Exception e) {
            String errorRef = logger.logError(e.getMessage() + '/n' + e.getStackTraceString());
            logger.setMessageErrors(messages, errorRef);
        }
    }
}
