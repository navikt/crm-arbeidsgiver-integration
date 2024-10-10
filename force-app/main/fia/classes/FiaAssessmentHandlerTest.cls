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

    private static final String ORG_NR = '987654001';

    @TestSetup
    static void setupTestData() {
        IACase__c caseReference1 = new IACase__c(Name = CASE_NAME_1);
        IACase__c caseReference2 = new IACase__c(Name = CASE_NAME_2);
        Account accountReference = new Account(INT_OrganizationNumber__c = ORG_NR);

        List<KafkaMessage__c> testMessages = new List<KafkaMessage__c>();

        //Record in old format (without prosessId)
        testMessages.add(
            new KafkaMessage__c(
                CRM_Topic__c = TOPIC,
                CRM_Key__c = '2c4c1a34-7e86-49de-8144-f7c5f48ce31a',
                CRM_Value__c = EncodingUtil.base64Encode(
                    Blob.valueOf(
                        '{"behovsvurderingId":"2c4c1a34-7e86-49de-8144-f7c5f48ce31a","saksnummer":"01H40FRVDM11FD1C8Z43BW1YDQ","fullførtTidspunkt":"2024-10-09T20:31:54.220825"}'
                    )
                )
            )
        );

        //Record in new format (with prosessId)
        testMessages.add(
            new KafkaMessage__c(
                CRM_Topic__c = TOPIC,
                CRM_Key__c = '9eeb344c-13bd-5e2f-869e-b99f77d6f898',
                CRM_Value__c = EncodingUtil.base64Encode(
                    Blob.valueOf(
                        '{"behovsvurderingId":"9eeb344c-13bd-5e2f-869e-b99f77d6f898","saksnummer":"01H40FRVDM11FD1C8Z43BW1YDQ","prosessId":"253","fullførtTidspunkt":"2024-10-09T20:31:54.220825"}'
                    )
                )
            )
        );

        //Record with no IA Case or IA Cooperationin SF
        testMessages.add(
            new KafkaMessage__c(
                CRM_Topic__c = TOPIC,
                CRM_Key__c = '983c6763-0908-5955-ace8-14b581cfc714',
                CRM_Value__c = EncodingUtil.base64Encode(
                    Blob.valueOf(
                        '{"behovsvurderingId":"983c6763-0908-5955-ace8-14b581cfc714","saksnummer":"yohoho","prosessId":"hmhmhm","fullførtTidspunkt":"2024-10-09T20:31:54.220825"}'
                    )
                )
            )
        );

        //Record with corrupted hash
        testMessages.add(
            new KafkaMessage__c(
                CRM_Topic__c = TOPIC,
                CRM_Key__c = 'cb6ae4ef-ef53-5f3b-9c7e-2bda786d28b7',
                CRM_Value__c = 'corrupted'
            )
        );

        // Mass generate records for bulk testing
        for (Integer i = 0; i < 20; i++) {
            String s = 'test' + i;
            testMessages.add(
                new KafkaMessage__c(
                    CRM_Topic__c = TOPIC,
                    CRM_Key__c = s,
                    CRM_Value__c = EncodingUtil.base64Encode(
                        Blob.valueOf(
                            '{"behovsvurderingId":"' +
                            s +
                            '","saksnummer":"01H40FRVDM11FD1C8Z43BW1YDQ","fullførtTidspunkt":"2024-10-09T20:31:54.220825"}'
                        )
                    )
                )
            );
        }

        insert new List<Account>{ new Account(Name = 'Allsidig Produksjon AS', INT_OrganizationNumber__c = ORG_NR) };
        insert new List<IaCase__c>{
            new IaCase__c(Name = CASE_NAME_1, Account__r = new Account(INT_OrganizationNumber__c = ORG_NR)),
            new IaCase__c(Name = CASE_NAME_2, Account__r = new Account(INT_OrganizationNumber__c = ORG_NR))
        };

        insert new List<IACooperation__c>{
            new IACooperation__c(
                CooperationId__c = '55',
                Name = 'mysterious',
                Status__c = 'AKTIV',
                IACase__r = caseReference1,
                Account__r = accountReference
            ),
            new IACooperation__c(
                CooperationId__c = '19',
                Name = 'trade',
                Status__c = 'PLANLAGT',
                IACase__r = caseReference1,
                Account__r = accountReference
            )
        };

        insert testMessages;
    }

    @IsTest
    static void Should_Create_New_Assessment_When_Processed() {
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
    static void Should_Fail_If_No_Related_IA_Record_In_SF() {
    }

    @IsTest
    static void Should_Relate_To_IA_Records_In_SF() {
    }

    @IsTest
    static void should_Log_Error_When_Processing_Corrupted_Message_Hash() {
    }

    @IsTest
    static void should_Handle_Multiple_Messages() {
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
    static void Should_Catch_Errors_During_Upsert() {
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
