public inherited sharing class KafkaArenaHandler implements IKafkaMessageConsumer {

	public void processMessages( List<KafkaMessage__c> messages ) {

		List<KafkaArenaHandler_Model> arenaModels = KafkaArenaHandler_Helper.convertKafkaToArenaModel( messages );

		Map<String, User> userMap = SharedIntegrationFunctions.getUsersByTitle( new Set<String> { 'GL1812', 'JEI1812' } );
		Map<String, Account> accountMap = SharedIntegrationFunctions.fetchAccounts( new List<String> { '973113631' } );


	}
}