/* mass update for existing arena activities */
public with sharing class ArenaMassUpdateService_Batch implements Database.Batchable<SObject> {

	private String query;

	public ArenaMassUpdateService_Batch( String query ) {
		this.query = query;
	}

	public Database.QueryLocator start( Database.BatchableContext BC ) {
		return Database.getQueryLocator( this.query );
	}

	public void execute( Database.BatchableContext BC, List<ArenaActivity__c> scope ) {
		for(ArenaActivity__c aa:scope){
			KafkaArenaHandler_Model arenaModel = KafkaArenaHandler_Model.parse( aa.JsonPayload__c, null, null );
			aa.RegisteredByNavIdent__c = arenaModel.RegUser;
			aa.CaseWorkerNavIdent__c=arenaModel.Saksbehandler;
			if(arenaModel.Fornavn!=null){
				aa.CaseWorkerName__c=arenaModel.Fornavn + ' ' + arenaModel.Etternavn;
			}
		}
		update scope;
	}

	public void finish( Database.BatchableContext BC ) {
	}
}
