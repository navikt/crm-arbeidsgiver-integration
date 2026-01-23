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
                CRM_Key__c = '2c4c1a34-7e86-49de-8144-f7c5f48ce31a6',
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
                CRM_Key__c = '983c6763-0908-5955-ace8-14b581cfc714',
                CRM_Value__c = EncodingUtil.base64Encode(
                    Blob.valueOf(
                        '{"aktørId": "2171954836936", "utfall": null, "navIdent": null, "navKontor": null, "kandidatlisteId": null, "stillingsId": null, "tidspunkt": null, "stillingskategori": null}'
                    )
                )
            )
        );

        //Message with corrupted hash
        testMessages.add(
            new KafkaMessage__c(
                CRM_Topic__c = topic,
                CRM_Key__c = 'cb6ae4ef-ef53-5f3b-9c7e-2bda786d28b7',
                CRM_Value__c = 'corrupted'
            )
        );

        //Message with updates to existing record
        testMessages.add(
            new KafkaMessage__c(
                CRM_Topic__c = topic,
                CRM_Key__c = 'd1f2b3cc-0c41-59bb-982e-ca868c4d8d80',
                CRM_Value__c = EncodingUtil.base64Encode(
                    Blob.valueOf(
                        '{"aktørId": "2171954836936", "utfall": "FATT_JOBBEN", "navIdent": "Z990248", "navKontor": "0219", "kandidatlisteId": "880e8678-3e04-4a3c-a81a-37fe25998ebf", "stillingsId": "016a90-75ad-4a39-8fb4-c65e4ed3c6689b", "tidspunkt": "2026-01-20T08:48:52.988", "stillingskategori": "FORMIDLING"}'
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

        insert new NavUnit__c(Name = 'Nav Unit 1', INT_UnitNumber__c = '0219');
        insert new NavUnit__c(Name = 'Nav Unit 2', INT_UnitNumber__c = '0220');
        insert testMessages;
    }
}