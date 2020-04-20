public inherited sharing class KafkaPermitteringHandler implements IKafkaMessageConsumer {

	public void processMessages( List<KafkaMessage__c> messages ) {

		List<KafkaPermitteringHandler_Model> permitteringer = KafkaPermitteringHandler_Helper.convertKafkaToPermittering( messages );
		List<String> organisationNumbers = KafkaPermitteringHandler_Helper.getOrgNumbersFromPermittering( permitteringer );
		Map<String, Account> accountMap = SharedIntegrationFunctions.fetchAccounts( organisationNumbers );
		System.debug( 'permitteringer: ' + permitteringer );
		System.debug( 'organisationNumbers: ' + organisationNumbers );
		System.debug( 'accountMap: ' + accountMap );

		// creates a list of each user / contact
		List<SharedIntegrationFunctions_Helper.ContactWrapper> wrapperList = KafkaPermitteringHandler_Helper.convertPermitteringToContactWrapper( permitteringer );
		System.debug( 'wrapperList: ' + wrapperList );

		// will create non-existing contacts and fetch those already existing + map existing contacts to new accounts if represnting another unit
		Map<String, Contact> contactMap = SharedIntegrationFunctions.fetchOrCreateContact( wrapperList, accountMap );
		System.debug( 'contactMap: ' + contactMap );

		// create SObject version of layoff
		List<TemporaryLayoff__c> layoffs = KafkaPermitteringHandler_Helper.convertPermitteringToLayoff( permitteringer, accountMap, contactMap );
		System.debug( 'layoffs: ' + layoffs );
		insert layoffs;
	}
}