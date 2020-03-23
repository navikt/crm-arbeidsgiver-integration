public with sharing class SharedIntegrationFunctions {

	public class ContactWrapper {
		public String firstName;
		public String lastName;
		public String phone;
		public String email;
		public String companyNumber;
	}

	public static Map<String, Account> fetchAccounts( List<String> organisationNumbers ) {

		List<Account> accounts = [SELECT Id, INT_OrganizationNumber__c, INT_MunicipalityNumber__c FROM Account

		                          WHERE
		                              ( INT_OrganizationNumber__c IN : organisationNumbers ) AND
		                              ( INT_OrganizationNumber__c != null ) AND
		                              ( IsPersonAccount = false )];

		Map<String, Account> accountMap = new Map<String, Account>();
		for ( Account acc : accounts ) {
			accountMap.put( acc.INT_OrganizationNumber__c, acc );
		}

		return accountMap;
	}

	public static Map<String, Contact> fetchOrCreateContact( List<ContactWrapper> wrapperList, Map<String, Account> accountMap ) {

		List<String> emails = new List<String>();
		for ( ContactWrapper cw : wrapperList ) {
			emails.add( cw.email );
		}

		List<Contact> existingContacts = [SELECT Id, Email, Account.INT_OrganizationNumber__c FROM Contact WHERE Email IN : emails];
		Map<String, Contact> contactMap = new Map<String, Contact>();

		for ( Contact con : existingContacts ) {
			contactMap.put( con.Email, con );
		}

		List<Contact> newContacts = new List<Contact>();
		for ( ContactWrapper cw : wrapperList ) {

			if ( !contactMap.containsKey( cw.email ) ) {
				Id accountId = accountMap.containsKey( cw.companyNumber ) ? accountMap.get( cw.companyNumber ).Id : null;
				Contact con = new Contact( FirstName = cw.firstName, LastName = cw.lastName, Email = cw.email, MobilePhone = cw.phone, AccountId = accountId, TAG_Informed__c = true );
				newContacts.add( con );
			}
		}

		insert newContacts;

		mapUnmappedContacts( wrapperList, existingContacts, accountMap );

		for ( Contact con : newContacts ) {
			contactMap.put( con.Email, con );
		}

		return contactMap;
	}

	public static void mapUnmappedContacts( List<ContactWrapper> wrapperList, List<Contact> existingContacts, Map<String, Account> accountMap ) {

		Map<String, ContactWrapper> contactWrapperMap = new Map<String, ContactWrapper>();
		for ( ContactWrapper cw : wrapperList ) {
			contactWrapperMap.put( cw.email, cw );
		}

		List<AccountContactRelation> relationships = new List<AccountContactRelation>();

		Map<Id, Id> contactAndAccountToMap = new Map<Id, Id>();
		for ( Contact con : existingContacts ) {

			String postedCompanyNumber = contactWrapperMap.get( con.Email ).companyNumber;
			String currentCompanyNumber = con.Account.INT_OrganizationNumber__c;

			if ( postedCompanyNumber != currentCompanyNumber ) {
				System.debug( 'accountMap: ' + accountMap );
				System.debug( 'currentCompanyNumber: ' + postedCompanyNumber );
				Id accId = accountMap.get( postedCompanyNumber ).Id;
				relationships.add( new AccountContactRelation( AccountId = accId, ContactId = con.Id ) );
			}
		}

		Database.insert( relationships, false );
	}
}
