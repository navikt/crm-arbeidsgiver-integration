@IsTest
private class ArenaMassUpdateService_BatchTest {

	@TestSetup
	static void makeData() {
		ArenaActivity__C activity = new ArenaActivity__c();
		activity.JsonPayload__c = '{"aktivitetStatuskode":"GJENN","bedriftsnr":611855940,"beskrivelse":null,"orgnrMorselskap":711728323,"saksbehandler":"BBA0412","aktivitetskode":"ARBTREN","fraDato":"2020-07-10","tilDato":"2020-09-10","regDato":"2020-07-10","regUser":"CBB0512","aktivitetsgruppekode":"TLTAK","aktivitetstypebeskrivelse":null,"aktivitetstypenavn":"Arbeidstrening","fornavn":"Fornavn","etternavn":"Etternavn","navIdent":"F183722"}';
		insert activity;
	}

	@IsTest
	private static void testExecute() {
		String query = 'SELECT RegisteredByNavIdent__c, CaseWorkerNavIdent__c, CaseWorkerName__c, JsonPayload__c FROM ArenaActivity__c WHERE CaseWorkerName__c=null';

		Test.startTest();
		ArenaMassUpdateService_Batch btch = new ArenaMassUpdateService_Batch( query );
		Database.executeBatch( btch, 2000 );
		Test.stopTest();

		ArenaActivity__c activity = [SELECT RegisteredByNavIdent__c, CaseWorkerNavIdent__c, CaseWorkerName__c FROM ArenaActivity__c];
		System.assertEquals( 'CBB0512', activity.RegisteredByNavIdent__c, 'RegUser from JSON payload' );
		System.assertEquals( 'BBA0412', activity.CaseWorkerNavIdent__c, 'Saksbehandler from JSON payload' );
		System.assertEquals( 'Fornavn Etternavn', activity.CaseWorkerName__c, 'Fornavn and Etternavn from JSON payload' );
	}
}
