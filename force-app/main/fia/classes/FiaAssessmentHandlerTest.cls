@IsTest
public with sharing class FiaAssessmentHandlerTest {
    private static final String TOPIC = 'pia.fullfort-behovsvurdering-v1';
    private static final String CASE_NAME_1 = 'QRAGANAjlM0qT';
    private static final String CASE_NAME_2 = 'l8pYDNoLtPCKb';
    private static final String KEY_1 = '4cce71a2-ffba-4d4a-865d-fca20b482598';
    private static final String KEY_2 = '50d477f7-fba2-53b4-a20a-b5fd50f28669';
    private static final String KEY_3 = 'd6433a6b-4e53-5432-a97a-7056a8410f34';
    private static final String KEY_4 = 'df04fc49-7374-59e9-9217-055604f0390b';
    private static final String KEY_5 = 'e910d6ff-5c0d-56fd-9a9d-f897c2484105';
    private static final String KEY_6 = '6b6df882-ff60-527b-92fb-6535d683fa4e';

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

    // Invalid date value
    private static final String JSON_BAD_DATA_1 =
        '{\n' +
        '   "behovsvurderingId": "' +
        KEY_4 +
        '",\n' +
        '   "saksnummer": "' +
        CASE_NAME_2 +
        '",\n' +
        '   "fullførtTidspunkt": "INVALID"\n' +
        '}';
    // Blank case value
    private static final String JSON_BAD_DATA_2 =
        '{\n' +
        '   "behovsvurderingId": "' +
        KEY_5 +
        '",\n' +
        '   "saksnummer": "",\n' +
        '   "fullførtTidspunkt": "2022-02-18T07:07:07.064711"\n' +
        '}';
    // Case value provided but does not exist
    private static final String JSON_BAD_DATA_3 =
        '{\n' +
        '   "behovsvurderingId": "' +
        KEY_6 +
        '",\n' +
        '   "saksnummer": "fvaU5xumsudoS",\n' +
        '   "fullførtTidspunkt": "2022-02-18T07:07:07.064711"\n' +
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
            ),
            new KafkaMessage__c(
                CRM_Topic__c = TOPIC,
                CRM_Key__c = KEY_5,
                CRM_Value__c = EncodingUtil.base64Encode(Blob.valueOf(JSON_BAD_DATA_2))
            ),
            new KafkaMessage__c(
                CRM_Topic__c = TOPIC,
                CRM_Key__c = KEY_6,
                CRM_Value__c = EncodingUtil.base64Encode(Blob.valueOf(JSON_BAD_DATA_3))
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
            SELECT Id, Name, IACase__c, KafkaId__c, KafkaHash__c, Type__c, CompletedDate__c
            FROM IADelivery__c
        ];

        System.assertEquals(1, iaDelivery.size(), 'Expected 1 IA delivery record to be created.');
        System.assertEquals(messages[0].CRM_Key__c, iaDelivery[0].KafkaId__c, 'Expected KafkaId to match.');
        System.assertEquals(messages[0].CRM_Value__c, iaDelivery[0].KafkaHash__c, 'Expected KafkaHash to match.');
        System.assertEquals('Assessment', iaDelivery[0].Type__c, 'Expected type to be Assessment');
        System.assertEquals(
            Datetime.newInstance(2022, 2, 18, 7, 7, 7),
            iaDelivery[0].CompletedDate__c,
            'Date should be set'
        );
        System.assert((iaDelivery[0].IACase__c != null), 'Should be related to IA Case');
    }

    @IsTest
    static void testProcessMultipleMessages() {
        List<KafkaMessage__c> messages = [SELECT CRM_Topic__c, CRM_Value__c, CRM_Key__c FROM KafkaMessage__c];

        Test.startTest();
        FiaAssessmentHandler handler = new FiaAssessmentHandler();
        handler.processMessages(messages);
        Test.stopTest();

        List<IADelivery__c> iaDelivery = [SELECT Id, Name, IACase__c, KafkaId__c, KafkaHash__c FROM IADelivery__c];
        Map<String, KafkaMessage__c> keyToKafkaMessageMap = new Map<String, KafkaMessage__c>();
        for (KafkaMessage__c kafkaMessage : messages) {
            keyToKafkaMessageMap.put(kafkaMessage.CRM_Key__c, kafkaMessage);
        }

        System.assertEquals(
            2,
            iaDelivery.size(),
            'Expected 2 IA delivery records to be created, the others should fail.'
        );
        System.assertNotEquals(
            'Error',
            keyToKafkaMessageMap.get(KEY_1).CRM_Status__c,
            'Message status should not be set as failed'
        );
        System.assertNotEquals(
            'Error',
            keyToKafkaMessageMap.get(KEY_2).CRM_Status__c,
            'Message status should not be set as failed'
        );
        System.assertEquals(
            'Error',
            keyToKafkaMessageMap.get(KEY_3).CRM_Status__c,
            'Message status should be set to Error'
        );
        System.assertEquals(
            'Error',
            keyToKafkaMessageMap.get(KEY_4).CRM_Status__c,
            'Message status should be set to Error'
        );
        System.assertEquals(
            'Error',
            keyToKafkaMessageMap.get(KEY_5).CRM_Status__c,
            'Message status should be set to Error'
        );
        System.assertEquals(
            'Error',
            keyToKafkaMessageMap.get(KEY_6).CRM_Status__c,
            'Message status should be set to Error'
        );
    }

    @IsTest
    static void testExceptionOnUpsertIADeliveryRecord() {
        List<KafkaMessage__c> messages = [SELECT CRM_Topic__c, CRM_Value__c, CRM_Key__c FROM KafkaMessage__c];
        List<IaCase__c> iaCases = [SELECT id FROM IaCase__c WHERE Name = :CASE_NAME_1];

        IADelivery__c iad1 = new IADelivery__c();
        iad1.Name = KEY_1;
        iad1.IACase__c = iaCases[0].id;
        iad1.CompletedDate__c = Datetime.newInstance(2022, 2, 18, 7, 7, 7);
        iad1.KafkaId__c = null;
        iad1.KafkaHash__c = messages[0].CRM_Value__c;

        FiaAssessmentHandler handler = new FiaAssessmentHandler();
        handler.upsertIADeliveryRecords(new List<IADelivery__c>{ iad1 }, messages);

        System.assertEquals('Error', messages[0].CRM_Status__c, 'Message status should be updated to Error');
    }
}
