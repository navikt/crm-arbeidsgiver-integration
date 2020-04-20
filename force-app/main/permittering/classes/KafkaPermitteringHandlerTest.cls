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

		insert messages;

		List<TemporaryLayoff__c> layoffs = [SELECT Id FROM TemporaryLayoff__c];
		System.assertEquals( 0, layoffs.size(), 'No messages added' );

		Test.startTest();
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
	public static void testHandleMessages_invalidEmail() {

		Account acc = new Account( Name = 'Test Employer 1', INT_OrganizationNumber__c = '99999999' );
		insert acc;

		KafkaMessage__c msg = new KafkaMessage__c();
		msg.CRM_Topic__c = 'aapen-permittering-arbeidsgiver';
		msg.CRM_Key__c = 'd60775ed-249f-49e6-bd15-ff790b56cc07';
		msg.CRM_Value__c = 'ewogICJpZCI6ICI1ZjYwMjdiZi0wNjA0LTRhY2YtODE2OC0wYzE2MTFmMzNjMGQiLAogICJiZWRyaWZ0c251bW1lciI6IDc3Nzc3Nzc3LAogICJzZW5kdElublRpZHNwdW5rdCI6ICIyMDIwLTAzLTE4VDEwOjE5OjMwLjM4MFoiLAogICJ0eXBlIjogIk1BU1NFT1BQU0lHRUxTRSIsCiAgImtvbnRha3ROYXZuIjogIlRvcmUgVG9yw6VzZW4iLAogICJrb250YWt0VGxmIjogIjY2Nzc4ODk5IiwKICAia29udGFrdEVwb3N0IjogInRvcmUudG9yw6VzZW5AZXhhbXBsZS5jb20iLAogICJ2YXJzbGV0QW5zYXR0RGF0byI6ICIyMDIwLTAzLTE0IiwKICAidmFyc2xldE5hdkRhdG8iOiAiMjAyMC0wMy0xNCIsCiAgInN0YXJ0RGF0byI6ICIyMDIwLTAzLTE2IiwKICAic2x1dHREYXRvIjogIjIwMjAtMDktMjAiLAogICJmcml0ZWtzdCI6ICJMb3JlbSBpcHN1bSwgZG9yZW0gZGltc3VtIiwKICAiYW50YWxsQmVyb3J0ZSI6IDEyMwp9';
		insert msg;

		List<TemporaryLayoff__c> layoffs = [SELECT Id FROM TemporaryLayoff__c];
		System.assertEquals( 0, layoffs.size(), 'No messages added' );

		Test.startTest();
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
		insert msg;

		List<TemporaryLayoff__c> layoffs = [SELECT Id FROM TemporaryLayoff__c];
		System.assertEquals( 0, layoffs.size(), 'No messages added' );

		Test.startTest();
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
		insert msg;

		List<Contact> contacts = [SELECT Id FROM Contact];
		System.assertEquals( 1, contacts.size(), 'Only one contact created' );

		Test.startTest();
		Test.stopTest();

		contacts = [SELECT Id FROM Contact];
		System.assertEquals( 1, contacts.size(), 'Still only one contact created' );
	}
}
