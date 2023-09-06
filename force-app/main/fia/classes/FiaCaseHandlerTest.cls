@IsTest
public with sharing class FiaCaseHandlerTest {
@TestSetup
static void makeData(){
    Account acc = new Account(Name = 'Test Employer 1', INT_OrganizationNumber__c = '973113631');
        insert acc;
    Account acc2 = new Account(Name = 'Test Employer 2', INT_OrganizationNumber__c = '973113632');
        insert acc2;

        List<User> users = TestDataFactory.getUsers(2, 'Standard User', false, false);
        users[0].CRM_NAV_Ident__c = 'C156986';
        users[1].CRM_NAV_Ident__c = 'C156987';
        insert users;

        String jsonStatusVurderes0 = '{"saksnummer": "a240d1adtuasydt0", "orgnr": "973113631", "eierAvSak": "C156986", "endretAvHendelseId": "sdfhoisdyfio49856", "status": "VURDERES", "opprettetTidspunkt": "2022-02-18T07:07:07.064711", "endretTidspunkt": "2022-02-18T07:19:21.575794"}';
        String jsonStatusVurderes1 = '{"saksnummer": "a240d1adtuasydt1", "orgnr": "973113631", "eierAvSak": "C156986", "endretAvHendelseId": "sdfhoisdyfio49856", "status": "VURDERES", "opprettetTidspunkt": "2022-02-18T07:07:07.064711", "endretTidspunkt": "2022-02-18T07:19:21.575794"}';
        String jsonStatusViBistar1 = '{"saksnummer": "a240d1adtuasydt1", "orgnr": "973113631", "eierAvSak": "C156987", "endretAvHendelseId": "sdfhoisdyfio49856", "status": "VI_BISTÅR", "opprettetTidspunkt": "2022-02-18T07:07:07.064711", "endretTidspunkt": "2022-02-18T07:22:21.575794"}';
        String jsonStatusViBistar2 = '{"saksnummer": "a240d1adtuasydt2", "orgnr": "973113632", "eierAvSak": "C156987", "endretAvHendelseId": "sdfhoisdyfio49856", "status": "VI_BISTÅR", "opprettetTidspunkt": "2022-02-18T07:07:07.064711", "endretTidspunkt": "2022-02-18T07:19:21.575794"}';
        String jsonStatusSlettet2 = '{"saksnummer": "a240d1adtuasydt2", "orgnr": "973113632", "eierAvSak": "C156987", "endretAvHendelseId": "sdfhoisdyfio49856", "status": "SLETTET", "opprettetTidspunkt": "2022-02-18T07:07:07.064711", "endretTidspunkt": "2022-02-19T07:19:21.575794"}';
        String jsonStatusViBistar3 = '{"saksnummer": "a240d1adtuasydt3", "orgnr": "973113632", "eierAvSak": "C156987", "endretAvHendelseId": "sdfhoisdyfio49856", "status": "VI_BISTÅR", "opprettetTidspunkt": "2022-02-18T07:07:07.064711", "endretTidspunkt": "2022-02-20T07:19:21.575794"}';
        String jsonStatusSlettet3 = '{"saksnummer": "a240d1adtuasydt3", "orgnr": "973113632", "eierAvSak": "C156987", "endretAvHendelseId": "sdfhoisdyfio49856", "status": "SLETTET", "opprettetTidspunkt": "2022-02-18T07:07:07.064711", "endretTidspunkt": "2022-02-21T07:19:21.575794"}';

        String encodedJsonStatusVurderes0 = EncodingUtil.base64Encode(Blob.valueOf(jsonStatusVurderes0));
        String encodedJsonStatusVurderes1 = EncodingUtil.base64Encode(Blob.valueOf(jsonStatusVurderes1));
        String encodedJsonStatusViBistar1 = EncodingUtil.base64Encode(Blob.valueOf(jsonStatusViBistar1));
        String encodedJsonStatusViBistar2 = EncodingUtil.base64Encode(Blob.valueOf(jsonStatusViBistar2));
        String encodedJsonStatusSlettet2 = EncodingUtil.base64Encode(Blob.valueOf(jsonStatusSlettet2));
        String encodedJsonStatusViBistar3 = EncodingUtil.base64Encode(Blob.valueOf(jsonStatusViBistar3));
        String encodedJsonStatusSlettet3 = EncodingUtil.base64Encode(Blob.valueOf(jsonStatusSlettet3));
      
        List<KafkaMessage__c> messages = new List<KafkaMessage__c>();

        KafkaMessage__c messageJsonStatusVurderes0 = new KafkaMessage__c();
        messageJsonStatusVurderes0.CRM_Topic__c = 'pia.ia-sak-v1';
        messageJsonStatusVurderes0.CRM_Key__c = 'a240d1adtuasydt0';
        messageJsonStatusVurderes0.CRM_Value__c = encodedJsonStatusVurderes0;

        KafkaMessage__c messageJsonStatusVurderes1 = new KafkaMessage__c();
        messageJsonStatusVurderes1.CRM_Topic__c = 'pia.ia-sak-v1';
        messageJsonStatusVurderes1.CRM_Key__c = 'a240d1adtuasydt1';
        messageJsonStatusVurderes1.CRM_Value__c = encodedJsonStatusVurderes1;

        KafkaMessage__c messageJsonStatusViBistar1 = new KafkaMessage__c();
        messageJsonStatusViBistar1.CRM_Topic__c = 'pia.ia-sak-v1';
        messageJsonStatusViBistar1.CRM_Key__c = 'a240d1adtuasydt1';
        messageJsonStatusViBistar1.CRM_Value__c = encodedJsonStatusViBistar1;

        KafkaMessage__c messageJsonStatusViBistar2 = new KafkaMessage__c();
        messageJsonStatusViBistar2.CRM_Topic__c = 'pia.ia-sak-v1';
        messageJsonStatusViBistar2.CRM_Key__c = 'a240d1adtuasydt2';
        messageJsonStatusViBistar2.CRM_Value__c = encodedJsonStatusViBistar2;

        KafkaMessage__c messageJsonStatusSlettet2 = new KafkaMessage__c();
        messageJsonStatusSlettet2.CRM_Topic__c = 'pia.ia-sak-v1';
        messageJsonStatusSlettet2.CRM_Key__c = 'a240d1adtuasydt2';
        messageJsonStatusSlettet2.CRM_Value__c = encodedJsonStatusSlettet2;

        KafkaMessage__c messageJsonStatusViBistar3 = new KafkaMessage__c();
        messageJsonStatusViBistar3.CRM_Topic__c = 'pia.ia-sak-v1';
        messageJsonStatusViBistar3.CRM_Key__c = 'a240d1adtuasydt3';
        messageJsonStatusViBistar3.CRM_Value__c = encodedJsonStatusViBistar3;

        KafkaMessage__c messageJsonStatusSlettet3 = new KafkaMessage__c();
        messageJsonStatusSlettet3.CRM_Topic__c = 'pia.ia-sak-v1';
        messageJsonStatusSlettet3.CRM_Key__c = 'a240d1adtuasydt3';
        messageJsonStatusSlettet3.CRM_Value__c = encodedJsonStatusSlettet3;
   
        messages.add(messageJsonStatusVurderes0);
        messages.add(messageJsonStatusVurderes1);
        messages.add(messageJsonStatusViBistar1);
        messages.add(messageJsonStatusViBistar2);
        messages.add(messageJsonStatusSlettet2);
        messages.add(messageJsonStatusViBistar3);
        messages.add(messageJsonStatusSlettet3);
    
        insert messages;
}

    @IsTest
    static void testProcessSingleMessagePositive() {
        List<KafkaMessage__c> message = [
            SELECT CRM_Topic__c, CRM_Value__c, CRM_Key__c
            FROM KafkaMessage__c WHERE CRM_Key__c = 'a240d1adtuasydt0'
        ];

        System.assert(message.size() == 1);
        
        Test.startTest();
        FiaCaseHandler handler = new FiaCaseHandler();
        handler.processMessages(message);
        Test.stopTest();

        List<IACase__c> iacase = [
            SELECT Id, Name, CaseOwnerNavIdent__c, CaseOwner__c, CaseStatus__c, Account__c, IALastModifiedDate__c, IACreatedDate__c, KafkaId__c, KafkaHash__c
            FROM IACase__c WHERE IACase__c.Name = 'a240d1adtuasydt0'
        ];

        List<User> user = [
            SELECT Id
            FROM User WHERE CRM_NAV_Ident__c = 'C156986'
        ];

        String startDate = string.valueOf(iacase[0].IACreatedDate__c);
        String lastModified = string.valueOf(iacase[0].IALastModifiedDate__c); 
    
        System.assertEquals(message[0].CRM_Key__c, iacase[0].KafkaId__c, 'Correct KafkaId');
        System.assertEquals(message[0].CRM_Value__c, iacase[0].KafkaHash__c, 'Correct KafkaHash');
        System.assertEquals('a240d1adtuasydt0', iacase[0].Name, 'Correct Case Nr');
        System.assertEquals('C156986', iacase[0].CaseOwnerNavIdent__c, 'Correct Case Owner NAV Ident');
        System.assertEquals('VURDERES', iacase[0].CaseStatus__c, 'Correct Status');
        System.assertEquals('2022-02-18 07:07:07', startDate, 'Correct Start date');
        System.assertEquals('2022-02-18 07:19:21', lastModified, 'Correct Last Modified date');
        System.assertEquals(user[0].id, iacase[0].CaseOwner__c);
    }

    @IsTest
    static void testSingleMessageChangedPositive() {

        List<KafkaMessage__c> message = [
            SELECT CRM_Topic__c, CRM_Value__c, CRM_Key__c
            FROM KafkaMessage__c WHERE CRM_Key__c = 'a240d1adtuasydt1' LIMIT 1
        ];
        FiaCaseHandler handler = new FiaCaseHandler();
        handler.processMessages(message);

        String jsonChanged = '{"saksnummer": "a240d1adtuasydt1", "orgnr": "973113631", "eierAvSak": "C156986", "endretAvHendelseId": "sdfhoisdyfio49856", "status": "VI_BISTÅR", "opprettetTidspunkt": "2022-02-18T07:07:07.064711", "endretTidspunkt": "2023-07-18T09:20:21.575794"}';
        String encodedValueDeleted = EncodingUtil.base64Encode(Blob.valueOf(jsonChanged));
        message[0].CRM_Value__c = encodedValueDeleted;

        Test.startTest();
        handler.processMessages(message);
        Test.stopTest();

        List<IACase__c> iacase = [
            SELECT Id, Name, CaseOwnerNavIdent__c, CaseStatus__c, Account__c, IALastModifiedDate__c, IACreatedDate__c, KafkaId__c, KafkaHash__c
            FROM IACase__c WHERE IACase__c.Name = 'a240d1adtuasydt1'
        ];
      
        String startDate = string.valueOf(iacase[0].IACreatedDate__c);
        String lastModified = string.valueOf(iacase[0].IALastModifiedDate__c); 

        System.assertEquals(1, iacase.size(), 'check that iacase does not add a new case when changes are made');
        System.assertEquals('VI_BISTÅR', iacase[0].CaseStatus__c,  'Status should be updated from vurderes to VI_BISTÅR');
        System.assertEquals('a240d1adtuasydt1', iacase[0].Name, 'Correct Case Nr');
        System.assertEquals('C156986', iacase[0].CaseOwnerNavIdent__c, 'Correct Case Owner');
        System.assertEquals('2023-07-18 09:20:21',lastModified, 'Last Modified date updated');
    }

    @IsTest
    static void testSeveralMessageChangedOnSameAccount() {
        List<KafkaMessage__c> messages = new List<KafkaMessage__c>();

        KafkaMessage__c message = [
            SELECT CRM_Topic__c, CRM_Value__c, CRM_Key__c
            FROM KafkaMessage__c WHERE CRM_Key__c = 'a240d1adtuasydt1' LIMIT 1
        ];
        KafkaMessage__c message2 = [
            SELECT CRM_Topic__c, CRM_Value__c, CRM_Key__c
            FROM KafkaMessage__c WHERE CRM_Key__c = 'a240d1adtuasydt2' LIMIT 1
        ];
        messages.add(message);
        messages.add(message2);

        FiaCaseHandler handler = new FiaCaseHandler();
        handler.processMessages(messages);

        String json1 = '{"saksnummer": "a240d1adtuasydt1", "orgnr": "973113631", "eierAvSak": "C156986", "endretAvHendelseId": "sdfhoisdyfio49856", "status": "VI_BISTÅR", "opprettetTidspunkt": "2022-02-18T07:07:07.064711", "endretTidspunkt": "2023-07-18T09:20:22.575794"}';
        String encodedValueDeleted = EncodingUtil.base64Encode(Blob.valueOf(json1));
        message.CRM_Value__c = encodedValueDeleted;

        String json2 = '{"saksnummer": "a240d1adtuasydt2", "orgnr": "973113631", "eierAvSak": "C156987", "endretAvHendelseId": "sdfhoisdyfio49856", "status": "Vurderes", "opprettetTidspunkt": "2022-02-18T07:07:07.064711", "endretTidspunkt": "2022-07-18T07:20:21.575794"}';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(json2));
        message2.CRM_Value__c = encodedValue;

        Test.startTest();
        handler.processMessages(messages);
        Test.stopTest();

        List<IACase__c> iacase1 = [
            SELECT Id, Name, CaseOwnerNavIdent__c, CaseStatus__c, Account__c, IALastModifiedDate__c, IACreatedDate__c, KafkaId__c, KafkaHash__c
            FROM IACase__c WHERE IACase__c.Name = 'a240d1adtuasydt1'
        ];
        List<IACase__c> iacase2 = [
            SELECT Id, Name, CaseOwnerNavIdent__c, CaseStatus__c, Account__c, IALastModifiedDate__c, IACreatedDate__c, KafkaId__c, KafkaHash__c
            FROM IACase__c WHERE IACase__c.Name = 'a240d1adtuasydt2'
        ];

        System.assertEquals('VI_BISTÅR', iacase1[0].CaseStatus__c,  'Status should be updated from vurderes to VI_BISTÅR');
        System.assertEquals('a240d1adtuasydt1', iacase1[0].Name, 'Correct Case Nr');
        System.assertEquals('C156986', iacase1[0].CaseOwnerNavIdent__c, 'Correct Case Owner');
        System.assertEquals(iacase1[0].Account__c, iacase2[0].Account__c, 'expecting connected Account id to be the same for both iacases');
        System.assertEquals('VURDERES', iacase2[0].CaseStatus__c,  'Status updated from slettet to vurderes');
        System.assertEquals('a240d1adtuasydt2', iacase2[0].Name, 'Correct Case Nr');
        System.assertEquals('C156987', iacase2[0].CaseOwnerNavIdent__c, 'Correct Case Owner');
    } 

    @IsTest
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

        List<KafkaMessage__c> message = [
            SELECT CRM_Topic__c, CRM_Value__c, CRM_Key__c
            FROM KafkaMessage__c WHERE CRM_Key__c = 'a240d1adtuasydt5'
        ];

        Test.startTest();
        FiaCaseHandler handler = new FiaCaseHandler();
        handler.processMessages(message);
        Test.stopTest();

        List<IACase__c> iaCase = [
            SELECT Id, Name, CaseOwnerNavIdent__c, CaseStatus__c, Account__c, IALastModifiedDate__c, IACreatedDate__c, KafkaId__c, KafkaHash__c
            FROM IACase__c WHERE IACase__c.Name = 'a240d1adtuasydt5'
        ];
        System.assertEquals('Error', message[0].CRM_Status__c, 'Expecting CRM_Status__c = Error as org nr is null');
        System.assertEquals(0, iaCase.size(), 'Expectiong iaCase-list to be empty(0) as the orgnr is null');
    }

    @IsTest
    static void testProcessSingleMessage_InvalidJson() {
        String invalid_json = '{"saksnummer": "a240d1adtuasydt4", "orgnr": "973113631", "eierAvSak": "C156986"';
        String invalidEncodedValue = EncodingUtil.base64Encode(Blob.valueOf(invalid_json));
      
        List<KafkaMessage__c> messages = new List<KafkaMessage__c>();

        KafkaMessage__c invalidmessage = new KafkaMessage__c();
        invalidmessage.CRM_Topic__c = 'pia.ia-sak-v1';
        invalidmessage.CRM_Key__c = 'a240d1adtuasydt4';
        invalidmessage.CRM_Value__c = invalidEncodedValue;
       
        messages.add(invalidmessage);
        insert messages;

        List<KafkaMessage__c> message = [
            SELECT CRM_Value__c, CRM_Key__c
            FROM KafkaMessage__c WHERE CRM_Key__c = 'a240d1adtuasydt4'
        ];

        Test.startTest();
        FiaCaseHandler handler = new FiaCaseHandler();
        handler.processMessages(message);
        Test.stopTest();

        System.assertEquals(KafkaMessageService.STATUS_ERROR, message[0].CRM_Status__c);
        System.assert(String.isNotBlank(message[0].CRM_ErrorMessage__c));
    }

    @IsTest
    static void testMultipleMessagesDeletePositive() {

        List<KafkaMessage__c> messages = [
            SELECT CRM_Topic__c, CRM_Value__c, CRM_Key__c
            FROM KafkaMessage__c
        ];

        System.assert(messages.size() == 7);

        Test.startTest();
        FiaCaseHandler handler = new FiaCaseHandler();
        handler.processMessages(messages);
        Test.stopTest();

        List<IACase__c> iacase1 = [
            SELECT Id, Name, CaseOwnerNavIdent__c, CaseStatus__c, Account__c, IALastModifiedDate__c, IACreatedDate__c, KafkaId__c, KafkaHash__c
            FROM IACase__c WHERE IACase__c.Name = 'a240d1adtuasydt1'
        ];
        
        List<IACase__c> iacase2 = [
            SELECT Id, Name, CaseOwnerNavIdent__c, CaseStatus__c, Account__c, IALastModifiedDate__c, IACreatedDate__c, KafkaId__c, KafkaHash__c
            FROM IACase__c WHERE IACase__c.Name = 'a240d1adtuasydt2'
        ];

        List<IACase__c> iacase3 = [
            SELECT Id, Name, CaseOwnerNavIdent__c, CaseStatus__c, Account__c, IALastModifiedDate__c, IACreatedDate__c, KafkaId__c, KafkaHash__c
            FROM IACase__c WHERE IACase__c.Name = 'a240d1adtuasydt3'
        ];

        System.assert(!iaCase1.isEmpty());
        System.assert(iaCase2.isEmpty());
        System.assert(iaCase3.isEmpty());
    }
}
