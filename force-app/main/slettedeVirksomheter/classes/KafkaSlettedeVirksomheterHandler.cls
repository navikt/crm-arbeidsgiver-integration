public without sharing class KafkaSlettedeVirksomheterHandler implements IKafkaMessageConsumer {
	public void processMessages( List<KafkaMessage__c> messages ) {
		convertKafka( messages );
	}

	public void accountsToUpdate( Set<String> orgNrs ) {
		List<Account> acts = [SELECT Id, INT_OrganizationNumber__c, TAG_IsDeleted__c FROM Account WHERE INT_OrganizationNumber__c IN: orgNrs AND TAG_IsDeleted__c = false];
		for ( Account act : acts ) {
			act.TAG_IsDeleted__c = true;
			act.TAG_DeletedDate__c = Date.today();
		}

		update acts;
	}

	public void convertKafka( List<KafkaMessage__c> messages ) {
		Set<String> orgNrs = new Set<String>();

		for ( KafkaMessage__c msg : messages ) {
			msg.CRM_Status__c = 'Processed';
			orgNrs.add( msg.CRM_Key__c );
		}
		accountsToUpdate( orgNrs );

	}
}
