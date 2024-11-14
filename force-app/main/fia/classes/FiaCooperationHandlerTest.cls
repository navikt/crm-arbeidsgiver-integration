@isTest
private class FiaCooperationHandlerTest {
    private static final String TOPIC = 'pia.samarbeidsplan-v1';
    private static final String JSON =
        '{' +
        '    "orgnr": "987654001",' +
        '    "saksnummer": "X6mPvf2qYP7r42I",' +
        '    "samarbeid": {' +
        '        "id": 142,' +
        '        "navn": "FYSIO-avdeling",' +
        '        "status": "AKTIV",' +
        '        "endretTidspunkt": "2024-09-20T11:37:35.150172",' +
        '        "startDato": "2024-09-01",' +
        '        "sluttDato": "2024-12-01"' +
        '    },' +
        '    "plan": {' +
        '        "id": "9220e758-d84c-4d33-8375-c0e55b4b0f49",' +
        '        "sistEndret": "2024-09-20T11:37:35.150172",' +
        '        "sistPublisert": "2024-09-18",' +
        '        "status": "AKTIV",' +
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
        '                        "status": "SLETTET",' +
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
        insert new List<Account>{
            new Account(Name = 'Allsidig Produksjon AS', INT_OrganizationNumber__c = '987654001')
        };
        insert new List<IaCase__c>{
            new IaCase__c(Name = 'X6mPvf2qYP7r42I', Account__r = new Account(INT_OrganizationNumber__c = '987654001'))
        };
    }

    @IsTest
    static void should_Create_Records_When_Messages_Are_Processed() {
        List<KafkaMessage__c> messages = new List<KafkaMessage__c>{
            new KafkaMessage__c(
                CRM_Topic__c = TOPIC,
                CRM_Key__c = 'X6mPvf2qYP7r42I-142-9220e758-d84c-4d33-8375-c0e55b4b0f49',
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
                IncludedPartssamarbeid__c,
                IncludedSykefravaersarbeid__c,
                IncludedArbeidsmiljo__c,
                (
                    SELECT Id, (SELECT Id FROM IA_Subthemes__r)
                    FROM IA_Themes__r
                    ORDER BY ThemeId__c
                )
            FROM IACooperation__c
            WHERE CooperationId__c = '142'
        ];

        IACooperation__c cooperationRecord = cooperationRecords[0];
        Assert.areEqual('142', cooperationRecord.CooperationId__c, 'Id on record should match.');
        Assert.areEqual('FYSIO-avdeling', cooperationRecord.Name, 'Name on record should match.');
        Assert.areEqual('9220e758-d84c-4d33-8375-c0e55b4b0f49', cooperationRecord.PlanId__c, 'Plan Id should match.');
        Assert.areEqual('X6mPvf2qYP7r42I', cooperationRecord.IACase__r.Name, 'Should be related to test case.');
        Assert.areEqual(
            '987654001',
            cooperationRecord.Account__r.INT_OrganizationNumber__c,
            'Should be related to test account.'
        );
        Assert.areEqual(3, cooperationRecord.IA_Themes__r.size(), 'Should have 3 themes');
        Assert.areEqual(1, cooperationRecord.IA_Themes__r[0].IA_Subthemes__r.size(), 'Should have 1 subtheme');
        Assert.areEqual(4, cooperationRecord.IA_Themes__r[1].IA_Subthemes__r.size(), 'Should have 4 subthemes');
        //Assert.areEqual(2, cooperationRecord.IA_Themes__r[1].IA_Subthemes__r.size(), 'Should have 2 subthemes');
        Assert.areEqual(0, cooperationRecord.IA_Themes__r[2].IA_Subthemes__r.size(), 'Should have 0 subthemes');

        Assert.isTrue(
            cooperationRecord.IncludedPartssamarbeid__c,
            'Should be true since marked as not included in json'
        );
        Assert.isTrue(
            cooperationRecord.IncludedSykefravaersarbeid__c,
            'Should be true since marked as included in json'
        );
        Assert.isFalse(
            cooperationRecord.IncludedArbeidsmiljo__c,
            'Should be false since theme name not present in json'
        );
    }

    @IsTest
    static void should_Log_Error_If_IACase_Is_Missing_In_SF() {
        List<KafkaMessage__c> messages = new List<KafkaMessage__c>{
            new KafkaMessage__c(
                CRM_Topic__c = TOPIC,
                CRM_Key__c = 'anykey',
                CRM_Value__c = EncodingUtil.base64Encode(Blob.valueOf(JSON))
            )
        };

        delete [SELECT Id FROM IaCase__c WHERE Name = 'X6mPvf2qYP7r42I'];

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
    static void should_Log_Error_When_Parsing_Fail() {
        List<KafkaMessage__c> messages = new List<KafkaMessage__c>{
            new KafkaMessage__c(CRM_Topic__c = TOPIC, CRM_Key__c = 'anykey', CRM_Value__c = 'bad data...')
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
    static void should_Log_Error_When_Upsert_Fails() {
        List<KafkaMessage__c> messages = new List<KafkaMessage__c>{
            new KafkaMessage__c(
                CRM_Topic__c = TOPIC,
                CRM_Key__c = 'anykey',
                CRM_Value__c = EncodingUtil.base64Encode(
                    Blob.valueOf(
                        '{' +
                            '    "orgnr": "987654001",' +
                            '    "saksnummer": "X6mPvf2qYP7r42I",' +
                            '    "samarbeid": {' +
                            '        "id": 142,' +
                            '        "navn": "FYSIO-avdeling",' +
                            '        "status": "AKTIV",' +
                            '        "endretTidspunkt": "2024-09-20T11:37:35.150172",' +
                            '        "startDato": "2024-09-01",' +
                            '        "sluttDato": "2024-12-01"' +
                            '    },' +
                            '    "plan": {' +
                            '        "id": "9220e758-d84c-4d33-8375-c0e55b4b0f49",' +
                            '        "sistEndret": "2024-09-20T11:37:35.150172",' +
                            '        "sistPublisert": "2024-09-18",' +
                            '        "status": "AKTIV",' +
                            '        "temaer": [{"id": NULL, "navn": "Partssamarbeid", "inkludert": true} ]' +
                            '   }' +
                            '}'
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
    static void failed_Status_Should_Only_Be_Set_On_Message_With_Most_Resent_Content() {
        List<KafkaMessage__c> messages = new List<KafkaMessage__c>{
            new KafkaMessage__c(
                CRM_Topic__c = 'new',
                CRM_Key__c = 'X6mPvf2qYP7r42I-142-39555a36-797c-5285-bf80-012cedd35d77',
                CRM_Value__c = EncodingUtil.base64Encode(
                    Blob.valueOf(
                        '{' +
                            '    "orgnr": "987654001",' +
                            '    "saksnummer": "X6mPvf2qYP7r42I",' +
                            '    "samarbeid": {' +
                            '        "id": 142,' +
                            '        "navn": "Fysio",' +
                            '        "status": "AKTIV",' +
                            '        "endretTidspunkt": "2024-09-16T11:37:35.150172",' +
                            '        "startDato": "2024-09-01",' +
                            '        "sluttDato": "2024-12-01"' +
                            '    },' +
                            '    "plan": {' +
                            '        "id": "39555a36-797c-5285-bf80-012cedd35d77",' +
                            '        "sistEndret": "2024-09-17T10:17:58.054765",' +
                            '        "sistPublisert": "2024-09-18",' +
                            '        "status": "AKTIV",' +
                            '        "temaer": [{"id": 1421, "navn": "Partssamarbeid", "inkludert": true} ]' +
                            '   }' +
                            '}'
                    )
                )
            ),
            new KafkaMessage__c(
                CRM_Topic__c = 'old',
                CRM_Key__c = 'X6mPvf2qYP7r42I-142-39555a36-797c-5285-bf80-012cedd35d77',
                CRM_Value__c = EncodingUtil.base64Encode(
                    Blob.valueOf(
                        '{' +
                            '    "orgnr": "987654001",' +
                            '    "saksnummer": "X6mPvf2qYP7r42I",' +
                            '    "samarbeid": {' +
                            '        "id": 142,' +
                            '        "navn": "Fysio",' +
                            '        "status": "AKTIV",' +
                            '        "endretTidspunkt": "2024-09-16T11:37:35.150172",' +
                            '        "startDato": "2024-09-01",' +
                            '        "sluttDato": "2024-12-01"' +
                            '    },' +
                            '    "plan": {' +
                            '        "id": "39555a36-797c-5285-bf80-012cedd35d77",' +
                            '        "sistEndret": "2024-09-17T10:17:57.054765",' +
                            '        "sistPublisert": "2024-09-18",' +
                            '        "status": "AKTIV",' +
                            '        "temaer": [{"id": 1421, "navn": "Partssamarbeid", "inkludert": true} ]' +
                            '   }' +
                            '}'
                    )
                )
            )
        };

        delete [SELECT Id FROM IaCase__c WHERE Name = 'X6mPvf2qYP7r42I'];

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
    }

    @IsTest
    static void should_Use_Newest_Message_For_Update() {
        List<KafkaMessage__c> messages = new List<KafkaMessage__c>{
            new KafkaMessage__c(
                CRM_Topic__c = 'test',
                CRM_Key__c = 'X6mPvf2qYP7r42I-142',
                CRM_Value__c = EncodingUtil.base64Encode(
                    Blob.valueOf(
                        '{' +
                            '    "orgnr": "987654001",' +
                            '    "saksnummer": "X6mPvf2qYP7r42I",' +
                            '    "samarbeid": {' +
                            '        "id": 142,' +
                            '        "navn": "Test3",' +
                            '        "status": "AKTIV",' +
                            '        "endretTidspunkt": "2024-09-17T11:37:35.150172",' +
                            '        "startDato": "2024-09-01",' +
                            '        "sluttDato": "2024-12-01"' +
                            '    }' +
                            '}'
                    )
                )
            ),
            new KafkaMessage__c(
                CRM_Topic__c = 'test',
                CRM_Key__c = 'X6mPvf2qYP7r42I-142-39555a36-797c-5285-bf80-012cedd35d77',
                CRM_Value__c = EncodingUtil.base64Encode(
                    Blob.valueOf(
                        '{' +
                            '    "orgnr": "987654001",' +
                            '    "saksnummer": "X6mPvf2qYP7r42I",' +
                            '    "samarbeid": {' +
                            '        "id": 142,' +
                            '        "navn": "Test2",' +
                            '        "status": "AKTIV",' +
                            '        "endretTidspunkt": "2024-09-16T11:37:35.150172",' +
                            '        "startDato": "2024-09-01",' +
                            '        "sluttDato": "2024-12-01"' +
                            '    },' +
                            '    "plan": {' +
                            '        "id": "39555a36-797c-5285-bf80-012cedd35d77",' +
                            '        "sistEndret": "2024-09-22T11:37:35.150172",' +
                            '        "sistPublisert": "2024-09-18",' +
                            '        "status": "AKTIV",' +
                            '        "temaer": [{"id": 1421, "navn": "Partssamarbeid", "inkludert": true} ]' +
                            '   }' +
                            '}'
                    )
                )
            ),
            new KafkaMessage__c(
                CRM_Topic__c = 'test',
                CRM_Key__c = 'X6mPvf2qYP7r42I-142-39555a36-797c-5285-bf80-012cedd35d77',
                CRM_Value__c = EncodingUtil.base64Encode(
                    Blob.valueOf(
                        '{' +
                            '    "orgnr": "987654001",' +
                            '    "saksnummer": "X6mPvf2qYP7r42I",' +
                            '    "samarbeid": {' +
                            '        "id": 142,' +
                            '        "navn": "Test2",' +
                            '        "status": "AKTIV",' +
                            '        "endretTidspunkt": "2024-09-16T11:37:35.150172",' +
                            '        "startDato": "2024-09-01",' +
                            '        "sluttDato": "2024-12-01"' +
                            '    },' +
                            '    "plan": {' +
                            '        "id": "39555a36-797c-5285-bf80-012cedd35d77",' +
                            '        "sistEndret": "2024-09-20T11:37:35.150172",' +
                            '        "sistPublisert": "2024-09-18",' +
                            '        "status": "AKTIV",' +
                            '        "temaer": [{"id": 1333, "navn": "Partssamarbeid", "inkludert": false} ]' +
                            '   }' +
                            '}'
                    )
                )
            ),
            new KafkaMessage__c(
                CRM_Topic__c = 'test',
                CRM_Key__c = 'X6mPvf2qYP7r42I-142',
                CRM_Value__c = EncodingUtil.base64Encode(
                    Blob.valueOf(
                        '{' +
                            '    "orgnr": "987654001",' +
                            '    "saksnummer": "X6mPvf2qYP7r42I",' +
                            '    "samarbeid": {' +
                            '        "id": 142,' +
                            '        "navn": "Test1",' +
                            '        "status": "AKTIV",' +
                            '        "endretTidspunkt": "2024-09-15T11:37:35.150172",' +
                            '        "startDato": "2024-09-01",' +
                            '        "sluttDato": "2024-12-01"' +
                            '    }' +
                            '}'
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
        Assert.areEqual(
            KafkaMessageService.STATUS_PROCESSED,
            messages[3].CRM_Status__c,
            'Message status should be updated to Processed'
        );

        List<IACooperation__c> cooperationRecords = [
            SELECT
                CooperationId__c,
                Name,
                PlanId__c,
                (
                    SELECT ThemeId__c
                    FROM IA_Themes__r
                )
            FROM IACooperation__c
            WHERE CooperationId__c = '142'
        ];

        Assert.areEqual(1, cooperationRecords.size(), 'Only one Ia Cooperation record should be created');
        Assert.areEqual(
            '39555a36-797c-5285-bf80-012cedd35d77',
            cooperationRecords[0].PlanId__c,
            'Plan Id should be set from message'
        );
        Assert.areEqual(1, cooperationRecords[0].IA_Themes__r.size(), 'Should have created 1 theme');
        Assert.areEqual(
            '1421',
            cooperationRecords[0].IA_Themes__r[0].ThemeId__c,
            'Theme Id should match the most recent change'
        );
        Assert.areEqual(
            'Test3',
            cooperationRecords[0].Name,
            'Name should be set from samarbeid with most recent change date'
        );
    }

    @IsTest
    static void should_Handle_Various_Message_Formats() {
        List<KafkaMessage__c> messages = new List<KafkaMessage__c>{
            new KafkaMessage__c(
                CRM_Topic__c = 'test',
                CRM_Key__c = 'X6mPvf2qYP7r42I-100',
                CRM_Value__c = EncodingUtil.base64Encode(
                    Blob.valueOf(
                        '{' +
                            '    "orgnr": "987654001",' +
                            '    "saksnummer": "X6mPvf2qYP7r42I",' +
                            '    "samarbeid": {' +
                            '        "id": 100,' +
                            '        "navn": "Kun samarbeid",' +
                            '        "status": "AKTIV",' +
                            '        "endretTidspunkt": "2024-09-17T11:37:35.150172",' +
                            '        "startDato": "2024-09-01",' +
                            '        "sluttDato": "2024-12-01"' +
                            '    }' +
                            '}'
                    )
                )
            ),
            new KafkaMessage__c(
                CRM_Topic__c = 'test',
                CRM_Key__c = 'X6mPvf2qYP7r42I-200-39555a36-797c-5285-bf80-012cedd35d77',
                CRM_Value__c = EncodingUtil.base64Encode(
                    Blob.valueOf(
                        '{' +
                            '    "orgnr": "987654001",' +
                            '    "saksnummer": "X6mPvf2qYP7r42I",' +
                            '    "samarbeid": {' +
                            '        "id": 200,' +
                            '        "navn": "Samarbeid med tom plan",' +
                            '        "status": "AKTIV",' +
                            '        "endretTidspunkt": "2024-09-16T11:37:35.150172",' +
                            '        "startDato": "2024-09-01",' +
                            '        "sluttDato": "2024-12-01"' +
                            '    },' +
                            '    "plan": {' +
                            '        "id": "39555a36-797c-5285-bf80-012cedd35d77",' +
                            '        "sistEndret": "2024-09-22T11:37:35.150172",' +
                            '        "sistPublisert": "2024-09-18",' +
                            '        "status": "AKTIV"' +
                            '   }' +
                            '}'
                    )
                )
            ),
            new KafkaMessage__c(
                CRM_Topic__c = 'test',
                CRM_Key__c = 'X6mPvf2qYP7r42I-300-39555a36-797c-5285-bf80-012cedd35d77',
                CRM_Value__c = EncodingUtil.base64Encode(
                    Blob.valueOf(
                        '{' +
                            '    "orgnr": "987654001",' +
                            '    "saksnummer": "X6mPvf2qYP7r42I",' +
                            '    "samarbeid": {' +
                            '        "id": 300,' +
                            '        "navn": "Samarbeid med plan og tema",' +
                            '        "status": "AKTIV",' +
                            '        "endretTidspunkt": "2024-09-16T11:37:35.150172",' +
                            '        "startDato": "2024-09-01",' +
                            '        "sluttDato": "2024-12-01"' +
                            '    },' +
                            '    "plan": {' +
                            '        "id": "39555a36-797c-5285-bf80-012cedd35d77",' +
                            '        "sistEndret": "2024-09-22T11:37:35.150172",' +
                            '        "sistPublisert": "2024-09-18",' +
                            '        "status": "AKTIV",' +
                            '        "temaer": [{"id": 3003, "navn": "Partssamarbeid", "inkludert": true} ]' +
                            '   }' +
                            '}'
                    )
                )
            ),
            new KafkaMessage__c(
                CRM_Topic__c = 'test',
                CRM_Key__c = 'X6mPvf2qYP7r42I-400-39555a36-797c-5285-bf80-012cedd35d77',
                CRM_Value__c = EncodingUtil.base64Encode(
                    Blob.valueOf(
                        '{' +
                            '    "orgnr": "987654001",' +
                            '    "saksnummer": "X6mPvf2qYP7r42I",' +
                            '    "samarbeid": {' +
                            '        "id": 400' + //Kun plan
                            '    },' +
                            '    "plan": {' +
                            '        "id": "39555a36-797c-5285-bf80-012cedd35d77",' +
                            '        "sistEndret": "2024-09-22T11:37:35.150172",' +
                            '        "sistPublisert": "2024-09-18",' +
                            '        "status": "AKTIV",' +
                            '        "temaer": [{"id": 4004, "navn": "Partssamarbeid", "inkludert": true} ]' +
                            '   }' +
                            '}'
                    )
                )
            )
        };

        Test.startTest();
        FiaCooperationHandler handler = new FiaCooperationHandler();
        handler.processMessages(messages);
        Test.stopTest();

        List<IACooperation__c> cooperationRecords = [SELECT Id FROM IACooperation__c];

        Assert.areEqual(4, cooperationRecords.size(), '4 Ia Cooperation records should be created');
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
        Assert.areEqual(
            KafkaMessageService.STATUS_PROCESSED,
            messages[3].CRM_Status__c,
            'Message status should be updated to Processed'
        );
    }
}
