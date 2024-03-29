@isTest
public with sharing class KafkaModiaDialogMoteHandler_TEST {
    @isTest
    static void processSingleMessage() {
        Account acc = new Account(Name = 'Test Employer 1', INT_OrganizationNumber__c = '973113631');
        insert acc;

        String json = '{"dialogmoteUuid": "a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e", "dialogmoteTidspunkt": 1970-01-19T18:55:30.540Z, "statusEndringType": "AVLYST", "statusEndringTidspunkt": 1970-01-19T18:46:52.748Z, "personIdent": "05087321470", "virksomhetsnummer": "973113631", "enhetNr": "1805", "navIdent": "Z994911", "tilfelleStartdato": 1970-01-01T00:00:18.779Z, "arbeidstaker": true, "arbeidsgiver": true, "sykmelder": false}';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(json));

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'teamsykefravr.isdialogmote-dialogmote-statusendring';
        msg1.CRM_Key__c = 'a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e';
        msg1.CRM_Value__c = encodedValue;

        KafkaModiaDialogMoteHandler handler = new KafkaModiaDialogMoteHandler();
        handler.processMessages(new List<KafkaMessage__c>{ msg1 });

        List<ArenaActivity__c> activities = [
            SELECT Id, Account__c, KafkaId__c, KafkaHash__c, JsonPayload__c
            FROM ArenaActivity__c
        ];

        System.assertEquals(1, activities.size(), 'Activity Inserted');
        System.assertEquals(acc.id, activities[0].Account__c, 'Correct Account');
        System.assertEquals(msg1.CRM_Key__c, activities[0].KafkaId__c, 'Correct KafkaId');
        System.assertEquals(msg1.CRM_Value__c, activities[0].KafkaHash__c, 'Correct KafkaId');
    }

    @isTest
    static void updateExistingActivity() {
        String json = '{"dialogmoteUuid": "a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e", "dialogmoteTidspunkt": 1970-01-19T18:55:30.540Z, "statusEndringType": "AVLYST", "statusEndringTidspunkt": 1970-01-19T18:46:52.748Z, "personIdent": "05087321470", "virksomhetsnummer": "973113631", "enhetNr": "1805", "navIdent": "Z994911", "tilfelleStartdato": 1970-01-01T00:00:18.779Z, "arbeidstaker": true, "arbeidsgiver": true, "sykmelder": false}';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(json));

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'teamsykefravr.isdialogmote-dialogmote-statusendring';
        msg1.CRM_Key__c = 'a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e';
        msg1.CRM_Value__c = encodedValue;

        ArenaActivity__c activity = new ArenaActivity__c(
            KafkaId__c = msg1.CRM_Key__c,
            AktivitetStatuskode__c = 'INNKALT'
        );
        insert activity;

        KafkaModiaDialogMoteHandler handler = new KafkaModiaDialogMoteHandler();
        handler.processMessages(new List<KafkaMessage__c>{ msg1 });

        List<ArenaActivity__c> activities = [
            SELECT Id, Account__c, KafkaId__c, KafkaHash__c, JsonPayload__c, AktivitetStatuskode__c
            FROM ArenaActivity__c
        ];

        System.assertEquals(1, activities.size(), 'Still only one activity');
        System.assertEquals('AVLYST', activities[0].AktivitetStatuskode__c, 'Successful status updated');
        System.assertEquals(msg1.CRM_Key__c, activities[0].KafkaId__c, 'Correct KafkaId');
        System.assertEquals(msg1.CRM_Value__c, activities[0].KafkaHash__c, 'Correct KafkaId');
    }

    @isTest
    static void newTimePlaceStatusUpdate() {
        String json = '{"dialogmoteUuid": "a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e", "dialogmoteTidspunkt": 1970-01-19T18:55:30.540Z, "statusEndringType": "NYTT_TID_STED", "statusEndringTidspunkt": 1970-01-19T18:46:52.748Z, "personIdent": "05087321470", "virksomhetsnummer": "973113631", "enhetNr": "1805", "navIdent": "Z994911", "tilfelleStartdato": 1970-01-01T00:00:18.779Z, "arbeidstaker": true, "arbeidsgiver": true, "sykmelder": false}';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(json));

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'teamsykefravr.isdialogmote-dialogmote-statusendring';
        msg1.CRM_Key__c = 'a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e';
        msg1.CRM_Value__c = encodedValue;

        ArenaActivity__c activity = new ArenaActivity__c(
            KafkaId__c = msg1.CRM_Key__c,
            AktivitetStatuskode__c = 'INNKALT'
        );
        insert activity;

        KafkaModiaDialogMoteHandler handler = new KafkaModiaDialogMoteHandler();
        handler.processMessages(new List<KafkaMessage__c>{ msg1 });

        List<ArenaActivity__c> activities = [
            SELECT Id, Account__c, KafkaId__c, KafkaHash__c, JsonPayload__c, AktivitetStatuskode__c
            FROM ArenaActivity__c
        ];

        System.assertEquals(1, activities.size(), 'Still only one activity');
        System.assertEquals('INNKALT', activities[0].AktivitetStatuskode__c, 'NYTT_TID_STED status ignored');
    }

    @isTest
    static void multipleMessageSameKey() {
        String json = '{"dialogmoteUuid": "a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e", "dialogmoteTidspunkt": 1970-01-19T18:55:30.540Z, "statusEndringType": "NYTT_TID_STED", "statusEndringTidspunkt": 1970-01-19T18:46:52.748Z, "personIdent": "05087321470", "virksomhetsnummer": "973113631", "enhetNr": "1805", "navIdent": "Z994911", "tilfelleStartdato": 1970-01-01T00:00:18.779Z, "arbeidstaker": true, "arbeidsgiver": true, "sykmelder": false}';
        String json2 = '{"dialogmoteUuid": "a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e", "dialogmoteTidspunkt": 1970-01-19T18:55:30.540Z, "statusEndringType": "AVLYST", "statusEndringTidspunkt": 1970-01-19T18:46:53.748Z, "personIdent": "05087321470", "virksomhetsnummer": "973113631", "enhetNr": "1805", "navIdent": "Z994911", "tilfelleStartdato": 1970-01-01T00:00:18.779Z, "arbeidstaker": true, "arbeidsgiver": true, "sykmelder": false}';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(json));
        String encodedValue2 = EncodingUtil.base64Encode(Blob.valueOf(json2));

        List<KafkaMessage__c> messages = new List<KafkaMessage__c>();

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'teamsykefravr.isdialogmote-dialogmote-statusendring';
        msg1.CRM_Key__c = 'a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e';
        msg1.CRM_Value__c = encodedValue;
        messages.add(msg1);

        KafkaMessage__c msg2 = new KafkaMessage__c();
        msg2.CRM_Topic__c = 'teamsykefravr.isdialogmote-dialogmote-statusendring';
        msg2.CRM_Key__c = 'a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e';
        msg2.CRM_Value__c = encodedValue2;
        messages.add(msg2);

        KafkaModiaDialogMoteHandler handler = new KafkaModiaDialogMoteHandler();
        handler.processMessages(messages);

        List<ArenaActivity__c> activities = [
            SELECT Id, Account__c, KafkaId__c, KafkaHash__c, JsonPayload__c, AktivitetStatuskode__c
            FROM ArenaActivity__c
        ];

        System.assertEquals(1, activities.size(), 'Only one activity');
        System.assertEquals('AVLYST', activities[0].AktivitetStatuskode__c, 'Most recent change inserted');
    }

    @isTest
    static void allFieldsChanged() {
        String json = '{"dialogmoteUuid": "a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e", "dialogmoteTidspunkt": 1970-01-19T18:55:30.540Z, "statusEndringType": "AVLYST", "statusEndringTidspunkt": 1970-01-19T18:46:52.748Z, "personIdent": "05087321470", "virksomhetsnummer": "973113631", "enhetNr": "1805", "navIdent": "Z994911", "tilfelleStartdato": 1970-01-01T00:00:18.779Z, "arbeidstaker": true, "arbeidsgiver": true, "sykmelder": false}';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(json));

        Account acc1 = new Account(Name = 'Test Employer 1', INT_OrganizationNumber__c = '973113631');
        insert acc1;
        Account acc2 = new Account(Name = 'Test Employer 2', INT_OrganizationNumber__c = '873113633');
        insert acc2;

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'teamsykefravr.isdialogmote-dialogmote-statusendring';
        msg1.CRM_Key__c = 'a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e';
        msg1.CRM_Value__c = encodedValue;

        ArenaActivity__c activity = new ArenaActivity__c(
            KafkaId__c = msg1.CRM_Key__c,
            AktivitetStatuskode__c = 'INNKALT',
            NavIdent__c = 'C158639',
            NAVenhet__c = '8888',
            DateRegistered__c = Date.newInstance(2006, 3, 16),
            DateFrom__c = Date.newInstance(2006, 3, 17),
            DateTimeRegistered__c = Datetime.newInstance(2008, 12, 1, 12, 30, 2),
            DateTimeFrom__c = Datetime.newInstance(2008, 12, 1, 12, 30, 2),
            TilfelleStartdato__c = Datetime.newInstance(2008, 12, 1, 12, 30, 2),
            Account__c = acc2.id
        );
        insert activity;

        KafkaModiaDialogMoteHandler handler = new KafkaModiaDialogMoteHandler();
        handler.processMessages(new List<KafkaMessage__c>{ msg1 });

        List<ArenaActivity__c> activities = [
            SELECT
                Id,
                Account__c,
                KafkaId__c,
                KafkaHash__c,
                JsonPayload__c,
                AktivitetStatuskode__c,
                NavIdent__c,
                NAVenhet__c,
                DateRegistered__c,
                DateFrom__c,
                DateTimeRegistered__c,
                DateTimeFrom__c,
                TilfelleStartdato__c
            FROM ArenaActivity__c
        ];

        String decodedValue = KafkaMessageUtils.base64ULSafeDecode(msg1.CRM_Value__c).toString();

        date checkDateRegistered = date.newInstance(1970, 1, 19);
        datetime checkDateTimeRegistered = datetime.newInstance(1970, 1, 19, 18, 46, 52);
        date checkDateFrom = date.newInstance(1970, 1, 19);
        datetime checkDateTimeFrom = datetime.newInstance(1970, 1, 19, 18, 55, 30);
        datetime checkTilfelleStartdato = datetime.newInstance(1970, 1, 1, 0, 0, 18);

        System.assertEquals(1, activities.size(), 'Still only one activity');
        System.assertEquals('AVLYST', activities[0].AktivitetStatuskode__c, 'Successful status updated');
        System.assertEquals(msg1.CRM_Key__c, activities[0].KafkaId__c, 'Correct KafkaId');
        System.assertEquals(msg1.CRM_Value__c, activities[0].KafkaHash__c, 'Correct KafkaId');
        System.assertEquals('Z994911', activities[0].NavIdent__c, 'Successful NavIdent updated');
        System.assertEquals('1805', activities[0].NAVenhet__c, 'Successful NavEnhet updated');
        System.assertEquals(acc1.id, activities[0].Account__c, 'Successful Account updated');
        System.assertEquals(checkDateRegistered, activities[0].DateRegistered__c, 'Successful DateRegistered updated');
        System.assertEquals(
            checkDateTimeRegistered,
            activities[0].DateTimeRegistered__c,
            'Successful DateTimeRegistered updated'
        );
        System.assertEquals(checkDateFrom, activities[0].DateFrom__c, 'Successful DateFrom updated');
        System.assertEquals(checkDateTimeFrom, activities[0].DateTimeFrom__c, 'Successful DateTimeFrom updated');
        System.assertEquals(
            checkTilfelleStartdato,
            activities[0].TilfelleStartdato__c,
            'Successful TilfelleStartdato updated'
        );
        System.assertEquals(decodedValue, activities[0].JsonPayload__c, 'Correct JsonPayload');
    }

    @isTest
    static void noChanges() {
        String json = '{"dialogmoteUuid": "a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e", "dialogmoteTidspunkt": 1970-01-19T18:55:30.540Z, "statusEndringType": "INNKALT", "statusEndringTidspunkt": 1970-01-19T18:46:52.748Z, "personIdent": "05087321470", "virksomhetsnummer": "973113631", "enhetNr": "1805", "navIdent": "Z994911", "tilfelleStartdato": 1970-01-01T00:00:18.779Z, "arbeidstaker": true, "arbeidsgiver": true, "sykmelder": false}';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(json));

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'teamsykefravr.isdialogmote-dialogmote-statusendring';
        msg1.CRM_Key__c = 'a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e';
        msg1.CRM_Value__c = encodedValue;

        ArenaActivity__c activity = new ArenaActivity__c(
            KafkaId__c = msg1.CRM_Key__c,
            KafkaHash__c = encodedValue,
            AktivitetStatuskode__c = 'INNKALT'
        );
        insert activity;

        KafkaModiaDialogMoteHandler handler = new KafkaModiaDialogMoteHandler();
        handler.processMessages(new List<KafkaMessage__c>{ msg1 });

        List<ArenaActivity__c> activities = [
            SELECT Id, Account__c, KafkaId__c, KafkaHash__c, JsonPayload__c, AktivitetStatuskode__c
            FROM ArenaActivity__c
        ];

        System.assertEquals(1, activities.size(), 'Still only one activity');
    }

    @isTest
    static void runJob() {
        KafkaEnhetFilter.bypassFilter = true;

        Account acc = new Account(Name = 'Test Employer 1', INT_OrganizationNumber__c = '973113631');
        insert acc;

        String json = '{"dialogmoteUuid": "a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e", "dialogmoteTidspunkt": 1970-01-19T18:55:30.540Z, "statusEndringType": "AVLYST", "statusEndringTidspunkt": 1970-01-19T18:46:52.748Z, "personIdent": "05087321470", "virksomhetsnummer": "973113631", "enhetNr": "1805", "navIdent": "Z994911", "tilfelleStartdato": 1970-01-01T00:00:18.779Z, "arbeidstaker": true, "arbeidsgiver": true, "sykmelder": false}';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(json));

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'teamsykefravr.isdialogmote-dialogmote-statusendring';
        msg1.CRM_Key__c = 'a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e';
        msg1.CRM_Value__c = encodedValue;
        insert msg1;

        Test.StartTest();
        AsyncRequestSchedulable.enqueueAsyncJobs();
        Test.StopTest();

        List<ArenaActivity__c> activities = [
            SELECT Id, Account__c, KafkaId__c, KafkaHash__c, JsonPayload__c
            FROM ArenaActivity__c
        ];

        System.assertEquals(1, activities.size(), 'Activity Inserted');
        System.assertEquals(acc.id, activities[0].Account__c, 'Correct Account');
        System.assertEquals(msg1.CRM_Key__c, activities[0].KafkaId__c, 'Correct KafkaId');
        System.assertEquals(msg1.CRM_Value__c, activities[0].KafkaHash__c, 'Correct KafkaId');
    }

    @isTest
    static void runJobBulk() {
        KafkaEnhetFilter.bypassFilter = true;

        Account acc = new Account(Name = 'Test Employer 1', INT_OrganizationNumber__c = '973113631');
        insert acc;

        String json = '{"dialogmoteUuid": "a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e", "dialogmoteTidspunkt": 1970-01-19T18:55:30.540Z, "statusEndringType": "INNKALT", "statusEndringTidspunkt": 1970-01-19T18:46:52.748Z, "personIdent": "05087321470", "virksomhetsnummer": "973113631", "enhetNr": "1805", "navIdent": "Z994911", "tilfelleStartdato": 1970-01-01T00:00:18.779Z, "arbeidstaker": true, "arbeidsgiver": true, "sykmelder": false}';
        String json2 = '{"dialogmoteUuid": "a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e", "dialogmoteTidspunkt": 1970-01-19T18:55:30.540Z, "statusEndringType": "AVLYST", "statusEndringTidspunkt": 1970-01-20T18:46:52.748Z, "personIdent": "05087321470", "virksomhetsnummer": "973113631", "enhetNr": "1805", "navIdent": "Z994911", "tilfelleStartdato": 1970-01-01T00:00:18.779Z, "arbeidstaker": true, "arbeidsgiver": true, "sykmelder": false}';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(json));
        String encodedValue2 = EncodingUtil.base64Encode(Blob.valueOf(json2));

        List<KafkaMessage__c> messages = new List<KafkaMessage__c>();

        KafkaMessage__c msg = new KafkaMessage__c();
        msg.CRM_Topic__c = 'teamsykefravr.isdialogmote-dialogmote-statusendring';
        msg.CRM_Key__c = 'a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e';
        msg.CRM_Value__c = encodedValue;

        KafkaMessage__c msg2 = msg.clone();
        msg2.CRM_Key__c = 'a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1f';

        KafkaMessage__c msg3 = msg.clone();
        msg3.CRM_Key__c = 'a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1g';

        // Same key as msg but different value
        KafkaMessage__c msg4 = msg.clone();
        msg.CRM_Value__c = encodedValue2;

        messages.add(msg);
        messages.add(msg2);
        messages.add(msg3);
        messages.add(msg4);

        insert messages;

        Test.StartTest();
        AsyncRequestSchedulable.enqueueAsyncJobs();
        Test.StopTest();

        List<ArenaActivity__c> activities = [
            SELECT Id, Account__c, KafkaId__c, KafkaHash__c, JsonPayload__c
            FROM ArenaActivity__c
        ];

        System.assertEquals(3, activities.size(), '3 activities inserted. One updated with prexisting key');
    }
}
