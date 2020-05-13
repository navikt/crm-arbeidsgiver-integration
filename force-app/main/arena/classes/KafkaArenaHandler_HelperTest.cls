@isTest
private without sharing class KafkaArenaHandler_HelperTest {

	@testSetup
	private static void setup() {

		User registeredUser = TAG_TestDataFactory.createStandardUser();
		registeredUser.title = 'GL1812';
		update registeredUser;

		User responsibleUser = TAG_TestDataFactory.createStandardUser();
		responsibleUser.title = 'JEI1812';
		update responsibleUser;

		Account acc = new Account( Name = 'Test Employer 1', INT_OrganizationNumber__c = '973113631' );
		insert acc;
	}

	@isTest
	private static void testConvertKafkaToArenaModel() {

		KafkaMessage__c msg1 = new KafkaMessage__c();
		msg1.CRM_Topic__c = 'gg-arbeidsgiver-aktivitet-v1';
		msg1.CRM_Key__c = 'd60gwew775ed-249f-49e6-bd15-ff790b56cc07';
		msg1.CRM_Value__c = 'ewogICAgImFrdGl2aXRldFN0YXR1c2tvZGUiOiAiRlVMTEYiLAogICAgImJlZHJpZnRzbnIiOiA5NzMxMTM2MzEsCiAgICAiYmVza3JpdmVsc2UiOiAiQmVkcmlmdHPDuGtvbm9tc3R1ZGlldCAyMCB2dFxuSMO4Z3Nrb2xla2FuZGlkYXRzdHVkaWV0IG1lZCByZXRuaW5nIGZvciByZWduc2thcHNmw7hyZXJlLiAyMHZ0IiwKICAgICJvcmduck1vcnNlbHNrYXAiOiA5NzEyMjg4NjUsCiAgICAic2Frc2JlaGFuZGxlciI6ICJKRUkxODEyIiwKICAgICJha3Rpdml0ZXRza29kZSI6ICJVVERZUksiLAogICAgImZyYURhdG8iOiAiMjAwMy0wMS0wMSIsCiAgICAidGlsRGF0byI6ICIyMDA0LTEyLTMxIiwKICAgICJyZWdEYXRvIjogIjIwMDMtMDMtMjUiLAogICAgInJlZ1VzZXIiOiAiR0wxODEyIiwKICAgICJha3Rpdml0ZXRzZ3J1cHBla29kZSI6ICJUTFRBSyIsCiAgICAiYWt0aXZpdGV0c3R5cGViZXNrcml2ZWxzZSI6IG51bGwsCiAgICAiYWt0aXZpdGV0c3R5cGVuYXZuIjogIlV0ZGFubmluZyIsCiAgICAiZm9ybmF2biI6ICJKb25uIEVnaWwiLAogICAgImV0dGVybmF2biI6ICJJbmRyZXZvbGwiLAogICAgIm5hdklkZW50IjogIkkxMTEzNDUiCn0=';

		Test.StartTest();
		List<KafkaArenaHandler_Model> models = KafkaArenaHandler_Helper.convertKafkaToArenaModel( new List<KafkaMessage__c> { msg1 } );
		Test.StopTest();

		System.assertEquals( 1, models.size(), 'Only one kafka message added, only one model returned' );

		System.assertEquals( 'FULLF', models[0].aktivitetStatuskode );
		System.assertEquals( 973113631, models[0].bedriftsnr );
		System.assertEquals( 'Bedriftsøkonomstudiet 20 vt\nHøgskolekandidatstudiet med retning for regnskapsførere. 20vt', models[0].beskrivelse );
		System.assertEquals( 971228865, models[0].orgnrMorselskap );
		System.assertEquals( 'JEI1812', models[0].saksbehandler );
		System.assertEquals( 'UTDYRK', models[0].aktivitetskode );
		System.assertEquals( '2003-01-01', models[0].fraDato );
		System.assertEquals( '2004-12-31', models[0].tilDato );
		System.assertEquals( '2003-03-25', models[0].regDato );
		System.assertEquals( 'GL1812', models[0].regUser );
		System.assertEquals( 'TLTAK', models[0].aktivitetsgruppekode );
		System.assertEquals( null, models[0].aktivitetstypebeskrivelse );
		System.assertEquals( 'Utdanning', models[0].aktivitetstypenavn );
		System.assertEquals( 'Jonn Egil', models[0].fornavn );
		System.assertEquals( 'Indrevoll', models[0].etternavn );
		System.assertEquals( 'I111345', models[0].navIdent );
	}

	@isTest
	private static void testGetOrgNumbers() {

		KafkaMessage__c msg1 = new KafkaMessage__c();
		msg1.CRM_Topic__c = 'gg-arbeidsgiver-aktivitet-v1';
		msg1.CRM_Key__c = 'd60gwew775ed-249f-49e6-bd15-ff790b56cc07';
		msg1.CRM_Value__c = 'ewogICAgImFrdGl2aXRldFN0YXR1c2tvZGUiOiAiRlVMTEYiLAogICAgImJlZHJpZnRzbnIiOiA5NzMxMTM2MzEsCiAgICAiYmVza3JpdmVsc2UiOiAiQmVkcmlmdHPDuGtvbm9tc3R1ZGlldCAyMCB2dFxuSMO4Z3Nrb2xla2FuZGlkYXRzdHVkaWV0IG1lZCByZXRuaW5nIGZvciByZWduc2thcHNmw7hyZXJlLiAyMHZ0IiwKICAgICJvcmduck1vcnNlbHNrYXAiOiA5NzEyMjg4NjUsCiAgICAic2Frc2JlaGFuZGxlciI6ICJKRUkxODEyIiwKICAgICJha3Rpdml0ZXRza29kZSI6ICJVVERZUksiLAogICAgImZyYURhdG8iOiAiMjAwMy0wMS0wMSIsCiAgICAidGlsRGF0byI6ICIyMDA0LTEyLTMxIiwKICAgICJyZWdEYXRvIjogIjIwMDMtMDMtMjUiLAogICAgInJlZ1VzZXIiOiAiR0wxODEyIiwKICAgICJha3Rpdml0ZXRzZ3J1cHBla29kZSI6ICJUTFRBSyIsCiAgICAiYWt0aXZpdGV0c3R5cGViZXNrcml2ZWxzZSI6IG51bGwsCiAgICAiYWt0aXZpdGV0c3R5cGVuYXZuIjogIlV0ZGFubmluZyIsCiAgICAiZm9ybmF2biI6ICJKb25uIEVnaWwiLAogICAgImV0dGVybmF2biI6ICJJbmRyZXZvbGwiLAogICAgIm5hdklkZW50IjogIkkxMTEzNDUiCn0=';
		List<KafkaArenaHandler_Model> models = KafkaArenaHandler_Helper.convertKafkaToArenaModel( new List<KafkaMessage__c> { msg1 } );

		Test.StartTest();
		List<String> results = KafkaArenaHandler_Helper.getOrgNumbers( models );
		Test.StopTest();

		System.assertEquals( 1, results.size(), 'Only one org number as only one kafka message' );
		System.assert ( results.contains( '973113631' ) );
	}

	@isTest
	private static void testGetUserTitles() {

		KafkaMessage__c msg1 = new KafkaMessage__c();
		msg1.CRM_Topic__c = 'gg-arbeidsgiver-aktivitet-v1';
		msg1.CRM_Key__c = 'd60gwew775ed-249f-49e6-bd15-ff790b56cc07';
		msg1.CRM_Value__c = 'ewogICAgImFrdGl2aXRldFN0YXR1c2tvZGUiOiAiRlVMTEYiLAogICAgImJlZHJpZnRzbnIiOiA5NzMxMTM2MzEsCiAgICAiYmVza3JpdmVsc2UiOiAiQmVkcmlmdHPDuGtvbm9tc3R1ZGlldCAyMCB2dFxuSMO4Z3Nrb2xla2FuZGlkYXRzdHVkaWV0IG1lZCByZXRuaW5nIGZvciByZWduc2thcHNmw7hyZXJlLiAyMHZ0IiwKICAgICJvcmduck1vcnNlbHNrYXAiOiA5NzEyMjg4NjUsCiAgICAic2Frc2JlaGFuZGxlciI6ICJKRUkxODEyIiwKICAgICJha3Rpdml0ZXRza29kZSI6ICJVVERZUksiLAogICAgImZyYURhdG8iOiAiMjAwMy0wMS0wMSIsCiAgICAidGlsRGF0byI6ICIyMDA0LTEyLTMxIiwKICAgICJyZWdEYXRvIjogIjIwMDMtMDMtMjUiLAogICAgInJlZ1VzZXIiOiAiR0wxODEyIiwKICAgICJha3Rpdml0ZXRzZ3J1cHBla29kZSI6ICJUTFRBSyIsCiAgICAiYWt0aXZpdGV0c3R5cGViZXNrcml2ZWxzZSI6IG51bGwsCiAgICAiYWt0aXZpdGV0c3R5cGVuYXZuIjogIlV0ZGFubmluZyIsCiAgICAiZm9ybmF2biI6ICJKb25uIEVnaWwiLAogICAgImV0dGVybmF2biI6ICJJbmRyZXZvbGwiLAogICAgIm5hdklkZW50IjogIkkxMTEzNDUiCn0=';
		List<KafkaArenaHandler_Model> models = KafkaArenaHandler_Helper.convertKafkaToArenaModel( new List<KafkaMessage__c> { msg1 } );

		Test.StartTest();
		Set<String> results = KafkaArenaHandler_Helper.getUserTitles( models );
		Test.StopTest();

		System.assertEquals( 2, results.size(), 'Two user titles as one is responsible and one is the creator' );
		System.assert (results.containsAll( new Set<String> { 'GL1812', 'JEI1812' } ), 'Results should contain both user titles (GL1812 and JEI1812)');
	}


	@isTest
	private static void testGetKafkaIds() {

		KafkaMessage__c msg1 = new KafkaMessage__c();
		msg1.CRM_Topic__c = 'gg-arbeidsgiver-aktivitet-v1';
		msg1.CRM_Key__c = 'd60gwew775ed-249f-49e6-bd15-ff790b56cc07';
		msg1.CRM_Value__c = 'ewogICAgImFrdGl2aXRldFN0YXR1c2tvZGUiOiAiRlVMTEYiLAogICAgImJlZHJpZnRzbnIiOiA5NzMxMTM2MzEsCiAgICAiYmVza3JpdmVsc2UiOiAiQmVkcmlmdHPDuGtvbm9tc3R1ZGlldCAyMCB2dFxuSMO4Z3Nrb2xla2FuZGlkYXRzdHVkaWV0IG1lZCByZXRuaW5nIGZvciByZWduc2thcHNmw7hyZXJlLiAyMHZ0IiwKICAgICJvcmduck1vcnNlbHNrYXAiOiA5NzEyMjg4NjUsCiAgICAic2Frc2JlaGFuZGxlciI6ICJKRUkxODEyIiwKICAgICJha3Rpdml0ZXRza29kZSI6ICJVVERZUksiLAogICAgImZyYURhdG8iOiAiMjAwMy0wMS0wMSIsCiAgICAidGlsRGF0byI6ICIyMDA0LTEyLTMxIiwKICAgICJyZWdEYXRvIjogIjIwMDMtMDMtMjUiLAogICAgInJlZ1VzZXIiOiAiR0wxODEyIiwKICAgICJha3Rpdml0ZXRzZ3J1cHBla29kZSI6ICJUTFRBSyIsCiAgICAiYWt0aXZpdGV0c3R5cGViZXNrcml2ZWxzZSI6IG51bGwsCiAgICAiYWt0aXZpdGV0c3R5cGVuYXZuIjogIlV0ZGFubmluZyIsCiAgICAiZm9ybmF2biI6ICJKb25uIEVnaWwiLAogICAgImV0dGVybmF2biI6ICJJbmRyZXZvbGwiLAogICAgIm5hdklkZW50IjogIkkxMTEzNDUiCn0=';
		List<KafkaArenaHandler_Model> models = KafkaArenaHandler_Helper.convertKafkaToArenaModel( new List<KafkaMessage__c> { msg1 } );

		Test.StartTest();
		Set<String> results = KafkaArenaHandler_Helper.getKafkaIds( models );
		Test.StopTest();

		System.assertEquals( 1, results.size(), 'One message, only one key' );
		System.assert ( results.contains( 'd60gwew775ed-249f-49e6-bd15-ff790b56cc07' ), 'Results should only contain the one key' );
	}

	@isTest
	private static void testGetArenaActivity() {

		ArenaActivity__c aa = new ArenaActivity__c( KafkaId__c = 'd60gwew775ed-249f-49e6-bd15-ff790b56cc07', KafkaHash__c = 'ewogICAgImFrdGl2aXRldFN0YXR1c2tvZGUiOiAiRlVMTEYiLAogICAgImJlZHJpZnRzbnIiOiA5NzMxMTM2MzEsCiAgICAiYmVza3JpdmVsc2UiOiAiQmVkcmlmdHPDuGtvbm9tc3R1ZGlldCAyMCB2dFxuSMO4Z3Nrb2xla2FuZGlkYXRzdHVkaWV0IG1lZCByZXRuaW5nIGZvciByZWduc2thcHNmw7hyZXJlLiAyMHZ0IiwKICAgICJvcmduck1vcnNlbHNrYXAiOiA5NzEyMjg4NjUsCiAgICAic2Frc2JlaGFuZGxlciI6ICJKRUkxODEyIiwKICAgICJha3Rpdml0ZXRza29kZSI6ICJVVERZUksiLAogICAgImZyYURhdG8iOiAiMjAwMy0wMS0wMSIsCiAgICAidGlsRGF0byI6ICIyMDA0LTEyLTMxIiwKICAgICJyZWdEYXRvIjogIjIwMDMtMDMtMjUiLAogICAgInJlZ1VzZXIiOiAiR0wxODEyIiwKICAgICJha3Rpdml0ZXRzZ3J1cHBla29kZSI6ICJUTFRBSyIsCiAgICAiYWt0aXZpdGV0c3R5cGViZXNrcml2ZWxzZSI6IG51bGwsCiAgICAiYWt0aXZpdGV0c3R5cGVuYXZuIjogIlV0ZGFubmluZyIsCiAgICAiZm9ybmF2biI6ICJKb25uIEVnaWwiLAogICAgImV0dGVybmF2biI6ICJJbmRyZXZvbGwiLAogICAgIm5hdklkZW50IjogIkkxMTEzNDUiCn0=' );
		insert aa;

		Test.StartTest();
		List<ArenaActivity__c> results = KafkaArenaHandler_Helper.getArenaActivity( new Set<String> { 'd60gwew775ed-249f-49e6-bd15-ff790b56cc07'} ).values();
		Test.StopTest();

		System.assertEquals( 1, results.size(), 'Only one arena activity in db' );
		System.assertEquals( aa.Id, results[0].Id, 'Same activity id' );
	}

	@isTest
	private static void testConvertArenaModelToSObject() {

		Account acc = [SELECT Id FROM Account WHERE INT_OrganizationNumber__c = '973113631' LIMIT 1][0];
		User registeredUser = [SELECT Id FROM User WHERE Title = 'GL1812' LIMIT 1][0];
		User responsibleUser = [SELECT Id FROM User WHERE Title = 'JEI1812' LIMIT 1][0];

		KafkaMessage__c msg1 = new KafkaMessage__c();
		msg1.CRM_Topic__c = 'gg-arbeidsgiver-aktivitet-v1';
		msg1.CRM_Key__c = 'd60gwew775ed-249f-49e6-bd15-ff790b56cc07';
		msg1.CRM_Value__c = 'ewogICAgImFrdGl2aXRldFN0YXR1c2tvZGUiOiAiRlVMTEYiLAogICAgImJlZHJpZnRzbnIiOiA5NzMxMTM2MzEsCiAgICAiYmVza3JpdmVsc2UiOiAiQmVkcmlmdHPDuGtvbm9tc3R1ZGlldCAyMCB2dFxuSMO4Z3Nrb2xla2FuZGlkYXRzdHVkaWV0IG1lZCByZXRuaW5nIGZvciByZWduc2thcHNmw7hyZXJlLiAyMHZ0IiwKICAgICJvcmduck1vcnNlbHNrYXAiOiA5NzEyMjg4NjUsCiAgICAic2Frc2JlaGFuZGxlciI6ICJKRUkxODEyIiwKICAgICJha3Rpdml0ZXRza29kZSI6ICJVVERZUksiLAogICAgImZyYURhdG8iOiAiMjAwMy0wMS0wMSIsCiAgICAidGlsRGF0byI6ICIyMDA0LTEyLTMxIiwKICAgICJyZWdEYXRvIjogIjIwMDMtMDMtMjUiLAogICAgInJlZ1VzZXIiOiAiR0wxODEyIiwKICAgICJha3Rpdml0ZXRzZ3J1cHBla29kZSI6ICJUTFRBSyIsCiAgICAiYWt0aXZpdGV0c3R5cGViZXNrcml2ZWxzZSI6IG51bGwsCiAgICAiYWt0aXZpdGV0c3R5cGVuYXZuIjogIlV0ZGFubmluZyIsCiAgICAiZm9ybmF2biI6ICJKb25uIEVnaWwiLAogICAgImV0dGVybmF2biI6ICJJbmRyZXZvbGwiLAogICAgIm5hdklkZW50IjogIkkxMTEzNDUiCn0=';

		List<KafkaArenaHandler_Model> models = KafkaArenaHandler_Helper.convertKafkaToArenaModel( new List<KafkaMessage__c> { msg1 } );
		Map<String, User> userMap = SharedIntegrationFunctions.fetchUsersByTitle( new Set<String> { 'GL1812', 'JEI1812' } );
		Map<String, Account> accountMap = SharedIntegrationFunctions.fetchAccounts( new List<String> { '973113631' } );


		Test.StartTest();
		List<ArenaActivity__c> arenaActivities = KafkaArenaHandler_Helper.convertArenaModelToSObject( models, userMap, accountMap, new Map<String, ArenaActivity__c>() );
		Test.StopTest();

		System.assertEquals( 1, arenaActivities.size(), 'Only one kafka message added, only one sobject returned' );

		System.assertEquals( 'FULLF', arenaActivities[0].AktivitetStatuskode__c );
		System.assertEquals( acc.Id, arenaActivities[0].Account__c );
		System.assertEquals( 'Bedriftsøkonomstudiet 20 vt\nHøgskolekandidatstudiet med retning for regnskapsførere. 20vt', arenaActivities[0].Description__c );
		System.assertEquals( 'UTDYRK', arenaActivities[0].AktivitetsKode__c );
		System.assertEquals( Date.newInstance( 2003, 01, 01 ), arenaActivities[0].DateFrom__c );
		System.assertEquals( Date.newInstance( 2004, 12, 31 ), arenaActivities[0].DateTo__c );
		System.assertEquals( Date.newInstance( 2003, 03, 25 ), arenaActivities[0].DateRegistered__c );
		System.assertEquals( registeredUser.Id, arenaActivities[0].RegisteredBy__c );
		System.assertEquals( responsibleUser.Id, arenaActivities[0].OwnerId );
		System.assertEquals( 'TLTAK', arenaActivities[0].Aktivitetsgruppekode__c );
		System.assertEquals( null, arenaActivities[0].AktivitetstypeBeskrivelse__c );
		System.assertEquals( 'Utdanning', arenaActivities[0].Aktivitetstype__c );
	}

	@isTest
	private static void testConvertArenaModelToSObject_updateExistingWithoutChange() {

		ArenaActivity__c aa = new ArenaActivity__c( AktivitetsKode__c = 'UTDYRK', KafkaId__c = 'd60gwew775ed-249f-49e6-bd15-ff790b56cc07', KafkaHash__c = 'ewogICAgImFrdGl2aXRldFN0YXR1c2tvZGUiOiAiRlVMTEYiLAogICAgImJlZHJpZnRzbnIiOiA5NzMxMTM2MzEsCiAgICAiYmVza3JpdmVsc2UiOiAiQmVkcmlmdHPDuGtvbm9tc3R1ZGlldCAyMCB2dFxuSMO4Z3Nrb2xla2FuZGlkYXRzdHVkaWV0IG1lZCByZXRuaW5nIGZvciByZWduc2thcHNmw7hyZXJlLiAyMHZ0IiwKICAgICJvcmduck1vcnNlbHNrYXAiOiA5NzEyMjg4NjUsCiAgICAic2Frc2JlaGFuZGxlciI6ICJKRUkxODEyIiwKICAgICJha3Rpdml0ZXRza29kZSI6ICJVVERZUksiLAogICAgImZyYURhdG8iOiAiMjAwMy0wMS0wMSIsCiAgICAidGlsRGF0byI6ICIyMDA0LTEyLTMxIiwKICAgICJyZWdEYXRvIjogIjIwMDMtMDMtMjUiLAogICAgInJlZ1VzZXIiOiAiR0wxODEyIiwKICAgICJha3Rpdml0ZXRzZ3J1cHBla29kZSI6ICJUTFRBSyIsCiAgICAiYWt0aXZpdGV0c3R5cGViZXNrcml2ZWxzZSI6IG51bGwsCiAgICAiYWt0aXZpdGV0c3R5cGVuYXZuIjogIlV0ZGFubmluZyIsCiAgICAiZm9ybmF2biI6ICJKb25uIEVnaWwiLAogICAgImV0dGVybmF2biI6ICJJbmRyZXZvbGwiLAogICAgIm5hdklkZW50IjogIkkxMTEzNDUiCn0=' );

		KafkaMessage__c msg1 = new KafkaMessage__c();
		msg1.CRM_Topic__c = 'gg-arbeidsgiver-aktivitet-v1';
		msg1.CRM_Key__c = 'd60gwew775ed-249f-49e6-bd15-ff790b56cc07';
		msg1.CRM_Value__c = 'ewogICAgImFrdGl2aXRldFN0YXR1c2tvZGUiOiAiRlVMTEYiLAogICAgImJlZHJpZnRzbnIiOiA5NzMxMTM2MzEsCiAgICAiYmVza3JpdmVsc2UiOiAiQmVkcmlmdHPDuGtvbm9tc3R1ZGlldCAyMCB2dFxuSMO4Z3Nrb2xla2FuZGlkYXRzdHVkaWV0IG1lZCByZXRuaW5nIGZvciByZWduc2thcHNmw7hyZXJlLiAyMHZ0IiwKICAgICJvcmduck1vcnNlbHNrYXAiOiA5NzEyMjg4NjUsCiAgICAic2Frc2JlaGFuZGxlciI6ICJKRUkxODEyIiwKICAgICJha3Rpdml0ZXRza29kZSI6ICJVVERZUksiLAogICAgImZyYURhdG8iOiAiMjAwMy0wMS0wMSIsCiAgICAidGlsRGF0byI6ICIyMDA0LTEyLTMxIiwKICAgICJyZWdEYXRvIjogIjIwMDMtMDMtMjUiLAogICAgInJlZ1VzZXIiOiAiR0wxODEyIiwKICAgICJha3Rpdml0ZXRzZ3J1cHBla29kZSI6ICJUTFRBSyIsCiAgICAiYWt0aXZpdGV0c3R5cGViZXNrcml2ZWxzZSI6IG51bGwsCiAgICAiYWt0aXZpdGV0c3R5cGVuYXZuIjogIlV0ZGFubmluZyIsCiAgICAiZm9ybmF2biI6ICJKb25uIEVnaWwiLAogICAgImV0dGVybmF2biI6ICJJbmRyZXZvbGwiLAogICAgIm5hdklkZW50IjogIkkxMTEzNDUiCn0=';

		List<KafkaArenaHandler_Model> models = KafkaArenaHandler_Helper.convertKafkaToArenaModel( new List<KafkaMessage__c> { msg1 } );
		Map<String, User> userMap = SharedIntegrationFunctions.fetchUsersByTitle( new Set<String> { 'GL1812', 'JEI1812' } );
		Map<String, Account> accountMap = SharedIntegrationFunctions.fetchAccounts( new List<String> { '973113631' } );
		Map<String, ArenaActivity__c> existingActivities = new Map<String, ArenaActivity__c>();
		existingActivities.put( aa.KafkaId__c, aa );

		Test.StartTest();
		List<ArenaActivity__c> arenaActivities = KafkaArenaHandler_Helper.convertArenaModelToSObject( models, userMap, accountMap, existingActivities );
		Test.StopTest();

		System.assertEquals( 0, arenaActivities.size(), '0 records, as the hash has NOT changed' );
	}

	@isTest
	private static void testConvertArenaModelToSObject_updateExistingWithChange() {

		ArenaActivity__c aa = new ArenaActivity__c( AktivitetsKode__c = 'UTDYRK', KafkaId__c = 'd60gwew775ed-249f-49e6-bd15-ff790b56cc07', KafkaHash__c = 'ewogICAgImFrdGl2aXRldFN0YXR1c2tvZGUiOiAiRlVMTEYiLAogICAgImJlZHJpZnRzbnIiOiA5NzMxMTM2MzEsCiAgICAiYmVza3JpdmVsc2UiOiAiQmVkcmlmdHPDuGtvbm9tc3R1ZGlldCAyMCB2dFxuSMO4Z3Nrb2xla2FuZGlkYXRzdHVkaWV0IG1lZCByZXRuaW5nIGZvciByZWduc2thcHNmw7hyZXJlLiAyMHZ0IiwKICAgICJvcmduck1vcnNlbHNrYXAiOiA5NzEyMjg4NjUsCiAgICAic2Frc2JlaGFuZGxlciI6ICJKRUkxODEyIiwKICAgICJha3Rpdml0ZXRza29kZSI6ICJVVERZUksiLAogICAgImZyYURhdG8iOiAiMjAwMy0wMS0wMSIsCiAgICAidGlsRGF0byI6ICIyMDA0LTEyLTMxIiwKICAgICJyZWdEYXRvIjogIjIwMDMtMDMtMjUiLAogICAgInJlZ1VzZXIiOiAiR0wxODEyIiwKICAgICJha3Rpdml0ZXRzZ3J1cHBla29kZSI6ICJUTFRBSyIsCiAgICAiYWt0aXZpdGV0c3R5cGViZXNrcml2ZWxzZSI6IG51bGwsCiAgICAiYWt0aXZpdGV0c3R5cGVuYXZuIjogIlV0ZGFubmluZyIsCiAgICAiZm9ybmF2biI6ICJKb25uIEVnaWwiLAogICAgImV0dGVybmF2biI6ICJJbmRyZXZvbGwiLAogICAgIm5hdklkZW50IjogIkkxMTEzNDUiCn0=' );

		KafkaMessage__c msg1 = new KafkaMessage__c();
		msg1.CRM_Topic__c = 'gg-arbeidsgiver-aktivitet-v1';
		msg1.CRM_Key__c = 'd60gwew775ed-249f-49e6-bd15-ff790b56cc07';
		msg1.CRM_Value__c = 'ewogICAgImFrdGl2aXRldFN0YXR1c2tvZGUiOiAiRlVMTEYiLAogICAgImJlZHJpZnRzbnIiOiA5NzMxMTM2MzEsCiAgICAiYmVza3JpdmVsc2UiOiAiQmVkcmlmdHPDuGtvbm9tc3R1ZGlldCAyMCB2dFxuSMO4Z3Nrb2xla2FuZGlkYXRzdHVkaWV0IG1lZCByZXRuaW5nIGZvciByZWduc2thcHNmw7hyZXJlLiAyMHZ0IiwKICAgICJvcmduck1vcnNlbHNrYXAiOiA5NzEyMjg4NjUsCiAgICAic2Frc2JlaGFuZGxlciI6ICJKRUkxODEyIiwKICAgICJha3Rpdml0ZXRza29kZSI6ICJVVERZUksyIiwKICAgICJmcmFEYXRvIjogIjIwMDMtMDEtMDEiLAogICAgInRpbERhdG8iOiAiMjAwNC0xMi0zMSIsCiAgICAicmVnRGF0byI6ICIyMDAzLTAzLTI1IiwKICAgICJyZWdVc2VyIjogIkdMMTgxMiIsCiAgICAiYWt0aXZpdGV0c2dydXBwZWtvZGUiOiAiVExUQUsiLAogICAgImFrdGl2aXRldHN0eXBlYmVza3JpdmVsc2UiOiBudWxsLAogICAgImFrdGl2aXRldHN0eXBlbmF2biI6ICJVdGRhbm5pbmciLAogICAgImZvcm5hdm4iOiAiSm9ubiBFZ2lsIiwKICAgICJldHRlcm5hdm4iOiAiSW5kcmV2b2xsIiwKICAgICJuYXZJZGVudCI6ICJJMTExMzQ1Igp9';

		List<KafkaArenaHandler_Model> models = KafkaArenaHandler_Helper.convertKafkaToArenaModel( new List<KafkaMessage__c> { msg1 } );
		Map<String, User> userMap = SharedIntegrationFunctions.fetchUsersByTitle( new Set<String> { 'GL1812', 'JEI1812' } );
		Map<String, Account> accountMap = SharedIntegrationFunctions.fetchAccounts( new List<String> { '973113631' } );
		Map<String, ArenaActivity__c> existingActivities = new Map<String, ArenaActivity__c>();
		existingActivities.put( aa.KafkaId__c, aa );

		Test.StartTest();
		List<ArenaActivity__c> arenaActivities = KafkaArenaHandler_Helper.convertArenaModelToSObject( models, userMap, accountMap, existingActivities );
		Test.StopTest();

		System.assertEquals( 1, arenaActivities.size(), 'Still one activity, as the hash has changed' );
	}

	@isTest
	private static void testRemoveDuplicates() {

		KafkaMessage__c msg1 = new KafkaMessage__c();
		msg1.CRM_Topic__c = 'gg-arbeidsgiver-aktivitet-v1';
		msg1.CRM_Key__c = 'd60gwew775ed-249f-49e6-bd15-ff790b56cc07';
		msg1.CRM_Value__c = 'ewogICAgImFrdGl2aXRldFN0YXR1c2tvZGUiOiAiRlVMTEYiLAogICAgImJlZHJpZnRzbnIiOiA5NzMxMTM2MzEsCiAgICAiYmVza3JpdmVsc2UiOiAiQmVkcmlmdHPDuGtvbm9tc3R1ZGlldCAyMCB2dFxuSMO4Z3Nrb2xla2FuZGlkYXRzdHVkaWV0IG1lZCByZXRuaW5nIGZvciByZWduc2thcHNmw7hyZXJlLiAyMHZ0IiwKICAgICJvcmduck1vcnNlbHNrYXAiOiA5NzEyMjg4NjUsCiAgICAic2Frc2JlaGFuZGxlciI6ICJKRUkxODEyIiwKICAgICJha3Rpdml0ZXRza29kZSI6ICJVVERZUksyIiwKICAgICJmcmFEYXRvIjogIjIwMDMtMDEtMDEiLAogICAgInRpbERhdG8iOiAiMjAwNC0xMi0zMSIsCiAgICAicmVnRGF0byI6ICIyMDAzLTAzLTI1IiwKICAgICJyZWdVc2VyIjogIkdMMTgxMiIsCiAgICAiYWt0aXZpdGV0c2dydXBwZWtvZGUiOiAiVExUQUsiLAogICAgImFrdGl2aXRldHN0eXBlYmVza3JpdmVsc2UiOiBudWxsLAogICAgImFrdGl2aXRldHN0eXBlbmF2biI6ICJVdGRhbm5pbmciLAogICAgImZvcm5hdm4iOiAiSm9ubiBFZ2lsIiwKICAgICJldHRlcm5hdm4iOiAiSW5kcmV2b2xsIiwKICAgICJuYXZJZGVudCI6ICJJMTExMzQ1Igp9';

		KafkaMessage__c msg2 = new KafkaMessage__c();
		msg2.CRM_Topic__c = 'gg-arbeidsgiver-aktivitet-v1';
		msg2.CRM_Key__c = 'd60gwew775ed-249f-49e6-bd15-ff790b56cc07';
		msg2.CRM_Value__c = 'ewogICAgImFrdGl2aXRldFN0YXR1c2tvZGUiOiAiRlVMTEYiLAogICAgImJlZHJpZnRzbnIiOiA5NzMxMTM2MzEsCiAgICAiYmVza3JpdmVsc2UiOiAiQmVkcmlmdHPDuGtvbm9tc3R1ZGlldCAyMCB2dFxuSMO4Z3Nrb2xla2FuZGlkYXRzdHVkaWV0IG1lZCByZXRuaW5nIGZvciByZWduc2thcHNmw7hyZXJlLiAyMHZ0IiwKICAgICJvcmduck1vcnNlbHNrYXAiOiA5NzEyMjg4NjUsCiAgICAic2Frc2JlaGFuZGxlciI6ICJKRUkxODEyIiwKICAgICJha3Rpdml0ZXRza29kZSI6ICJVVERZUksiLAogICAgImZyYURhdG8iOiAiMjAwMy0wMS0wMSIsCiAgICAidGlsRGF0byI6ICIyMDA0LTEyLTMxIiwKICAgICJyZWdEYXRvIjogIjIwMDMtMDMtMjUiLAogICAgInJlZ1VzZXIiOiAiR0wxODEyIiwKICAgICJha3Rpdml0ZXRzZ3J1cHBla29kZSI6ICJUTFRBSyIsCiAgICAiYWt0aXZpdGV0c3R5cGViZXNrcml2ZWxzZSI6IG51bGwsCiAgICAiYWt0aXZpdGV0c3R5cGVuYXZuIjogIlV0ZGFubmluZyIsCiAgICAiZm9ybmF2biI6ICJKb25uIEVnaWwiLAogICAgImV0dGVybmF2biI6ICJJbmRyZXZvbGwiLAogICAgIm5hdklkZW50IjogIkkxMTEzNDUiCn0=';

		List<KafkaArenaHandler_Model> models = KafkaArenaHandler_Helper.convertKafkaToArenaModel( new List<KafkaMessage__c> { msg1, msg2 } );
		Map<String, User> userMap = SharedIntegrationFunctions.fetchUsersByTitle( new Set<String> { 'GL1812', 'JEI1812' } );
		Map<String, Account> accountMap = SharedIntegrationFunctions.fetchAccounts( new List<String> { '973113631' } );
		List<ArenaActivity__c> arenaActivities = KafkaArenaHandler_Helper.convertArenaModelToSObject( models, userMap, accountMap, new Map<String, ArenaActivity__c>() );

		System.assertEquals( 2, arenaActivities.size(), 'Two duplicates were added' );

		Test.StartTest();
		arenaActivities = KafkaArenaHandler_Helper.removeDuplicates( arenaActivities );
		Test.StopTest();

		System.assertEquals( 1, arenaActivities.size(), 'Should only have one record after removing duplicate' );
		System.assertEquals( 'UTDYRK', arenaActivities[0].AktivitetsKode__c, 'Activity code should be from the last msg' );
	}

	@isTest
	private static void testStringToDate() {

		Test.StartTest();
		Date res = KafkaArenaHandler_Helper.stringToDate( '2003-01-01' );
		Test.StopTest();

		System.assertEquals( 2003, res.year() );
		System.assertEquals( 1, res.month() );
		System.assertEquals( 1, res.day() );
	}
}