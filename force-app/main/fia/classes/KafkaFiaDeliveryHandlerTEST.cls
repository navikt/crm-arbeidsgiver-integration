@IsTest
public with sharing class KafkaFiaDeliveryHandlerTEST {    
@TestSetup
    static void makeData(){
      //mulig noen av dataen er feil, særlig enhetsnavn og enhetsnummer ,datoene og modul, og sistendretavrolle.
        String json1 = 
        '{"id":, "21", "saksnummer": "01H40FVWVQVWQA15T5AAP41A89", "modul": "{"id": "1", "iaTjeneste": "{"id": "11", "navn": "Redusere sykefravær", "deaktivert": "false"}", "navn": "Oppfølgingssamtalen", "deaktivert": "false"}""frist": "2023-08-18", "status": "Vi bistår", "opprettetAv": "Z994948", "sistEndret": "2022-02-18T07:07:07.064711" ,"sistEndretAv": "Z991098","sistEndretAvRolle": "Veileder","fullfort": "false","enhetsnummer": "315826853","enhetsnavn": "Privat og offentlig næringsvirksomhet",}';

        String encodedValue1 = EncodingUtil.base64Encode(Blob.valueOf(json1));

        List<KafkaMessage__c> messages = new List<KafkaMessage__c>();

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'pia.ia-sak-leveranse-v1';
        msg1.CRM_Key__c = 'a240d1adtuasydt1';
        msg1.CRM_Value__c = encodedValue1;
        
        messages.add(msg1);
        insert messages;
    }
    @IsTest
    static void testProcessSingleMessage() {

        System.debug('test start');
        List<KafkaMessage__c> msg = [
            SELECT CRM_Topic__c, CRM_Value__c, CRM_Key__c
            FROM KafkaMessage__c WHERE CRM_Key__c = 'a240d1adtuasydt1'
        ];
        System.debug( 'funker msg? tester for antall msg in kafkamessage list');
        System.debug(msg.size());
        Test.startTest();
        KafkaFiaDeliveryHandler handler = new KafkaFiaDeliveryHandler();
        handler.processMessages(msg);
        Test.stopTest();

        List<IADelivery__c> iaDelivery = [
            SELECT Id, Name, DeliveryCreatedBy__c, Status__c, KafkaId__c, KafkaHash__c, IACase__c, Deadline__c
            FROM IADelivery__c //WHERE IADelivery__c.Name = '21'
        ];

        System.debug('Hva er str på iadelivery?');
        System.debug(iaDelivery.Size());
        String deadlineDate = string.valueOf(iaDelivery[0].Deadline__c);

        System.assertEquals(msg[0].CRM_Key__c, iaDelivery[0].KafkaId__c, 'Correct KafkaId');
        System.assertEquals(msg[0].CRM_Value__c, iaDelivery[0].KafkaHash__c, 'Correct KafkaHash');
        System.assertEquals('a240d1adtuasydt1', iaDelivery[0].Name, 'Correct Case Nr');
        System.assertEquals('Z994948', iaDelivery[0].DeliveryCreatedBy__c, 'Correct Case Owner NAV Ident');
        System.assertEquals('Vi bistår', iaDelivery[0].Status__c, 'Correct Status');
        System.assertEquals('22023-08-18', deadlineDate, 'Correct deadline date');
        System.assertEquals('01H40FVWVQVWQA15T5AAP41A89', iaDelivery[0].IACase__c);

    } 

}