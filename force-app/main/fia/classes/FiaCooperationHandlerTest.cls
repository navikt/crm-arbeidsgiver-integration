@isTest
private class FiaCooperationHandlerTest {
    private static final String TOPIC = 'pia.temp-topic';
    private static final String TEST_CASE_NUMBER_1 = 'X6mPvf2qYP7r42I';
    private static final String ORG_NR = '987654001';
    private static final String JSON =
        '{' +
        '    "orgnr": "987654001",' +
        '    "saksnummer": "X6mPvf2qYP7r42I",' +
        '    "samarbeid": {' +
        '        "id": 12345678,' +
        '        "navn": "FYSIO-avdeling",' +
        '        "status": "AKTIV",' +
        '        "endretTidspunkt": "2024-09-20T11:37:35.150172",' +
        '        "startDato": "2024-09-01",' +
        '        "sluttDato": "2024-12-01"' +
        '    },' +
        '    "plan": {' +
        '        "id": "9220e758-d84c-4d33-8375-c0e55b4b0f49",' +
        '        "sistEndret": "2024-09-20T11:37:35.150172",' +
        '        "sistPublisert": null,' +
        '        "temaer": [' +
        '            {' +
        '                "id": 175,' +
        '                "navn": "Partssamarbeid",' +
        '                "inkludert": true,' +
        '                "undertemaer": [' +
        '                    {' +
        '                        "id": 628,' +
        '                        "navn": "Utvikle partssamarbeidet",' +
        '                        "målsetning": "Styrke og strukturere samarbeidet mellom leder, tillitsvalgt og verneombud, samt øke kunnskap og ferdigheter for å jobbe systematisk og forebyggende med sykefravær og arbeidsmiljø.",' +
        '                        "inkludert": true,' +
        '                        "status": "PÅGÅR",' +
        '                        "startDato": "2024-09-01",' +
        '                        "sluttDato": "2024-12-01"' +
        '                    }' +
        '                ]' +
        '            },' +
        '            {' +
        '                "id": 176,' +
        '                "navn": "Sykefraværsarbeid",' +
        '                "inkludert": true,' +
        '                "undertemaer": [' +
        '                    {' +
        '                        "id": 632,' +
        '                        "navn": "Sykefravær - enkeltsaker",' +
        '                        "målsetning": "Øke kompetanse og ferdigheter for hvordan man tar tak i, følger opp og løser enkeltsaker.",' +
        '                        "inkludert": false,' +
        '                        "status": null,' +
        '                        "startDato": null,' +
        '                        "sluttDato": null' +
        '                    },' +
        '                    {' +
        '                        "id": 629,' +
        '                        "navn": "Sykefraværsrutiner",' +
        '                        "målsetning": "Jobbe systematisk og forebyggende med sykefravær, samt forbedre rutiner og oppfølging av ansatte som er sykmeldte eller står i fare for å bli det.",' +
        '                        "inkludert": true,' +
        '                        "status": "PLANLAGT",' +
        '                        "startDato": "2024-09-20",' +
        '                        "sluttDato": "2024-10-20"' +
        '                    },' +
        '                    {' +
        '                        "id": 630,' +
        '                        "navn": "Oppfølgingssamtaler",' +
        '                        "målsetning": "Øke kompetanse og ferdigheter for hvordan man gjennomfører gode oppfølgingssamtaler, både gjennom teori og praksis.",' +
        '                        "inkludert": true,' +
        '                        "status": "PLANLAGT",' +
        '                        "startDato": "2024-09-01",' +
        '                        "sluttDato": "2024-12-01"' +
        '                    },' +
        '                    {' +
        '                        "id": 631,' +
        '                        "navn": "Tilretteleggings- og medvirkningsplikt",' +
        '                        "målsetning": "Utvikle rutiner og kultur for tilrettelegging og medvirkning, samt kartlegging av tilretteleggingsmuligheter på arbeidsplassen.",' +
        '                        "inkludert": false,' +
        '                        "status": null,' +
        '                        "startDato": null,' +
        '                        "sluttDato": null' +
        '                    }' +
        '                ]' +
        '            },' +
        '            {' +
        '                "id": 177,' +
        '                "navn": "Arbeidsmiljø",' +
        '                "inkludert": false,' +
        '                "undertemaer": [' +
        '                    {' +
        '                        "id": 636,' +
        '                        "navn": "Livsfaseorientert personalpolitikk",' +
        '                        "målsetning": "Utvikle kultur og personalpolitikk som ivaretar medarbeideres ulike behov, krav, begrensninger og muligheter i ulike livsfaser.",' +
        '                        "inkludert": false,' +
        '                        "status": null,' +
        '                        "startDato": null,' +
        '                        "sluttDato": null' +
        '                    },' +
        '                    {' +
        '                        "id": 637,' +
        '                        "navn": "Psykisk helse",' +
        '                        "målsetning": "Gi innsikt i hvordan psykiske utfordringer kan komme til uttrykk i arbeidshverdagen og øke ferdigheter for hvordan man møter medarbeidere med psykiske helseutfordringer.",' +
        '                        "inkludert": false,' +
        '                        "status": null,' +
        '                        "startDato": null,' +
        '                        "sluttDato": null' +
        '                    },' +
        '                    {' +
        '                        "id": 633,' +
        '                        "navn": "Utvikle arbeidsmiljøet",' +
        '                        "målsetning": "Øke anvendelse og kompetanse innen verktøy og bransjerettet kunnskap for å jobbe målrettet og kunnskapsbasert med eget arbeidsmiljø.",' +
        '                        "inkludert": false,' +
        '                        "status": null,' +
        '                        "startDato": null,' +
        '                        "sluttDato": null' +
        '                    },' +
        '                    {' +
        '                        "id": 634,' +
        '                        "navn": "Endring og omstilling",' +
        '                        "målsetning": "Øke kompetansen for hvordan man ivaretar arbeidsmiljø og forebygger sykefravær under endring og omstilling.",' +
        '                        "inkludert": false,' +
        '                        "status": null,' +
        '                        "startDato": null,' +
        '                        "sluttDato": null' +
        '                    },' +
        '                    {' +
        '                        "id": 635,' +
        '                        "navn": "Oppfølging av arbeidsmiljøundersøkelser",' +
        '                        "målsetning": "Øke ferdigheter og gi støtte til hvordan man kan jobbe med forhold på arbeidsplassen som belyses i egne arbeidsmiljøundersøkelser.",' +
        '                        "inkludert": false,' +
        '                        "status": null,' +
        '                        "startDato": null,' +
        '                        "sluttDato": null' +
        '                    },' +
        '                    {' +
        '                        "id": 638,' +
        '                        "navn": "HelseIArbeid",' +
        '                        "målsetning": "Øke kompetansen og få ansatte til å mestre jobb, selv med muskel/skjelett- og psykiske helseplager.",' +
        '                        "inkludert": false,' +
        '                        "status": null,' +
        '                        "startDato": null,' +
        '                        "sluttDato": null' +
        '                    }' +
        '                ]' +
        '            }' +
        '        ]' +
        '    }' +
        '}';

    @TestSetup
    static void setupTestData() {
        insert new List<Account>{ new Account(Name = 'Allsidig Produksjon AS', INT_OrganizationNumber__c = ORG_NR) };
        insert new List<IaCase__c>{
            new IaCase__c(Name = TEST_CASE_NUMBER_1, Account__r = new Account(INT_OrganizationNumber__c = ORG_NR))
        };
    }

    @IsTest
    static void should_Create_Records_When_Messages_Are_Processed() {
        List<KafkaMessage__c> messages = new List<KafkaMessage__c>{
            new KafkaMessage__c(
                CRM_Topic__c = TOPIC,
                CRM_Key__c = 'X6mPvf2qYP7r42I-12345678',
                CRM_Value__c = EncodingUtil.base64Encode(Blob.valueOf(JSON))
            )
        };

        Test.startTest();
        FiaCooperationHandler handler = new FiaCooperationHandler();
        handler.processMessages(messages);
        Test.stopTest();

        List<IACooperation__c> cooperationRecords = [
            SELECT
                CooperationId__c,
                Name,
                IACase__r.Name,
                Account__r.INT_OrganizationNumber__c,
                PlanId__c,
                (
                    SELECT Id, (SELECT Id FROM IA_Subthemes__r)
                    FROM IA_Themes__r
                    ORDER BY ThemeId__c
                )
            FROM IACooperation__c
            WHERE CooperationId__c = '12345678'
        ];

        IACooperation__c cooperationRecord = cooperationRecords[0];
        Assert.areEqual('12345678', cooperationRecord.CooperationId__c, 'Id on record should match.');
        Assert.areEqual('FYSIO-avdeling', cooperationRecord.Name, 'Name on record should match.');
        Assert.areEqual('9220e758-d84c-4d33-8375-c0e55b4b0f49', cooperationRecord.PlanId__c, 'Plan Id should match.');
        Assert.areEqual(TEST_CASE_NUMBER_1, cooperationRecord.IACase__r.Name, 'Should be related to test case.');
        Assert.areEqual(
            ORG_NR,
            cooperationRecord.Account__r.INT_OrganizationNumber__c,
            'Should be related to test account.'
        );
        Assert.areEqual(3, cooperationRecord.IA_Themes__r.size(), 'Should have 3 themes');
        Assert.areEqual(1, cooperationRecord.IA_Themes__r[0].IA_Subthemes__r.size(), 'Should have 1 subtheme');
        Assert.areEqual(2, cooperationRecord.IA_Themes__r[1].IA_Subthemes__r.size(), 'Should have 2 subthemes');
        Assert.areEqual(0, cooperationRecord.IA_Themes__r[2].IA_Subthemes__r.size(), 'Should have 0 subthemes');
    }

    @IsTest
    static void should_Handle_Multiple_Messages() {
        List<KafkaMessage__c> messages = new List<KafkaMessage__c>();
        // Mass generate records for bulk testing
        for (Integer i = 0; i < 20; i++) {
            String s = '1000' + i;
            messages.add(
                new KafkaMessage__c(
                    CRM_Topic__c = TOPIC,
                    CRM_Key__c = 'X6mPvf2qYP7r42I-' + s,
                    CRM_Value__c = EncodingUtil.base64Encode(
                        Blob.valueOf(
                            '{ "orgnr": "' +
                                ORG_NR +
                                '", ' +
                                '"saksnummer": "' +
                                TEST_CASE_NUMBER_1 +
                                '", ' +
                                '"samarbeid": { "id": ' +
                                s +
                                ', "navn": "Fysio", "status": "AKTIV" }, ' +
                                '"plan": { "id": "4963ebe2-90be-5b40-a821-3ad0abcfd570", ' +
                                '"sistEndret": "2024-09-17T10:17:59.054765", ' +
                                '"sistPublisert": null, ' +
                                '"temaer": [' +
                                '{ "id": ' +
                                s +
                                '01, "navn": "Sykefraværsarbeid", ' +
                                '"inkludert": true, "undertemaer": [ { "id": ' +
                                s +
                                '0101, ' +
                                '"navn": "Sykefraværsrutiner", ' +
                                '"målsetning": "Jobbe systematisk og forebyggende med sykefravær, samt forbedre rutiner og oppfølging av ansatte ' +
                                'som er sykmeldte eller står i fare for å bli det.", ' +
                                '"inkludert": true, "status": "PLANLAGT", "startDato": "2010-01-01", "sluttDato": "2025-02-02" } ' +
                                ' ] } ] } }'
                        )
                    )
                )
            );
        }

        Test.startTest();
        FiaCooperationHandler handler = new FiaCooperationHandler();
        handler.processMessages(messages);
        Test.stopTest();

        Assert.areEqual(
            20,
            [SELECT COUNT() FROM IACooperation__c WHERE CooperationId__c LIKE '1000%'],
            'Should have created 20 cooperation records'
        );
        Assert.areEqual(
            20,
            [SELECT COUNT() FROM IATheme__c WHERE IACooperation__r.CooperationId__c LIKE '1000%'],
            'Should have created 20 themes'
        );
        Assert.areEqual(
            20,
            [SELECT COUNT() FROM IA_Subtheme__c WHERE IA_CooperationTheme__r.CooperationId__c LIKE '1000%'],
            'Should have created 20 subthemes'
        );

        for (KafkaMessage__c k : messages) {
            Assert.areNotEqual(
                KafkaMessageService.STATUS_ERROR,
                k.CRM_Status__c,
                'Message should not have error status: ' + k
            );
        }
    }

    @IsTest
    static void should_Log_Error_If_IACase_Is_Missing_In_SF() {
        List<KafkaMessage__c> messages = new List<KafkaMessage__c>{
            new KafkaMessage__c(
                CRM_Topic__c = TOPIC,
                CRM_Key__c = 'X6mPvf2qYP7r42I-12345678',
                CRM_Value__c = EncodingUtil.base64Encode(Blob.valueOf(JSON))
            )
        };

        delete [SELECT Id FROM IaCase__c WHERE Name = :TEST_CASE_NUMBER_1];

        Test.startTest();
        FiaCooperationHandler handler = new FiaCooperationHandler();
        handler.processMessages(messages);
        Test.stopTest();

        Assert.areEqual(
            KafkaMessageService.STATUS_ERROR,
            messages[0].CRM_Status__c,
            'Message status should be updated to Error'
        );
    }

    @IsTest
    static void should_Log_Error_When_Processing_Corrupted_Message_Hash() {
        List<KafkaMessage__c> messages = new List<KafkaMessage__c>{
            new KafkaMessage__c(
                CRM_Topic__c = TOPIC,
                CRM_Key__c = 'X6mPvf2qYP7r42I-12345678',
                CRM_Value__c = 'bad data...'
            )
        };

        Test.startTest();
        FiaCooperationHandler handler = new FiaCooperationHandler();
        handler.processMessages(messages);
        Test.stopTest();

        Assert.areEqual(
            KafkaMessageService.STATUS_ERROR,
            messages[0].CRM_Status__c,
            'Message status should be updated to Error'
        );
    }

    @IsTest
    static void should_Log_Error_When_Upserting_Blank_Id() {
        List<KafkaMessage__c> messages = new List<KafkaMessage__c>{
            new KafkaMessage__c(
                CRM_Topic__c = TOPIC,
                CRM_Key__c = 'X6mPvf2qYP7r42I-12345678',
                CRM_Value__c = EncodingUtil.base64Encode(
                    Blob.valueOf(
                        '{ "orgnr": "' +
                            ORG_NR +
                            '", ' +
                            '"saksnummer": "' +
                            TEST_CASE_NUMBER_1 +
                            '", ' +
                            '"samarbeid": { "id": 999902, "navn": "Fysio", "status": "AKTIV" }, ' +
                            '"plan": { "id": "4963ebe2-90be-5b40-a821-3ad0abcfd570", ' +
                            '"sistEndret": "2024-09-17T10:17:59.054765", ' +
                            '"sistPublisert": "2024-09-18", ' +
                            '"temaer": [' +
                            '{ "id": null, "navn": "Sykefraværsarbeid", ' +
                            '"inkludert": true, "undertemaer": [ { "id": null, ' +
                            '"navn": "Sykefraværsrutiner", ' +
                            '"målsetning": "Jobbe systematisk og forebyggende med sykefravær, samt forbedre rutiner og oppfølging av ansatte ' +
                            'som er sykmeldte eller står i fare for å bli det.", ' +
                            '"inkludert": true, "status": "PLANLAGT", "startDato": "2010-01-01", "sluttDato": "2025-02-02" } ' +
                            ' ] } ] } }'
                    )
                )
            )
        };

        Test.startTest();
        FiaCooperationHandler handler = new FiaCooperationHandler();
        handler.processMessages(messages);
        Test.stopTest();

        Assert.areEqual(
            KafkaMessageService.STATUS_ERROR,
            messages[0].CRM_Status__c,
            'Message status should be updated to Error'
        );
    }

    @IsTest
    static void Should_Update_Included_Themes_On_IACooperation_When_Processing_Kafka_Message() {
        List<KafkaMessage__c> messages = new List<KafkaMessage__c>{
            new KafkaMessage__c(
                CRM_Topic__c = TOPIC,
                CRM_Key__c = 'X6mPvf2qYP7r42I-12345678',
                CRM_Value__c = EncodingUtil.base64Encode(Blob.valueOf(JSON))
            )
        };

        Test.startTest();
        FiaCooperationHandler handler = new FiaCooperationHandler();
        handler.processMessages(messages);
        Test.stopTest();

        IACooperation__c iaCooperation = [
            SELECT
                CooperationId__c,
                Name,
                IncludedArbeidsmiljo__c,
                IncludedPartssamarbeid__c,
                IncludedSykefravaersarbeid__c
            FROM IACooperation__c
            WHERE CooperationId__c = '12345678'
            LIMIT 1
        ];

        Assert.isTrue(iaCooperation.IncludedPartssamarbeid__c, 'Should be true since marked as not included in json');
        Assert.isTrue(iaCooperation.IncludedSykefravaersarbeid__c, 'Should be true since marked as included in json');
        Assert.isFalse(iaCooperation.IncludedArbeidsmiljo__c, 'Should be false since theme name not present in json');
    }

    @IsTest
    static void should_Process_Message_With_Newest_Content_When_Messages_Have_Same_Key() {
        List<KafkaMessage__c> messages = new List<KafkaMessage__c>{
            new KafkaMessage__c(
                CRM_Topic__c = 'new',
                CRM_Key__c = 'HOehxSbJ5WM',
                CRM_Value__c = EncodingUtil.base64Encode(
                    Blob.valueOf(
                        '{ "orgnr": "' +
                            ORG_NR +
                            '", ' +
                            '"saksnummer": "' +
                            TEST_CASE_NUMBER_1 +
                            '", ' +
                            '"samarbeid": { "id": 142, "navn": "Fysio", "status": "AKTIV" }, ' +
                            '"plan": { "id": "39555a36-797c-5285-bf80-012cedd35d77", ' +
                            '"sistEndret": "2024-09-17T10:17:58.054765", ' +
                            '"sistPublisert": null, ' +
                            '"temaer": [' +
                            '{ "id": 1421, "navn": "Sykefraværsarbeid", ' +
                            '"inkludert": false, "undertemaer": [ { "id": 14211, ' +
                            '"navn": "Sykefraværsrutiner", ' +
                            '"målsetning": "Jobbe systematisk og forebyggende med sykefravær, samt forbedre rutiner og oppfølging av ansatte ' +
                            'som er sykmeldte eller står i fare for å bli det.", ' +
                            '"inkludert": false, "status": null, "startDato": null, "sluttDato": null } ' +
                            ' ] } ] } }'
                    )
                )
            ),
            new KafkaMessage__c(
                CRM_Topic__c = 'old',
                CRM_Key__c = 'HOehxSbJ5WM',
                CRM_Value__c = EncodingUtil.base64Encode(
                    Blob.valueOf(
                        '{ "orgnr": "' +
                            ORG_NR +
                            '", ' +
                            '"saksnummer": "' +
                            TEST_CASE_NUMBER_1 +
                            '", ' +
                            '"samarbeid": { "id": 142, "navn": "Fysio", "status": "AKTIV" }, ' +
                            '"plan": { "id": "39555a36-797c-5285-bf80-012cedd35d77", ' +
                            '"sistEndret": "2024-09-17T10:17:57.054765", ' +
                            '"sistPublisert": null, ' +
                            '"temaer": [' +
                            '{ "id": 1421, "navn": "Sykefraværsarbeid", ' +
                            '"inkludert": false, "undertemaer": [ { "id": 14211, ' +
                            '"navn": "Sykefraværsrutiner", ' +
                            '"målsetning": "Jobbe systematisk og forebyggende med sykefravær, samt forbedre rutiner og oppfølging av ansatte ' +
                            'som er sykmeldte eller står i fare for å bli det.", ' +
                            '"inkludert": false, "status": null, "startDato": null, "sluttDato": null } ' +
                            ' ] } ] } }'
                    )
                )
            )
        };

        Test.startTest();
        FiaCooperationHandler handler = new FiaCooperationHandler();
        handler.processMessages(messages);
        Test.stopTest();

        Assert.areEqual(
            KafkaMessageService.STATUS_PROCESSED,
            messages[0].CRM_Status__c,
            'Message status should be updated to Processed'
        );
        Assert.areEqual(
            KafkaMessageService.STATUS_PROCESSED,
            messages[1].CRM_Status__c,
            'Message status should be updated to Processed'
        );

        List<IACooperation__c> cooperationRecords = [
            SELECT PlanLastModified__c
            FROM IACooperation__c
            WHERE KafkaId__c = 'HOehxSbJ5WM'
        ];

        Assert.areEqual(1, cooperationRecords.size(), 'Only one Ia Cooperation record should be created');
        Assert.areEqual(
            Datetime.newInstanceGMT(2024, 9, 17, 10, 17, 58),
            cooperationRecords[0].PlanLastModified__c,
            'Shoud match datetime 2024-09-17T10:17:58.054765'
        );
    }

    @IsTest
    static void failed_Status_Should_Only_Be_Set_On_Message_With_Most_Resent_Content() {
        List<KafkaMessage__c> messages = new List<KafkaMessage__c>{
            new KafkaMessage__c(
                CRM_Topic__c = 'new',
                CRM_Key__c = 'HOehxSbJ5WM',
                CRM_Value__c = EncodingUtil.base64Encode(
                    Blob.valueOf(
                        '{ "orgnr": "' +
                            ORG_NR +
                            '", ' +
                            '"saksnummer": "' +
                            TEST_CASE_NUMBER_1 +
                            '", ' +
                            '"samarbeid": { "id": 142, "navn": "Fysio", "status": "AKTIV" }, ' +
                            '"plan": { "id": "39555a36-797c-5285-bf80-012cedd35d77", ' +
                            '"sistEndret": "2024-09-17T10:17:58.054765", ' +
                            '"sistPublisert": null, ' +
                            '"temaer": [' +
                            '{ "id": 1421, "navn": "Sykefraværsarbeid", ' +
                            '"inkludert": false, "undertemaer": [ { "id": 14211, ' +
                            '"navn": "Sykefraværsrutiner", ' +
                            '"målsetning": "Jobbe systematisk og forebyggende med sykefravær, samt forbedre rutiner og oppfølging av ansatte ' +
                            'som er sykmeldte eller står i fare for å bli det.", ' +
                            '"inkludert": false, "status": null, "startDato": null, "sluttDato": null } ' +
                            ' ] } ] } }'
                    )
                )
            ),
            new KafkaMessage__c(
                CRM_Topic__c = 'old',
                CRM_Key__c = 'HOehxSbJ5WM',
                CRM_Value__c = EncodingUtil.base64Encode(
                    Blob.valueOf(
                        '{ "orgnr": "' +
                            ORG_NR +
                            '", ' +
                            '"saksnummer": "' +
                            TEST_CASE_NUMBER_1 +
                            '", ' +
                            '"samarbeid": { "id": 142, "navn": "Fysio", "status": "AKTIV" }, ' +
                            '"plan": { "id": "39555a36-797c-5285-bf80-012cedd35d77", ' +
                            '"sistEndret": "2024-09-17T10:17:57.054765", ' +
                            '"sistPublisert": null, ' +
                            '"temaer": [' +
                            '{ "id": 1421, "navn": "Sykefraværsarbeid", ' +
                            '"inkludert": false, "undertemaer": [ { "id": 14211, ' +
                            '"navn": "Sykefraværsrutiner", ' +
                            '"målsetning": "Jobbe systematisk og forebyggende med sykefravær, samt forbedre rutiner og oppfølging av ansatte ' +
                            'som er sykmeldte eller står i fare for å bli det.", ' +
                            '"inkludert": false, "status": null, "startDato": null, "sluttDato": null } ' +
                            ' ] } ] } }'
                    )
                )
            )
        };

        delete [SELECT Id FROM IaCase__c WHERE Name = :TEST_CASE_NUMBER_1];

        Test.startTest();
        FiaCooperationHandler handler = new FiaCooperationHandler();
        handler.processMessages(messages);
        Test.stopTest();

        KafkaMessage__c olderMessage;
        KafkaMessage__c newerMessage;
        if (messages[0].CRM_Topic__c == 'old') {
            olderMessage = messages[0];
            newerMessage = messages[1];
        } else {
            olderMessage = messages[1];
            newerMessage = messages[0];
        }
        Assert.areEqual(
            KafkaMessageService.STATUS_ERROR,
            newerMessage.CRM_Status__c,
            'The most recent message should be marked as failed'
        );
        Assert.areEqual(
            KafkaMessageService.STATUS_PROCESSED,
            olderMessage.CRM_Status__c,
            'The older message should be marked as processed'
        );

        List<IACooperation__c> cooperationRecords = [
            SELECT PlanLastModified__c
            FROM IACooperation__c
            WHERE kafkaId__c = 'HOehxSbJ5WM'
        ];

        Assert.areEqual(0, cooperationRecords.size(), 'No Ia Cooperation record should be created');
    }

    @IsTest
    static void should_Process_Message_With_Deleted_Plan() {
        List<KafkaMessage__c> messages = new List<KafkaMessage__c>{
            new KafkaMessage__c(
                CRM_Topic__c = 'test',
                CRM_Key__c = 'HOehxSbJ5WM-142',
                CRM_Value__c = EncodingUtil.base64Encode(
                    Blob.valueOf(
                        '{ "orgnr": "' +
                            ORG_NR +
                            '", ' +
                            '"saksnummer": "' +
                            TEST_CASE_NUMBER_1 +
                            '", ' +
                            '"samarbeid": { "id": 142, "navn": "Fysio", "status": "AKTIV", "endretTidspunkt": "2024-09-17T10:17:58.054765" }, ' +
                            '"plan": null' +
                            ' }'
                    )
                )
            )
        };

        Test.startTest();
        FiaCooperationHandler handler = new FiaCooperationHandler();
        handler.processMessages(messages);
        Test.stopTest();

        List<IACooperation__c> cooperationRecords = [
            SELECT
                PlanLastModified__c,
                CooperationId__c,
                Name,
                PlanId__c,
                KafkaId__c,
                IncludedArbeidsmiljo__c,
                IncludedPartssamarbeid__c,
                IncludedSykefravaersarbeid__c
            FROM IACooperation__c
            WHERE CooperationId__c = '142'
        ];

        Assert.areEqual(1, cooperationRecords.size(), 'One Ia Cooperation record should be created');
        Assert.areEqual('HOehxSbJ5WM-142', cooperationRecords[0].KafkaId__c, 'KafkaId should be set');
        Assert.areEqual(null, cooperationRecords[0].PlanId__c, 'Plan Id should be blank');
    }

    @IsTest
    static void should_Update_Cooperation_And_Plan() {
        List<KafkaMessage__c> messages = new List<KafkaMessage__c>{
            new KafkaMessage__c(
                CRM_Topic__c = 'test',
                CRM_Key__c = 'HOehxSbJ5WM',
                CRM_Value__c = EncodingUtil.base64Encode(
                    Blob.valueOf(
                        '{ "orgnr": "' +
                            ORG_NR +
                            '", ' +
                            '"saksnummer": "' +
                            TEST_CASE_NUMBER_1 +
                            '", ' +
                            '"samarbeid": { "id": 142, "navn": "Fysio", "status": "AKTIV", "endretTidspunkt": "2024-09-17T09:17:59.054765"} }'
                    )
                )
            ),
            new KafkaMessage__c(
                CRM_Topic__c = 'test',
                CRM_Key__c = 'HOehxSbJ5WM',
                CRM_Value__c = EncodingUtil.base64Encode(
                    Blob.valueOf(
                        '{ "orgnr": "' +
                            ORG_NR +
                            '", ' +
                            '"saksnummer": "' +
                            TEST_CASE_NUMBER_1 +
                            '", ' +
                            '"samarbeid": { "id": 142, "navn": "Fysio", "status": "AKTIV","endretTidspunkt": "2024-09-17T09:17:59.054765" }, ' +
                            '"plan": { "id": "39555a36-797c-5285-bf80-012cedd35d77", ' +
                            '"sistEndret": "2024-09-17T10:17:57.054765", ' +
                            '"sistPublisert": null, ' +
                            '"temaer": [' +
                            '{ "id": 1421, "navn": "Sykefraværsarbeid", ' +
                            '"inkludert": false, "undertemaer": [ { "id": 14211, ' +
                            '"navn": "Sykefraværsrutiner", ' +
                            '"målsetning": "Jobbe systematisk og forebyggende med sykefravær, samt forbedre rutiner og oppfølging av ansatte ' +
                            'som er sykmeldte eller står i fare for å bli det.", ' +
                            '"inkludert": false, "status": null, "startDato": null, "sluttDato": null } ' +
                            ' ] } ] } }'
                    )
                )
            ),
            new KafkaMessage__c(
                CRM_Topic__c = 'test',
                CRM_Key__c = 'HOehxSbJ5WM',
                CRM_Value__c = EncodingUtil.base64Encode(
                    Blob.valueOf(
                        '{ "orgnr": "' +
                            ORG_NR +
                            '", ' +
                            '"saksnummer": "' +
                            TEST_CASE_NUMBER_1 +
                            '", ' +
                            '"samarbeid": { "id": 142, "navn": "Fysio2", "status": "AKTIV", "endretTidspunkt": "2024-09-17T11:17:59.054765"} }'
                    )
                )
            )
        };

        Test.startTest();
        FiaCooperationHandler handler = new FiaCooperationHandler();
        handler.processMessages(messages);
        Test.stopTest();

        Assert.areEqual(
            KafkaMessageService.STATUS_PROCESSED,
            messages[0].CRM_Status__c,
            'Message status should be updated to Processed'
        );
        Assert.areEqual(
            KafkaMessageService.STATUS_PROCESSED,
            messages[1].CRM_Status__c,
            'Message status should be updated to Processed'
        );
        Assert.areEqual(
            KafkaMessageService.STATUS_PROCESSED,
            messages[2].CRM_Status__c,
            'Message status should be updated to Processed'
        );

        List<IACooperation__c> cooperationRecords = [
            SELECT
                CooperationId__c,
                Name,
                PlanId__c,
                (
                    SELECT Id, (SELECT Id FROM IA_Subthemes__r)
                    FROM IA_Themes__r
                    ORDER BY ThemeId__c
                )
            FROM IACooperation__c
            WHERE CooperationId__c = '142'
        ];

        Assert.areEqual(1, cooperationRecords.size(), 'Only one Ia Cooperation record should be created');
        Assert.areEqual(
            '39555a36-797c-5285-bf80-012cedd35d77',
            cooperationRecords[0].PlanId__c,
            'Plan Id should be updated'
        );
        Assert.areEqual('Fysio2', cooperationRecords[0].Name, 'Name should be updated');
    }
}
