@isTest
public with sharing class KafkaFiaCaseHandlerTEST {
@TestSetup
static void makeData(){
    Account acc = new Account(Name = 'Test Employer 1', INT_OrganizationNumber__c = '973113631');
        insert acc;
    Account acc2 = new Account(Name = 'Test Employer 2', INT_OrganizationNumber__c = '973113632');
        insert acc2;

        List<User> use = TestDataFactory.getUsers(4, 'Standard User', false, false);
        use[0].CRM_NAV_Ident__c = 'C156986';
        use[1].CRM_NAV_Ident__c = 'C156987';
        insert use;

        String json1 = '{"saksnummer": "a240d1adtuasydt1", "orgnr": "973113631", "eierAvSak": "C156986", "endretAvHendelseId": "sdfhoisdyfio49856", "status": "Vurderes", "opprettetTidspunkt": "2022-02-18T07:07:07.064711", "endretTidspunkt": "2022-02-18T07:19:21.575794"}';
        String json2 = '{"saksnummer": "a240d1adtuasydt2", "orgnr": "973113631", "eierAvSak": "C156987", "endretAvHendelseId": "sdfhoisdyfio49856", "status": "SLETTET", "opprettetTidspunkt": "2022-02-18T07:07:07.064711", "endretTidspunkt": "2022-02-18T07:19:21.575794"}';
        String json3 = '{"saksnummer": "a240d1adtuasydt3", "orgnr": "973113635", "eierAvSak": "C156987", "endretAvHendelseId": "sdfhoisdyfio49856", "status": "IKKE_AKTIV", "opprettetTidspunkt": "2022-02-18T07:07:07.064711", "endretTidspunkt": "2022-02-18T07:19:23.575794"}';
        String invalid_json = '{"saksnummer": "a240d1adtuasydt4", "orgnr": "973113631", "eierAvSak": "C156986"';
       // String invalid_jsonNoOrgNr = '{"saksnummer": "a240d1adtuasydt5", "orgnr": null, "eierAvSak": "C156986", "endretAvHendelseId": "sdfhoisdyfio49856", "status": "Kartlegges", "opprettetTidspunkt": "2022-02-18T07:07:07.064711", "endretTidspunkt": "2022-02-18T07:19:21.575794"}';
        
        String encodedValue1 = EncodingUtil.base64Encode(Blob.valueOf(json1));
        String encodedValue2 = EncodingUtil.base64Encode(Blob.valueOf(json2));
        String encodedValue3 = EncodingUtil.base64Encode(Blob.valueOf(json3));
        String invalidEncodedValue = EncodingUtil.base64Encode(Blob.valueOf(invalid_json));
       // String invalidEncodedValueNoOrgNr = EncodingUtil.base64Encode(Blob.valueOf(invalid_jsonNoOrgNr));
       
        List<KafkaMessage__c> messages = new List<KafkaMessage__c>();

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'pia.ia-sak-v1';
        msg1.CRM_Key__c = 'a240d1adtuasydt1';
        msg1.CRM_Value__c = encodedValue1;

        KafkaMessage__c msg2 = new KafkaMessage__c();
        msg2.CRM_Topic__c = 'pia.ia-sak-v1';
        msg2.CRM_Key__c = 'a240d1adtuasydt2';
        msg2.CRM_Value__c = encodedValue2;

        KafkaMessage__c msg3 = new KafkaMessage__c();
        msg3.CRM_Topic__c = 'pia.ia-sak-v1';
        msg3.CRM_Key__c = 'a240d1adtuasydt3';
        msg3.CRM_Value__c = encodedValue3;

        KafkaMessage__c invalidMsg = new KafkaMessage__c();
        invalidMsg.CRM_Topic__c = 'pia.ia-sak-v1';
        invalidMsg.CRM_Key__c = 'a240d1adtuasydt4';
        invalidMsg.CRM_Value__c = invalidEncodedValue;
       
    /*     KafkaMessage__c invalidNoOrgNr = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'pia.ia-sak-v1';
        msg1.CRM_Key__c = 'a240d1adtuasydt5';
        msg1.CRM_Value__c = invalidEncodedValueNoOrgNr; */
       
        messages.add(msg1);
        messages.add(msg2);
        messages.add(msg3);
        messages.add(invalidMsg);
       // messages.add(invalidNoOrgNr);

        insert messages;
}

@isTest
static void testProcessSingleMessage() {
    List<KafkaMessage__c> msg = [
        SELECT CRM_Topic__c, CRM_Value__c, CRM_Key__c
        FROM KafkaMessage__c WHERE CRM_Key__c = 'a240d1adtuasydt1'
    ];
    Test.startTest();
    KafkaFiaCaseHandler handler = new KafkaFiaCaseHandler();
    handler.processMessages(msg);
    Test.stopTest();

    List<IACase__c> iacase = [
        SELECT Id, Name, CaseOwner__c, CaseStatus__c, Account__c, IALastModifiedDate__c, IACreatedDate__c, KafkaId__c, KafkaHash__c
        FROM IACase__c WHERE IACase__c.Name = 'a240d1adtuasydt1'
    ];

    String startDate = string.valueOf(iacase[0].IACreatedDate__c);
    String lastModified = string.valueOf(iacase[0].IALastModifiedDate__c); 
   
    System.assertEquals(msg[0].CRM_Key__c, iacase[0].KafkaId__c, 'Correct KafkaId');
    System.assertEquals(msg[0].CRM_Value__c, iacase[0].KafkaHash__c, 'Correct KafkaId');
    System.assertEquals('a240d1adtuasydt1', iacase[0].Name, 'Correct Case Nr');
    System.assertEquals('C156986', iacase[0].CaseOwner__c, 'Correct Case Owner');
    System.assertEquals('VURDERES', iacase[0].CaseStatus__c, 'Correct Status');
    System.assertEquals('2022-02-18 07:07:07', startDate, 'Correct Start date');
    System.assertEquals('2022-02-18 07:19:21', lastModified, 'Correct Last Modified date');
}

    @isTest
    static void testIsMostRecent() {

//gjør denne testen noen ting nå?
        List<KafkaMessage__c> messages = new List<KafkaMessage__c>();

        String json1 = '{"saksnummer": "a240d1adtuasydt1", "orgnr": "973113631", "eierAvSak": "C156986", "endretAvHendelseId": "sdfhoisdyfio49856", "status": "SLETTET", "opprettetTidspunkt": "2022-02-18T07:07:07.064711", "endretTidspunkt": "2023-07-18T09:20:21.575794"}';
        String encodedValue1 = EncodingUtil.base64Encode(Blob.valueOf(json1));

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'pia.ia-sak-v1';
        msg1.CRM_Key__c = 'a240d1adtuasydt1';
        msg1.CRM_Value__c = encodedValue1;

        messages.add(msg1);
        insert messages;

     
        Test.startTest();
    
        List<KafkaMessage__c> updatedMsg = [
            SELECT CRM_Topic__c, CRM_Value__c, CRM_Key__c
            FROM KafkaMessage__c WHERE CRM_Key__c = 'a240d1adtuasydt1'
        ];
        KafkaFiaCaseHandler handler = new KafkaFiaCaseHandler();
        handler.processMessages(updatedMsg);

        Test.stopTest();

        List<IACase__c> iacase = [
            SELECT Id, Name, CaseOwner__c, CaseStatus__c, Account__c, IALastModifiedDate__c, IACreatedDate__c, KafkaId__c, KafkaHash__c
            FROM IACase__c WHERE IACase__c.Name = 'a240d1adtuasydt1'
        ];
      
        String startDate = string.valueOf(iacase[0].IACreatedDate__c);
        String lastModified = string.valueOf(iacase[0].IALastModifiedDate__c); 
   
        System.assertEquals('SLETTET', iacase[0].CaseStatus__c,  'Status updated from vurderes to kartlegges');
        System.assertEquals(1, iacase.size(), 'check that iacase does not add a new case when changes are made');
        System.assertEquals('a240d1adtuasydt1', iacase[0].Name, 'Correct Case Nr');
        System.assertEquals('C156986', iacase[0].CaseOwner__c, 'Correct Case Owner');
        System.assertEquals('2023-07-18 09:20:21',lastModified, 'Last Modified date updated');

    }

    @isTest
    static void testNoOrgNr() {

        String invalid_jsonNoOrgNr = '{"saksnummer": "a240d1adtuasydt5", "orgnr": null, "eierAvSak": "C156986", "endretAvHendelseId": "sdfhoisdyfio49856", "status": "Kartlegges", "opprettetTidspunkt": "2022-02-18T07:07:07.064711", "endretTidspunkt": "2022-02-18T07:19:21.575794"}';
        String invalidEncodedValueNoOrgNr = EncodingUtil.base64Encode(Blob.valueOf(invalid_jsonNoOrgNr));
       
        List<KafkaMessage__c> messages = new List<KafkaMessage__c>();
        KafkaMessage__c invalidNoOrgNr = new KafkaMessage__c();
        invalidNoOrgNr.CRM_Topic__c = 'pia.ia-sak-v1';
        invalidNoOrgNr.CRM_Key__c = 'a240d1adtuasydt5';
        invalidNoOrgNr.CRM_Value__c = invalidEncodedValueNoOrgNr;
        messages.add(invalidNoOrgNr);

        insert messages;

        List<KafkaMessage__c> msg = [
            SELECT CRM_Topic__c, CRM_Value__c, CRM_Key__c
            FROM KafkaMessage__c WHERE CRM_Key__c = 'a240d1adtuasydt5'
        ];

         Test.startTest();
        KafkaFiaCaseHandler handler = new KafkaFiaCaseHandler();
        handler.processMessages(msg);
         Test.stopTest();

        List<IACase__c> iacase = [
            SELECT Id, Name, CaseOwner__c, CaseStatus__c, Account__c, IALastModifiedDate__c, IACreatedDate__c, KafkaId__c, KafkaHash__c
            FROM IACase__c WHERE IACase__c.Name = 'a240d1adtuasydt5'
        ];
      
        System.assertEquals('null1', iacase[0].Account__c);
        System.assertEquals('null', iacase[0].Account__c);
        System.assertEquals('Error', iacase[0].CaseStatus__c);
        System.assertEquals('null', iacase[0].Account__c);
        System.assertEquals('Error', msg[0].CRM_Status__c);
    }

    @IsTest
    static void testProcessSingleMessage_InvalidJson() {

        List<KafkaMessage__c> msg = [
            SELECT CRM_Value__c, CRM_Key__c
            FROM KafkaMessage__c WHERE CRM_Key__c = 'a240d1adtuasydt4'
        ];

        KafkaFiaCaseHandler handler = new KafkaFiaCaseHandler();
        handler.processMessages(msg);

        System.assertEquals(KafkaMessageService.STATUS_ERROR, msg[0].CRM_Status__c);
        System.assert(String.isNotBlank(msg[0].CRM_ErrorMessage__c));
    }

/*    @isTest
    static void checkThatAllFiaCasesAreSavedOnAccount() {
        KafkaFiaCaseHandler handler = new KafkaFiaCaseHandler();
        List<IACase__c> fiaCases = new List<IACase__c>();
        test.startTest();

        //getfiacaswsobjects henter ikke ut noen ting? nei, den er tom
        fiaCases = handler.getFiaCasesSObjects();
        test.stopTest();
        System.debug('fiacase1');
        System.debug(fiaCases[0].CaseNr__c);
        System.debug('fiacase2');
        System.debug(fiaCases[1].CaseNr__c);
        System.debug('fiacase3');
        System.debug(fiaCases[2].CaseNr__c);
        System.debug(fiaCases[3].CaseNr__c);
        System.debug(fiaCases[4].CaseNr__c);
        Assert.areEqual('SLETTET', fiaCases[3].CaseNr__c, 'Check is first fiacase in array fiacases har TAG_FiaCaseStatus__c deleted');
        System.assertEquals('SLETTET', fiaCases[3].CaseNr__c, 'Check is first fiacase in array fiacases har TAG_FiaCaseStatus__c deleted');
        Assert.areEqual('IKKE_AKTIV', fiaCases[4].CaseNr__c, 'Check is second fiacase in array fiacases har TAG_FiaCaseStatus__c IKKE_AKTIV');
        System.assertEquals('IKKE_AKTIV', fiaCases[5].CaseNr__c, 'Check is second fiacase in array fiacases har TAG_FiaCaseStatus__c IKKE_AKTIV');
    
    }  */

}
