public inherited sharing class KafkaArenaHandler_Filter implements IKafkaMessageFilter {
    @TestVisible
    public static Boolean bypassFilter = false;
    private static List<Id> recordIdsToDelete = new List<Id>();
    private static Boolean isSandbox = [
        SELECT Id, InstanceName, IsSandbox, Name, OrganizationType
        FROM Organization
        LIMIT 1
    ]
    .IsSandbox;

    public Set<Id> filterMessages(List<KafkaMessage__c> messages) {
        // Return full set of message ids if we are in a production environment
        if (!isSandbox)
            return new Map<Id, SObject>(messages).keySet();

        // Otherwise filter messages by type and based on number of Account records already in the environment
        List<KafkaMessage__c> filteredMessages = new List<KafkaMessage__c>();
        // filteredMessages = filterByType( messages );
        filteredMessages = filterByTotalRecordCount(messages);

        if (recordIdsToDelete.size() > 0) {
            Database.delete(recordIdsToDelete);
            Database.emptyRecycleBin(recordIdsToDelete);
        }

        return new Map<Id, KafkaMessage__c>(filteredMessages).keySet();
    }

    // private List<KafkaMessage__c> filterByType( List<KafkaMessage__c> messages ) {
    // 	List<KafkaMessage__c> filteredMessages = new List<KafkaMessage__c>();
    // 	for ( KafkaMessage__c msg : messages ) {
    // 		if ( msg.CRM_Key__c.contains( 'UNDERENHET' ) ) {
    // 			filteredMessages.add( msg );
    // 		} else {
    // 			recordIdsToDelete.add( msg.Id );
    // 		}
    // 	}

    // 	return filteredMessages;
    // }

    private List<KafkaMessage__c> filterByTotalRecordCount(List<KafkaMessage__c> messages) {
        if (messages.size() == 0)
            return messages;

        List<KafkaMessage__c> messagesToKeep = new List<KafkaMessage__c>();

        // If we will be at record limit after this insert
        // we check if the accounts already exist in the org
        if ([SELECT COUNT() FROM ArenaActivity__c] > 10000) {
            Map<String, KafkaMessage__c> msgByKafkaId = new Map<String, KafkaMessage__c>();
            for (KafkaMessage__c msg : messages) {
                msgByKafkaId.put(msg.CRM_Key__c, msg);
            }

            Set<String> existingKafkaIds = new Set<String>();
            for (ArenaActivity__c aa : [
                SELECT Id, KafkaId__c
                FROM ArenaActivity__c
                WHERE KafkaId__c IN :msgByKafkaId.keySet()
            ]) {
                existingKafkaIds.add(aa.KafkaId__c);
            }

            for (String kafkaId : msgByKafkaId.keySet()) {
                if (existingKafkaIds.contains(kafkaId)) {
                    messagesToKeep.add(msgByKafkaId.get(kafkaId));
                } else {
                    recordIdsToDelete.add(msgByKafkaId.get(kafkaId).Id);
                }
            }
        } else {
            messagesToKeep.addAll(messages);
        }

        return messagesToKeep;
    }
}
