@isTest
private without sharing class KafkaPermitteringHandler_HelperTest {

	@isTest
	private static void testGetOrgNumbersFromPermittering() {

		String testJson = KafkaPermitteringHandler_ModelTest.json;
		List<KafkaPermitteringHandler_Model> permitteringer = new List<KafkaPermitteringHandler_Model>  { KafkaPermitteringHandler_Model.parse( testJson ) };

		Test.StartTest();
		List<String> orgNumbers = KafkaPermitteringHandler_Helper.getOrgNumbersFromPermittering( permitteringer );
		Test.StopTest();

		System.assertEquals( 3, orgNumbers.size(), 'Only one json sent in, but contains two subsidiaries as well' );
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
		Account sub1 = new Account( Name = 'Subsidiary 1', INT_OrganizationNumber__c = '12345678' );
		Account sub2 = new Account( Name = 'Subsidiary 1', INT_OrganizationNumber__c = '87654321' );
		insert new List<Account> { acc, sub1, sub2 };

		Contact con = new Contact( TAG_Informed__c = true, LastName = 'test', FirstName = 'test', Email = 'ververvr@test.com', AccountId = acc.Id );
		insert con;

		String testJson = KafkaPermitteringHandler_ModelTest.json;
		List<KafkaPermitteringHandler_Model> permitteringer = new List<KafkaPermitteringHandler_Model>  { KafkaPermitteringHandler_Model.parse( testJson ) };

		List<String> organisationNumbers = KafkaPermitteringHandler_Helper.getOrgNumbersFromPermittering( permitteringer );
		Map<String, Account> accountMap = SharedIntegrationFunctions.fetchAccounts( organisationNumbers );

		List<SharedIntegrationFunctions_Helper.ContactWrapper> wrapperList = KafkaPermitteringHandler_Helper.convertPermitteringToContactWrapper( permitteringer );
		Map<String, Contact> contactMap = SharedIntegrationFunctions.fetchOrCreateContact( wrapperList, accountMap );

		Test.StartTest();
		KafkaPermitteringHandler_Helper.LayoffWrapper resultWrapper = KafkaPermitteringHandler_Helper.convertPermitteringToLayoff( permitteringer, accountMap, contactMap );
		Test.StopTest();

		List<TemporaryLayoff__c> result = resultWrapper.layoffs.values();
		List<TemporaryLayoffJunction__c> resultJunction = resultWrapper.layoffJunction.values()[0];

		System.assertEquals( 2, resultJunction.size(), 'Two permittering subsidiaries' );
		for ( TemporaryLayoffJunction__c lj : resultJunction ) {
			System.assertEquals( result[0].Id, lj.TemporaryLayoff__c, 'Both junction records should have same parent' );
			if ( lj.Account__c == sub1.Id ) {
				System.assertEquals( 12, lj.NumberOfEmployees__c, '12 employees in subsidiary 1 is affected' );
			} else if ( lj.Account__c == sub2.Id ) {
				System.assertEquals( 124, lj.NumberOfEmployees__c, '12 employees in subsidiary 1 is affected' );
			}
		}

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

	@isTest
	private static void testConvertPermitteringToLayoff_EmptyAnnet() {

		String b64String = 'ewogICJpZCIgOiAiYTIwMzY4MGQtZDUyYS00Y2EwLTk2ODctMzUzMzE3YmJlYmIzIiwKICAiYmVkcmlmdHNudW1tZXIiIDogIjkxMDgyNTUxOCIsCiAgInNlbmR0SW5uVGlkc3B1bmt0IiA6ICIyMDIwLTA0LTIxVDEwOjM3OjU1Ljk2NjU4OFoiLAogICJ0eXBlIiA6ICJQRVJNSVRURVJJTkdfVVRFTl9Mw5hOTiIsCiAgImtvbnRha3ROYXZuIiA6ICJiZW5kaWsgdGVzdCBmb3Igam9obiAyIiwKICAia29udGFrdFRsZiIgOiAiMTIzNDU2NzgiLAogICJrb250YWt0RXBvc3QiIDogImJlbm55QGJhem9va2EuY29tIiwKICAidmFyc2xldEFuc2F0dERhdG8iIDogIjIwMjAtMDQtMjEiLAogICJ2YXJzbGV0TmF2RGF0byIgOiAiMjAyMC0wNC0yMSIsCiAgInN0YXJ0RGF0byIgOiAiMjAyMC0wNC0xMyIsCiAgImZyaXRla3N0IiA6ICJcbiMjIyDDhXJzYWtcbkJyYW5uXG4jIyMgWXJrZXJcbktva2sgKHNraXApXG4jIyMgQW5uZXRcbiIsCiAgImFudGFsbEJlcm9ydGUiIDogMTMzOCwKICAiw6Vyc2Frc2tvZGUiIDogIkJSQU5OIiwKICAieXJrZXNrYXRlZ29yaWVyIiA6IFsgewogICAgImtvbnNlcHRJZCIgOiAyMTg0NCwKICAgICJzdHlyazA4IiA6ICI1MTIwIiwKICAgICJsYWJlbCIgOiAiS29rayAoc2tpcCkiCiAgfSBdCn0';
		String testJson = KafkaMessageUtils.base64ULSafeDecode( b64String ).toString();

		List<KafkaPermitteringHandler_Model> permitteringer = new List<KafkaPermitteringHandler_Model>  { KafkaPermitteringHandler_Model.parse( testJson ) };

		List<String> organisationNumbers = KafkaPermitteringHandler_Helper.getOrgNumbersFromPermittering( permitteringer );
		Map<String, Account> accountMap = SharedIntegrationFunctions.fetchAccounts( organisationNumbers );

		List<SharedIntegrationFunctions_Helper.ContactWrapper> wrapperList = KafkaPermitteringHandler_Helper.convertPermitteringToContactWrapper( permitteringer );
		Map<String, Contact> contactMap = SharedIntegrationFunctions.fetchOrCreateContact( wrapperList, accountMap );

		Test.StartTest();
		KafkaPermitteringHandler_Helper.LayoffWrapper resultWrapper = KafkaPermitteringHandler_Helper.convertPermitteringToLayoff( permitteringer, accountMap, contactMap );
		Test.StopTest();

		List<TemporaryLayoff__c> result = resultWrapper.layoffs.values();

		System.assertEquals( 1, result.size(), 'Only one permittering' );

		System.assertEquals( 1338, result[0].NumberOfEmployees__c );
		System.assertEquals( null, result[0].OtherField__c );
	}

	@isTest
	private static void testRemoveExistingTempLayoffs() {

		TemporaryLayoff__c tl = new TemporaryLayoff__c( KafkaId__c = 'test' );
		insert tl;

		Account acc = new Account( Name = 'Test Employer 1', INT_OrganizationNumber__c = '99999999' );
		insert acc;
		TemporaryLayoff__c tl2 = new TemporaryLayoff__c( KafkaId__c = 'test' );
		TemporaryLayoffJunction__c tlj2 = new TemporaryLayoffJunction__c( TemporaryLayoff__r = tl2, Account__c = acc.Id );

		KafkaPermitteringHandler_Helper.LayoffWrapper resultWrapper = new KafkaPermitteringHandler_Helper.LayoffWrapper();
		resultWrapper.layoffs = new Map<String, TemporaryLayoff__c>();
		resultWrapper.layoffs.put( 'test', tl2 );
		resultWrapper.layoffJunction = new Map<String, List<TemporaryLayoffJunction__c> >();
		resultWrapper.layoffJunction.put( 'test', new List<TemporaryLayoffJunction__c> { tlj2 } );


		Test.StartTest();
		KafkaPermitteringHandler_Helper.removeExistingTempLayoffs( resultWrapper );
		Test.StopTest();

		System.assertEquals( 0, resultWrapper.layoffs.size(), 'Same KafkaId, thus, it shouldn\'t be added' );
		System.assertEquals( 0, resultWrapper.layoffJunction.size(), 'Same KafkaId, thus, it shouldn\'t be added' );
	}

	@isTest
	private static void testRemoveExistingTempLayoffs_shouldNotRemove() {

		TemporaryLayoff__c tl = new TemporaryLayoff__c( KafkaId__c = 'uniqueId' );
		insert tl;

		Account acc = new Account( Name = 'Test Employer 1', INT_OrganizationNumber__c = '99999999' );
		insert acc;
		TemporaryLayoff__c tl2 = new TemporaryLayoff__c( KafkaId__c = 'test' );
		TemporaryLayoffJunction__c tlj2 = new TemporaryLayoffJunction__c( TemporaryLayoff__r = tl2, Account__c = acc.Id );

		KafkaPermitteringHandler_Helper.LayoffWrapper resultWrapper = new KafkaPermitteringHandler_Helper.LayoffWrapper();
		resultWrapper.layoffs = new Map<String, TemporaryLayoff__c>();
		resultWrapper.layoffs.put( 'test', tl2 );
		resultWrapper.layoffJunction = new Map<String, List<TemporaryLayoffJunction__c> >();
		resultWrapper.layoffJunction.put( 'test', new List<TemporaryLayoffJunction__c> { tlj2 } );


		Test.StartTest();
		KafkaPermitteringHandler_Helper.removeExistingTempLayoffs( resultWrapper );
		Test.StopTest();

		System.assertEquals( 1, resultWrapper.layoffs.size(), 'Different KafkaId, thus, it should be added' );
		System.assertEquals( 1, resultWrapper.layoffJunction.size(), 'Different KafkaId, thus, it should be added' );
	}

	@isTest
	private static void testRemoveDuplicateTempLayoffsInList() {

		TemporaryLayoff__c tl1 = new TemporaryLayoff__c( KafkaId__c = 'test' );
		TemporaryLayoff__c tl2 = new TemporaryLayoff__c( KafkaId__c = 'test' );

		Test.StartTest();
		List<TemporaryLayoff__c> layoffs = KafkaPermitteringHandler_Helper.removeDuplicateTempLayoffsInList( new List<TemporaryLayoff__c> { tl1, tl2 } );
		Test.StopTest();

		System.assertEquals( 1, layoffs.size(), 'Same KafkaId on both, thus, only one should be added' );
	}

}