@IsTest
public with sharing class KafkaFiaDeliveryHandlerTEST {    
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
        
        String json1 = 
        '{"id":139,"saksnummer":"01H5MKC3T0G5Z81K7YE50J138T","modul":{"id":10,"iaTjeneste":{"id":2,"navn":"Forebyggende arbeidsmiljøarbeid","deaktivert":false},"navn":"Livsfaseorientert personalpolitikk","deaktivert":false},"frist":"2023-08-31","status":"UNDER_ARBEID","opprettetAv":"Z994537","sistEndret":"2023-07-18T15:35:27.485670","sistEndretAv":"Z994537","sistEndretAvRolle":"SUPERBRUKER","fullfort":"2023-07-27T15:35:27.485670","enhetsnummer":"2970","enhetsnavn":"Ukjent"}';

        String encodedValue1 = EncodingUtil.base64Encode(Blob.valueOf(json1));

        List<KafkaMessage__c> messages = new List<KafkaMessage__c>();

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'pia.ia-sak-leveranse-v1';
        msg1.CRM_Key__c = '139';
        msg1.CRM_Value__c = encodedValue1;
        
        messages.add(msg1);
        insert messages;
    }
    
    @IsTest
    static void testProcessSingleMessage() {

        System.debug('test start');
        List<KafkaMessage__c> msg = [
            SELECT CRM_Topic__c, CRM_Value__c, CRM_Key__c
            FROM KafkaMessage__c WHERE CRM_Key__c = '139'
        ];
        System.debug( 'funker msg? tester for antall msg in kafkamessage list');
        System.debug(msg.size());
        Test.startTest();
        KafkaFiaDeliveryHandler handler = new KafkaFiaDeliveryHandler();
        handler.processMessages(msg);
        Test.stopTest();

        List<IADelivery__c> iaDelivery = [
            SELECT Id, Name, IACase__c, NAVUnit__c, DeliveryCreatedByUser__c, Module__c, IAService__c, Status__c, DeliveryCreatedBy__c, DeliveryLastModifiedDate__c, DeliveryLastModifiedBy__c, DeliveryLastModifiedByRole__c, CompletedDate__c, KafkaId__c, KafkaHash__c, JsonPayload__c, Deadline__c
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


        System.debug('Hva er str på iadelivery?');
        System.debug(iaDelivery.Size());


        String deadlineDate = string.valueOf(iaDelivery[0].Deadline__c);
        String deliveryLastModifiedDate = string.valueOf(iaDelivery[0].DeliveryLastModifiedDate__c);
        String completedDate = string.valueOf(iaDelivery[0].CompletedDate__c);

        System.assertEquals(msg[0].CRM_Key__c, iaDelivery[0].KafkaId__c, 'Correct KafkaId');
        System.assertEquals(msg[0].CRM_Value__c, iaDelivery[0].KafkaHash__c, 'Correct KafkaHash');
        System.assertEquals('139', iaDelivery[0].Name, 'Correct Delivery Id');
      //  System.assertEquals('Livsfaseorientert personalpolitikk', iaDelivery[0].Module__c, 'Correct Module');
      //  System.assertEquals('Forebyggende arbeidsmiljøarbeid', iaDelivery[0].IAService__c,  'Correct IA Service');
        System.assertEquals('2023-08-31', deadlineDate, 'Correct Deadline');
        System.assertEquals('UNDER_ARBEID', iaDelivery[0].Status__C, 'Correct Status');
        System.assertEquals('Z994537', iaDelivery[0].DeliveryCreatedBy__c, 'Correct created by user nav ident');
        System.assertEquals('2023-07-18 15:35:27', deliveryLastModifiedDate, 'Correct last modified date');
        System.assertEquals('Z994537', iaDelivery[0].DeliveryLastModifiedBy__c, 'Correct last modified by user');
        System.assertEquals('SUPERBRUKER', iaDelivery[0].DeliveryLastModifiedByRole__c, 'Correct last modified by role');
        System.assertEquals('2023-07-27 15:35:27', completedDate, 'Correct completed date');
        System.assertEquals(us[0].id, iaDelivery[0].DeliveryCreatedByUser__c, 'Correct User linked');
        System.assertEquals(nu[0].id, iaDelivery[0].NAVUnit__c, 'Correct NAV unit linked');
        System.assertEquals(ic[0].id, iaDelivery[0].IACase__c, 'Correct IA Case linked');

    } 

}