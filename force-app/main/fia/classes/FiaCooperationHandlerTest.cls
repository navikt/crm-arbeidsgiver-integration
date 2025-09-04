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
        insert new List<Account>{
            new Account(Name = 'Allsidig Produksjon AS', INT_OrganizationNumber__c = '987654001')
        };
        insert new List<IaCase__c>{
            new IaCase__c(Name = 'X6mPvf2qYP7r42I', Account__r = new Account(INT_OrganizationNumber__c = '987654001'))
        };

        insert new List<IACooperation__c>{
            new IACooperation__c(
                Name = 'Existing Cooperation',
                CooperationId__c = '500',
                status__c = 'AKTIV',
                PlanId__c = 'Existing Plan',
                planstatus__c = 'AKTIV'
            )
        };
        insert new List<IATheme__c>{
            new IATheme__c(
                Name = 'Existing Theme',
                ThemeId__c = '500',
                IsPlanned__c = true,
                IACooperation__r = new IACooperation__c(CooperationId__c = '500')
            )
        };
        insert new List<IA_Subtheme__c>{
            new IA_Subtheme__c(
                Name = 'Existing Subtheme',
                SubthemeId__c = '500',
                Status__c = 'PLANLAGT',
                IsPlanned__c = true,
                IATheme__r = new IATheme__c(ThemeId__c = '500'),
                IA_CooperationTheme__r = new IACooperation__c(CooperationId__c = '500')
            )
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
        Assert.areEqual(6, cooperationRecord.IA_Themes__r[2].IA_Subthemes__r.size(), 'Should have 6 subthemes');
        //Assert.areEqual(0, cooperationRecord.IA_Themes__r[2].IA_Subthemes__r.size(), 'Should have 0 subthemes');

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
    static void should_handle_deleted_plans() {
        List<KafkaMessage__c> messages = new List<KafkaMessage__c>{
            new KafkaMessage__c(
                CRM_Topic__c = 'test',
                CRM_Key__c = 'X6mPvf2qYP7r42I-500-ExistingPlan',
                CRM_Value__c = EncodingUtil.base64Encode(
                    Blob.valueOf(
                        '{' +
                            '    "orgnr": "987654001",' +
                            '    "saksnummer": "X6mPvf2qYP7r42I",' +
                            '    "samarbeid": {' +
                            '        "id": 500,' +
                            '        "navn": "Existing Cooperation",' +
                            '        "status": "AKTIV",' +
                            '        "endretTidspunkt": "2024-09-16T11:20:10.000000",' +
                            '        "startDato": "2024-09-01",' +
                            '        "sluttDato": "2024-12-01"' +
                            '    },' +
                            '    "plan": {' +
                            '        "id": "Existing Plan",' +
                            '        "sistEndret": "2024-09-16T11:30:10.000000",' +
                            '        "status": "SLETTET",' +
                            '        "temaer": [{"id": 500, "navn": "Existing Theme", "inkludert": true, "undertemaer": [ {' +
                            '                        "id": 500, "navn": "Existing Subtheme", "inkludert": true, "status": "PLANLAGT" }]' +
                            '          }]' +
                            '   }' +
                            '}'
                    )
                )
            ),
            new KafkaMessage__c(
                CRM_Topic__c = 'test',
                CRM_Key__c = 'X6mPvf2qYP7r42I-500-NewPlan',
                CRM_Value__c = EncodingUtil.base64Encode(
                    Blob.valueOf(
                        '{' +
                            '    "orgnr": "987654001",' +
                            '    "saksnummer": "X6mPvf2qYP7r42I",' +
                            '    "samarbeid": {' +
                            '        "id": 500,' +
                            '        "navn": "Existing Cooperation",' +
                            '        "status": "AKTIV",' +
                            '        "endretTidspunkt": "2024-09-16T11:20:10.000000",' +
                            '        "startDato": "2024-09-01",' +
                            '        "sluttDato": "2024-12-01"' +
                            '    },' +
                            '    "plan": {' +
                            '        "id": "New Plan",' +
                            '        "sistEndret":  "2024-09-16T11:30:20.000000",' +
                            '        "status": "AKTIV",' +
                            '        "temaer": [{"id": 600, "navn": "New Theme", "inkludert": true, "undertemaer": [ {' +
                            '                        "id": 600, "navn": "New Subtheme", "inkludert": true, "status": "PLANLAGT" }]' +
                            '          }]' +
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

        List<IACooperation__c> cooperationRecords = [
            SELECT
                planstatus__c,
                PlanId__c,
                (
                    SELECT Id, ThemeId__c, (SELECT Id, SubthemeId__c FROM IA_Subthemes__r)
                    FROM IA_Themes__r
                    ORDER BY ThemeId__c
                )
            FROM IACooperation__c
            WHERE CooperationId__c = '500'
        ];
        Assert.areEqual(1, cooperationRecords[0].IA_Themes__r.size(), 'Should only have 1 theme');
        Assert.areEqual(
            '600',
            cooperationRecords[0].IA_Themes__r[0].ThemeId__c,
            'Theme Id should be from the new plan'
        );
        Assert.areEqual(1, cooperationRecords[0].IA_Themes__r[0].IA_Subthemes__r.size(), 'Should only have 1 subtheme');
        Assert.areEqual(
            '600',
            cooperationRecords[0].IA_Themes__r[0].IA_Subthemes__r[0].SubthemeId__c,
            'Subtheme Id should be from the new plan'
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

    @IsTest
    static void should_handle_deleted_cooperation() {
        List<KafkaMessage__c> messages = new List<KafkaMessage__c>{
            new KafkaMessage__c(
                CRM_Topic__c = 'test',
                CRM_Key__c = 'X6mPvf2qYP7r42I-500',
                CRM_Value__c = EncodingUtil.base64Encode(
                    Blob.valueOf(
                        '{' +
                            '    "orgnr": "987654001",' +
                            '    "saksnummer": "X6mPvf2qYP7r42I",' +
                            '    "samarbeid": {' +
                            '        "id": 500,' +
                            '        "navn": "Existing Cooperation",' +
                            '        "status": "SLETTET",' +
                            '        "endretTidspunkt": "2024-09-16T11:20:10.000000"' +
                            '    }' +
                            '}'
                    )
                )
            ),
            new KafkaMessage__c(
                CRM_Topic__c = 'test',
                CRM_Key__c = 'X6mPvf2qYP7r42I-500-ExistingPlan',
                CRM_Value__c = EncodingUtil.base64Encode(
                    Blob.valueOf(
                        '{' +
                            '    "orgnr": "987654001",' +
                            '    "saksnummer": "X6mPvf2qYP7r42I",' +
                            '    "samarbeid": {' +
                            '        "id": 500,' +
                            '        "navn": "Existing Cooperation",' +
                            '        "status": "AKTIV",' +
                            '        "endretTidspunkt": "2024-09-16T11:10:00.000000",' +
                            '        "startDato": "2024-09-01",' +
                            '        "sluttDato": "2024-12-01"' +
                            '    },' +
                            '    "plan": {' +
                            '        "id": "Existing Plan",' +
                            '        "sistEndret":  "2024-09-16T11:30:20.000000",' +
                            '        "status": "SLETTET",' +
                            '        "temaer": [{"id": 500, "navn": "Existing Theme", "inkludert": true, "undertemaer": [ {' +
                            '                        "id": 500, "navn": "Existing Subtheme", "inkludert": true, "status": "PLANLAGT" }]' +
                            '          }]' +
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

        List<IACooperation__c> cooperationRecords = [
            SELECT
                planstatus__c,
                PlanId__c,
                (
                    SELECT Id, ThemeId__c, (SELECT Id, SubthemeId__c FROM IA_Subthemes__r)
                    FROM IA_Themes__r
                    ORDER BY ThemeId__c
                )
            FROM IACooperation__c
            WHERE CooperationId__c = '500'
        ];
        Assert.areEqual(0, cooperationRecords.size(), 'Cooperation should be deleted');
    }

    @IsTest
    static void testDeleteRecords() {
        // Arrange: Create test data
        List<IACooperation__c> recordsToDelete = new List<IACooperation__c>{
            new IACooperation__c(CooperationId__c = '1', Name = 'Test Cooperation 1'),
            new IACooperation__c(CooperationId__c = '2', Name = 'Test Cooperation 2')
        };
        insert recordsToDelete;

        // Verify records are inserted
        List<IACooperation__c> insertedRecords = [
            SELECT Id, CooperationId__c
            FROM IACooperation__c
            WHERE CooperationId__c IN ('1', '2')
        ];
        System.assertEquals(2, insertedRecords.size(), 'Records should be inserted before deletion.');

        // Act: Call the deleteRecords method
        Test.startTest();
        new FiaCooperationHandler().deleteRecords(insertedRecords);
        Test.stopTest();

        // Assert: Verify records are deleted
        List<IACooperation__c> deletedRecords = [SELECT Id FROM IACooperation__c WHERE CooperationId__c IN ('1', '2')];
        System.assertEquals(0, deletedRecords.size(), 'Records should be deleted.');
    }

    @isTest
    static void testIsNewerCooperation() {
        FiaCooperation existingCooperation = new FiaCooperation();
        FiaCooperation newCooperation = new FiaCooperation();

        newCooperation.samarbeid = new FiaCooperation.Samarbeid();
        newCooperation.samarbeid.endretTidspunkt = '2025-01-01T00:00:00.106545'; //Datetime.newInstance(2025, 1, 1, 0, 0, 0);
        Assert.isTrue(
            FiaCooperationHandler.isNewerCooperation(existingCooperation, newCooperation),
            'New cooperation should be considered newer if existing cooperation is null.'
        );

        existingCooperation.samarbeid = new FiaCooperation.Samarbeid();
        Assert.isTrue(
            FiaCooperationHandler.isNewerCooperation(existingCooperation, newCooperation),
            'New cooperation should be considered newer if existing cooperation endretTidspunkt is null.'
        );

        // Set newer date
        existingCooperation.samarbeid.endretTidspunkt = '2025-01-01T00:00:01.106545'; //Datetime.newInstance(2025, 1, 1, 0, 0, 1);
        Assert.isFalse(
            FiaCooperationHandler.isNewerCooperation(existingCooperation, newCooperation),
            'Existing cooperation date should be considered newer.'
        );

        newCooperation.samarbeid.endretTidspunkt = null;
        Assert.isFalse(
            FiaCooperationHandler.isNewerCooperation(existingCooperation, newCooperation),
            'Existing cooperation date should be considered newer when compared to null.'
        );
    }

    @isTest
    static void testIsNewerPlan() {
        FiaCooperation.Plan oldPlan = new FiaCooperation.Plan();
        oldPlan.sistEndret = '2023-01-01T00:00:00.106545'; //Datetime.newInstance(2023, 1, 1, 0, 0, 0);

        FiaCooperation.Plan newPlan = new FiaCooperation.Plan();
        newPlan.sistEndret = '2023-06-01T00:00:00.106545'; //Datetime.newInstance(2023, 6, 1, 0, 0, 0);

        Boolean result = FiaCooperationHandler.isNewerPlan(oldPlan, newPlan);
        System.assert(result, 'New plan should be considered newer.');
    }

    @isTest
    static void testCombineCooperationAndPlanMaps() {
        Map<String, FiaCooperation> cooperationMap = new Map<String, FiaCooperation>();
        Map<String, FiaCooperation.Plan> planMap = new Map<String, FiaCooperation.Plan>();

        FiaCooperation cooperation = new FiaCooperation();
        cooperation.samarbeid = new FiaCooperation.Samarbeid();
        cooperation.samarbeid.id = '1';

        FiaCooperation.Plan plan = new FiaCooperation.Plan();
        plan.sistEndret = '2023-06-01T00:00:00.106545'; // Datetime.newInstance(2023, 6, 1, 0, 0, 0);

        cooperationMap.put('1', cooperation);
        planMap.put('1', plan);

        Map<String, FiaCooperation> result = FiaCooperationHandler.combineCooperationAndPlanMaps(
            cooperationMap,
            planMap
        );
        System.assert(result.get('1').plan != null, 'Plan should be combined with cooperation.');
    }
}
