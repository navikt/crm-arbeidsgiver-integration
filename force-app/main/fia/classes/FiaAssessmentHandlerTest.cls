@IsTest
public with sharing class FiaAssessmentHandlerTest {
    @TestSetup
    static void setupTestData() {
        String topic = 'pia.fullfort-behovsvurdering-v1';
        String ORG_NR = '987654001';
        List<KafkaMessage__c> testMessages = new List<KafkaMessage__c>();

        //Record in old format (without prosessId)
        testMessages.add(
            new KafkaMessage__c(
                CRM_Topic__c = topic,
                CRM_Key__c = '2c4c1a34-7e86-49de-8144-f7c5f48ce31a',
                CRM_Value__c = EncodingUtil.base64Encode(
                    Blob.valueOf(
                        '{"behovsvurderingId":"2c4c1a34-7e86-49de-8144-f7c5f48ce31a","saksnummer":"GUrnf","fullførtTidspunkt":"2024-10-09T20:31:54.220825"}'
                    )
                )
            )
        );

        //Record in new format (with prosessId)
        testMessages.add(
            new KafkaMessage__c(
                CRM_Topic__c = topic,
                CRM_Key__c = '9eeb344c-13bd-5e2f-869e-b99f77d6f898',
                CRM_Value__c = EncodingUtil.base64Encode(
                    Blob.valueOf(
                        '{"behovsvurderingId":"9eeb344c-13bd-5e2f-869e-b99f77d6f898","saksnummer":"GUrnf","prosessId":"253","fullførtTidspunkt":"2024-10-09T20:31:54.220825"}'
                    )
                )
            )
        );

        //Record with no IA Case or IA Cooperationin SF
        testMessages.add(
            new KafkaMessage__c(
                CRM_Topic__c = topic,
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
                CRM_Topic__c = topic,
                CRM_Key__c = 'cb6ae4ef-ef53-5f3b-9c7e-2bda786d28b7',
                CRM_Value__c = 'corrupted'
            )
        );

        //Update to existing record
        testMessages.add(
            new KafkaMessage__c(
                CRM_Topic__c = topic,
                CRM_Key__c = 'd1f2b3cc-0c41-59bb-982e-ca868c4d8d80',
                CRM_Value__c = EncodingUtil.base64Encode(
                    Blob.valueOf(
                        '{"behovsvurderingId":"d1f2b3cc-0c41-59bb-982e-ca868c4d8d80","saksnummer":"GUrnf","prosessId":"253","fullførtTidspunkt":"2024-10-09T20:31:54.220825"}'
                    )
                )
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
                            '{"behovsvurderingId":"' +
                            s +
                            '","saksnummer":"GUrnf","prosessId":"253","fullførtTidspunkt":"2024-10-09T20:31:54.220825"}'
                        )
                    )
                )
            );
        }

        insert testMessages;
        insert new Account(Name = 'Allsidig Produksjon AS', INT_OrganizationNumber__c = ORG_NR);
        insert new List<IaCase__c>{
            new IaCase__c(Name = 'GUrnf', Account__r = new Account(INT_OrganizationNumber__c = ORG_NR)),
            new IaCase__c(Name = 'l8pYDNoLtPCKb', Account__r = new Account(INT_OrganizationNumber__c = ORG_NR))
        };
        insert new IACooperation__c(
            CooperationId__c = '253',
            Name = 'mysterious',
            Status__c = 'AKTIV',
            IACase__r = new IACase__c(Name = 'GUrnf'),
            Account__r = new Account(INT_OrganizationNumber__c = ORG_NR)
        );

        insert new IADelivery__c(
            Name = 'd1f2b3cc-0c41-59bb-982e-ca868c4d8d80',
            IACase__r = new IACase__c(Name = 'l8pYDNoLtPCKb'),
            KafkaId__c = 'd1f2b3cc-0c41-59bb-982e-ca868c4d8d80',
            KafkaHash__c = EncodingUtil.base64Encode(
                Blob.valueOf(
                    '{"behovsvurderingId":"d1f2b3cc-0c41-59bb-982e-ca868c4d8d80","saksnummer":"l8pYDNoLtPCKb","fullførtTidspunkt":"2024-10-09T20:31:54.220825"}'
                )
            )
        );
    }

    @IsTest
    static void Should_Create_Record_When_Processing_Old_Message_Format() {
        List<KafkaMessage__c> messages = [
            SELECT CRM_Topic__c, CRM_Value__c, CRM_Key__c
            FROM KafkaMessage__c
            WHERE CRM_Key__c = '2c4c1a34-7e86-49de-8144-f7c5f48ce31a'
        ];

        Test.startTest();
        FiaAssessmentHandler handler = new FiaAssessmentHandler();
        handler.processMessages(messages);
        Test.stopTest();

        List<IADelivery__c> iaDelivery = [
            SELECT Id, Name, IACase__c, IA_Cooperation__c, KafkaId__c, KafkaHash__c, Type__c, CompletedDate__c
            FROM IADelivery__c
            WHERE KafkaId__c = '2c4c1a34-7e86-49de-8144-f7c5f48ce31a'
        ];
        Assert.areEqual(1, iaDelivery.size(), 'Expected 1 IA delivery record to be created.');
        Assert.areEqual(messages[0].CRM_Key__c, iaDelivery[0].KafkaId__c, 'Expected KafkaId to match.');
        Assert.areEqual(messages[0].CRM_Value__c, iaDelivery[0].KafkaHash__c, 'Expected KafkaHash to match.');
        Assert.areEqual('Assessment', iaDelivery[0].Type__c, 'Expected type to be Assessment');
        Assert.areEqual(
            Datetime.newInstance(2024, 10, 9, 20, 31, 54),
            iaDelivery[0].CompletedDate__c,
            'Date should be set'
        );
        Assert.isNotNull(iaDelivery[0].IACase__c, 'Should be related to IA Case');
    }

    @IsTest
    static void Should_Create_Record_When_Processing_New_Message_Format() {
        List<KafkaMessage__c> messages = [
            SELECT CRM_Topic__c, CRM_Value__c, CRM_Key__c
            FROM KafkaMessage__c
            WHERE CRM_Key__c = '9eeb344c-13bd-5e2f-869e-b99f77d6f898'
        ];

        Test.startTest();
        FiaAssessmentHandler handler = new FiaAssessmentHandler();
        handler.processMessages(messages);
        Test.stopTest();

        List<IADelivery__c> iaDelivery = [
            SELECT Id, Name, IACase__c, IA_Cooperation__c, KafkaId__c, KafkaHash__c
            FROM IADelivery__c
            WHERE KafkaId__c = '9eeb344c-13bd-5e2f-869e-b99f77d6f898'
        ];
        Assert.areEqual(1, iaDelivery.size(), 'Expected 1 IA delivery record to be created.');
        Assert.isNotNull(iaDelivery[0].IACase__c, 'Record should be related to IA Case');
        Assert.isNotNull(iaDelivery[0].IA_Cooperation__c, 'Record should be related to IA Cooperation');
    }

    @IsTest
    static void Should_Update_Record() {
        List<IADelivery__c> iaDelivery = [
            SELECT Id, Name, IACase__r.Name, IA_Cooperation__c, KafkaId__c
            FROM IADelivery__c
            WHERE KafkaId__c = 'd1f2b3cc-0c41-59bb-982e-ca868c4d8d80'
        ];
        Assert.areEqual('l8pYDNoLtPCKb', iaDelivery[0].IACase__r.Name, 'Should be related to IA Case');
        Assert.isNull(iaDelivery[0].IA_Cooperation__c, 'Should not be related to an IA Cooperation');

        List<KafkaMessage__c> messages = [
            SELECT CRM_Topic__c, CRM_Value__c, CRM_Key__c
            FROM KafkaMessage__c
            WHERE CRM_Key__c = 'd1f2b3cc-0c41-59bb-982e-ca868c4d8d80'
        ];

        Test.startTest();
        FiaAssessmentHandler handler = new FiaAssessmentHandler();
        handler.processMessages(messages);
        Test.stopTest();

        iaDelivery = [
            SELECT Id, Name, IACase__r.Name, IA_Cooperation__r.CooperationId__c, KafkaId__c
            FROM IADelivery__c
            WHERE KafkaId__c = 'd1f2b3cc-0c41-59bb-982e-ca868c4d8d80'
        ];
        Assert.areEqual('GUrnf', iaDelivery[0].IACase__r.Name, 'Should be related to other IA Case');
        Assert.areEqual('253', iaDelivery[0].IA_Cooperation__r.CooperationId__c, 'Should be related to IA Cooperation');
    }

    @IsTest
    static void should_Handle_Multiple_Messages() {
        List<KafkaMessage__c> messages = [
            SELECT CRM_Topic__c, CRM_Value__c, CRM_Key__c
            FROM KafkaMessage__c
            WHERE CRM_Key__c LIKE 'TEST%'
        ];

        Test.startTest();
        FiaAssessmentHandler handler = new FiaAssessmentHandler();
        handler.processMessages(messages);
        Test.stopTest();

        List<IADelivery__c> iaDelivery = [
            SELECT Id, Name, IACase__c, KafkaId__c, KafkaHash__c
            FROM IADelivery__c
            WHERE KafkaId__c LIKE 'TEST%'
        ];

        System.assertEquals(20, iaDelivery.size(), 'Expected 20 IA delivery records to be created');
    }

    @IsTest
    static void Should_Fail_If_No_Related_IA_Record_In_SF() {
        List<KafkaMessage__c> messages = [
            SELECT CRM_Topic__c, CRM_Value__c, CRM_Key__c
            FROM KafkaMessage__c
            WHERE CRM_Key__c = '983c6763-0908-5955-ace8-14b581cfc714'
        ];

        Test.startTest();
        FiaAssessmentHandler handler = new FiaAssessmentHandler();
        handler.processMessages(messages);
        Test.stopTest();

        Assert.areEqual(
            0,
            [SELECT COUNT() FROM IADelivery__c WHERE KafkaId__c = '983c6763-0908-5955-ace8-14b581cfc714'],
            'Expected 0 IA delivery record to be created.'
        );
        Assert.areEqual(
            KafkaMessageService.STATUS_ERROR,
            messages[0].CRM_Status__c,
            'Kafka message should be marked as failed'
        );
    }

    @IsTest
    static void should_Catch_Error_When_Processing_Corrupted_Message_Hash() {
        List<KafkaMessage__c> messages = [
            SELECT CRM_Topic__c, CRM_Value__c, CRM_Key__c
            FROM KafkaMessage__c
            WHERE CRM_Key__c = 'cb6ae4ef-ef53-5f3b-9c7e-2bda786d28b7'
        ];

        Test.startTest();
        FiaAssessmentHandler handler = new FiaAssessmentHandler();
        handler.processMessages(messages);
        Test.stopTest();

        Assert.areEqual(
            0,
            [SELECT COUNT() FROM IADelivery__c WHERE KafkaId__c = 'cb6ae4ef-ef53-5f3b-9c7e-2bda786d28b7'],
            'Expected 0 IA delivery record to be created.'
        );
        Assert.areEqual(
            KafkaMessageService.STATUS_ERROR,
            messages[0].CRM_Status__c,
            'Kafka message should be marked as failed'
        );
    }

    @IsTest
    static void Should_Catch_Errors_During_Upsert() {
        List<KafkaMessage__c> messages = [
            SELECT CRM_Topic__c, CRM_Value__c, CRM_Key__c
            FROM KafkaMessage__c
            WHERE CRM_Key__c = '2c4c1a34-7e86-49de-8144-f7c5f48ce31a'
        ];
        //Record without KafkaId__c, which is used as key during upsert
        IADelivery__c iad1 = new IADelivery__c(
            Name = '2c4c1a34-7e86-49de-8144-f7c5f48ce31a',
            KafkaId__c = null,
            KafkaHash__c = messages[0].CRM_Value__c
        );

        Test.startTest();
        FiaAssessmentHandler handler = new FiaAssessmentHandler();
        handler.upsertIADeliveryRecords(new List<IADelivery__c>{ iad1 }, messages);
        Test.stopTest();

        Assert.areEqual(
            0,
            [SELECT COUNT() FROM IADelivery__c WHERE KafkaId__c = '2c4c1a34-7e86-49de-8144-f7c5f48ce31a'],
            'No record should be created'
        );
        Assert.areEqual(
            KafkaMessageService.STATUS_ERROR,
            messages[0].CRM_Status__c,
            'Kafka message should be marked as failed'
        );
    }
}
