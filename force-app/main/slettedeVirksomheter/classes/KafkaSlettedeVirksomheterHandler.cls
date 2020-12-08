public without sharing class KafkaSlettedeVirksomheterHandler implements IKafkaMessageConsumer {
	public void processMessages( List<KafkaMessage__c> messages ) {
		String orgNr;

		for ( KafkaMessage__c msg : messages ) {
			try {
				msg.CRM_Status__c = 'Processed';
				orgNr = msg.CRM_Value__c;
			} catch ( Exception e ) {
				msg.CRM_ErrorMessage__c = e.getMessage() + ' (' + e.getLineNumber() + ')';
			}
		}
		accountsToUpdate( orgNr );
	}

	public void accountsToUpdate( String orgNr ) {
		List<Account> acts = [SELECT Id, INT_OrganizationNumber__c, IsDeleted__c FROM Account WHERE INT_OrganizationNumber__c =: orgNr];
		for ( Account act : acts ) {
			act.IsDeleted__c = true;
		}
		update acts;
	}
}
