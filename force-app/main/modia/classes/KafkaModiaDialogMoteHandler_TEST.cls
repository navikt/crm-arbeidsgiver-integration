@isTest
public with sharing class KafkaModiaDialogMoteHandler_TEST {
    /* Can not Test  OwnerId because NAV Kontor Profile User because NAV Kontor profile is not in the package*/
    @TestSetup
    static void makeData() {
        NavUnit__c NavUnit = new NavUnit__c(Name = 'NAV Test', INT_UnitNumber__c = '1805');
        insert NavUnit;

        List<User> users = TestDataFactory.getUsers(1, 'Standard User', false, false);
        users[0].CRM_NAV_Ident__c = 'Z994911';
        insert users;
    }
    
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

        List<DialogueMeeting__c> activities = [
            SELECT Id, Account__c, KafkaId__c, KafkaHash__c, JsonPayload__c
            FROM DialogueMeeting__c
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

        List<User> owner = [SELECT Id FROM User WHERE CRM_NAV_Ident__c = 'Z994911'];

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'teamsykefravr.isdialogmote-dialogmote-statusendring';
        msg1.CRM_Key__c = 'a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e';
        msg1.CRM_Value__c = encodedValue;

        DialogueMeeting__c activity = new DialogueMeeting__c(
            KafkaId__c = msg1.CRM_Key__c,
            Status__c = 'INNKALT',
            OwnerId = owner[0].id
        );
        insert activity;

        KafkaModiaDialogMoteHandler handler = new KafkaModiaDialogMoteHandler();
        handler.processMessages(new List<KafkaMessage__c>{ msg1 });

        List<DialogueMeeting__c> activities = [
            SELECT Id, Account__c, KafkaId__c, KafkaHash__c, JsonPayload__c, Status__c
            FROM DialogueMeeting__c
        ];

        System.assertEquals(1, activities.size(), 'Still only one activity');
        System.assertEquals('AVLYST', activities[0].Status__c, 'Successful status updated');
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

        DialogueMeeting__c activity = new DialogueMeeting__c(
            KafkaId__c = msg1.CRM_Key__c,
            Status__c = 'INNKALT'
        );
        insert activity;

        KafkaModiaDialogMoteHandler handler = new KafkaModiaDialogMoteHandler();
        handler.processMessages(new List<KafkaMessage__c>{ msg1 });

        List<DialogueMeeting__c> activities = [
            SELECT Id, Account__c, KafkaId__c, KafkaHash__c, JsonPayload__c, Status__c
            FROM DialogueMeeting__c
        ];

        System.assertEquals(1, activities.size(), 'Still only one activity');
        System.assertEquals('INNKALT', activities[0].Status__c, 'NYTT_TID_STED status ignored');
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

        List<DialogueMeeting__c> activities = [
            SELECT Id, Account__c, KafkaId__c, KafkaHash__c, JsonPayload__c, Status__c
            FROM DialogueMeeting__c
        ];

        System.assertEquals(1, activities.size(), 'Only one activity');
        System.assertEquals('AVLYST', activities[0].Status__c, 'Most recent change inserted');
    }

    @isTest
    static void allFieldsChanged() {
        String json = '{"dialogmoteUuid": "a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e", "dialogmoteTidspunkt": 1970-01-19T18:55:30.540Z, "statusEndringType": "AVLYST", "statusEndringTidspunkt": 1970-01-19T18:46:52.748Z, "personIdent": "05087321470", "virksomhetsnummer": "973113631", "enhetNr": "1805", "navIdent": "Z994911", "tilfelleStartdato": 1970-01-01T00:00:18.779Z, "arbeidstaker": true, "arbeidsgiver": true, "sykmelder": false}';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(json));

        Account acc1 = new Account(Name = 'Test Employer 1', INT_OrganizationNumber__c = '973113631');
        insert acc1;
        Account acc2 = new Account(Name = 'Test Employer 2', INT_OrganizationNumber__c = '873113633');
        insert acc2;

        List<User> owner = [SELECT Id FROM User WHERE CRM_NAV_Ident__c = 'Z994911'];

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'teamsykefravr.isdialogmote-dialogmote-statusendring';
        msg1.CRM_Key__c = 'a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e';
        msg1.CRM_Value__c = encodedValue;

        DialogueMeeting__c activity = new DialogueMeeting__c(
            Name = 'Dialogmøte',
            DialogueMeetingId__c = 'a240d1ad-ac38-4c2e-b0e7-e204c7e5bc12',
            KafkaId__c = msg1.CRM_Key__c,
            Status__c = 'INNKALT',
            UserNavIdent__c = 'C158639',
            OwnerId = owner[0].id,
            MeetingTime__c = Datetime.newInstance(2008, 12, 1, 12, 30, 2),
            StatusChangeTime__c = Datetime.newInstance(2008, 12, 1, 12, 30, 2),
            CaseStartDate__c = Datetime.newInstance(2008, 12, 1, 12, 30, 2),
            Account__c = acc2.id
        );
        insert activity;

        KafkaModiaDialogMoteHandler handler = new KafkaModiaDialogMoteHandler();
        handler.processMessages(new List<KafkaMessage__c>{ msg1 });

        List<DialogueMeeting__c> activities = [
            SELECT
                Id,
                Name,
                Account__c,
                KafkaId__c,
                KafkaHash__c,
                JsonPayload__c,
                Status__c,
                UserNavIdent__c,
                NavUnit__c,
                StatusChangeTime__c,
                DialogueMeetingId__c,
                MeetingTime__c,
                CaseStartDate__c,
                IsEmployeeParticipating__c,
                IsEmployerParticipating__c,
                IsSickLeaveIssuerParticipating__c,
                OwnerId
            FROM DialogueMeeting__c
        ];

        String decodedValue = KafkaMessageUtils.base64ULSafeDecode(msg1.CRM_Value__c).toString();

        List<NavUnit__c> NavUnitId = [SELECT Id FROM NavUnit__c WHERE INT_UnitNumber__c = '1805'];
        datetime checkStatusChangeTime = datetime.newInstance(1970, 1, 19, 18, 46, 52);
        datetime checkMeetingTime = datetime.newInstance(1970, 1, 19, 18, 55, 30);
        datetime checkCaseStartDate = datetime.newInstance(1970, 1, 1, 0, 0, 18);

        System.assertEquals(1, activities.size(), 'Still only one activity');
        System.assertEquals('AVLYST', activities[0].Status__c, 'Successful status updated');
        System.assertEquals(msg1.CRM_Key__c, activities[0].KafkaId__c, 'Correct KafkaId');
        System.assertEquals(msg1.CRM_Value__c, activities[0].KafkaHash__c, 'Correct KafkaId');
        System.assertEquals('Z994911', activities[0].UserNavIdent__c, 'Successful NavIdent updated');
        System.assertEquals(NavUnitId[0].id, activities[0].NavUnit__c, 'Successful NavUnit updated');
        System.assertEquals(acc1.id, activities[0].Account__c, 'Successful Account updated');
        //System.assertEquals(owner[0].id, activities[0].OwnerId, 'Successful User updated');
        System.assertEquals('a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e', activities[0].DialogueMeetingId__c, 'Successful DialogueMeetingId__c updated');
        System.assertEquals('Dialogmøte 1970-01-19', activities[0].Name, 'Successful Name updated');
        System.assertEquals(
            checkStatusChangeTime,
            activities[0].StatusChangeTime__c,
            'Successful DateTimeRegistered updated'
        );
        System.assertEquals(checkMeetingTime, activities[0].MeetingTime__c, 'Successful MeetingTime updated');
        System.assertEquals(
            checkCaseStartDate,
            activities[0].CaseStartDate__c,
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

        DialogueMeeting__c activity = new DialogueMeeting__c(
            KafkaId__c = msg1.CRM_Key__c,
            KafkaHash__c = encodedValue,
            Status__c = 'INNKALT'
        );
        insert activity;

        KafkaModiaDialogMoteHandler handler = new KafkaModiaDialogMoteHandler();
        handler.processMessages(new List<KafkaMessage__c>{ msg1 });

        List<DialogueMeeting__c> activities = [
            SELECT Id, Account__c, KafkaId__c, KafkaHash__c, JsonPayload__c, Status__c
            FROM DialogueMeeting__c
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

        List<DialogueMeeting__c> activities = [
            SELECT Id, Account__c, KafkaId__c, KafkaHash__c, JsonPayload__c, OwnerId
            FROM DialogueMeeting__c
        ];

        List<User> owner = [SELECT Id FROM User WHERE CRM_NAV_Ident__c = 'Z994911'];

        System.assertEquals(1, activities.size(), 'Activity Inserted');
        System.assertEquals(acc.id, activities[0].Account__c, 'Correct Account');
        System.assertEquals(msg1.CRM_Key__c, activities[0].KafkaId__c, 'Correct KafkaId');
        System.assertEquals(msg1.CRM_Value__c, activities[0].KafkaHash__c, 'Correct KafkaId');
        //System.assertEquals(owner[0].id, activities[0].OwnerId, 'Correct Owner');
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

        List<DialogueMeeting__c> activities = [
            SELECT Id, Account__c, KafkaId__c, KafkaHash__c, JsonPayload__c
            FROM DialogueMeeting__c
        ];

        System.assertEquals(3, activities.size(), '3 activities inserted. One updated with prexisting key');
    }
}
