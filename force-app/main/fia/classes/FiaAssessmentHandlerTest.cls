@IsTest
public with sharing class FiaAssessmentHandlerTest {
    private static final String TOPIC = 'pia.fullfort-behovsvurdering-v1';
    private static final String CASE_NAME_1 = 'QRAGANAjlM0qT';
    private static final String CASE_NAME_2 = 'l8pYDNoLtPCKb';
    private static final String KEY_1 = '4cce71a2-ffba-4d4a-865d-fca20b482598';
    private static final String KEY_2 = '50d477f7-fba2-53b4-a20a-b5fd50f28669';
    private static final String KEY_3 = 'd6433a6b-4e53-5432-a97a-7056a8410f34';
    private static final String KEY_4 = 'df04fc49-7374-59e9-9217-055604f0390b';

    private static final String JSON_1 =
        '{"behovsvurderingId": "' +
        KEY_1 +
        '", "saksnummer": "' +
        CASE_NAME_1 +
        '", "fullførtTidspunkt": "2022-02-18T07:07:07.064711"}';
    private static final String JSON_2 =
        '{\n' +
        '   "behovsvurderingId": "' +
        KEY_2 +
        '",\n' +
        '   "saksnummer": "' +
        CASE_NAME_2 +
        '",\n' +
        '   "fullførtTidspunkt": "2022-02-18T07:07:07.064711"\n' +
        '}';

    private static final String JSON_BAD_DATA_1 =
        '{\n' +
        '   "behovsvurderingId": "' +
        KEY_4 +
        '",\n' +
        '   "saksnummer": "",\n' +
        '   "fullførtTidspunkt": "INVALID"\n' +
        '}';

    @TestSetup
    static void setupTestData() {
        insert new List<IaCase__c>{ new IaCase__c(Name = CASE_NAME_1), new IaCase__c(Name = CASE_NAME_2) };

        insert new List<KafkaMessage__c>{
            new KafkaMessage__c(
                CRM_Topic__c = TOPIC,
                CRM_Key__c = KEY_1,
                CRM_Value__c = EncodingUtil.base64Encode(Blob.valueOf(JSON_1))
            ),
            new KafkaMessage__c(
                CRM_Topic__c = TOPIC,
                CRM_Key__c = KEY_2,
                CRM_Value__c = EncodingUtil.base64Encode(Blob.valueOf(JSON_2))
            ),
            new KafkaMessage__c(CRM_Topic__c = TOPIC, CRM_Key__c = KEY_3, CRM_Value__c = 'CORRUPTED_HASH'),
            new KafkaMessage__c(
                CRM_Topic__c = TOPIC,
                CRM_Key__c = KEY_4,
                CRM_Value__c = EncodingUtil.base64Encode(Blob.valueOf(JSON_BAD_DATA_1))
            )
        };
    }

    @IsTest
    static void testProcessSingleMessage() {
        List<KafkaMessage__c> messages = [
            SELECT CRM_Topic__c, CRM_Value__c, CRM_Key__c
            FROM KafkaMessage__c
            WHERE CRM_Key__c = :KEY_1
        ];

        Test.startTest();
        FiaAssessmentHandler handler = new FiaAssessmentHandler();
        handler.processMessages(messages);
        Test.stopTest();

        List<IADelivery__c> iaDelivery = [
            SELECT Id, Name, IACase__c, KafkaId__c, KafkaHash__c
            FROM IADelivery__c
            WHERE Name = :KEY_1
        ];

        System.assertEquals(1, iaDelivery.size(), 'Expected 1 IA delivery record to be created.');
        System.assertEquals(messages[0].CRM_Key__c, iaDelivery[0].KafkaId__c, 'Expected KafkaId to match.');
        System.assertEquals(messages[0].CRM_Value__c, iaDelivery[0].KafkaHash__c, 'Expected KafkaHash to match.');
    }

    @IsTest
    static void testProcessMultipleMessages() {
        List<KafkaMessage__c> messages = [SELECT CRM_Topic__c, CRM_Value__c, CRM_Key__c FROM KafkaMessage__c];

        Test.startTest();
        FiaAssessmentHandler handler = new FiaAssessmentHandler();
        handler.processMessages(messages);
        Test.stopTest();

        List<IADelivery__c> iaDelivery = [SELECT Id, Name, IACase__c, KafkaId__c, KafkaHash__c FROM IADelivery__c];

        System.assertEquals(2, iaDelivery.size(), 'Expected 2 IA delivery records to be created.');
        System.assertEquals(
            messages[0].CRM_Key__c,
            iaDelivery[0].KafkaId__c,
            'Expected KafkaId to match for the first record.'
        );
        System.assertEquals(
            messages[0].CRM_Value__c,
            iaDelivery[0].KafkaHash__c,
            'Expected KafkaHash to match for the first record.'
        );
    }

    @IsTest
    static void testExtractFiaAssessmentData() {
        List<KafkaMessage__c> messages = [SELECT CRM_Topic__c, CRM_Value__c, CRM_Key__c FROM KafkaMessage__c];

        FiaAssessmentHandler handler = new FiaAssessmentHandler();
        Map<String, FiaAssessment> keyToFiaAssessmentMap = handler.extractFiaAssessmentData(messages);

        System.assert(keyToFiaAssessmentMap.containsKey(KEY_1), 'The map should contain the key: ' + KEY_1);
        System.assert(keyToFiaAssessmentMap.containsKey(KEY_2), 'The map should contain the key: ' + KEY_2);
        System.assert(!keyToFiaAssessmentMap.containsKey(KEY_3), 'The map should not contain the key: ' + KEY_3);
        System.assert(keyToFiaAssessmentMap.containsKey(KEY_4), 'The map should contain the key: ' + KEY_4);
    }

    @IsTest
    static void testCreateIADeliveryRecords() {
        Map<String, FiaAssessment> fiaAssessmentMap = new Map<String, FiaAssessment>();
        FiaAssessment fa1 = new FiaAssessment();
        fa1.behovsvurderingId = KEY_1;
        fa1.saksnummer = CASE_NAME_1;
        fa1.fullfortTidspunkt = '2022-02-18T07:07:07.064711';
        fa1.jsonPayload = JSON_1;
        fa1.hash = EncodingUtil.base64Encode(Blob.valueOf(JSON_1));
        fa1.key = KEY_1;
        fiaAssessmentMap.put(fa1.key, fa1);

        FiaAssessment fa2 = new FiaAssessment();
        fa2.behovsvurderingId = KEY_4;
        fa2.saksnummer = 'BAD_DATA';
        fa2.fullfortTidspunkt = 'BAD_DATA';
        fa2.jsonPayload = JSON_BAD_DATA_1;
        fa2.hash = EncodingUtil.base64Encode(Blob.valueOf(JSON_BAD_DATA_1));
        fa2.key = KEY_4;
        fiaAssessmentMap.put(fa2.key, fa2);

        List<KafkaMessage__c> messages = [
            SELECT CRM_Topic__c, CRM_Value__c, CRM_Key__c
            FROM KafkaMessage__c
            WHERE CRM_Key__c = :fiaAssessmentMap.keySet()
        ];

        FiaAssessmentHandler handler = new FiaAssessmentHandler();
        List<IADelivery__c> iaDeliveryRecords = handler.createIADeliveryRecords(fiaAssessmentMap, messages);

        System.assertEquals(1, iaDeliveryRecords.size(), 'Expected 1 new IA delivery records to be created.');
    }

    @IsTest
    static void testUpsertIADeliveryRecords() {
        List<KafkaMessage__c> messages = [SELECT CRM_Topic__c, CRM_Value__c, CRM_Key__c FROM KafkaMessage__c];
        List<IaCase__c> iaCases = [SELECT id FROM IaCase__c WHERE Name = :CASE_NAME_1];

        IADelivery__c iad1 = new IADelivery__c();
        iad1.Name = KEY_1;
        iad1.IACase__c = iaCases[0].id;
        iad1.CompletedDate__c = Datetime.newInstance(2022, 2, 18, 7, 7, 7);
        iad1.KafkaId__c = KEY_1;
        iad1.KafkaHash__c = messages[0].CRM_Value__c;

        IADelivery__c iad2 = new IADelivery__c();
        iad2.Name = KEY_2;
        iad2.KafkaId__c = null;

        FiaAssessmentHandler handler = new FiaAssessmentHandler();
        handler.upsertIADeliveryRecords(new List<IADelivery__c>{ iad1, iad2 }, messages);

        List<IADelivery__c> iaDelivery = [
            SELECT
                Id,
                Name,
                IACase__c,
                Module__c,
                IAService__c,
                Status__c,
                CompletedDate__c,
                KafkaId__c,
                KafkaHash__c,
                JsonPayload__c
            FROM IADelivery__c
        ];

        System.assertEquals(1, iaDelivery.size(), 'Expected 1 IA delivery record to be created.');
    }
}
