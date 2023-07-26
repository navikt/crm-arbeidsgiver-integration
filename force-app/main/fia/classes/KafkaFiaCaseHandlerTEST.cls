@isTest
public with sharing class KafkaFiaCaseHandlerTEST {
@TestSetup
static void makeData(){
    Account acc = new Account(Name = 'Test Employer 1', INT_OrganizationNumber__c = '973113631');
        insert acc;
    Account acc2 = new Account(Name = 'Test Employer 2', INT_OrganizationNumber__c = '973113632');
        insert acc2;
    Account acc3 = new Account(Name = 'Test Employer 3', INT_OrganizationNumber__c = '973113633');
        insert acc3;
    Account acc4 = new Account(Name = 'Test Employer 4', INT_OrganizationNumber__c = '973113634');

        List<User> use = TestDataFactory.getUsers(4, 'Standard User', false, false);
        use[0].CRM_NAV_Ident__c = 'C156986';
        use[1].CRM_NAV_Ident__c = 'C156987';
        use[2].CRM_NAV_Ident__c = 'C156988';
        use[3].CRM_NAV_Ident__c = 'C156989';
        insert use; 

        String json1 = '{"saksnummer": "a240d1adtuasydt1", "orgnr": "973113631", "eierAvSak": "C156986", "endretAvHendelseId": "sdfhoisdyfio49856", "status": "Vurderes", "opprettetTidspunkt": "2022-02-18T07:07:07.064711", "endretTidspunkt": "2022-02-18T07:19:21.575794"}';
        String json2 = '{"saksnummer": "a240d1adtuasydt2", "orgnr": "973113632", "eierAvSak": "C156987", "endretAvHendelseId": "sdfhoisdyfio49856", "status": "Vurderes", "opprettetTidspunkt": "2022-02-18T07:07:07.064711", "endretTidspunkt": "2022-02-18T07:19:21.575794"}';
        String json3 = '{"saksnummer": "a240d1adtuasydt3", "orgnr": "973113633", "eierAvSak": "C156988", "endretAvHendelseId": "sdfhoisdyfio49856", "status": "Vurderes", "opprettetTidspunkt": "2022-02-18T07:07:07.064711", "endretTidspunkt": "2022-02-18T07:19:21.575794"}';
       // String json4 = '{"saksnummer": "a240d1adtuasydt3", "orgnr": "973113633", "eierAvSak": "C156988", "endretAvHendelseId": "sdfhoisdyfio49856", "status": "Kartlegges", "opprettetTidspunkt": "2022-02-18T07:07:07.064711", "endretTidspunkt": "2022-02-18T07:19:23.575794"}';
        String json5 = '{"saksnummer": "a240d1adtuasydt5", "orgnr": "973113634", "eierAvSak": "C156989", "endretAvHendelseId": "sdfhoisdyfio49856", "status": "SLETTET", "opprettetTidspunkt": "2022-02-18T07:07:07.064711", "endretTidspunkt": "2022-02-18T07:19:21.575794"}';
        String json6 = '{"saksnummer": "a240d1adtuasydt6", "orgnr": "973113635", "eierAvSak": "C156989", "endretAvHendelseId": "sdfhoisdyfio49856", "status": "IKKE_AKTIV", "opprettetTidspunkt": "2022-02-18T07:07:07.064711", "endretTidspunkt": "2022-02-18T07:19:23.575794"}';
          //  String invalid_json5 = '{"saksnummer": "a240d1adtuasydt5", "orgnr": "973113636", "eierAvSak": "C156986", "endretAvHendelseId": "sdfhoisdyfio49856", "status": "Vurderes", "opprettetTidspunkt": "2022-02-18T07:07:07.064711", "endretTidspunkt": "2022-02-18T07:19:21.575794"}';

     
       
        String encodedValue1 = EncodingUtil.base64Encode(Blob.valueOf(json1));
        String encodedValue2 = EncodingUtil.base64Encode(Blob.valueOf(json2));
        String encodedValue3 = EncodingUtil.base64Encode(Blob.valueOf(json3));
      //  String encodedValue4 = EncodingUtil.base64Encode(Blob.valueOf(json4));
        String encodedValue5 = EncodingUtil.base64Encode(Blob.valueOf(json5));
        String encodedValue6 = EncodingUtil.base64Encode(Blob.valueOf(json6));
    //    String invalidEncodedValue5 = EncodingUtil.base64Encode(Blob.valueOf(invalid_json5));
       
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
/* 
        KafkaMessage__c msg4 = new KafkaMessage__c();
        msg4.CRM_Topic__c = 'pia.ia-sak-v1';
        msg4.CRM_Key__c = 'a240d1adtuasydt3';
        msg4.CRM_Value__c = encodedValue4; */

        KafkaMessage__c msg5 = new KafkaMessage__c();
        msg5.CRM_Topic__c = 'pia.ia-sak-v1';
        msg5.CRM_Key__c = 'a240d1adtuasydt5';
        msg5.CRM_Value__c = encodedValue5;
       

        KafkaMessage__c msg6 = new KafkaMessage__c();
        msg6.CRM_Topic__c = 'pia.ia-sak-v1';
        msg6.CRM_Key__c = 'a240d1adtuasydt6';
        msg6.CRM_Value__c = encodedValue6;
       
/* 
        KafkaMessage__c msg5 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'pia.ia-sak-v1';
        msg1.CRM_Key__c = 'a240d1adtuasydt5';
        msg1.CRM_Value__c = invalidEncodedValue5;
 */
        messages.add(msg1);
        messages.add(msg2);
        messages.add(msg3);
      //  messages.add(msg4);
       // messages.add(msg5);

        insert messages;
}

@isTest
static void processSingleMessage() {
    List<KafkaMessage__c> msg = [
        SELECT CRM_Topic__c, CRM_Value__c, CRM_Key__c
        FROM KafkaMessage__c WHERE CRM_Key__c = 'a240d1adtuasydt1'
    ];
    List<Account> accounts = [
        SELECT Id, Name, INT_OrganizationNumber__c
        FROM Account
    ];
    List<IACase__c> iacase = [
        SELECT Id, Name, CaseOwner__c, CaseStatus__c, Account__c, IALastModifiedDate__c, IACreatedDate__c, KafkaId__c, KafkaHash__c
        FROM IACase__c WHERE IACase__c.Name = 'a240d1adtuasydt1'
    ];

    KafkaFiaCaseHandler handler = new KafkaFiaCaseHandler();
    handler.processMessages(msg);

  //  List<IACase__c> fiasaker = [SELECT Id, Name, CaseNr__c, CaseOwner__c, CaseStatus__c FROM IACase__c WHERE IACase__c.CaseNr__c = 'a240d1adtuasydt1'];

       
/*     System.assertEquals('a240d1adtuasydt1', fiaSaker[0].CaseNr__c, 'Correct Case Nr');
    System.assertEquals('C156986', fiaSaker[0].CaseOwner__c, 'Correct Case Owner');
    System.assertEquals('Vurderes', fiaSaker[0].CaseStatus__c, 'Correct Status');
    */

    String startDate = string.valueOf(iacase[0].IACreatedDate__c);
    String lastModified = string.valueOf(iacase[0].IALastModifiedDate__c);
    System.assertEquals(1, accounts.size(), 'Account inserted');
   // System.assertEquals(acc.id, accounts[0].id, 'Correct Account');
   // System.assertEquals(msg.CRM_Key__c, iacase[0].KafkaId__c, 'Correct KafkaId');
   // System.assertEquals(msg.CRM_Value__c, iacase[0].KafkaHash__c, 'Correct KafkaId');
    System.assertEquals('a240d1adtuasydt', iacase[0].Name, 'Correct Case Nr');
    System.assertEquals('C156986', iacase[0].CaseOwner__c, 'Correct Case Owner');
    System.assertEquals('VURDERES', iacase[0].CaseStatus__c, 'Correct Status');
    System.assertEquals('2022-02-18 07:07:07', startDate, 'Correct Start date');
    System.assertEquals('2022-02-18 07:19:21', lastModified, 'Correct Last Modified date');
}

/* @isTest
static void processSingleMessage() {      
    List<KafkaMessage__c> msg = [
        SELECT CRM_Value__c, CRM_Key__c
        FROM KafkaMessage__c WHERE CRM_Key__c = 'a240d1adtuasydt1'
    ];

    if (!msg.isEmpty()) {
        KafkaFiaCaseHandler handler = new KafkaFiaCaseHandler();
        handler.processMessages(msg);

  /*       // Query for the Account records after processing the message
        List<Account> accounts = [
            SELECT Id, Name, INT_OrganizationNumber__c,
                (SELECT CaseNr__c, CaseOwner__c, CaseStatus__c
                 FROM FiaSaker__r)
            FROM Account
            WHERE INT_OrganizationNumber__c = '973113631'
        ]; 

        List<IACase__c> fiasaker = [SELECT Id, Name, CaseNr__c, CaseOwner__c, CaseStatus__c FROM IACase__c WHERE IACase__c.CaseNr__c = 'a240d1adtuasydt1'];

       
            System.assertEquals('a240d1adtuasydt1', fiaSaker[0].CaseNr__c, 'Correct Case Nr');
            System.assertEquals('C156986', fiaSaker[0].CaseOwner__c, 'Correct Case Owner');
            System.assertEquals('Vurderes', fiaSaker[0].CaseStatus__c, 'Correct Status');
           
        
    } else {
        System.debug('No KafkaMessage__c record found with the specified CRM_Key__c.');
    }
}


        // Query for the Account records after processing the message
        List<Account> accounts = [
            SELECT Id, Name, INT_OrganizationNumber__c, (SELECT CaseNr__c, CaseOwner__c, CaseStatus__c, StartDate__c, LastModifiedDate__c FROM FiaSak__r)
            FROM Account
            WHERE INT_OrganizationNumber__c = '973113631'
        ]; 

        // Verify that the Account records are not empty after processing the message

        // Perform the assertions on the related IACase__c records for each Account
 */

    @isTest
    static void updateExistingFiaDetails() {

        //bør endres så vi faktisk oppdaterer noe så vi kan sjekke det. lurer på om det er en duplicate testing. 

        List<Account> accounts = [
            SELECT Id, Name, INT_OrganizationNumber__c, TAG_FiaCaseNr__c, TAG_FiaCaseOwner__c, TAG_FiaCaseStatus__c, TAG_FiaStartDate__c, TAG_FiaLastModifiedDate__c, TAG_FiaKafkaId__c, KafkaHash__c, JsonPayload__c 
            FROM Account
        ];

        System.assertEquals('Kartlegges', accounts[0].TAG_FiaCaseStatus__c, 'Correct Status updated');
        System.assertEquals('B2508285', accounts[0].TAG_FiaCaseOwner__c, 'Correct Case Owner updated');
    }

    @isTest
    static void noOrgNr() {
        String invalid_json = '{"saksnummer": "a240d1adtuasydt", "orgnr": null, "eierAvSak": "C156986", "endretAvHendelseId": "sdfhoisdyfio49856", "status": "Vurderes", "opprettetTidspunkt": "2022-02-18T07:07:07.064711", "endretTidspunkt": "2022-02-18T07:19:21.575794"}';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(invalid_json));

        List<KafkaMessage__c> messages = new List<KafkaMessage__c>();
        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'pia.ia-sak-v1';
        msg1.CRM_Key__c = 'a240d1adtuasydt';
        msg1.CRM_Value__c = encodedValue;
        messages.add(msg1);

        KafkaFiaCaseHandler handler = new KafkaFiaCaseHandler();
        handler.processMessages(messages);

        System.assertEquals('Error', messages[0].CRM_Status__c);
    }

    @IsTest
    static void processSingleMessage_InvalidJson() {


        String INVALID_JSON = '{"saksnummer": "a240d1adtuasydt1", "orgnr": "973113631", "eierAvSak": "C156986"';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(INVALID_JSON));

        List<KafkaMessage__c> messages = new List<KafkaMessage__c>();

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'pia.ia-sak-v1';
        msg1.CRM_Key__c = 'a240d1adtuasydt1';
        msg1.CRM_Value__c = encodedValue;
        messages.add(msg1);


        List<KafkaMessage__c> msg = [
            SELECT CRM_Value__c, CRM_Key__c
            FROM KafkaMessage__c WHERE CRM_Key__c = 'a240d1adtuasydt1'
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
