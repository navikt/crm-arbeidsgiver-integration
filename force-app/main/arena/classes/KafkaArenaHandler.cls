public inherited sharing class KafkaArenaHandler implements IKafkaMessageConsumer {

	public void processMessages( List<KafkaMessage__c> messages ) {

		List<KafkaArenaHandler_Model> arenaModels = KafkaArenaHandler_Helper.convertKafkaToArenaModel( messages );
		List<String> orgNumbers =                   KafkaArenaHandler_Helper.getOrgNumbers( arenaModels );
		Set<String> userTitles =                    KafkaArenaHandler_Helper.getUserTitles( arenaModels );
		Map<String, Account> accountMap =           SharedIntegrationFunctions.fetchAccounts( orgNumbers );
		Map<String, User> userMap =                 SharedIntegrationFunctions.fetchUsersByTitle( userTitles );
		List<ArenaActivity__c> arenaActivities =    KafkaArenaHandler_Helper.convertArenaModelToSObject( arenaModels, userMap, accountMap );

		insert arenaActivities;
	}
}