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
      
        String encodedValue1 = EncodingUtil.base64Encode(Blob.valueOf(json1));
        String encodedValue2 = EncodingUtil.base64Encode(Blob.valueOf(json2));
        String encodedValue3 = EncodingUtil.base64Encode(Blob.valueOf(json3));
        String invalidEncodedValue = EncodingUtil.base64Encode(Blob.valueOf(invalid_json));
      
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
       
        messages.add(msg1);
        messages.add(msg2);
        messages.add(msg3);
        messages.add(invalidMsg);
    
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
    static void testSingleMessageChanged() {

        List<KafkaMessage__c> messages = new List<KafkaMessage__c>();

        List<KafkaMessage__c> msg = [
            SELECT CRM_Topic__c, CRM_Value__c, CRM_Key__c
            FROM KafkaMessage__c WHERE CRM_Key__c = 'a240d1adtuasydt1' LIMIT 1
        ];
        KafkaFiaCaseHandler handler = new KafkaFiaCaseHandler();
        handler.processMessages(msg);

        String json1 = '{"saksnummer": "a240d1adtuasydt1", "orgnr": "973113631", "eierAvSak": "C156986", "endretAvHendelseId": "sdfhoisdyfio49856", "status": "SLETTET", "opprettetTidspunkt": "2022-02-18T07:07:07.064711", "endretTidspunkt": "2023-07-18T09:20:21.575794"}';
        String encodedValueDeleted = EncodingUtil.base64Encode(Blob.valueOf(json1));
        msg[0].CRM_Value__c = encodedValueDeleted;

        Test.startTest();
        handler.processMessages(msg);
        Test.stopTest();

        List<IACase__c> iacase = [
            SELECT Id, Name, CaseOwner__c, CaseStatus__c, Account__c, IALastModifiedDate__c, IACreatedDate__c, KafkaId__c, KafkaHash__c
            FROM IACase__c WHERE IACase__c.Name = 'a240d1adtuasydt1'
        ];
      
        String startDate = string.valueOf(iacase[0].IACreatedDate__c);
        String lastModified = string.valueOf(iacase[0].IALastModifiedDate__c); 

        System.assertEquals(1, iacase.size(), 'check that iacase does not add a new case when changes are made');
        System.assertEquals('SLETTET', iacase[0].CaseStatus__c,  'Status updated from vurderes to slettet');
        System.assertEquals('a240d1adtuasydt1', iacase[0].Name, 'Correct Case Nr');
        System.assertEquals('C156986', iacase[0].CaseOwner__c, 'Correct Case Owner');
        System.assertEquals('2023-07-18 09:20:21',lastModified, 'Last Modified date updated');
    }

/*     @isTest
    static void testSeveralMessageChanged() {

        List<KafkaMessage__c> messages = new List<KafkaMessage__c>();

        List<KafkaMessage__c> msg = [
            SELECT CRM_Topic__c, CRM_Value__c, CRM_Key__c
            FROM KafkaMessage__c WHERE CRM_Key__c = 'a240d1adtuasydt1' LIMIT 1
        ];
        List<KafkaMessage__c> msg2 = [
            SELECT CRM_Topic__c, CRM_Value__c, CRM_Key__c
            FROM KafkaMessage__c WHERE CRM_Key__c = 'a240d1adtuasydt2' LIMIT 1
        ];
        messages.add(msg);
        messages.add(msg2);

        KafkaFiaCaseHandler handler = new KafkaFiaCaseHandler();
        handler.processMessages(messages);

        String json1 = '{"saksnummer": "a240d1adtuasydt1", "orgnr": "973113631", "eierAvSak": "C156986", "endretAvHendelseId": "sdfhoisdyfio49856", "status": "SLETTET", "opprettetTidspunkt": "2022-02-18T07:07:07.064711", "endretTidspunkt": "2023-07-18T09:20:22.575794"}';
        String encodedValueDeleted = EncodingUtil.base64Encode(Blob.valueOf(json1));
        msg[0].CRM_Value__c = encodedValueDeleted;

        String json2 = '{"saksnummer": "a240d1adtuasydt2", "orgnr": "973113631", "eierAvSak": "C156987", "endretAvHendelseId": "sdfhoisdyfio49856", "status": "Vurderes", "opprettetTidspunkt": "2022-02-18T07:07:07.064711", "endretTidspunkt": "2022-07-18T07:20:21.575794"}';
        String encodedValueDeleted = EncodingUtil.base64Encode(Blob.valueOf(json1));
        msg2[0].CRM_Value__c = encodedValueDeleted;


        Test.startTest();
        handler.processMessages(messages);
        Test.stopTest();

        List<IACase__c> iacase1 = [
            SELECT Id, Name, CaseOwner__c, CaseStatus__c, Account__c, IALastModifiedDate__c, IACreatedDate__c, KafkaId__c, KafkaHash__c
            FROM IACase__c WHERE IACase__c.Name = 'a240d1adtuasydt1'
        ];
      
        List<IACase__c> iacase2 = [
            SELECT Id, Name, CaseOwner__c, CaseStatus__c, Account__c, IALastModifiedDate__c, IACreatedDate__c, KafkaId__c, KafkaHash__c
            FROM IACase__c WHERE IACase__c.Name = 'a240d1adtuasydt2'
        ];

        //hent ut account så jeg kan teste om account nå har to iacases tilknyttet.

        System.assertEquals(1, iacase1.size(), 'check that iacase does not add a new case when changes are made');
        System.assertEquals('SLETTET', iacase1[0].CaseStatus__c,  'Status updated from vurderes to slettet');
        System.assertEquals('a240d1adtuasydt1', iacase1[0].Name, 'Correct Case Nr');
        System.assertEquals('C156986', iacase1[0].CaseOwner__c, 'Correct Case Owner');
     

      
        System.assertEquals('Vurderes', iacase2[0].CaseStatus__c,  'Status updated from slettet to vurderes');
        System.assertEquals('a240d1adtuasydt2', iacase2[0].Name, 'Correct Case Nr');
        System.assertEquals('C156986', iacase2[0].CaseOwner__c, 'Correct Case Owner');

    } */

    @isTest
    static void testInvalidMessageNoOrgNr() {

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

        List<IACase__c> iaCase = [
            SELECT Id, Name, CaseOwner__c, CaseStatus__c, Account__c, IALastModifiedDate__c, IACreatedDate__c, KafkaId__c, KafkaHash__c
            FROM IACase__c WHERE IACase__c.Name = 'a240d1adtuasydt5'
        ];
        System.assertEquals('Error', msg[0].CRM_Status__c, 'Expecting CRM_Status__c = Error as org nr is null');
        System.assertEquals(0, iaCase.size(), 'Expectiong iaCase-list to be empty(0) as the orgnr is null');
    }

    @IsTest
    static void testProcessSingleMessage_InvalidJson() {

        String invalid_json = '{"saksnummer": "a240d1adtuasydt4", "orgnr": "973113631", "eierAvSak": "C156986"';
        String invalidEncodedValue = EncodingUtil.base64Encode(Blob.valueOf(invalid_json));
      
        List<KafkaMessage__c> messages = new List<KafkaMessage__c>();

        KafkaMessage__c invalidMsg = new KafkaMessage__c();
        invalidMsg.CRM_Topic__c = 'pia.ia-sak-v1';
        invalidMsg.CRM_Key__c = 'a240d1adtuasydt4';
        invalidMsg.CRM_Value__c = invalidEncodedValue;
       
        messages.add(invalidMsg);
    
        insert messages;


        List<KafkaMessage__c> msg = [
            SELECT CRM_Value__c, CRM_Key__c
            FROM KafkaMessage__c WHERE CRM_Key__c = 'a240d1adtuasydt4'
        ];

        KafkaFiaCaseHandler handler = new KafkaFiaCaseHandler();
        handler.processMessages(msg);

        System.assertEquals(KafkaMessageService.STATUS_ERROR, msg[0].CRM_Status__c);
        System.assert(String.isNotBlank(msg[0].CRM_ErrorMessage__c));
    }
}
