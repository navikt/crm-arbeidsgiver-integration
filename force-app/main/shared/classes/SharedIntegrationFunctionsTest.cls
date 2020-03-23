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
		Map<String, Account> result = SharedIntegrationFunctions.fetchAccounts( new List<String> { acc.INT_OrganizationNumber__c, acc2.INT_OrganizationNumber__c } );
		Test.StopTest();

		System.assertEquals( acc.Id, result.get( acc.INT_OrganizationNumber__c ).Id, 'Should be same account' );
		System.assertEquals( acc2.Id, result.get( acc2.INT_OrganizationNumber__c ).Id, 'Should be same account' );

		Integer contactRelationships = [SELECT Id FROM AccountContactRelation].size();
		System.assertEquals( 1, contactRelationships, 'Should have added the contact to the new accounts as a relationship' );
	}

	@isTest
	private static void testFetchOrCreateContact_create() {

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

		Map<String, Account> accountMap = SharedIntegrationFunctions.fetchAccounts( new List<String> { wrapper.companyNumber } );

		Test.StartTest();
		Map<String, Contact> result = SharedIntegrationFunctions.fetchOrCreateContact( wrapperList, accountMap );
		Test.StopTest();

		System.assertEquals( acc.Id, result.get( 'test@test.com' ).AccountId, 'Should be same account' );

		Integer contactRelationships = [SELECT Id FROM AccountContactRelation].size();
		System.assertEquals( 1, contactRelationships, 'Should have added the contact to the new accounts as a relationship' );
	}


	@isTest
	private static void testFetchOrCreateContact_existingContact() {

		Account acc = new Account( Name = 'Test Employer 1', INT_OrganizationNumber__c = '99999999' );
		insert acc;

		Contact con = new Contact( LastName = 'test', FirstName = 'test', Email = 'test@test.com', AccountId = acc.Id );
		insert con;

		List<SharedIntegrationFunctions.ContactWrapper> wrapperList = new List<SharedIntegrationFunctions.ContactWrapper>();
		SharedIntegrationFunctions.ContactWrapper wrapper = new SharedIntegrationFunctions.ContactWrapper();
		wrapper.firstName = 'test';
		wrapper.lastName = 'etternavn';
		wrapper.phone = '90080900';
		wrapper.email = 'test@test.com';
		wrapper.companyNumber = '99999999';
		wrapperList.add( wrapper );

		Map<String, Account> accountMap = SharedIntegrationFunctions.fetchAccounts( new List<String> { wrapper.companyNumber } );

		Test.StartTest();
		Map<String, Contact> result = SharedIntegrationFunctions.fetchOrCreateContact( wrapperList, accountMap );
		Test.StopTest();

		System.assertEquals( con.Id, result.get( 'test@test.com' ).Id, 'Should be same existing contact' );

		Integer contactRelationships = [SELECT Id FROM AccountContactRelation].size();
		System.assertEquals( 1, contactRelationships, 'Should have added the contact to the new accounts as a relationship' );
	}

	@isTest
	private static void testFetchOrCreateContact_existingContactOnAnotherAccount() {

		Account acc = new Account( Name = 'Test Employer 1', INT_OrganizationNumber__c = '99999999' );
		insert acc;

		Account acc2 = new Account( Name = 'Test Employer 2', INT_OrganizationNumber__c = '77777777' );
		insert acc2;

		Contact con = new Contact( LastName = 'test', FirstName = 'test', Email = 'test@test.com', AccountId = acc.Id );
		insert con;

		List<SharedIntegrationFunctions.ContactWrapper> wrapperList = new List<SharedIntegrationFunctions.ContactWrapper>();
		SharedIntegrationFunctions.ContactWrapper wrapper = new SharedIntegrationFunctions.ContactWrapper();
		wrapper.firstName = 'test';
		wrapper.lastName = 'etternavn';
		wrapper.phone = '90080900';
		wrapper.email = 'test@test.com';
		wrapper.companyNumber = '77777777';
		wrapperList.add( wrapper );

		Map<String, Account> accountMap = SharedIntegrationFunctions.fetchAccounts( new List<String> { wrapper.companyNumber } );

		Test.StartTest();
		Map<String, Contact> result = SharedIntegrationFunctions.fetchOrCreateContact( wrapperList, accountMap );
		Test.StopTest();

		System.assertEquals( con.Id, result.get( 'test@test.com' ).Id, 'Should be same existing contact' );

		Integer contactRelationships = [SELECT Id FROM AccountContactRelation].size();
		System.assertEquals( 2, contactRelationships, 'Should have added the contact to the new accounts as a relationship' );
	}
}