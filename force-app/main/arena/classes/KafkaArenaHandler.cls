public inherited sharing class KafkaArenaHandler implements IKafkaMessageConsumer {

	public void processMessages( List<KafkaMessage__c> messages ) {

		List<KafkaArenaHandler_Model> arenaModels = KafkaArenaHandler_Helper.convertKafkaToArenaModel( messages );


	}
}