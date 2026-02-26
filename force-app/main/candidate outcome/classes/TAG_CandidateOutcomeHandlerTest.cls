/**
 * @description This TAG_CandidateOutcomeHandlerTest class tests the TAG_CandidateOutcomeHandler class
 *
 * @author Andre Colle <andre.colle@nav.no>
 * @since 2026-01-22 Created.
 *
 * @see [License](https://github.com/navikt/crm-arbeidsgiver-integration/blob/main/LICENSE)
 * @see [Github](https://github.com/navikt/crm-arbeidsgiver-integration)
 * @see TAG_CandidateOutcome
 * @see TAG_CandidateOutcomeHandler
 *
 * @group TAG Candidate Outcome Integration
 */

@IsTest
public with sharing class TAG_CandidateOutcomeHandlerTest {
    @TestSetup
    static void setupTestData() {
        String topic = 'toi.kandidatutfall';
        List<KafkaMessage__c> testMessages = new List<KafkaMessage__c>();

        //Message with all fields populated
        testMessages.add(
            new KafkaMessage__c(
                CRM_Topic__c = topic,
                CRM_Key__c = 'ZDJkNGYwMmQtOGEzOC00Mjk3LTg2YWMtMjEzYTMyOWYxZmFm1',
                CRM_Value__c = EncodingUtil.base64Encode(
                    Blob.valueOf(
                        '{"aktørId": "2171954836936", "utfall": "FATT_JOBBEN", "navIdent": "Z990248", "navKontor": "0219", "kandidatlisteId": "880e8678-3e04-4a3c-a81a-37fe25998ebf", "stillingsId": "016a90-75ad-4a39-8fb4-c65e4ed3c6689b", "tidspunkt": "2026-01-20T08:48:52.988", "stillingskategori": "FORMIDLING"}'
                    )
                )
            )
        );

        //Message with nulls
        testMessages.add(
            new KafkaMessage__c(
                CRM_Topic__c = topic,
                CRM_Key__c = 'ZDJkNGYwMmQtOGEzOC00Mjk3LTg2YWMtMjEzYTMyOWYxZmFm2',
                CRM_Value__c = EncodingUtil.base64Encode(
                    Blob.valueOf(
                        '{"aktørId": "2171954836936", "utfall": null, "navIdent": null, "navKontor": null, "kandidatlisteId": null, "stillingsId": null, "tidspunkt": "2026-01-20T08:48:52.988", "stillingskategori": null}'
                    )
                )
            )
        );

        //Message with corrupted hash
        testMessages.add(
            new KafkaMessage__c(
                CRM_Topic__c = topic,
                CRM_Key__c = 'ZDJkNGYwMmQtOGEzOC00Mjk3LTg2YWMtMjEzYTMyOWYxZmFm3',
                CRM_Value__c = 'corrupted'
            )
        );

        // Mass generate records for bulk testing
        for (Integer i = 0; i < 20; i++) {
            String s = 'TEST' + i;
            testMessages.add(
                new KafkaMessage__c(
                    CRM_Topic__c = topic,
                    CRM_Key__c = s,
                    CRM_Value__c = EncodingUtil.base64Encode(
                        Blob.valueOf(
                            '{"aktørId":"' +
                            s +
                            '","utfall":"FATT_JOBBEN","navIdent":"Z990248","navKontor":"0219","kandidatlisteId":"880e8678-3e04-4a3c-a81a-37fe25998ebf","stillingsId":"016a90-75ad-4a39-8fb4-c65e4ed3c6689b","tidspunkt":"2026-01-20T08:48:52.988","stillingskategori":"FORMIDLING"}'
                        )
                    )
                )
            );
        }

        insert new NavUnit__c(Name = 'Nav Unit 1', INT_UnitNumber__c = '0219');
        insert testMessages;
    }

    @IsTest
    static void testProcessSingleMessagePositive() {
        List<KafkaMessage__c> messages = [
            SELECT CRM_Topic__c, CRM_Value__c, CRM_Key__c
            FROM KafkaMessage__c
            WHERE CRM_Key__c = 'ZDJkNGYwMmQtOGEzOC00Mjk3LTg2YWMtMjEzYTMyOWYxZmFm1'
        ];

        Test.startTest();
        TAG_CandidateOutcomeHandler handler = new TAG_CandidateOutcomeHandler();
        handler.processMessages(messages);
        Test.stopTest();

        List<CandidateOutcome__c> candidateOutcomeList = [
            SELECT Id, Name, CandidateId__c, Result__c, NavIdent__c, NavUnit__c, CandidateListId__c, JobPostingId__c, TimeRegistered__c, Category__c, Type__c, KafkaId__c, KafkaHash__c
            FROM CandidateOutcome__c
            WHERE KafkaId__c = 'ZDJkNGYwMmQtOGEzOC00Mjk3LTg2YWMtMjEzYTMyOWYxZmFm1'
        ];

        String timeRegistered = string.valueOf(candidateOutcomeList[0].TimeRegistered__c);

        Assert.areEqual(1, candidateOutcomeList.size(), 'Expected 1 CandidateOutcome record to be created.');
        Assert.areEqual(messages[0].CRM_Key__c, candidateOutcomeList[0].KafkaId__c, 'Expected KafkaId to match.');
        Assert.areEqual(messages[0].CRM_Value__c, candidateOutcomeList[0].KafkaHash__c, 'Expected KafkaHash to match.');
        Assert.areEqual('FATT_JOBBEN', candidateOutcomeList[0].Result__c, 'Expected result to be FATT_JOBBEN');
        Assert.areEqual('Z990248', candidateOutcomeList[0].NavIdent__c, 'Expected NavIdent to match.');
        Assert.isNotNull(candidateOutcomeList[0].NavUnit__c, 'Expected NavUnit to be populated.');
        Assert.areEqual('880e8678-3e04-4a3c-a81a-37fe25998ebf', candidateOutcomeList[0].CandidateListId__c, 'Expected CandidateListId to match.');
        Assert.areEqual('016a90-75ad-4a39-8fb4-c65e4ed3c6689b', candidateOutcomeList[0].JobPostingId__c, 'Expected JobPostingId to match.');
        Assert.areEqual('2026-01-20 08:48:52', timeRegistered, 'Expected TimeRegistered to match.');
        Assert.areEqual('FORMIDLING', candidateOutcomeList[0].Category__c, 'Expected Category to match.');
        Assert.areEqual('2171954836936', candidateOutcomeList[0].CandidateId__c, 'Expected CandidateId to match.');
        Assert.areEqual('ZDJkNGYwMmQtOGEzOC00Mjk3LTg2YWMtMjEzYTMyOWYxZmFm1', candidateOutcomeList[0].KafkaId__c, 'Expected KafkaId to match.');
    }

    @IsTest
    static void testProcessMessageWithNullsPositive() {
        List<KafkaMessage__c> messages = [
            SELECT CRM_Topic__c, CRM_Value__c, CRM_Key__c
            FROM KafkaMessage__c
            WHERE CRM_Key__c = 'ZDJkNGYwMmQtOGEzOC00Mjk3LTg2YWMtMjEzYTMyOWYxZmFm2'
        ];

        Test.startTest();
        TAG_CandidateOutcomeHandler handler = new TAG_CandidateOutcomeHandler();
        handler.processMessages(messages);
        Test.stopTest();

        List<CandidateOutcome__c> candidateOutcomeList = [
            SELECT Id, Name, CandidateId__c, Result__c, NavIdent__c, NavUnit__c, CandidateListId__c, JobPostingId__c, TimeRegistered__c, Category__c, Type__c, KafkaId__c, KafkaHash__c
            FROM CandidateOutcome__c
            WHERE KafkaId__c = 'ZDJkNGYwMmQtOGEzOC00Mjk3LTg2YWMtMjEzYTMyOWYxZmFm2'
        ];

        Assert.areEqual(1, candidateOutcomeList.size(), 'Expected 1 CandidateOutcome record to be created.');
        Assert.areEqual(null, candidateOutcomeList[0].Result__c, 'Expected result to be FATT_JOBBEN');
        Assert.areEqual(null, candidateOutcomeList[0].NavIdent__c, 'Expected NavIdent to match.');
        Assert.isNull(candidateOutcomeList[0].NavUnit__c, 'Expected NavUnit to be populated.');
        Assert.areEqual(null, candidateOutcomeList[0].CandidateListId__c, 'Expected CandidateListId to match.');
        Assert.areEqual(null, candidateOutcomeList[0].JobPostingId__c, 'Expected JobPostingId to match.');
        Assert.areEqual(null, candidateOutcomeList[0].Category__c, 'Expected Category to match.');
        Assert.areEqual('2171954836936', candidateOutcomeList[0].CandidateId__c, 'Expected CandidateId to match.');
    }

    @IsTest
    static void testProcessMessageUpdatePositive() {
        String topic = 'toi.kandidatutfall';
        List<KafkaMessage__c> testMessage = new List<KafkaMessage__c>();
        //Message with updates to existing record
        testMessage.add(
            new KafkaMessage__c(
                CRM_Topic__c = topic,
                CRM_Key__c = 'ZDJkNGYwMmQtOGEzOC00Mjk3LTg2YWMtMjEzYTMyOWYxZmFm1',
                CRM_Value__c = EncodingUtil.base64Encode(
                    Blob.valueOf(
                        '{"aktørId": "2171954836936", "utfall": "FATT_JOBBEN", "navIdent": "Z990248", "navKontor": "0219", "kandidatlisteId": "880e8678-3e04-4a3c-a81a-37fe25998ebf", "stillingsId": "016a90-75ad-4a39-8fb4-c65e4ed3c6689b", "tidspunkt": "2026-01-20T08:49:52.988", "stillingskategori": "STILLING"}'
                    )
                )
            )
        );
        insert testMessage;

        List<KafkaMessage__c> messages = [
            SELECT CRM_Topic__c, CRM_Value__c, CRM_Key__c
            FROM KafkaMessage__c
            WHERE CRM_Key__c = 'ZDJkNGYwMmQtOGEzOC00Mjk3LTg2YWMtMjEzYTMyOWYxZmFm1'
        ];

        System.assert(messages.size() == 2);

        Test.startTest();
        TAG_CandidateOutcomeHandler handler = new TAG_CandidateOutcomeHandler();
        handler.processMessages(messages);
        Test.stopTest();

        List<CandidateOutcome__c> candidateOutcomeList = [
            SELECT Id, Name, CandidateId__c, Result__c, NavIdent__c, NavUnit__c, CandidateListId__c, JobPostingId__c, TimeRegistered__c, Category__c, Type__c, KafkaId__c, KafkaHash__c
            FROM CandidateOutcome__c
            WHERE KafkaId__c = 'ZDJkNGYwMmQtOGEzOC00Mjk3LTg2YWMtMjEzYTMyOWYxZmFm1'
        ];

        Assert.areEqual(1, candidateOutcomeList.size(), 'Expected 1 CandidateOutcome record to be created.');
        Assert.areEqual(messages[0].CRM_Key__c, candidateOutcomeList[0].KafkaId__c, 'Expected KafkaId to match.');
        Assert.areEqual('FATT_JOBBEN', candidateOutcomeList[0].Result__c, 'Expected result to be FATT_JOBBEN');
        Assert.areEqual('STILLING', candidateOutcomeList[0].Category__c, 'Expected Category to match.');
    }

    @isTest
    static void testProcessMultipleMessagesPositive() {
        List<KafkaMessage__c> message = [
            SELECT CRM_Topic__c, CRM_Value__c, CRM_Key__c
            FROM KafkaMessage__c
            WHERE CRM_Key__c LIKE 'TEST%'
        ];

        System.assert(message.size() == 20);

        Test.startTest();
        TAG_CandidateOutcomeHandler handler = new TAG_CandidateOutcomeHandler();
        handler.processMessages(message);
        Test.stopTest();

        List<CandidateOutcome__c> candidateOutcomeList = [SELECT Id FROM CandidateOutcome__c];

        System.assertEquals(20, candidateOutcomeList.size());
    }

    @isTest
    static void testProcessSingleMessageWithCorruptedJsonStringNegative() {
        List<KafkaMessage__c> message = [
            SELECT CRM_Topic__c, CRM_Value__c, CRM_Key__c, CRM_Status__c
            FROM KafkaMessage__c
            WHERE CRM_Key__c = 'ZDJkNGYwMmQtOGEzOC00Mjk3LTg2YWMtMjEzYTMyOWYxZmFm3'
        ];

        System.assert(message.size() == 1);

        Test.startTest();
        TAG_CandidateOutcomeHandler handler = new TAG_CandidateOutcomeHandler();
        handler.processMessages(message);
        Test.stopTest();

        List<CandidateOutcome__c> candidateOutcomeList = [
            SELECT Id
            FROM CandidateOutcome__c
        ];

        System.assertEquals(
            'Error',
            message[0].CRM_Status__c,
            'Expecting CRM_Status__c = Error as json-string has errors'
        );
        System.assertEquals(0, candidateOutcomeList.size(), 'Expecting candidateOutcomeList to be empty');
    }

}