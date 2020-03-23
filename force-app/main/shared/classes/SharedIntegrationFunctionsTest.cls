@isTest
private without sharing class SharedIntegrationFunctionsTest {

	@testSetup
	private static void setup() {

	}

	@isTest
	private static void testFetchAccounts() {

		Account acc = new Account( Name = 'Test Employer 1', INT_OrganizationNumber__c = '99999999' );
		insert acc;

		Account acc2 = new Account( Name = 'Test Employer 2', INT_OrganizationNumber__c = '77777777' );
		insert acc2;

		Contact con = new Contact( LastName = 'test', FirstName = 'test', Email = 'tore.toresen@example.com', AccountId = acc.Id );
		insert con;

		Test.StartTest();
		Map<String, Account> result = SharedIntegrationFunctions.fetchAccounts( new List<String> { (String) acc.INT_OrganizationNumber__c, (String) acc2.INT_OrganizationNumber__c } );
		Test.StopTest();

		System.debug( 'result: ' + result );

		System.assertEquals( acc.Id, result.get( acc.INT_OrganizationNumber__c ).Id, 'Should be same account' );
		System.assertEquals( acc2.Id, result.get( acc2.INT_OrganizationNumber__c ).Id, 'Should be same account' );
	}


	@isTest
	private static void testFetchOrCreateContact() {

		Account acc = new Account( Name = 'Test Employer 1', INT_OrganizationNumber__c = '99999999' );
		insert acc;

		List<SharedIntegrationFunctions.ContactWrapper> wrapperList = new List<SharedIntegrationFunctions.ContactWrapper>();

		SharedIntegrationFunctions.ContactWrapper wrapper = new SharedIntegrationFunctions.ContactWrapper();
		wrapper.firstName = 'test';
		wrapper.lastName = 'etternavn';
		wrapper.phone = '90080900';
		wrapper.email = 'test@test.com';
		wrapper.companyNumber = '99999999';
		wrapperList.add( wrapper );

		Map<String, Account> accountMap = SharedIntegrationFunctions.fetchAccounts( new List<String> { acc.INT_OrganizationNumber__c } );

		Test.StartTest();
		Map<String, Contact> result = SharedIntegrationFunctions.fetchOrCreateContact( wrapperList, accountMap );
		Test.StopTest();

		System.assertEquals( acc.Id, result.get( 'test@test.com' ).AccountId, 'Should be same account' );
	}
}