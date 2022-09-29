@isTest
public with sharing class KafkaFiaCaseHandlerTEST {
    @isTest
    static void processSingleMessage() {
        Account acc = new Account(Name = 'Test Employer 1', INT_OrganizationNumber__c = '973113631');
        insert acc;

        List<User> use = TestDataFactory.getUsers(1, 'Standard User', false, false);
        use[0].CRM_NAV_Ident__c = 'C156986';
        insert use;        

        String json = '{"saksnummer": "a240d1adtuasydt", "orgnr": "973113631", "eierAvSak": "C156986", "endretAvHendelseId": "sdfhoisdyfio49856", "status": "Vurderes", "opprettetTidspunkt": "2022-02-18T07:07:07.064711", "endretTidspunkt": "2022-02-18T07:19:21.575794"}';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(json));

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'pia.ia-sak-v1';
        msg1.CRM_Key__c = 'a240d1adtuasydt';
        msg1.CRM_Value__c = encodedValue;

        KafkaFiaCaseHandler handler = new KafkaFiaCaseHandler();
        handler.processMessages(new List<KafkaMessage__c>{ msg1 });

        List<Account> accounts = [
            SELECT Id, Name, INT_OrganizationNumber__c, TAG_FiaCaseNr__c, TAG_FiaCaseOwner__c, TAG_FiaCaseStatus__c, TAG_FiaStartDate__c, TAG_FiaLastModifiedDate__c, TAG_FiaKafkaId__c, KafkaHash__c, JsonPayload__c, TAG_FiaCaseOwnerName__c
            FROM Account
        ];

        String startDate = string.valueOf(accounts[0].TAG_FiaStartDate__c);
        String lastModified = string.valueOf(accounts[0].TAG_FiaLastModifiedDate__c);

        System.assertEquals(1, accounts.size(), 'Account inserted');
        System.assertEquals(acc.id, accounts[0].id, 'Correct Account');
        System.assertEquals(msg1.CRM_Key__c, accounts[0].TAG_FiaKafkaId__c, 'Correct KafkaId');
        System.assertEquals(msg1.CRM_Value__c, accounts[0].KafkaHash__c, 'Correct KafkaId');
        System.assertEquals('a240d1adtuasydt', accounts[0].TAG_FiaCaseNr__c, 'Correct Case Nr');
        System.assertEquals('973113631', accounts[0].INT_OrganizationNumber__c, 'Correct Org Nr');
        System.assertEquals('C156986', accounts[0].TAG_FiaCaseOwner__c, 'Correct Case Owner');
        System.assertEquals('Vurderes', accounts[0].TAG_FiaCaseStatus__c, 'Correct Status');
        System.assertEquals('2022-02-18 07:07:07', startDate, 'Correct Start date');
        System.assertEquals('2022-02-18 07:19:21', lastModified, 'Correct Last Modified date');
        System.assertEquals('User 1', accounts[0].TAG_FiaCaseOwnerName__c, 'Correct Fia case owner name');
    }

    @isTest
    static void updateExistingFiaDetails() {
        Account acc = new Account(Name = 'Test Employer 1', INT_OrganizationNumber__c = '973113631', TAG_FiaCaseStatus__c = 'Kartlegges', TAG_FiaCaseOwner__c = 'B2508285');
        insert acc;

        String json = '{"saksnummer": "a240d1adtuasydt", "orgnr": "973113631", "eierAvSak": "C156986", "endretAvHendelseId": "sdfhoisdyfio49856", "status": "Vurderes", "opprettetTidspunkt": "2022-02-18T07:07:07.064711", "endretTidspunkt": "2022-02-18T07:19:21.575794"}';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(json));

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'pia.ia-sak-v1';
        msg1.CRM_Key__c = 'a240d1adtuasydt';
        msg1.CRM_Value__c = encodedValue;

        KafkaFiaCaseHandler handler = new KafkaFiaCaseHandler();
        handler.processMessages(new List<KafkaMessage__c>{ msg1 });

        List<Account> accounts = [
            SELECT Id, Name, INT_OrganizationNumber__c, TAG_FiaCaseNr__c, TAG_FiaCaseOwner__c, TAG_FiaCaseStatus__c, TAG_FiaStartDate__c, TAG_FiaLastModifiedDate__c, TAG_FiaKafkaId__c, KafkaHash__c, JsonPayload__c 
            FROM Account
        ];

        System.assertEquals(1, accounts.size(), 'Account inserted');
        System.assertEquals(acc.id, accounts[0].id, 'Correct Account');
        System.assertEquals('Vurderes', accounts[0].TAG_FiaCaseStatus__c, 'Correct Status updated');
        System.assertEquals('C156986', accounts[0].TAG_FiaCaseOwner__c, 'Correct Case Owner updated');
    }

    @isTest
    static void multipleMessageSameKey() {
        Account acc = new Account(Name = 'Test Employer 1', INT_OrganizationNumber__c = '973113631');
        insert acc;

        String json = '{"saksnummer": "a240d1adtuasydt", "orgnr": "973113631", "eierAvSak": "C156986", "endretAvHendelseId": "sdfhoisdyfio49856", "status": "Vurderes", "opprettetTidspunkt": "2022-02-18T07:07:07.064711", "endretTidspunkt": "2022-02-18T07:19:21.575794"}';
        String json2 = '{"saksnummer": "a240d1adtuasydt", "orgnr": "973113631", "eierAvSak": "C156986", "endretAvHendelseId": "sdfhoisdyfio49856", "status": "Kartlegges", "opprettetTidspunkt": "2022-02-18T07:07:07.064711", "endretTidspunkt": "2022-02-18T07:19:23.575794"}';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(json));
        String encodedValue2 = EncodingUtil.base64Encode(Blob.valueOf(json2));

        List<KafkaMessage__c> messages = new List<KafkaMessage__c>();

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'pia.ia-sak-v1';
        msg1.CRM_Key__c = 'a240d1adtuasydt';
        msg1.CRM_Value__c = encodedValue;
        messages.add(msg1);

        KafkaMessage__c msg2 = new KafkaMessage__c();
        msg2.CRM_Topic__c = 'pia.ia-sak-v1';
        msg2.CRM_Key__c = 'a240d1adtuasydt';
        msg2.CRM_Value__c = encodedValue2;
        messages.add(msg2);

        KafkaFiaCaseHandler handler = new KafkaFiaCaseHandler();
        handler.processMessages(messages);

        List<Account> accounts = [
            SELECT Id, Name, INT_OrganizationNumber__c, TAG_FiaCaseNr__c, TAG_FiaCaseOwner__c, TAG_FiaCaseStatus__c, TAG_FiaStartDate__c, TAG_FiaLastModifiedDate__c, TAG_FiaKafkaId__c, KafkaHash__c, JsonPayload__c 
            FROM Account
        ];

        System.assertEquals(1, accounts.size(), 'Only one account');
        System.assertEquals('Kartlegges', accounts[0].TAG_FiaCaseStatus__c, 'Most recent change inserted');
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

        System.assertEquals('Processed', messages[0].CRM_Status__c);
    }

    @isTest
    static void noMatchingOrgNr() {
        Account acc = new Account(Name = 'Test Employer 1', INT_OrganizationNumber__c = '973113631');
        insert acc;

        String invalid_json = '{"saksnummer": "a240d1adtuasydt", "orgnr": "978567833", "eierAvSak": "C156986", "endretAvHendelseId": "sdfhoisdyfio49856", "status": "Vurderes", "opprettetTidspunkt": "2022-02-18T07:07:07.064711", "endretTidspunkt": "2022-02-18T07:19:21.575794"}';
        String invalid_json2 = '{"saksnummer": "a240d1adtuasydt", "orgnr": "973113631", "eierAvSak": "C156986", "endretAvHendelseId": "sdfhoisdyfio49856", "status": "Vurderes", "opprettetTidspunkt": "2022-02-18T07:07:07.064711", "endretTidspunkt": "2022-02-18T07:19:21.575794"}';
        
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(invalid_json));
        String encodedValue2 = EncodingUtil.base64Encode(Blob.valueOf(invalid_json2));

        List<KafkaMessage__c> messages = new List<KafkaMessage__c>();
        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'pia.ia-sak-v1';
        msg1.CRM_Key__c = 'a240d1adtuasydt';
        msg1.CRM_Value__c = encodedValue;
        messages.add(msg1);

        KafkaMessage__c msg2 = new KafkaMessage__c();
        msg2.CRM_Topic__c = 'pia.ia-sak-v1';
        msg2.CRM_Key__c = 'a240d1adtuasydt';
        msg2.CRM_Value__c = encodedValue2;
        messages.add(msg2);

        KafkaFiaCaseHandler handler = new KafkaFiaCaseHandler();
        handler.processMessages(messages);

        List<Account> account1 = [
            SELECT Id, Name, INT_OrganizationNumber__c, TAG_FiaCaseNr__c, TAG_FiaCaseOwner__c, TAG_FiaCaseStatus__c, TAG_FiaStartDate__c, TAG_FiaLastModifiedDate__c, TAG_FiaKafkaId__c, KafkaHash__c, JsonPayload__c 
            FROM Account WHERE INT_OrganizationNumber__c = '978567833'
        ];

        List<Account> account2 = [
            SELECT Id, Name, INT_OrganizationNumber__c, TAG_FiaCaseNr__c, TAG_FiaCaseOwner__c, TAG_FiaCaseStatus__c, TAG_FiaStartDate__c, TAG_FiaLastModifiedDate__c, TAG_FiaKafkaId__c, KafkaHash__c, JsonPayload__c 
            FROM Account WHERE INT_OrganizationNumber__c = '973113631'
        ];

        System.assertEquals(0, account1.size(), 'No account matching incoming org nr');
        System.assertEquals(1, account2.size(), 'Existing account');
        System.assertEquals('Processed', messages[0].CRM_Status__c);
    }

    @isTest
    static void runBulkJob() {
        Account acc1 = new Account(Name = 'Test Employer 1', INT_OrganizationNumber__c = '973113631');
        insert acc1;
        Account acc2 = new Account(Name = 'Test Employer 2', INT_OrganizationNumber__c = '973113632');
        insert acc2;
        Account acc3 = new Account(Name = 'Test Employer 3', INT_OrganizationNumber__c = '973113633');
        insert acc3;

        List<User> use = TestDataFactory.getUsers(3, 'Standard User', false, false);
        use[0].CRM_NAV_Ident__c = 'C156986';
        use[1].CRM_NAV_Ident__c = 'C156987';
        use[2].CRM_NAV_Ident__c = 'C156988';
        insert use;        


        String json1 = '{"saksnummer": "a240d1adtuasydt1", "orgnr": "973113631", "eierAvSak": "C156986", "endretAvHendelseId": "sdfhoisdyfio49856", "status": "Vurderes", "opprettetTidspunkt": "2022-02-18T07:07:07.064711", "endretTidspunkt": "2022-02-18T07:19:21.575794"}';
        String json2 = '{"saksnummer": "a240d1adtuasydt2", "orgnr": "973113632", "eierAvSak": "C156987", "endretAvHendelseId": "sdfhoisdyfio49856", "status": "Vurderes", "opprettetTidspunkt": "2022-02-18T07:07:07.064711", "endretTidspunkt": "2022-02-18T07:19:21.575794"}';
        String json3 = '{"saksnummer": "a240d1adtuasydt3", "orgnr": "973113633", "eierAvSak": "C156988", "endretAvHendelseId": "sdfhoisdyfio49856", "status": "Vurderes", "opprettetTidspunkt": "2022-02-18T07:07:07.064711", "endretTidspunkt": "2022-02-18T07:19:21.575794"}';
        String json4 = '{"saksnummer": "a240d1adtuasydt3", "orgnr": "973113633", "eierAvSak": "C156988", "endretAvHendelseId": "sdfhoisdyfio49856", "status": "Kartlegges", "opprettetTidspunkt": "2022-02-18T07:07:07.064711", "endretTidspunkt": "2022-02-18T07:19:23.575794"}';
        String encodedValue1 = EncodingUtil.base64Encode(Blob.valueOf(json1));
        String encodedValue2 = EncodingUtil.base64Encode(Blob.valueOf(json2));
        String encodedValue3 = EncodingUtil.base64Encode(Blob.valueOf(json3));
        String encodedValue4 = EncodingUtil.base64Encode(Blob.valueOf(json4));

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

        KafkaMessage__c msg4 = new KafkaMessage__c();
        msg4.CRM_Topic__c = 'pia.ia-sak-v1';
        msg4.CRM_Key__c = 'a240d1adtuasydt3';
        msg4.CRM_Value__c = encodedValue4;

        messages.add(msg1);
        messages.add(msg2);
        messages.add(msg3);
        messages.add(msg4);

        insert messages;

        Test.StartTest();
        AsyncRequestSchedulable.enqueueAsyncJobs();
        Test.StopTest();

        List<Account> account1 = [
            SELECT Id, Name, INT_OrganizationNumber__c, TAG_FiaCaseNr__c, TAG_FiaCaseOwner__c, TAG_FiaCaseStatus__c, TAG_FiaStartDate__c, TAG_FiaLastModifiedDate__c, TAG_FiaKafkaId__c, KafkaHash__c, JsonPayload__c, TAG_FiaCaseOwnerName__c 
            FROM Account WHERE INT_OrganizationNumber__c = '973113631'
        ];

        List<Account> account2 = [
            SELECT Id, Name, INT_OrganizationNumber__c, TAG_FiaCaseNr__c, TAG_FiaCaseOwner__c, TAG_FiaCaseStatus__c, TAG_FiaStartDate__c, TAG_FiaLastModifiedDate__c, TAG_FiaKafkaId__c, KafkaHash__c, JsonPayload__c, TAG_FiaCaseOwnerName__c 
            FROM Account WHERE INT_OrganizationNumber__c = '973113632'
        ];

        List<Account> account3 = [
            SELECT Id, Name, INT_OrganizationNumber__c, TAG_FiaCaseNr__c, TAG_FiaCaseOwner__c, TAG_FiaCaseStatus__c, TAG_FiaStartDate__c, TAG_FiaLastModifiedDate__c, TAG_FiaKafkaId__c, KafkaHash__c, JsonPayload__c, TAG_FiaCaseOwnerName__c 
            FROM Account WHERE INT_OrganizationNumber__c = '973113633'
        ];

        System.assertEquals('Vurderes', account1[0].TAG_FiaCaseStatus__c, 'Account 1 updated');
        System.assertEquals('Vurderes', account2[0].TAG_FiaCaseStatus__c, 'Account 2 updated');
        System.assertEquals('Kartlegges', account3[0].TAG_FiaCaseStatus__c, 'Account 3 updated with newest value');
        System.assertEquals('User 1', account1[0].TAG_FiaCaseOwnerName__c, 'Account 1 user updated');
        System.assertEquals('User 2', account2[0].TAG_FiaCaseOwnerName__c, 'Account 2 user updated');
        System.assertEquals('User 3', account3[0].TAG_FiaCaseOwnerName__c, 'Account 3 user updated');
    }

    @IsTest
    static void processSingleMessage_InvalidJson() {
        Account acc = new Account(Name = 'Test Employer 1', INT_OrganizationNumber__c = '973113631');
        insert acc;

        String INVALID_JSON = '{"saksnummer": "a240d1adtuasydt1", "orgnr": "973113631", "eierAvSak": "C156986"';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(INVALID_JSON));

        List<KafkaMessage__c> messages = new List<KafkaMessage__c>();

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'pia.ia-sak-v1';
        msg1.CRM_Key__c = 'a240d1adtuasydt1';
        msg1.CRM_Value__c = encodedValue;
        messages.add(msg1);

        KafkaFiaCaseHandler handler = new KafkaFiaCaseHandler();
        handler.processMessages(messages);

        System.assertEquals(KafkaMessageService.STATUS_ERROR, messages[0].CRM_Status__c);
        System.assert(String.isNotBlank(messages[0].CRM_ErrorMessage__c));
    }

    @IsTest
    static void processSingleMessage_nulls() {
        Account acc = new Account(Name = 'Test Employer 1', INT_OrganizationNumber__c = '973113631');
        insert acc;

        String JSON_WITH_NULLS = '{"saksnummer": "a240d1adtuasydt1", "orgnr": "973113631", "eierAvSak": null, "endretAvHendelseId": "sdfhoisdyfio49856", "status": null, "opprettetTidspunkt": "2022-02-18T07:07:07.064711", "endretTidspunkt": "2022-02-18T07:19:21.575794"}';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(JSON_WITH_NULLS));


        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'pia.ia-sak-v1';
        msg1.CRM_Key__c = 'a240d1adtuasydt1';
        msg1.CRM_Value__c = encodedValue;

        KafkaFiaCaseHandler handler = new KafkaFiaCaseHandler();
        handler.processMessages(new List<KafkaMessage__c>{ msg1 });
        
        List<Account> accounts = [
            SELECT Id, Name, INT_OrganizationNumber__c, TAG_FiaCaseNr__c, TAG_FiaCaseOwner__c, TAG_FiaCaseStatus__c, TAG_FiaStartDate__c, TAG_FiaLastModifiedDate__c, TAG_FiaKafkaId__c, KafkaHash__c, JsonPayload__c 
            FROM Account
        ];

        String lastModified = string.valueOf(accounts[0].TAG_FiaLastModifiedDate__c);

        System.assertEquals(1, accounts.size(), 'Account inserted');
        System.assertEquals(msg1.CRM_Key__c, accounts[0].TAG_FiaKafkaId__c, 'Correct KafkaId');
        System.assertEquals(msg1.CRM_Value__c, accounts[0].KafkaHash__c, 'Correct KafkaId');
        System.assertEquals(null, accounts[0].TAG_FiaCaseOwner__c, 'Case Owner is null');
        System.assertEquals(null, accounts[0].TAG_FiaCaseStatus__c, 'Status is null');
        System.assertEquals('2022-02-18 07:19:21', lastModified, 'Correct Last Modified date');
    }

    @isTest
    static void noMatchingUser() {
        Account acc = new Account(Name = 'Test Employer 1', INT_OrganizationNumber__c = '973113631');
        insert acc;

        List<User> use = TestDataFactory.getUsers(1, 'Standard User', false, false);
        use[0].CRM_NAV_Ident__c = 'C156987';
        insert use; 

        String json = '{"saksnummer": "a240d1adtuasydt", "orgnr": "973113631", "eierAvSak": "C156986", "endretAvHendelseId": "sdfhoisdyfio49856", "status": "Vurderes", "opprettetTidspunkt": "2022-02-18T07:07:07.064711", "endretTidspunkt": "2022-02-18T07:19:21.575794"}';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(json));

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'pia.ia-sak-v1';
        msg1.CRM_Key__c = 'a240d1adtuasydt';
        msg1.CRM_Value__c = encodedValue;

        KafkaFiaCaseHandler handler = new KafkaFiaCaseHandler();
        handler.processMessages(new List<KafkaMessage__c>{ msg1 });

        List<Account> accounts = [
            SELECT Id, Name, INT_OrganizationNumber__c, TAG_FiaCaseNr__c, TAG_FiaCaseOwner__c, TAG_FiaCaseStatus__c, TAG_FiaStartDate__c, TAG_FiaLastModifiedDate__c, TAG_FiaKafkaId__c, KafkaHash__c, JsonPayload__c, TAG_FiaCaseOwnerName__c
            FROM Account
        ];

        String startDate = string.valueOf(accounts[0].TAG_FiaStartDate__c);
        String lastModified = string.valueOf(accounts[0].TAG_FiaLastModifiedDate__c);

        System.assertEquals(1, accounts.size(), 'Account inserted');
        System.assertEquals('C156986', accounts[0].TAG_FiaCaseOwner__c, 'Correct Case Owner');
        System.assertEquals(Null, accounts[0].TAG_FiaCaseOwnerName__c, 'Fia case owner name is null');
    }

    @isTest
    static void multipleMessagesSameOrgDifferentCaseNr() {
        Account acc = new Account(Name = 'Test Employer 1', INT_OrganizationNumber__c = '973113631', TAG_FiaCaseStatus__c = 'Ny', TAG_FiaCaseOwner__c = 'B2508285');
        insert acc;

        String json = '{"saksnummer": "a240d1adtuasydt", "orgnr": "973113631", "eierAvSak": "C156986", "endretAvHendelseId": "sdfhoisdyfio49856", "status": "Vurderes", "opprettetTidspunkt": "2022-02-18T07:07:07.064711", "endretTidspunkt": "2022-02-18T07:19:21.575794"}';
        String json2 = '{"saksnummer": "a240d1adtuasyy", "orgnr": "973113631", "eierAvSak": "C156987", "endretAvHendelseId": "sdfhoisdyfio49856", "status": "Kartlegges", "opprettetTidspunkt": "2022-02-18T07:07:07.064711", "endretTidspunkt": "2022-02-18T07:19:23.575794"}';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(json));
        String encodedValue2 = EncodingUtil.base64Encode(Blob.valueOf(json2));

        List<KafkaMessage__c> messages = new List<KafkaMessage__c>();

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'pia.ia-sak-v1';
        msg1.CRM_Key__c = 'a240d1adtuasydt';
        msg1.CRM_Value__c = encodedValue;
        messages.add(msg1);

        KafkaMessage__c msg2 = new KafkaMessage__c();
        msg2.CRM_Topic__c = 'pia.ia-sak-v1';
        msg2.CRM_Key__c = 'a240d1adtuasyy';
        msg2.CRM_Value__c = encodedValue2;
        messages.add(msg2);

        KafkaFiaCaseHandler handler = new KafkaFiaCaseHandler();
        handler.processMessages(messages);

        List<Account> accounts = [
            SELECT Id, Name, INT_OrganizationNumber__c, TAG_FiaCaseNr__c, TAG_FiaCaseOwner__c, TAG_FiaCaseStatus__c, TAG_FiaStartDate__c, TAG_FiaLastModifiedDate__c, TAG_FiaKafkaId__c, KafkaHash__c, JsonPayload__c 
            FROM Account
        ];

        System.assertEquals(1, accounts.size(), 'Only one account');
        System.assertEquals('Kartlegges', accounts[0].TAG_FiaCaseStatus__c, 'Most recent change inserted');
        System.assertEquals('a240d1adtuasyy', accounts[0].TAG_FiaCaseNr__c, 'Most recent change inserted');
    }

    @isTest
    static void statusSlettesOrIkkeAktiv() {
        Account acc = new Account(Name = 'Test Employer 1', INT_OrganizationNumber__c = '973113631', TAG_FiaCaseStatus__c = 'Vurderes', TAG_FiaCaseOwner__c = 'B2508285');
        insert acc;
        Account acc2 = new Account(Name = 'Test Employer 2', INT_OrganizationNumber__c = '973113632', TAG_FiaCaseStatus__c = 'Vurderes', TAG_FiaCaseOwner__c = 'B2508286');
        insert acc2;

        String json = '{"saksnummer": "a240d1adtuasydt", "orgnr": "973113631", "eierAvSak": "C156986", "endretAvHendelseId": "sdfhoisdyfio49856", "status": "SLETTET", "opprettetTidspunkt": "2022-02-18T07:07:07.064711", "endretTidspunkt": "2022-02-18T07:19:21.575794"}';
        String json2 = '{"saksnummer": "a240d1adtuasyy", "orgnr": "973113632", "eierAvSak": "C156987", "endretAvHendelseId": "sdfhoisdyfio49856", "status": "IKKE_AKTIV", "opprettetTidspunkt": "2022-02-18T07:07:07.064711", "endretTidspunkt": "2022-02-18T07:19:23.575794"}';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(json));
        String encodedValue2 = EncodingUtil.base64Encode(Blob.valueOf(json2));

        List<KafkaMessage__c> messages = new List<KafkaMessage__c>();

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'pia.ia-sak-v1';
        msg1.CRM_Key__c = 'a240d1adtuasydt';
        msg1.CRM_Value__c = encodedValue;
        messages.add(msg1);

        KafkaMessage__c msg2 = new KafkaMessage__c();
        msg2.CRM_Topic__c = 'pia.ia-sak-v1';
        msg2.CRM_Key__c = 'a240d1adtuasyy';
        msg2.CRM_Value__c = encodedValue2;
        messages.add(msg2);

        KafkaFiaCaseHandler handler = new KafkaFiaCaseHandler();
        handler.processMessages(messages);

        List<Account> account1 = [
            SELECT Id, Name, INT_OrganizationNumber__c, TAG_FiaCaseNr__c, TAG_FiaCaseOwner__c, TAG_FiaCaseStatus__c, TAG_FiaStartDate__c, TAG_FiaLastModifiedDate__c, TAG_FiaKafkaId__c, KafkaHash__c, JsonPayload__c 
            FROM Account WHERE INT_OrganizationNumber__c = '973113631'
        ];

        List<Account> account2 = [
            SELECT Id, Name, INT_OrganizationNumber__c, TAG_FiaCaseNr__c, TAG_FiaCaseOwner__c, TAG_FiaCaseStatus__c, TAG_FiaStartDate__c, TAG_FiaLastModifiedDate__c, TAG_FiaKafkaId__c, KafkaHash__c, JsonPayload__c 
            FROM Account WHERE INT_OrganizationNumber__c = '973113632'
        ];

        System.assertEquals(null, account1[0].TAG_FiaCaseStatus__c, 'Most recent change inserted');
        System.assertEquals(null, account1[0].TAG_FiaCaseNr__c, 'Most recent change inserted');
        System.assertEquals(null, account1[0].TAG_FiaLastModifiedDate__c, 'Most recent change inserted');
        System.assertEquals(null, account1[0].JsonPayload__c, 'Most recent change inserted');
        System.assertEquals(null, account2[0].TAG_FiaCaseStatus__c, 'Most recent change inserted');
        System.assertEquals(null, account2[0].TAG_FiaCaseNr__c, 'Most recent change inserted');
        System.assertEquals(null, account2[0].TAG_FiaLastModifiedDate__c, 'Most recent change inserted');
        System.assertEquals(null, account2[0].JsonPayload__c, 'Most recent change inserted');
    }
}
