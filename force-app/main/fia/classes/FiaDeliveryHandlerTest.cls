@IsTest
public with sharing class FiaDeliveryHandlerTest {    
@TestSetup
    static void makeData(){
        
        IaCase__c ic1 = new IaCase__c(Name = '01H5MKC3T0G5Z81K7YE50J138T');
        insert ic1;

        NAVUnit__c nu1 = new NAVUnit__c(INT_UnitNumber__c = '2970');
        insert nu1;

        List<User> users = TestDataFactory.getUsers(2, 'Standard User', false, false);
        users[0].CRM_NAV_Ident__c = 'Z994537';
        users[1].CRM_NAV_Ident__c = 'C156987';
        insert users;
            
        String json =
            '{\n' +
            '   "id": 139,\n' +
            '   "saksnummer": "01H5MKC3T0G5Z81K7YE50J138T",\n' +
            '   "iaTjenesteId": 2,\n' +
            '   "iaTjenesteNavn": "Forebyggende arbeidsmiljøarbeid",\n' +
            '   "iaModulId": 16,\n' +
            '   "iaModulNavn": "Forebyggende arbeidsmiljøarbeid",\n' +
            '   "frist": "2023-08-31",\n' +
            '   "status": "UNDER_ARBEID",\n' +
            '   "opprettetAv": "Z994537",\n' +
            '   "sistEndret": "2023-07-18T15:35:27.485670",\n' +
            '   "sistEndretAv": "Z994537",\n' +
            '   "sistEndretAvRolle": "SUPERBRUKER",\n' +
            '   "fullført": null,\n' +
            '   "enhetsnummer": "2970",\n' +
            '   "enhetsnavn": "Ukjent",\n' +
            '   "opprettetTidspunkt":"2023-07-10T15:35:27.485670"\n' +
            '}';

        String json1 =
            '{\n' +
            '   "id": 140,\n' +
            '   "saksnummer": "01H5MKC3T0G5Z81K7YE50J138T",\n' +
            '   "iaTjenesteId": 2,\n' +
            '   "iaTjenesteNavn": "Forebyggende arbeidsmiljøarbeid",\n' +
            '   "iaModulId": 16,\n' +
            '   "iaModulNavn": "Forebyggende arbeidsmiljøarbeid",\n' +
            '   "frist": "2023-08-10",\n' +
            '   "status": "UNDER_ARBEID",\n' +
            '   "opprettetAv": "Z991098",\n' +
            '   "sistEndret": "2023-08-08T12:28:37.877598",\n' +
            '   "sistEndretAv": "Z991098",\n' +
            '   "sistEndretAvRolle": "SAKSBEHANDLER",\n' +
            '   "fullført": null,\n' +
            '   "enhetsnummer": "2970",\n' +
            '   "enhetsnavn": "Ukjent",\n' +
            '   "opprettetTidspunkt":"2023-07-10T15:35:27.485670"\n' +
            '}';

            String json2 =
            '{\n' +
            '   "id": 141,\n' +
            '   "saksnummer": "01H5MKC3T0G5Z81K7YE50J138T",\n' +
            '   "iaTjenesteId": 2,\n' +
            '   "iaTjenesteNavn": "Forebyggende arbeidsmiljøarbeid",\n' +
            '   "iaModulId": 16,\n' +
            '   "iaModulNavn": "Forebyggende arbeidsmiljøarbeid",\n' +
            '   "frist": "2023-08-10",\n' +
            '   "status": "UNDER_ARBEID",\n' +
            '   "opprettetAv": "Z991098",\n' +
            '   "sistEndret": "2023-08-08T12:28:37.877598",\n' +
            '   "sistEndretAv": "Z991098",\n' +
            '   "sistEndretAvRolle": "SAKSBEHANDLER",\n' +
            '   "fullført": null,\n' +
            '   "enhetsnummer": "2970",\n' +
            '   "enhetsnavn": "Ukjent",\n' +
            '   "opprettetTidspunkt":"2023-07-10T15:35:27.485670"\n' +
            '}';

            String jsonStatusSlettet =
            '{\n' +
            '   "id": 141,\n' +
            '   "saksnummer": "01H5MKC3T0G5Z81K7YE50J138T",\n' +
            '   "iaTjenesteId": 2,\n' +
            '   "iaTjenesteNavn": "Forebyggende arbeidsmiljøarbeid",\n' +
            '   "iaModulId": 16,\n' +
            '   "iaModulNavn": "Forebyggende arbeidsmiljøarbeid",\n' +
            '   "frist": "2023-08-10",\n' +
            '   "status": "SLETTET",\n' +
            '   "opprettetAv": "Z991098",\n' +
            '   "sistEndret": "2023-08-08T12:28:37.877598",\n' +
            '   "sistEndretAv": "Z991098",\n' +
            '   "sistEndretAvRolle": "SAKSBEHANDLER",\n' +
            '   "fullført": null,\n' +
            '   "enhetsnummer": "2970",\n' +
            '   "enhetsnavn": "Ukjent",\n' +
            '   "opprettetTidspunkt":"2023-07-10T15:35:27.485670"\n' +
            '}';

        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(json));
        String encodedValue1 = EncodingUtil.base64Encode(Blob.valueOf(json1));
        String encodedValue2 = EncodingUtil.base64Encode(Blob.valueOf(json2));
        String encodedValueSlettet = EncodingUtil.base64Encode(Blob.valueOf(jsonStatusSlettet));

        List<KafkaMessage__c> messages = new List<KafkaMessage__c>();

        KafkaMessage__c msg = new KafkaMessage__c();
        msg.CRM_Topic__c = 'pia.ia-sak-leveranse-v1';
        msg.CRM_Key__c = '139';
        msg.CRM_Value__c = encodedValue;
    
        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'pia.ia-sak-leveranse-v1';
        msg1.CRM_Key__c = '140';
        msg1.CRM_Value__c = encodedValue1;

        KafkaMessage__c msg2 = new KafkaMessage__c();
        msg2.CRM_Topic__c = 'pia.ia-sak-leveranse-v1';
        msg2.CRM_Key__c = '141';
        msg2.CRM_Value__c = encodedValue2;

        KafkaMessage__c msg3 = new KafkaMessage__c();
        msg3.CRM_Topic__c = 'pia.ia-sak-leveranse-v1';
        msg3.CRM_Key__c = '141';
        msg3.CRM_Value__c = encodedValueSlettet;
        
        messages.add(msg);
        messages.add(msg1);
        messages.add(msg2);
        messages.add(msg3);

        insert messages;
    }
    
    @IsTest
    static void testProcessSingleMessage() {

        List<KafkaMessage__c> msg = [
            SELECT 
            CRM_Topic__c, CRM_Value__c, CRM_Key__c
            FROM KafkaMessage__c WHERE CRM_Key__c = '139'
        ];

        Test.startTest();
        FiaDeliveryHandler handler = new FiaDeliveryHandler();
        handler.processMessages(msg);
        Test.stopTest();

        List<IADelivery__c> iaDelivery = [
            SELECT 
            Id, Name, IACase__c, NAVUnit__c, DeliveryCreatedByUser__c, Module__c, IAService__c,
            Status__c, DeliveryCreatedBy__c, DeliveryLastModifiedDate__c, DeliveryLastModifiedBy__c, 
            DeliveryLastModifiedByRole__c, CompletedDate__c, KafkaId__c, KafkaHash__c, JsonPayload__c, Deadline__c
            FROM IADelivery__c WHERE Name = '139'
        ];
        List<User> us = [
            SELECT Id
            FROM User WHERE CRM_NAV_Ident__c = 'Z994537'
        ];
        List<NAVUnit__c> nu = [
            SELECT Id
            FROM NAVUnit__c WHERE INT_UnitNumber__c = '2970'
        ];
        List<IACase__c> ic = [
            SELECT Id
            FROM IACase__c WHERE Name = '01H5MKC3T0G5Z81K7YE50J138T'
        ];
    
        String deadlineDate = string.valueOf(iaDelivery[0].Deadline__c);
        String deliveryLastModifiedDate = string.valueOf(iaDelivery[0].DeliveryLastModifiedDate__c);
        String completedDate = string.valueOf(iaDelivery[0].CompletedDate__c);

        System.assertEquals(msg[0].CRM_Key__c, iaDelivery[0].KafkaId__c, 'Correct KafkaId');
        System.assertEquals(msg[0].CRM_Value__c, iaDelivery[0].KafkaHash__c, 'Correct KafkaHash');
        System.assertEquals('139', iaDelivery[0].Name, 'Correct Delivery Id');
        System.assertEquals('Forebyggende arbeidsmiljøarbeid', iaDelivery[0].IAService__c,  'Correct IA Service');
        System.assertEquals('2023-08-31', deadlineDate, 'Correct Deadline');
        System.assertEquals('UNDER_ARBEID', iaDelivery[0].Status__c, 'Correct Status');
        System.assertEquals('Z994537', iaDelivery[0].DeliveryCreatedBy__c, 'Correct created by user nav ident');
        System.assertEquals('2023-07-18 15:35:27', deliveryLastModifiedDate, 'Correct last modified date');
        System.assertEquals('Z994537', iaDelivery[0].DeliveryLastModifiedBy__c, 'Correct last modified by user');
        System.assertEquals('SUPERBRUKER', iaDelivery[0].DeliveryLastModifiedByRole__c, 'Correct last modified by role');
        System.assertEquals(null, completedDate, 'completed date should be null as fullført is null');
        System.assertEquals(us[0].id, iaDelivery[0].DeliveryCreatedByUser__c, 'Correct User linked');
        System.assertEquals(nu[0].id, iaDelivery[0].NAVUnit__c, 'Correct NAV unit linked');
        System.assertEquals(ic[0].id, iaDelivery[0].IACase__c, 'Correct IA Case linked');
    } 

    @IsTest
    static void testSingleMessageChanged() {

        List<KafkaMessage__c> msg = [
            SELECT 
            CRM_Topic__c, CRM_Value__c, CRM_Key__c
            FROM KafkaMessage__c WHERE CRM_Key__c = '139'
        ];

        FiaDeliveryHandler handler = new FiaDeliveryHandler();
        handler.processMessages(msg);

        String changedJson =
        '{\n' +
        '   "id": 139,\n' +
        '   "saksnummer": "01H5MKC3T0G5Z81K7YE50J138T",\n' +
        '   "frist": "2023-08-31",\n' +
        '   "status": "LEVERT",\n' +
        '   "opprettetAv": "Z994537",\n' +
        '   "sistEndret": "2023-08-18T15:35:27.485670",\n' +
        '   "sistEndretAv": "Z994537",\n' +
        '   "sistEndretAvRolle": "SAKSBEHANDLER",\n' +
        '   "fullført": "2023-07-20T15:35:27.485670",\n' +
        '   "enhetsnummer": "2970",\n' +
        '   "enhetsnavn": "Ukjent",\n' +
        '   "opprettetTidspunkt":"2023-07-10T15:35:27.485670"\n' +
        '}'; 

        String encodedValueChanged = EncodingUtil.base64Encode(Blob.valueOf(changedJson));
        msg[0].CRM_Value__c = encodedValueChanged;

        Test.startTest();
        handler.processMessages(msg);
        Test.stopTest();  

        List<IADelivery__c> iaDelivery = [
            SELECT Id, Name, Status__c, DeliveryLastModifiedByRole__c, CompletedDate__c, KafkaId__c, KafkaHash__c, JsonPayload__c, Deadline__c
            FROM IADelivery__c WHERE Name = '139'
        ];
        
        String finishedDate = string.valueOf(iaDelivery[0].CompletedDate__c);
        System.assertEquals('SAKSBEHANDLER', iaDelivery[0].DeliveryLastModifiedByRole__c, 'Role changed from SUPERBRUKER to SAKSBEHANDLER');
        System.assertEquals('2023-07-20 15:35:27',finishedDate, 'finishedDate set from null til date');
        System.assertEquals(1, iaDelivery.size(), 'iaDelivery Size'); 
        System.assertEquals('139', iaDelivery[0].Name, 'Correct Name');
        System.assertEquals('LEVERT', iaDelivery[0].Status__c,  'Status updated from UNDER_ABEID to LEVERT');
        System.assertEquals(msg[0].CRM_Key__c, iaDelivery[0].KafkaId__c, 'Correct KafkaId');
        System.assertEquals(msg[0].CRM_Value__c, iaDelivery[0].KafkaHash__c, 'Correct KafkaHash');
    }

    @IsTest
    static void testProcessMultipleMessages() {

        List<KafkaMessage__c> msg = [
            SELECT CRM_Topic__c, CRM_Value__c, CRM_Key__c
            FROM KafkaMessage__c
        ];

        Test.startTest();
        FiaDeliveryHandler handler = new FiaDeliveryHandler();
        handler.processMessages(msg);
        Test.stopTest();

        List<IACase__c> ic = [
            SELECT Id
            FROM IACase__c WHERE Name = '01H5MKC3T0G5Z81K7YE50J138T'
        ];

        List<IADelivery__c> iaDelivery = [
            SELECT Id, Name, IACase__c, NAVUnit__c, DeliveryCreatedByUser__c, Module__c, IAService__c, Status__c, DeliveryCreatedBy__c, DeliveryLastModifiedDate__c, DeliveryLastModifiedBy__c, DeliveryLastModifiedByRole__c, CompletedDate__c, KafkaId__c, KafkaHash__c, JsonPayload__c, Deadline__c
            FROM IADelivery__c 
        ];

        System.assertEquals(2, iaDelivery.size(), 'expecting iaDelivery size 2');
        System.assertEquals(ic[0].id, iaDelivery[0].IACase__c, 'Correct IA Case linked for [0]');
        System.assertEquals(msg[0].CRM_Key__c, iaDelivery[0].KafkaId__c, 'Correct KafkaId for [0]');
        System.assertEquals(msg[0].CRM_Value__c, iaDelivery[0].KafkaHash__c, 'Correct KafkaHash for [0]');
        System.assertEquals('139', iaDelivery[0].Name, 'Correct Delivery Id for [0]');

        System.assertEquals(ic[0].id, iaDelivery[1].IACase__c, 'Correct IA Case linked for [1]');
        System.assertEquals(msg[1].CRM_Key__c, iaDelivery[1].KafkaId__c, 'Correct KafkaId for [1]');
        System.assertEquals(msg[1].CRM_Value__c, iaDelivery[1].KafkaHash__c, 'Correct KafkaHash for [1]');
        System.assertEquals('140', iaDelivery[1].Name, 'Correct Delivery Id for [1]');
    }
    @IsTest
    static void testProcessSingleMessage_InvalidJson() {
    
        String invalid_json = '{"id": "139","saksnummer": "01H5MKC3T0G5Z81K7YE50J138T", "opprettetAv": "Z994537", "enhetsnummer": "2970"';
        String invalidEncodedValue = EncodingUtil.base64Encode(Blob.valueOf(invalid_json));
        
        List<KafkaMessage__c> messages = new List<KafkaMessage__c>();
        KafkaMessage__c invalidMsg = new KafkaMessage__c();
        invalidMsg.CRM_Topic__c = 'pia.ia-sak-leveranse-v1';
        invalidMsg.CRM_Key__c = '139';
        invalidMsg.CRM_Value__c = invalidEncodedValue;

        messages.add(invalidMsg);
        insert messages;
 
        List<KafkaMessage__c> msg = [
            SELECT CRM_Value__c, CRM_Key__c
            FROM KafkaMessage__c WHERE CRM_Key__c = '139'
        ];

        Test.startTest();
        FiaCaseHandler handler = new FiaCaseHandler();
        handler.processMessages(msg);
        Test.stopTest();

        System.assertEquals(KafkaMessageService.STATUS_ERROR, msg[0].CRM_Status__c);
        System.assertEquals('Error', msg[0].CRM_Status__c, 'Expecting CRM_Status__c = Error as org nr is null');
        System.assert(String.isNotBlank(msg[0].CRM_ErrorMessage__c));
    }

    @IsTest
    static void testInvalidMessageNoCaseNr() {

        String invalid_jsonNoCaseNr =
        '{\n' +
        '   "id": 139,\n' +
        '   "saksnummer": null,\n' +
        '   "frist": "2023-08-31",\n' +
        '   "status": "UNDER_ARBEID",\n' +
        '   "opprettetAv": "Z994537",\n' +
        '   "sistEndret": "2023-07-18T15:35:27.485670",\n' +
        '   "sistEndretAv": "Z994537",\n' +
        '   "sistEndretAvRolle": "SUPERBRUKER",\n' +
        '   "fullført": null,\n' +
        '   "enhetsnummer": "2970",\n' +
        '   "enhetsnavn": "Ukjent",\n' +
        '   "opprettetTidspunkt":"2023-07-10T15:35:27.485670"\n' +
        '}'; 

        String invalidEncodedValueNoOrgNr = EncodingUtil.base64Encode(Blob.valueOf(invalid_jsonNoCaseNr));
       
        List<KafkaMessage__c> messages = new List<KafkaMessage__c>();
        KafkaMessage__c invalidNoOrgNr = new KafkaMessage__c();
        invalidNoOrgNr.CRM_Topic__c = 'pia.ia-sak-leveranse-v1';
        invalidNoOrgNr.CRM_Key__c = '141';
        invalidNoOrgNr.CRM_Value__c = invalidEncodedValueNoOrgNr;
        messages.add(invalidNoOrgNr);
        insert messages;

        List<KafkaMessage__c> msg = [
            SELECT CRM_Topic__c, CRM_Value__c, CRM_Key__c
            FROM KafkaMessage__c WHERE CRM_Key__c = '141'
        ];

        Test.startTest();
        FiaCaseHandler handler = new FiaCaseHandler();
        handler.processMessages(msg);
        Test.stopTest();

        List<IADelivery__c> iaDelivery = [
            SELECT Id, Name, Status__c, DeliveryLastModifiedByRole__c, CompletedDate__c, KafkaId__c, KafkaHash__c, JsonPayload__c, Deadline__c
            FROM IADelivery__c WHERE Name = '139'
        ];
    
        System.assertEquals('Error', msg[0].CRM_Status__c, 'Expecting CRM_Status__c = Error as case nr is null');
        System.assertEquals(0, iaDelivery.size(), 'Expectiong iaDelivery-list to be empty(0) as the Casenr is null');
    }

    @IsTest
    static void testDeleteSingleMessagePositive() {

        List<KafkaMessage__c> msg = [
            SELECT 
            CRM_Topic__c, CRM_Value__c, CRM_Key__c
            FROM KafkaMessage__c
        ];

        System.assert(msg.size() == 4);

        Test.startTest();
        FiaDeliveryHandler handler = new FiaDeliveryHandler();
        handler.processMessages(msg);
        Test.stopTest();

        List<IADelivery__c> iaDelivery = [
            SELECT 
            Id, Name, IACase__c, NAVUnit__c, DeliveryCreatedByUser__c, Module__c, IAService__c,
            Status__c, DeliveryCreatedBy__c, DeliveryLastModifiedDate__c, DeliveryLastModifiedBy__c, 
            DeliveryLastModifiedByRole__c, CompletedDate__c, KafkaId__c, KafkaHash__c, JsonPayload__c, Deadline__c
            FROM IADelivery__c WHERE Name = '139'
        ];

        List<IADelivery__c> iaDeliveryDeleted = [
            SELECT 
            Id, Name, IACase__c, NAVUnit__c, DeliveryCreatedByUser__c, Module__c, IAService__c,
            Status__c, DeliveryCreatedBy__c, DeliveryLastModifiedDate__c, DeliveryLastModifiedBy__c, 
            DeliveryLastModifiedByRole__c, CompletedDate__c, KafkaId__c, KafkaHash__c, JsonPayload__c, Deadline__c
            FROM IADelivery__c WHERE Name = '141'
        ];

        System.assert(!iaDelivery.isEmpty());
        System.assert(iaDeliveryDeleted.isEmpty());

    } 
}