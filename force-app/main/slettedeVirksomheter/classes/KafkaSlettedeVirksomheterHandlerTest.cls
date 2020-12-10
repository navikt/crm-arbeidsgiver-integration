@IsTest
private without sharing class KafkaSlettedeVirksomheterHandlerTest {
	@IsTest
	public static void testNewKafkaMessages() {

KafkaEnhetFilter.bypassFilter = true;

		Account acc = new Account( Name = 'Test Employer 1', INT_OrganizationNumber__c = '99999999' );
		insert acc;

		Account acc2 = new Account( Name = 'Test Employer 2', INT_OrganizationNumber__c = '77777777' );
		insert acc2;

		List<Account> accts = [SELECT Id FROM Account WHERE TAG_IsDeleted__c = true];
		System.assertEquals( 0, accts.size(), 'No accounts deleted' );

		List<KafkaMessage__c> messages = new List<KafkaMessage__c>();
		KafkaMessage__c msg1 = new KafkaMessage__c();
		msg1.CRM_Topic__c = 'public-ereg-cache-org-tombstones';
		msg1.CRM_Key__c = '99999999';
		msg1.CRM_Value__c = '99999999';
		messages.add( msg1 );

		KafkaMessage__c msg2 = new KafkaMessage__c();
		msg2.CRM_Topic__c = 'public-ereg-cache-org-tombstones';
		msg2.CRM_Key__c = '77777777';
		msg2.CRM_Value__c = '77777777';
		messages.add( msg2 );

		Test.startTest();
		AsyncRequestSchedulable.enqueueAsyncJobs();
		Test.stopTest();

		accts = [SELECT Id, TAG_DeletedDate__c FROM Account WHERE TAG_IsDeleted__c = true];
		System.assertEquals( 2, accts.size(), 'two accounts deleted' );
		System.assertEquals( Date.today(), accts[0].TAG_DeletedDate__c, 'deleted date is today' );

	}
}
