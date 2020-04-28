@isTest
private without sharing class KafkaPermitteringHandlerSubsidiariesTest {

	@IsTest
	public static void testMultipleSubsidiaries() {

		Account acc = new Account( Name = 'Test Employer 1', INT_OrganizationNumber__c = '99999999' );
		Account sub1 = new Account( Name = 'Subsidiary 1', INT_OrganizationNumber__c = '12345678' );
		Account sub2 = new Account( Name = 'Subsidiary 1', INT_OrganizationNumber__c = '87654321' );
		insert new List<Account> { acc, sub1, sub2 };

		KafkaMessage__c msg1 = new KafkaMessage__c();
		msg1.CRM_Topic__c = 'aapen-permittering-arbeidsgiver';
		msg1.CRM_Key__c = 'd60775ed-249f-49e6-bd15-ff790b56cc07';
		msg1.CRM_Value__c = 'ewogICJpZCI6ICI1ZjYwMjdiZi0wNjA0LTRhY2YtODE2OC0wYzE2MTFmMzNjMGQiLAogICJiZWRyaWZ0c251bW1lciI6IDk5OTk5OTk5LAogICJzZW5kdElublRpZHNwdW5rdCI6ICIyMDIwLTAzLTE4VDEwOjE5OjMwLjM4MFoiLAogICJ0eXBlIjogIk1BU1NFT1BQU0lHRUxTRSIsCiAgImtvbnRha3ROYXZuIjogIlRvcmUgVG9yZXNlbiIsCiAgImtvbnRha3RUbGYiOiAiNjY3Nzg4OTkiLAogICJrb250YWt0RXBvc3QiOiAidG9yZS50b3Jlc2VuQGV4YW1wbGUuY29tIiwKICAidmFyc2xldEFuc2F0dERhdG8iOiAiMjAyMC0wMy0xNCIsCiAgInZhcnNsZXROYXZEYXRvIjogIjIwMjAtMDMtMTQiLAogICJzdGFydERhdG8iOiAiMjAyMC0wMy0xNiIsCiAgInNsdXR0RGF0byI6ICIyMDIwLTA5LTIwIiwKICAiZnJpdGVrc3QiOiAiTG9yZW0gaXBzdW0sIGRvcmVtIGRpbXN1bSIsCiAgImFudGFsbEJlcm9ydGUiOiAxMjMsCiAgInlya2Vza2F0ZWdvcmllciI6IFsKICAgIHsKICAgICAgImtvbnNlcHRJZCI6IDcwMDI5LAogICAgICAibGFiZWwiOiAiU2VsZ2VyIiwKICAgICAgInN0eXJrMDgiOiAiNTI0NiIKICAgIH0sCiAgICB7CiAgICAgICJrb25zZXB0SWQiOiA3MDAyOSwKICAgICAgImxhYmVsIjogIktvbnN1bGVudCIsCiAgICAgICJzdHlyazA4IjogIjUyNDYiCiAgICB9LAogICAgewogICAgICAia29uc2VwdElkIjogMzEzODA4LAogICAgICAibGFiZWwiOiAiRGFnbGlnIGxlZGVyIiwKICAgICAgInN0eXJrMDgiOiAiMTEyMCIKICAgIH0KICBdLAogICJiZWRyaWZ0IjogWwogICAgewogICAgICAiYmVkcmlmdE5yIjogIjEyMzQ1Njc4IiwKICAgICAgImJlZHJpZnROYXZuIjogInRlc3QiLAogICAgICAiYW50YWxsQmVyb3J0ZSI6IDEyCiAgICB9LAogICAgewogICAgICAiYmVkcmlmdE5yIjogIjg3NjU0MzIxIiwKICAgICAgImJlZHJpZnROYXZuIjogInRlc3QyIiwKICAgICAgImFudGFsbEJlcm9ydGUiOiAxMjQKICAgIH0KICBdCn0=';

		List<TemporaryLayoff__c> layoffs = [SELECT Id FROM TemporaryLayoff__c];
		System.assertEquals( 0, layoffs.size(), 'No messages added' );
		List<TemporaryLayoffJunction__c> layoffJunction = [SELECT Id FROM TemporaryLayoffJunction__c];
		System.assertEquals( 0, layoffJunction.size(), 'No junctions added' );
		List<Account> accounts = [SELECT Id FROM Account];
		System.assertEquals( 3, accounts.size(), 'Three accounts before' );
		List<Contact> contacts = [SELECT Id FROM Contact];
		System.assertEquals( 0, contacts.size(), 'zero contacts before' );
		List<AccountContactRelation> acr = [SELECT Id FROM AccountContactRelation];
		System.assertEquals( 0, acr.size(), 'zero contacts before, thus no AccountContactRelation' );

		KafkaPermitteringHandler perm = new KafkaPermitteringHandler();
		Test.startTest();
		perm.processMessages( new List<KafkaMessage__c> { msg1 }  );
		Test.stopTest();

		layoffs = [SELECT Id FROM TemporaryLayoff__c];
		System.assertEquals( 1, layoffs.size(), 'One layoff added' );
		layoffJunction = [SELECT Id, TemporaryLayoff__c, NumberOfEmployees__c, Account__c FROM TemporaryLayoffJunction__c];
		System.assertEquals( 2, layoffJunction.size(), 'Two junctions added' );
		accounts = [SELECT Id FROM Account];
		System.assertEquals( 3, accounts.size(), 'Still three accounts' );
		contacts = [SELECT AccountId FROM Contact];
		System.assertEquals( 1, contacts.size(), 'One contact added' );
		System.assertEquals( acc.Id, contacts[0].AccountId, 'Multiple subsidiaries, add contact to single parent account' );
		acr = [SELECT Id, AccountId FROM AccountContactRelation];
		System.assertEquals( 1, acr.size(), 'one contact added, thus 1 AccountContactRelation' );

		System.assertEquals( acc.Id, acr[0].AccountId, 'Should only assign contact relation to main account if reporting for multiple at a time' );

		for ( TemporaryLayoffJunction__c lj : layoffJunction ) {
			System.assertEquals( layoffs[0].Id, lj.TemporaryLayoff__c, 'Both junction records should have same parent' );
			if ( lj.Account__c == sub1.Id ) {
				System.assertEquals( 12, lj.NumberOfEmployees__c, '12 employees in subsidiary 1 is affected' );
			} else if ( lj.Account__c == sub2.Id ) {
				System.assertEquals( 124, lj.NumberOfEmployees__c, '12 employees in subsidiary 1 is affected' );
			}
		}
	}

	@IsTest
	public static void testMultipleSubsidiaries_OnlyOneSubsidiary() {

		Account acc = new Account( Name = 'Test Employer 1', INT_OrganizationNumber__c = '99999999' );
		Account sub1 = new Account( Name = 'Subsidiary 1', INT_OrganizationNumber__c = '12345678' );
		insert new List<Account> { acc, sub1 };

		KafkaMessage__c msg1 = new KafkaMessage__c();
		msg1.CRM_Topic__c = 'aapen-permittering-arbeidsgiver';
		msg1.CRM_Key__c = 'd60775ed-249f-49e6-bd15-ff790b56cc07';
		msg1.CRM_Value__c = 'ewogICJpZCI6ICI1ZjYwMjdiZi0wNjA0LTRhY2YtODE2OC0wYzE2MTFmMzNjMGQiLAogICJiZWRyaWZ0c251bW1lciI6IDk5OTk5OTk5LAogICJzZW5kdElublRpZHNwdW5rdCI6ICIyMDIwLTAzLTE4VDEwOjE5OjMwLjM4MFoiLAogICJ0eXBlIjogIk1BU1NFT1BQU0lHRUxTRSIsCiAgImtvbnRha3ROYXZuIjogIlRvcmUgVG9yZXNlbiIsCiAgImtvbnRha3RUbGYiOiAiNjY3Nzg4OTkiLAogICJrb250YWt0RXBvc3QiOiAidG9yZS50b3Jlc2VuQGV4YW1wbGUuY29tIiwKICAidmFyc2xldEFuc2F0dERhdG8iOiAiMjAyMC0wMy0xNCIsCiAgInZhcnNsZXROYXZEYXRvIjogIjIwMjAtMDMtMTQiLAogICJzdGFydERhdG8iOiAiMjAyMC0wMy0xNiIsCiAgInNsdXR0RGF0byI6ICIyMDIwLTA5LTIwIiwKICAiZnJpdGVrc3QiOiAiTG9yZW0gaXBzdW0sIGRvcmVtIGRpbXN1bSIsCiAgImFudGFsbEJlcm9ydGUiOiAxMjMsCiAgInlya2Vza2F0ZWdvcmllciI6IFsKICAgIHsKICAgICAgImtvbnNlcHRJZCI6IDcwMDI5LAogICAgICAibGFiZWwiOiAiU2VsZ2VyIiwKICAgICAgInN0eXJrMDgiOiAiNTI0NiIKICAgIH0sCiAgICB7CiAgICAgICJrb25zZXB0SWQiOiA3MDAyOSwKICAgICAgImxhYmVsIjogIktvbnN1bGVudCIsCiAgICAgICJzdHlyazA4IjogIjUyNDYiCiAgICB9LAogICAgewogICAgICAia29uc2VwdElkIjogMzEzODA4LAogICAgICAibGFiZWwiOiAiRGFnbGlnIGxlZGVyIiwKICAgICAgInN0eXJrMDgiOiAiMTEyMCIKICAgIH0KICBdLAogICJiZWRyaWZ0IjogWwogICAgewogICAgICAiYmVkcmlmdE5yIjogIjEyMzQ1Njc4IiwKICAgICAgImJlZHJpZnROYXZuIjogInRlc3QiLAogICAgICAiYW50YWxsQmVyb3J0ZSI6IDEyCiAgICB9CiAgXQp9';

		List<TemporaryLayoff__c> layoffs = [SELECT Id FROM TemporaryLayoff__c];
		System.assertEquals( 0, layoffs.size(), 'No messages added' );
		List<TemporaryLayoffJunction__c> layoffJunction = [SELECT Id FROM TemporaryLayoffJunction__c];
		System.assertEquals( 0, layoffJunction.size(), 'No junctions added' );
		List<Account> accounts = [SELECT Id FROM Account];
		System.assertEquals( 2, accounts.size(), 'Three accounts before' );
		List<Contact> contacts = [SELECT Id FROM Contact];
		System.assertEquals( 0, contacts.size(), 'zero contacts before' );
		List<AccountContactRelation> acr = [SELECT Id FROM AccountContactRelation];
		System.assertEquals( 0, acr.size(), 'zero contacts before, thus no AccountContactRelation' );

		KafkaPermitteringHandler perm = new KafkaPermitteringHandler();
		Test.startTest();
		perm.processMessages( new List<KafkaMessage__c> { msg1 }  );
		Test.stopTest();

		layoffs = [SELECT Id FROM TemporaryLayoff__c];
		System.assertEquals( 1, layoffs.size(), 'One layoff added' );
		layoffJunction = [SELECT Id, TemporaryLayoff__c, NumberOfEmployees__c, Account__c FROM TemporaryLayoffJunction__c];
		System.assertEquals( 0, layoffJunction.size(), 'Two junctions added' );
		accounts = [SELECT Id FROM Account];
		System.assertEquals( 2, accounts.size(), 'Still three accounts' );
		contacts = [SELECT AccountId FROM Contact];
		System.assertEquals( 1, contacts.size(), 'One contact added' );
		System.assertEquals( sub1.Id, contacts[0].AccountId, 'One subsidiary, add contact to subsidiary' );
		acr = [SELECT Id, AccountId FROM AccountContactRelation];
		System.assertEquals( 1, acr.size(), 'one contact added, thus 1 AccountContactRelation' );

		System.assertEquals( sub1.Id, acr[0].AccountId, 'Should only assign contact relation to sub account if reporting for one account at a time' );
	}
}