@isTest
private without sharing class SharedIntegrationFunctionsTest {

	@isTest
	private static void testfetchUsersByTitle() {

		User u = TAG_TestDataFactory.createStandardUser( 'Last UNIQUE NAME' );
		u.title = 'testTitle';
		update u;

		Test.StartTest();
		Map<String, User> userMap = SharedIntegrationFunctions.fetchUsersByTitle( new Set<String> { 'testTitle' } );
		Test.StopTest();

		System.assertEquals( 1, userMap.size(), 'Only one user added' );
		System.assertEquals( u.Id, userMap.get( 'testTitle' ).Id, 'Same user as created' );
	}
}