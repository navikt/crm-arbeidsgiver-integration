@IsTest
private without sharing class KafkaArenaHandlerTest {

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
	private static void testHandleMessages() {

		Account acc = [SELECT Id FROM Account WHERE INT_OrganizationNumber__c = '973113631' LIMIT 1][0];
		User registeredUser = [SELECT Id FROM User WHERE Title = 'GL1812' LIMIT 1][0];
		User responsibleUser = [SELECT Id FROM User WHERE Title = 'JEI1812' LIMIT 1][0];

		KafkaMessage__c msg1 = new KafkaMessage__c();
		msg1.CRM_Topic__c = 'aapen-arena-arbeidsgiver';
		msg1.CRM_Key__c = 'd60gwew775ed-249f-49e6-bd15-ff790b56cc07';
		msg1.CRM_Value__c = 'ewogICAgImFrdGl2aXRldFN0YXR1c2tvZGUiOiAiRlVMTEYiLAogICAgImJlZHJpZnRzbnIiOiA5NzMxMTM2MzEsCiAgICAiYmVza3JpdmVsc2UiOiAiQmVkcmlmdHPDuGtvbm9tc3R1ZGlldCAyMCB2dFxuSMO4Z3Nrb2xla2FuZGlkYXRzdHVkaWV0IG1lZCByZXRuaW5nIGZvciByZWduc2thcHNmw7hyZXJlLiAyMHZ0IiwKICAgICJvcmduck1vcnNlbHNrYXAiOiA5NzEyMjg4NjUsCiAgICAic2Frc2JlaGFuZGxlciI6ICJKRUkxODEyIiwKICAgICJha3Rpdml0ZXRza29kZSI6ICJVVERZUksiLAogICAgImZyYURhdG8iOiAiMjAwMy0wMS0wMSIsCiAgICAidGlsRGF0byI6ICIyMDA0LTEyLTMxIiwKICAgICJyZWdEYXRvIjogIjIwMDMtMDMtMjUiLAogICAgInJlZ1VzZXIiOiAiR0wxODEyIiwKICAgICJha3Rpdml0ZXRzZ3J1cHBla29kZSI6ICJUTFRBSyIsCiAgICAiYWt0aXZpdGV0c3R5cGViZXNrcml2ZWxzZSI6IG51bGwsCiAgICAiYWt0aXZpdGV0c3R5cGVuYXZuIjogIlV0ZGFubmluZyIsCiAgICAiZm9ybmF2biI6ICJKb25uIEVnaWwiLAogICAgImV0dGVybmF2biI6ICJJbmRyZXZvbGwiLAogICAgIm5hdklkZW50IjogIkkxMTEzNDUiCn0=';
		insert msg1;

		Test.StartTest();
		Test.StopTest();

		List<ArenaActivity__c> arenaActivities = [SELECT Id, Account__c, Account__r.INT_OrganizationNumber__c, Aktivitetsgruppekode__c, AktivitetsKode__c, AktivitetStatuskode__c, Aktivitetstype__c, AktivitetstypeBeskrivelse__c, DateFrom__c, DateRegistered__c, DateTo__c, Description__c, RegisteredBy__c, OwnerId FROM ArenaActivity__c];

		System.assertEquals( 1, arenaActivities.size(), 'Only one activity added' );

		System.assertEquals( 'FULLF', arenaActivities[0].AktivitetStatuskode__c );
		System.assertEquals( acc.Id, arenaActivities[0].Account__c );
		System.assertEquals( '973113631', arenaActivities[0].Account__r.INT_OrganizationNumber__c );
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
	private static void testHandleMessages_usersAndAccountsDontExists() {

		KafkaMessage__c msg1 = new KafkaMessage__c();
		msg1.CRM_Topic__c = 'aapen-arena-arbeidsgiver';
		msg1.CRM_Key__c = 'd60gwew775ed-249f-49e6-bd15-ff790b56cc07';
		msg1.CRM_Value__c = 'ewogICAgImFrdGl2aXRldFN0YXR1c2tvZGUiOiAiRlVMTEYiLAogICAgImJlZHJpZnRzbnIiOiAxMjMsCiAgICAiYmVza3JpdmVsc2UiOiAiQmVkcmlmdHPDuGtvbm9tc3R1ZGlldCAyMCB2dFxuSMO4Z3Nrb2xla2FuZGlkYXRzdHVkaWV0IG1lZCByZXRuaW5nIGZvciByZWduc2thcHNmw7hyZXJlLiAyMHZ0IiwKICAgICJvcmduck1vcnNlbHNrYXAiOiAxMjMxMjMsCiAgICAic2Frc2JlaGFuZGxlciI6ICJXSUxMTk9URVhJU1RTMiIsCiAgICAiYWt0aXZpdGV0c2tvZGUiOiAiVVREWVJLIiwKICAgICJmcmFEYXRvIjogIjIwMDMtMDEtMDEiLAogICAgInRpbERhdG8iOiAiMjAwNC0xMi0zMSIsCiAgICAicmVnRGF0byI6ICIyMDAzLTAzLTI1IiwKICAgICJyZWdVc2VyIjogIldJTExOT1RFWElTVFMiLAogICAgImFrdGl2aXRldHNncnVwcGVrb2RlIjogIlRMVEFLIiwKICAgICJha3Rpdml0ZXRzdHlwZWJlc2tyaXZlbHNlIjogbnVsbCwKICAgICJha3Rpdml0ZXRzdHlwZW5hdm4iOiAiVXRkYW5uaW5nIiwKICAgICJmb3JuYXZuIjogIkpvbm4gRWdpbCIsCiAgICAiZXR0ZXJuYXZuIjogIkluZHJldm9sbCIsCiAgICAibmF2SWRlbnQiOiAiSTExMTM0NSIKfQ==';
		insert msg1;

		Test.StartTest();
		Test.StopTest();

		List<ArenaActivity__c> arenaActivities = [SELECT Id, Account__c, RegisteredBy__c, OwnerId FROM ArenaActivity__c];

		System.assertEquals( 1, arenaActivities.size(), 'Only one activity added' );
		System.assertEquals( null, arenaActivities[0].Account__c );
		System.assertEquals( null, arenaActivities[0].RegisteredBy__c );
		System.assertEquals( System.UserInfo.getUserId(), arenaActivities[0].OwnerId );
	}
}
