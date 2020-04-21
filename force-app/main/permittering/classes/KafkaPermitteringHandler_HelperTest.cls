@isTest
private without sharing class KafkaPermitteringHandler_HelperTest {

	@isTest
	private static void testGetOrgNumbersFromPermittering() {

		String testJson = KafkaPermitteringHandler_ModelTest.json;
		List<KafkaPermitteringHandler_Model> permitteringer = new List<KafkaPermitteringHandler_Model>  { KafkaPermitteringHandler_Model.parse( testJson ) };

		Test.StartTest();
		List<String> orgNumbers = KafkaPermitteringHandler_Helper.getOrgNumbersFromPermittering( permitteringer );
		Test.StopTest();

		System.assertEquals( 1, orgNumbers.size(), 'Only one json sent in' );
		System.assertEquals( '920845908', orgNumbers[0], 'Only one json sent in' );
	}

	@isTest
	private static void testConvertKafkaToPermittering() {

		String testJson = KafkaPermitteringHandler_ModelTest.json;
		List<KafkaPermitteringHandler_Model> expected = new List<KafkaPermitteringHandler_Model>  { KafkaPermitteringHandler_Model.parse( testJson ) };

		KafkaMessage__c msg1 = new KafkaMessage__c();
		msg1.CRM_Value__c = 'ewogICJpZCIgOiAiMmQ3MjdjZWItZjNmMS00MTY1LWExNDYtMmEyNjY1ZDY0NDQxIiwKICAiYmVkcmlmdHNudW1tZXIiIDogIjkyMDg0NTkwOCIsCiAgInNlbmR0SW5uVGlkc3B1bmt0IiA6ICIyMDIwLTA0LTE5VDE2OjAyOjIyLjAzMzQyMFoiLAogICJ0eXBlIiA6ICJQRVJNSVRURVJJTkdfVVRFTl9Mw5hOTiIsCiAgImtvbnRha3ROYXZuIiA6ICJ0ZXN0IG5hdiIsCiAgImtvbnRha3RUbGYiIDogIjgwMDgwOTAwIiwKICAia29udGFrdEVwb3N0IiA6ICJ2ZXJ2ZXJ2ckB0ZXN0LmNvbSIsCiAgInZhcnNsZXRBbnNhdHREYXRvIiA6ICIyMDIwLTA0LTE5IiwKICAidmFyc2xldE5hdkRhdG8iIDogIjIwMjAtMDQtMTkiLAogICJzdGFydERhdG8iIDogIjIwMjAtMDMtMTQiLAogICJzbHV0dERhdG8iIDogIjIwMjAtMDQtMjYiLAogICJmcml0ZWtzdCIgOiAiXG4jIyMgw4Vyc2FrXG5Db3JvbmEtdmlydXNcbiMjIyBZcmtlclxuS2FmZW1lZGFyYmVpZGVyLCBEYWdsaWcgbGVkZXJcbiMjIyBBbm5ldFxuSGFyIHRpZGxpZ2VyZSBzZW5kdCBpbm4gcGVybWl0dGVyaW5nc3ZhcnNlbCBmcmEgZGFnIDEgKDE0LiBtYXJzIDIwMjApLiBEZXR0ZSBlciB2YXJzZWwgb20gZm9ybGVuZ2luZyBmcmVtIHRpbCAyNywgYXByaWwgMjAyMC4gIiwKICAiYW50YWxsQmVyb3J0ZSIgOiAyLAogICLDpXJzYWtza29kZSIgOiAiQU5EUkVfw4VSU0FLRVIiLAogICLDpXJzYWtzdGVrc3QiIDogIkNvcm9uYS12aXJ1cyIsCiAgInlya2Vza2F0ZWdvcmllciIgOiBbIHsKICAgICJrb25zZXB0SWQiIDogNzAwMjksCiAgICAic3R5cmswOCIgOiAiNTI0NiIsCiAgICAibGFiZWwiIDogIkthZmVtZWRhcmJlaWRlciIKICB9LCB7CiAgICAia29uc2VwdElkIiA6IDMxMzgwOCwKICAgICJzdHlyazA4IiA6ICIxMTIwIiwKICAgICJsYWJlbCIgOiAiRGFnbGlnIGxlZGVyIgogIH0gXSwKICAiYmVkcmlmdCI6IFsKICAgIHsKICAgICAgImJlZHJpZnROciI6ICIxMjM0NTY3OCIsCiAgICAgICJiZWRyaWZ0TmF2biI6ICJ0ZXN0IiwKICAgICAgImFudGFsbEJlcm9ydGUiOiAxMgogICAgfSwKICAgIHsKICAgICAgImJlZHJpZnROciI6ICI4NzY1NDMyMSIsCiAgICAgICJiZWRyaWZ0TmF2biI6ICJ0ZXN0MiIsCiAgICAgICJhbnRhbGxCZXJvcnRlIjogMTI0CiAgICB9CiAgXQp9';

		Test.StartTest();
		List<KafkaPermitteringHandler_Model> actual = KafkaPermitteringHandler_Helper.convertKafkaToPermittering( new List<KafkaMessage__c> { msg1 } );
		Test.StopTest();

		expected[0].jsonPayload = null;
		actual[0].jsonPayload = null;

		System.assertEquals( expected[0].id, actual[0].id );
		System.assertEquals( expected[0].bedriftsnummer, actual[0].bedriftsnummer );
		System.assertEquals( expected[0].sendtInnTidspunkt, actual[0].sendtInnTidspunkt );
		System.assertEquals( expected[0].type, actual[0].type );
		System.assertEquals( expected[0].kontaktNavn, actual[0].kontaktNavn );
		System.assertEquals( expected[0].kontaktTlf, actual[0].kontaktTlf );
		System.assertEquals( expected[0].kontaktEpost, actual[0].kontaktEpost );
		System.assertEquals( expected[0].varsletAnsattDato, actual[0].varsletAnsattDato );
		System.assertEquals( expected[0].varsletNavDato, actual[0].varsletNavDato );
		System.assertEquals( expected[0].startDato, actual[0].startDato );
		System.assertEquals( expected[0].sluttDato, actual[0].sluttDato );
		System.assertEquals( expected[0].fritekst, actual[0].fritekst );
		System.assertEquals( expected[0].antallBerorte, actual[0].antallBerorte );
		System.assertEquals( expected[0].arsakskode, actual[0].arsakskode );
		System.assertEquals( expected[0].arsakstekst, actual[0].arsakstekst );
	}

	@isTest
	private static void testConvertPermitteringToContactWrapper() {

		String testJson = KafkaPermitteringHandler_ModelTest.json;
		List<KafkaPermitteringHandler_Model> permitteringer = new List<KafkaPermitteringHandler_Model>  { KafkaPermitteringHandler_Model.parse( testJson ) };

		Test.StartTest();
		List<SharedIntegrationFunctions_Helper.ContactWrapper> result = KafkaPermitteringHandler_Helper.convertPermitteringToContactWrapper( permitteringer );
		Test.StopTest();

		System.assertEquals( 1, result.size(), 'Only one contact' );
		System.assertEquals( 'test', result[0].firstName, 'firstName should be set from testJson' );
		System.assertEquals( 'nav', result[0].lastName, 'lastName should be set from testJson' );
		System.assertEquals( '920845908', result[0].companyNumber, 'companyNumber should be set from testJson' );
		System.assertEquals( '80080900', result[0].phone, 'phone should be set from testJson' );
		System.assertEquals( 'ververvr@test.com', result[0].email, 'email should be set from testJson' );
	}


	@isTest
	private static void testConvertPermitteringToLayoff() {

		Account acc = new Account( Name = 'Test Employer 1', INT_OrganizationNumber__c = '920845908' );
		insert acc;

		Contact con = new Contact( TAG_Informed__c = true, LastName = 'test', FirstName = 'test', Email = 'ververvr@test.com', AccountId = acc.Id );
		insert con;

		String testJson = KafkaPermitteringHandler_ModelTest.json;
		List<KafkaPermitteringHandler_Model> permitteringer = new List<KafkaPermitteringHandler_Model>  { KafkaPermitteringHandler_Model.parse( testJson ) };

		List<String> organisationNumbers = KafkaPermitteringHandler_Helper.getOrgNumbersFromPermittering( permitteringer );
		Map<String, Account> accountMap = SharedIntegrationFunctions.fetchAccounts( organisationNumbers );

		List<SharedIntegrationFunctions_Helper.ContactWrapper> wrapperList = KafkaPermitteringHandler_Helper.convertPermitteringToContactWrapper( permitteringer );
		Map<String, Contact> contactMap = SharedIntegrationFunctions.fetchOrCreateContact( wrapperList, accountMap );

		Test.StartTest();
		List<TemporaryLayoff__c> result = KafkaPermitteringHandler_Helper.convertPermitteringToLayoff( permitteringer, accountMap, contactMap );
		Test.StopTest();

		System.assertEquals( 1, result.size(), 'Only one permittering' );
		System.assertEquals( Con.Id, result[0].Contact__c );
		System.assertEquals( acc.Id, result[0].Account__c, 'Should have used the existing account' );

		System.assertEquals( 2, result[0].NumberOfEmployees__c );
		System.assertEquals( 'PERMITTERING_UTEN_LØNN', result[0].Type__c );
		System.assertEquals( 'ververvr@test.com', result[0].ContactEmail__c );
		System.assertEquals( Date.newInstance( 2020, 03, 14 ), result[0].StartDate__c );
		System.assertEquals( Date.newInstance( 2020, 04, 26 ), result[0].EndDate__c );
		System.assertEquals( 'ANDRE_ÅRSAKER', result[0].Reason__c );
		System.assertEquals( 'Corona-virus', result[0].ReasonOther__c );
		System.assert ( result[0].Profession__c.split( ';' ).contains( 'Daglig leder' ) );
		System.assert ( result[0].Profession__c.split( ';' ).contains( 'Kafemedarbeider' ) );
		System.assertEquals( 'Har tidligere sendt inn permitteringsvarsel fra dag 1 (14. mars 2020). Dette er varsel om forlenging frem til 27, april 2020. ', result[0].OtherField__c );
	}

}