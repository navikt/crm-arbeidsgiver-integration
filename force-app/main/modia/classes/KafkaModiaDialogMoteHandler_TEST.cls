@isTest
public with sharing class KafkaModiaDialogMoteHandler_TEST {
    @isTest
    static void processSingleMessage() {
        Account acc = new Account(Name = 'Test Employer 1', INT_OrganizationNumber__c = '973113631');
        insert acc;

        String json = '{"dialogmoteUuid": "a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e", "dialogmoteTidspunkt": "1970-01-19T18:55:30.540Z", "statusEndringType": "AVLYST", "statusEndringTidspunkt": "1970-01-19T18:46:52.748Z", "personIdent": "05087321470", "virksomhetsnummer": "973113631", "enhetNr": "1805", "navIdent": "Z994911", "tilfelleStartdato": "1970-01-01T00:00:18.779Z", "arbeidstaker": true, "arbeidsgiver": true, "sykmelder": false}';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(json));

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'isdialogmote-dialogmote-statusendring';
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
        String json = '{"dialogmoteUuid": "a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e", "dialogmoteTidspunkt": "1970-01-19T18:55:30.540Z", "statusEndringType": "AVLYST", "statusEndringTidspunkt": "1970-01-19T18:46:52.748Z", "personIdent": "05087321470", "virksomhetsnummer": "973113631", "enhetNr": "1805", "navIdent": "Z994911", "tilfelleStartdato": "1970-01-01T00:00:18.779Z", "arbeidstaker": true, "arbeidsgiver": true, "sykmelder": false}';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(json));

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'isdialogmote-dialogmote-statusendring';
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
        String json = '{"dialogmoteUuid": "a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e", "dialogmoteTidspunkt": "1970-01-19T18:55:30.540Z", "statusEndringType": "NYTT_TID_STED", "statusEndringTidspunkt": "1970-01-19T18:46:52.748Z", "personIdent": "05087321470", "virksomhetsnummer": "973113631", "enhetNr": "1805", "navIdent": "Z994911", "tilfelleStartdato": "1970-01-01T00:00:18.779Z", "arbeidstaker": true, "arbeidsgiver": true, "sykmelder": false}';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(json));

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'isdialogmote-dialogmote-statusendring';
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
        String json = '{"dialogmoteUuid": "a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e", "dialogmoteTidspunkt": "1970-01-19T18:55:30.540Z", "statusEndringType": "NYTT_TID_STED", "statusEndringTidspunkt": "1970-01-19T18:46:52.748Z", "personIdent": "05087321470", "virksomhetsnummer": "973113631", "enhetNr": "1805", "navIdent": "Z994911", "tilfelleStartdato": "1970-01-01T00:00:18.779Z", "arbeidstaker": true, "arbeidsgiver": true, "sykmelder": false}';
        String json2 = '{"dialogmoteUuid": "a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e", "dialogmoteTidspunkt": "1970-01-19T18:55:30.540Z", "statusEndringType": "AVLYST", "statusEndringTidspunkt": "1970-01-19T18:46:53.748Z", "personIdent": "05087321470", "virksomhetsnummer": "973113631", "enhetNr": "1805", "navIdent": "Z994911", "tilfelleStartdato": "1970-01-01T00:00:18.779Z", "arbeidstaker": true, "arbeidsgiver": true, "sykmelder": false}';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(json));
        String encodedValue2 = EncodingUtil.base64Encode(Blob.valueOf(json2));

        List<KafkaMessage__c> messages = new List<KafkaMessage__c>();

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'isdialogmote-dialogmote-statusendring';
        msg1.CRM_Key__c = 'a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e';
        msg1.CRM_Value__c = encodedValue;
        messages.add(msg1);

        KafkaMessage__c msg2 = new KafkaMessage__c();
        msg2.CRM_Topic__c = 'isdialogmote-dialogmote-statusendring';
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

    // TODO: Test that all fields(Except CRM_Key__c) get updated on an existing activity.
    @isTest
    static void allFieldsChanged() {
    }

    @isTest
    static void noChanges() {
        String json = '{"dialogmoteUuid": "a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e", "dialogmoteTidspunkt": "1970-01-19T18:55:30.540Z", "statusEndringType": "INNKALT", "statusEndringTidspunkt": "1970-01-19T18:46:52.748Z", "personIdent": "05087321470", "virksomhetsnummer": "973113631", "enhetNr": "1805", "navIdent": "Z994911", "tilfelleStartdato": "1970-01-01T00:00:18.779Z", "arbeidstaker": true, "arbeidsgiver": true, "sykmelder": false}';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(json));

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'isdialogmote-dialogmote-statusendring';
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

        String json = '{"dialogmoteUuid": "a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e", "dialogmoteTidspunkt": "1970-01-19T18:55:30.540Z", "statusEndringType": "AVLYST", "statusEndringTidspunkt": "1970-01-19T18:46:52.748Z", "personIdent": "05087321470", "virksomhetsnummer": "973113631", "enhetNr": "1805", "navIdent": "Z994911", "tilfelleStartdato": "1970-01-01T00:00:18.779Z", "arbeidstaker": true, "arbeidsgiver": true, "sykmelder": false}';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(json));

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'isdialogmote-dialogmote-statusendring';
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

        String json = '{"dialogmoteUuid": "a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e", "dialogmoteTidspunkt": "1970-01-19T18:55:30.540Z", "statusEndringType": "INNKALT", "statusEndringTidspunkt": "1970-01-19T18:46:52.748Z", "personIdent": "05087321470", "virksomhetsnummer": "973113631", "enhetNr": "1805", "navIdent": "Z994911", "tilfelleStartdato": "1970-01-01T00:00:18.779Z", "arbeidstaker": true, "arbeidsgiver": true, "sykmelder": false}';
        String json2 = '{"dialogmoteUuid": "a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e", "dialogmoteTidspunkt": "1970-01-19T18:55:30.540Z", "statusEndringType": "AVLYST", "statusEndringTidspunkt": "1970-01-20T18:46:52.748Z", "personIdent": "05087321470", "virksomhetsnummer": "973113631", "enhetNr": "1805", "navIdent": "Z994911", "tilfelleStartdato": "1970-01-01T00:00:18.779Z", "arbeidstaker": true, "arbeidsgiver": true, "sykmelder": false}';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(json));
        String encodedValue2 = EncodingUtil.base64Encode(Blob.valueOf(json2));

        List<KafkaMessage__c> messages = new List<KafkaMessage__c>();

        KafkaMessage__c msg = new KafkaMessage__c();
        msg.CRM_Topic__c = 'isdialogmote-dialogmote-statusendring';
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
