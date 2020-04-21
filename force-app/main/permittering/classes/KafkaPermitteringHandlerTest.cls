@IsTest
private without sharing class KafkaPermitteringHandlerTest {

	@IsTest
	public static void testHandleMessages() {

		Account acc = new Account( Name = 'Test Employer 1', INT_OrganizationNumber__c = '99999999' );
		insert acc;

		Account acc2 = new Account( Name = 'Test Employer 2', INT_OrganizationNumber__c = '77777777' );
		insert acc2;

		Contact con = new Contact( TAG_Informed__c = true, LastName = 'test', FirstName = 'test', Email = 'tore.toresen@example.com', AccountId = acc.Id );
		insert con;

		// Create two KafkaMessages with Base64 encoded JSON-payloads matching two of the three inserted accounts
		List<KafkaMessage__c> messages = new List<KafkaMessage__c>();
		KafkaMessage__c msg1 = new KafkaMessage__c();
		msg1.CRM_Topic__c = 'aapen-permittering-arbeidsgiver';
		msg1.CRM_Key__c = 'd60775ed-249f-49e6-bd15-ff790b56cc07';
		msg1.CRM_Value__c = 'ewogICJpZCI6ICI1ZjYwMjdiZi0wNjA0LTRhY2YtODE2OC0wYzE2MTFmMzNjMGQiLAogICJiZWRyaWZ0c251bW1lciI6IDk5OTk5OTk5LAogICJzZW5kdElublRpZHNwdW5rdCI6ICIyMDIwLTAzLTE4VDEwOjE5OjMwLjM4MFoiLAogICJ0eXBlIjogIk1BU1NFT1BQU0lHRUxTRSIsCiAgImtvbnRha3ROYXZuIjogIlRvcmUgVG9yZXNlbiIsCiAgImtvbnRha3RUbGYiOiAiNjY3Nzg4OTkiLAogICJrb250YWt0RXBvc3QiOiAidG9yZS50b3Jlc2VuQGV4YW1wbGUuY29tIiwKICAidmFyc2xldEFuc2F0dERhdG8iOiAiMjAyMC0wMy0xNCIsCiAgInZhcnNsZXROYXZEYXRvIjogIjIwMjAtMDMtMTQiLAogICJzdGFydERhdG8iOiAiMjAyMC0wMy0xNiIsCiAgInNsdXR0RGF0byI6ICIyMDIwLTA5LTIwIiwKICAiZnJpdGVrc3QiOiAiTG9yZW0gaXBzdW0sIGRvcmVtIGRpbXN1bSIsCiAgImFudGFsbEJlcm9ydGUiOiAxMjMKfQ==';
		messages.add( msg1 );

		KafkaMessage__c msg2 = new KafkaMessage__c();
		msg2.CRM_Topic__c = 'aapen-permittering-arbeidsgiver';
		msg2.CRM_Key__c = '27a3cca9-0b1e-486a-8632-3a95391dfc18';
		msg2.CRM_Value__c = 'ewogICJpZCI6ICI1ZjYwMjdiZi0wNjA0LTRhY2YtODE2OC0wYzE2MTFmMzNjMGQiLAogICJiZWRyaWZ0c251bW1lciI6IDc3Nzc3Nzc3LAogICJzZW5kdElublRpZHNwdW5rdCI6ICIyMDIwLTAzLTE4VDEwOjE5OjMwLjM4MFoiLAogICJ0eXBlIjogIk1BU1NFT1BQU0lHRUxTRSIsCiAgImtvbnRha3ROYXZuIjogIlRvcmUgVG9yZXNlbiIsCiAgImtvbnRha3RUbGYiOiAiNjY3Nzg4OTkiLAogICJrb250YWt0RXBvc3QiOiAidG9yZS50b3Jlc2VuX2Zha2VAZXhhbXBsZS5jb20iLAogICJ2YXJzbGV0QW5zYXR0RGF0byI6ICIyMDIwLTAzLTE0IiwKICAidmFyc2xldE5hdkRhdG8iOiAiMjAyMC0wMy0xNCIsCiAgInN0YXJ0RGF0byI6ICIyMDIwLTAzLTE2IiwKICAic2x1dHREYXRvIjogIjIwMjAtMDktMjAiLAogICJmcml0ZWtzdCI6ICJMb3JlbSBpcHN1bSwgZG9yZW0gZGltc3VtIiwKICAiYW50YWxsQmVyb3J0ZSI6IDEyMwp9';
		messages.add( msg2 );

		List<TemporaryLayoff__c> layoffs = [SELECT Id FROM TemporaryLayoff__c];
		System.assertEquals( 0, layoffs.size(), 'No messages added' );

		KafkaPermitteringHandler perm = new KafkaPermitteringHandler();

		Test.startTest();
		perm.processMessages( messages );
		Test.stopTest();

		layoffs = [SELECT Id, Contact__c, Contact__r.AccountId, Account__c FROM TemporaryLayoff__c];
		System.assertEquals( 2, layoffs.size(), 'two layoffs' );

		layoffs = [SELECT Id, Contact__c, Contact__r.AccountId, Account__c FROM TemporaryLayoff__c WHERE Account__c = : acc.Id];
		System.assertEquals( 1, layoffs.size(), 'just one message from query' );
		System.assertEquals( con.Id, layoffs[0].Contact__c, 'Should have used the existing contact' );
		System.assertEquals( acc.Id, layoffs[0].Account__c, 'Should have used the existing account' );

		layoffs = [SELECT Id, Contact__c, Contact__r.AccountId, Account__c FROM TemporaryLayoff__c WHERE Account__c = : acc2.Id];
		System.assertEquals( 1, layoffs.size(), 'just one message from query' );
		System.assertNotEquals( con.Id, layoffs[0].Contact__c, 'Should NOT have used the existing contact' );
		System.assertEquals( acc2.Id, layoffs[0].Account__c, 'Should have used the existing second account' );
		System.assertEquals( acc2.Id, layoffs[0].Contact__r.AccountId, 'Contact should be attached to the second Account' );
	}

	@IsTest
	public static void testHandleMessages_separateProfessionAndReason() {

		Account acc = new Account( Name = 'Test Employer 1', INT_OrganizationNumber__c = '99999999' );
		insert acc;

		Contact con = new Contact( TAG_Informed__c = true, LastName = 'test', FirstName = 'test', Email = 'tore.toresen@example.com', AccountId = acc.Id );
		insert con;

		// Create two KafkaMessages with Base64 encoded JSON-payloads matching two of the three inserted accounts
		List<KafkaMessage__c> messages = new List<KafkaMessage__c>();
		KafkaMessage__c msg1 = new KafkaMessage__c();
		msg1.CRM_Topic__c = 'aapen-permittering-arbeidsgiver';
		msg1.CRM_Key__c = 'd60775ed-249f-49e6-bd15-ff790b56cc07';
		msg1.CRM_Value__c = 'ewogICJhbnRhbGxCZXJvcnRlIjogMiwKICAiYmVkcmlmdHNudW1tZXIiOiAiOTk5OTk5OTkiLAogICJmcml0ZWtzdCI6ICJcbiMjIyDDhXJzYWtcbkNvcm9uYS12aXJ1c1xuIyMjIFlya2VyXG5TZWxnZXIsIERhZ2xpZyBsZWRlciIsCiAgImlkIjogIjJkNzI3Y2ViLWYzZjEtNDE2NS1hMTQ2LTJhMjY2NWQ2NDQ0MSIsCiAgImtvbnRha3RFcG9zdCI6ICJ0b3JlLnRvcmVzZW5AZXhhbXBsZS5jb20iLAogICJrb250YWt0TmF2biI6ICJUb3JlIFRvcmVzZW4iLAogICJrb250YWt0VGxmIjogIjkwMDgwMDkwMCIsCiAgInNlbmR0SW5uVGlkc3B1bmt0IjogIjIwMjAtMDQtMTlUMTY6MDI6MjIuMDMzNDIwWiIsCiAgInNsdXR0RGF0byI6ICIyMDIwLTA0LTI2IiwKICAic3RhcnREYXRvIjogIjIwMjAtMDMtMTQiLAogICJ0eXBlIjogIlBFUk1JVFRFUklOR19VVEVOX0zDmE5OIiwKICAidmFyc2xldEFuc2F0dERhdG8iOiAiMjAyMC0wNC0xOSIsCiAgInZhcnNsZXROYXZEYXRvIjogIjIwMjAtMDQtMTkiLAogICJ5cmtlc2thdGVnb3JpZXIiOiBbCiAgICB7CiAgICAgICJrb25zZXB0SWQiOiA3MDAyOSwKICAgICAgImxhYmVsIjogIlNlbGdlciIsCiAgICAgICJzdHlyazA4IjogIjUyNDYiCiAgICB9LAogICAgewogICAgICAia29uc2VwdElkIjogNzAwMjksCiAgICAgICJsYWJlbCI6ICJLb25zdWxlbnQiLAogICAgICAic3R5cmswOCI6ICI1MjQ2IgogICAgfSwKICAgIHsKICAgICAgImtvbnNlcHRJZCI6IDMxMzgwOCwKICAgICAgImxhYmVsIjogIkRhZ2xpZyBsZWRlciIsCiAgICAgICJzdHlyazA4IjogIjExMjAiCiAgICB9CiAgXSwKICAiw6Vyc2Frc2tvZGUiOiAiTUFOR0VMX1DDhV9BUkJFSUQiCn0=';
		messages.add( msg1 );

		List<TemporaryLayoff__c> result = [SELECT Id FROM TemporaryLayoff__c];
		System.assertEquals( 0, result.size(), 'No messages added' );

		KafkaPermitteringHandler perm = new KafkaPermitteringHandler();

		Test.startTest();
		perm.processMessages( messages );
		Test.stopTest();

		result = [SELECT Id, Contact__c, Account__c, NumberOfEmployees__c, Type__c, ContactEmail__c, StartDate__c, EndDate__c, Reason__c, ReasonOther__c, Profession__c, OtherField__c FROM TemporaryLayoff__c];
		System.assertEquals( 1, result.size(), 'one layoffs' );
		System.assertEquals( con.Id, result[0].Contact__c, 'Should have used the existing contact' );
		System.assertEquals( acc.Id, result[0].Account__c, 'Should have used the existing account' );

		System.assertEquals( 2, result[0].NumberOfEmployees__c );
		System.assertEquals( 'PERMITTERING_UTEN_LØNN', result[0].Type__c );
		System.assertEquals( 'tore.toresen@example.com', result[0].ContactEmail__c );
		System.assertEquals( Date.newInstance( 2020, 03, 14 ), result[0].StartDate__c );
		System.assertEquals( Date.newInstance( 2020, 04, 26 ), result[0].EndDate__c );
		System.assertEquals( 'MANGEL_PÅ_ARBEID', result[0].Reason__c );
		System.assertEquals( null, result[0].ReasonOther__c );
		System.assert ( result[0].Profession__c.split( ';' ).contains( 'Daglig leder' ) );
		System.assert ( result[0].Profession__c.split( ';' ).contains( 'Konsulent' ) );
		System.assert ( result[0].Profession__c.split( ';' ).contains( 'Selger' ) );
		System.assertEquals( null, result[0].OtherField__c );
	}

	@IsTest
	public static void testHandleMessages_invalidEmail() {

		Account acc = new Account( Name = 'Test Employer 1', INT_OrganizationNumber__c = '99999999' );
		insert acc;

		KafkaMessage__c msg = new KafkaMessage__c();
		msg.CRM_Topic__c = 'aapen-permittering-arbeidsgiver';
		msg.CRM_Key__c = 'd60775ed-249f-49e6-bd15-ff790b56cc07';
		msg.CRM_Value__c = 'ewogICJpZCI6ICI1ZjYwMjdiZi0wNjA0LTRhY2YtODE2OC0wYzE2MTFmMzNjMGQiLAogICJiZWRyaWZ0c251bW1lciI6IDc3Nzc3Nzc3LAogICJzZW5kdElublRpZHNwdW5rdCI6ICIyMDIwLTAzLTE4VDEwOjE5OjMwLjM4MFoiLAogICJ0eXBlIjogIk1BU1NFT1BQU0lHRUxTRSIsCiAgImtvbnRha3ROYXZuIjogIlRvcmUgVG9yw6VzZW4iLAogICJrb250YWt0VGxmIjogIjY2Nzc4ODk5IiwKICAia29udGFrdEVwb3N0IjogInRvcmUudG9yw6VzZW5AZXhhbXBsZS5jb20iLAogICJ2YXJzbGV0QW5zYXR0RGF0byI6ICIyMDIwLTAzLTE0IiwKICAidmFyc2xldE5hdkRhdG8iOiAiMjAyMC0wMy0xNCIsCiAgInN0YXJ0RGF0byI6ICIyMDIwLTAzLTE2IiwKICAic2x1dHREYXRvIjogIjIwMjAtMDktMjAiLAogICJmcml0ZWtzdCI6ICJMb3JlbSBpcHN1bSwgZG9yZW0gZGltc3VtIiwKICAiYW50YWxsQmVyb3J0ZSI6IDEyMwp9';

		List<TemporaryLayoff__c> layoffs = [SELECT Id FROM TemporaryLayoff__c];
		System.assertEquals( 0, layoffs.size(), 'No messages added' );

		KafkaPermitteringHandler perm = new KafkaPermitteringHandler();

		Test.startTest();
		perm.processMessages( new List<KafkaMessage__c> { msg } );
		Test.stopTest();

		layoffs = [SELECT ContactEmail__c, Contact__r.Email, Contact__r.InvalidEmail__c FROM TemporaryLayoff__c];
		System.assertEquals( 1, layoffs.size(), 'one layoffs' );
		System.assertEquals( null, layoffs[0].Contact__r.Email, 'Email should be empty because it contained invalid characters' );
		System.assertEquals( null, layoffs[0].ContactEmail__c, 'ContactEmail should be null as it is not valid' );
		System.assertEquals( 'tore.toråsen@example.com', layoffs[0].Contact__r.InvalidEmail__c, 'Email should be empty because it contained invalid characters' );

	}

	@IsTest
	public static void testHandleMessages_invalidEmail_ExistingContact() {

		Account acc = new Account( Name = 'Test Employer 1', INT_OrganizationNumber__c = '99999999' );
		insert acc;

		Contact con = new Contact( TAG_Informed__c = true, LastName = 'Toråsen', InvalidEmail__c = 'tore.toråsen@example.com' );
		insert con;

		KafkaMessage__c msg = new KafkaMessage__c();
		msg.CRM_Topic__c = 'aapen-permittering-arbeidsgiver';
		msg.CRM_Key__c = 'd60775ed-249f-49e6-bd15-ff790b56cc07';
		msg.CRM_Value__c = 'ewogICJpZCI6ICI1ZjYwMjdiZi0wNjA0LTRhY2YtODE2OC0wYzE2MTFmMzNjMGQiLAogICJiZWRyaWZ0c251bW1lciI6IDc3Nzc3Nzc3LAogICJzZW5kdElublRpZHNwdW5rdCI6ICIyMDIwLTAzLTE4VDEwOjE5OjMwLjM4MFoiLAogICJ0eXBlIjogIk1BU1NFT1BQU0lHRUxTRSIsCiAgImtvbnRha3ROYXZuIjogIlRvcmUgVG9yw6VzZW4iLAogICJrb250YWt0VGxmIjogIjY2Nzc4ODk5IiwKICAia29udGFrdEVwb3N0IjogInRvcmUudG9yw6VzZW5AZXhhbXBsZS5jb20iLAogICJ2YXJzbGV0QW5zYXR0RGF0byI6ICIyMDIwLTAzLTE0IiwKICAidmFyc2xldE5hdkRhdG8iOiAiMjAyMC0wMy0xNCIsCiAgInN0YXJ0RGF0byI6ICIyMDIwLTAzLTE2IiwKICAic2x1dHREYXRvIjogIjIwMjAtMDktMjAiLAogICJmcml0ZWtzdCI6ICJMb3JlbSBpcHN1bSwgZG9yZW0gZGltc3VtIiwKICAiYW50YWxsQmVyb3J0ZSI6IDEyMwp9';

		List<TemporaryLayoff__c> layoffs = [SELECT Id FROM TemporaryLayoff__c];
		System.assertEquals( 0, layoffs.size(), 'No messages added' );

		KafkaPermitteringHandler perm = new KafkaPermitteringHandler();

		Test.startTest();
		perm.processMessages( new List<KafkaMessage__c> { msg } );
		Test.stopTest();

		layoffs = [SELECT ContactEmail__c, Contact__c, Contact__r.Email, Contact__r.InvalidEmail__c FROM TemporaryLayoff__c];
		System.assertEquals( 1, layoffs.size(), 'one layoffs' );
		System.assertEquals( null, layoffs[0].Contact__r.Email, 'Email should be empty because it contained invalid characters' );
		System.assertEquals( 'tore.toråsen@example.com', layoffs[0].Contact__r.InvalidEmail__c, 'Email should be empty because it contained invalid characters' );
		System.assertEquals( null, layoffs[0].ContactEmail__c, 'ContactEmail should be null as it is not valid' );
		System.assertEquals( con.Id, layoffs[0].Contact__c, 'Contact should be existing contact' );

	}

	@IsTest
	public static void testHandleMessages_upperCaseEmail() {

		Account acc = new Account( Name = 'Test Employer', INT_OrganizationNumber__c = '77777777' );
		insert acc;

		Contact con = new Contact( TAG_Informed__c = true, LastName = 'test', FirstName = 'test', Email = 'TORE.toresen@example.com', AccountId = acc.Id );
		insert con;

		KafkaMessage__c msg = new KafkaMessage__c();
		msg.CRM_Topic__c = 'aapen-permittering-arbeidsgiver';
		msg.CRM_Key__c = 'd60775ed-249f-49e6-bd15-ff790b56cc07';
		msg.CRM_Value__c = 'ewogICJpZCI6ICI1ZjYwMjdiZi0wNjA0LTRhY2YtODE2OC0wYzE2MTFmMzNjMGQiLAogICJiZWRyaWZ0c251bW1lciI6IDk5OTk5OTk5LAogICJzZW5kdElublRpZHNwdW5rdCI6ICIyMDIwLTAzLTE4VDEwOjE5OjMwLjM4MFoiLAogICJ0eXBlIjogIk1BU1NFT1BQU0lHRUxTRSIsCiAgImtvbnRha3ROYXZuIjogIlRvcmUgVG9yZXNlbiIsCiAgImtvbnRha3RUbGYiOiAiNjY3Nzg4OTkiLAogICJrb250YWt0RXBvc3QiOiAidG9yZS50b3Jlc2VuQGV4YW1wbGUuY29tIiwKICAidmFyc2xldEFuc2F0dERhdG8iOiAiMjAyMC0wMy0xNCIsCiAgInZhcnNsZXROYXZEYXRvIjogIjIwMjAtMDMtMTQiLAogICJzdGFydERhdG8iOiAiMjAyMC0wMy0xNiIsCiAgInNsdXR0RGF0byI6ICIyMDIwLTA5LTIwIiwKICAiZnJpdGVrc3QiOiAiTG9yZW0gaXBzdW0sIGRvcmVtIGRpbXN1bSIsCiAgImFudGFsbEJlcm9ydGUiOiAxMjMKfQ==';

		List<Contact> contacts = [SELECT Id FROM Contact];
		System.assertEquals( 1, contacts.size(), 'Only one contact created' );

		KafkaPermitteringHandler perm = new KafkaPermitteringHandler();

		Test.startTest();
		perm.processMessages( new List<KafkaMessage__c> { msg } );
		Test.stopTest();

		contacts = [SELECT Id FROM Contact];
		System.assertEquals( 1, contacts.size(), 'Still only one contact created' );
	}
}
