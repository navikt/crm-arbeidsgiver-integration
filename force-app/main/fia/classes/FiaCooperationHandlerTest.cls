@isTest
private class FiaCooperationHandlerTest {
    // Status på samarbeid?

    private static final String JSON =
        '{ "orgnr": "987654321", ' +
        '"saksnummer": "01HNA9BAQFBN660D8TDCNV1R77", ' +
        '"samarbeid": { "id": 12345678, "navn": "Fysio", "status": "AKTIV" }, ' +
        '"plan": { "id": "c3e1ee3b-a9b4-420c-8ec8-def50e83d054", ' +
        '"sistEndret": "2024-09-17T10:17:59.054765", ' +
        '"sistPublisert": "2024-09-18", ' +
        '"temaer": [ { "id": 9847, "rekkefølge": 1, "navn": "Partssamarbeid", ' +
        '"planlagt": false, "undertemaer": [ { "id": 345, "rekkefølge": 1, ' +
        '"navn": "Utvikle partssamarbeidet", ' +
        '"målsetning": "Styrke og strukturere samarbeidet mellom leder, tillitsvalgt og verneombud, ' +
        'samt øke kunnskap og ferdigheter for å jobbe systematisk og forebyggende med sykefravær og arbeidsmiljø.", ' +
        '"planlagt": false, "status": null, "startDato": null, "sluttDato": null } ] }, ' +
        '{ "id": 6576, "rekkefølge": 2, "navn": "Sykefraværsarbeid", ' +
        '"planlagt": true, "undertemaer": [ { "id": 76576, "rekkefølge": 1, ' +
        '"navn": "Sykefraværsrutiner", ' +
        '"målsetning": "Jobbe systematisk og forebyggende med sykefravær, samt forbedre rutiner og oppfølging av ansatte ' +
        'som er sykmeldte eller står i fare for å bli det.", ' +
        '"planlagt": true, "status": "PLANLAGT", "startDato": "2010-01-01", "sluttDato": "2025-02-02" }, ' +
        '{ "id": 65765, "rekkefølge": 2, "navn": "Oppfølgingssamtaler", ' +
        '"målsetning": "Øke kompetanse og ferdigheter for hvordan man gjennomfører gode oppfølgingssamtaler, ' +
        'både gjennom teori og praksis.", ' +
        '"planlagt": true, "status": "PLANLAGT", "startDato": "2010-01-01", "sluttDato": "2025-02-02" } ] } ] } }';

    private static final String TOPIC = 'pia.temp-topic';
    private static final String TEST_CASE_NUMBER_1 = '01HNA9BAQFBN660D8TDCNV1R77';
    private static final String ORG_NR = '987654321';
    private static final String KEY_1 = '12345678';

    @TestSetup
    static void setupTestData() {
        insert new List<Account>{ new Account(Name = 'Allsidig Produksjon AS', INT_OrganizationNumber__c = ORG_NR) };

        Account accountReference = new Account(INT_OrganizationNumber__c = ORG_NR);
        insert new List<IaCase__c>{ new IaCase__c(Name = TEST_CASE_NUMBER_1, Account__r = accountReference) };

        List<KafkaMessage__c> testMessages = new List<KafkaMessage__c>();

        // Record with representative json
        testMessages.add(
            new KafkaMessage__c(
                CRM_Topic__c = TOPIC,
                CRM_Key__c = KEY_1,
                CRM_Value__c = EncodingUtil.base64Encode(Blob.valueOf(JSON))
            )
        );

        // Record with bad hash for verifying error handling
        testMessages.add(
            new KafkaMessage__c(CRM_Topic__c = TOPIC, CRM_Key__c = '999901', CRM_Value__c = 'bad data...')
        );

        //Record with missing ids for verifying error handling
        testMessages.add(
            new KafkaMessage__c(
                CRM_Topic__c = TOPIC,
                CRM_Key__c = '999902',
                CRM_Value__c = EncodingUtil.base64Encode(
                    Blob.valueOf(
                        '{ "orgnr": "987654321", ' +
                        '"saksnummer": "01HNA9BAQFBN660D8TDCNV1R77", ' +
                        '"samarbeid": { "id": 999902, "navn": "Fysio", "status": "AKTIV" }, ' +
                        '"plan": { "id": "4963ebe2-90be-5b40-a821-3ad0abcfd570", ' +
                        '"sistEndret": "2024-09-17T10:17:59.054765", ' +
                        '"sistPublisert": "2024-09-18", ' +
                        '"temaer": [' +
                        '{ "id": null, "rekkefølge": 1, "navn": "Sykefraværsarbeid", ' +
                        '"planlagt": true, "undertemaer": [ { "id": null, "rekkefølge": 1, ' +
                        '"navn": "Sykefraværsrutiner", ' +
                        '"målsetning": "Jobbe systematisk og forebyggende med sykefravær, samt forbedre rutiner og oppfølging av ansatte ' +
                        'som er sykmeldte eller står i fare for å bli det.", ' +
                        '"planlagt": true, "status": "PLANLAGT", "startDato": "2010-01-01", "sluttDato": "2025-02-02" } ' +
                        ' ] } ] } }'
                    )
                )
            )
        );

        // Mass generate records for bulk testing, CRM_Key__c prefix 1000..
        for (Integer i = 0; i < 20; i++) {
            String s = '1000' + i;
            testMessages.add(
                new KafkaMessage__c(
                    CRM_Topic__c = TOPIC,
                    CRM_Key__c = s,
                    CRM_Value__c = EncodingUtil.base64Encode(
                        Blob.valueOf(
                            '{ "orgnr": "987654321", ' +
                            '"saksnummer": "01HNA9BAQFBN660D8TDCNV1R77", ' +
                            '"samarbeid": { "id": ' +
                            s +
                            ', "navn": "Fysio", "status": "AKTIV" }, ' +
                            '"plan": { "id": "4963ebe2-90be-5b40-a821-3ad0abcfd570", ' +
                            '"sistEndret": "2024-09-17T10:17:59.054765", ' +
                            '"sistPublisert": "2024-09-18", ' +
                            '"temaer": [' +
                            '{ "id": ' +
                            s +
                            '01, "rekkefølge": 1, "navn": "Sykefraværsarbeid", ' +
                            '"planlagt": true, "undertemaer": [ { "id": ' +
                            s +
                            '0101, "rekkefølge": 1, ' +
                            '"navn": "Sykefraværsrutiner", ' +
                            '"målsetning": "Jobbe systematisk og forebyggende med sykefravær, samt forbedre rutiner og oppfølging av ansatte ' +
                            'som er sykmeldte eller står i fare for å bli det.", ' +
                            '"planlagt": true, "status": "PLANLAGT", "startDato": "2010-01-01", "sluttDato": "2025-02-02" } ' +
                            ' ] } ] } }'
                        )
                    )
                )
            );
        }

        insert testMessages;
    }

    @IsTest
    static void should_Create_Records_When_Messages_Are_Processed() {
        List<KafkaMessage__c> messages = [
            SELECT CRM_Topic__c, CRM_Value__c, CRM_Key__c
            FROM KafkaMessage__c
            WHERE CRM_Key__c = :KEY_1
        ];

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
                PlanLastModified__c,
                PlanLastPublished__c,
                (
                    SELECT
                        ThemeId__c,
                        Name,
                        IsPlanned__c,
                        Order__c,
                        (
                            SELECT
                                SubthemeId__c,
                                Name,
                                IsPlanned__c,
                                Order__c,
                                Goal__c,
                                StartDate__c,
                                EndDate__c,
                                Status__c,
                                IA_CooperationTheme__r.PlanId__c
                            FROM IA_Subthemes__r
                            ORDER BY Order__c
                        )
                    FROM IA_Themes__r
                    ORDER BY Order__c
                )
            FROM IACooperation__c
            WHERE CooperationId__c = :KEY_1
        ];

        IACooperation__c cooperationRecord = cooperationRecords[0];
        Assert.areEqual('12345678', cooperationRecord.CooperationId__c, 'Id on record should match.');
        Assert.areEqual('Fysio', cooperationRecord.Name, 'Name on record should match.');
        Assert.areEqual('c3e1ee3b-a9b4-420c-8ec8-def50e83d054', cooperationRecord.PlanId__c, 'Plan Id should match.');
        Assert.areEqual(TEST_CASE_NUMBER_1, cooperationRecord.IACase__r.Name, 'Should be related to test case.');
        Assert.areEqual(
            ORG_NR,
            cooperationRecord.Account__r.INT_OrganizationNumber__c,
            'Should be related to test account.'
        );
        Assert.areEqual(
            Datetime.newInstanceGMT(2024, 9, 17, 10, 17, 59),
            cooperationRecord.PlanLastModified__c,
            'Shoud match datetime 2024-09-17T10:17:59.054765'
        );
        Assert.areEqual(
            Date.newInstance(2024, 9, 18),
            cooperationRecord.PlanLastPublished__c,
            'Shoud match date 2024-09-18'
        );
        Assert.areEqual(2, cooperationRecord.IA_Themes__r.size(), 'Should have 2 themes');

        IATheme__c theme1 = cooperationRecord.IA_Themes__r[0];
        IATheme__c theme2 = cooperationRecord.IA_Themes__r[1];
        Assert.areEqual('9847', theme1.ThemeId__c, 'Field should match value from json');
        Assert.areEqual('6576', theme2.ThemeId__c, 'Field should match value from json');
        Assert.areEqual(1, theme1.IA_Subthemes__r.size(), 'Should have 1 subtheme');
        Assert.areEqual(2, theme2.IA_Subthemes__r.size(), 'Should have 2 subthemes');

        IA_Subtheme__c theme1Subtheme1 = theme1.IA_Subthemes__r[0];
        IA_Subtheme__c theme2Subtheme1 = theme2.IA_Subthemes__r[0];
        IA_Subtheme__c theme2Subtheme2 = theme2.IA_Subthemes__r[1];
        Assert.areEqual('345', theme1Subtheme1.SubthemeId__c, 'Field should match value from json');
        Assert.areEqual('76576', theme2Subtheme1.SubthemeId__c, 'Field should match value from json');
        Assert.areEqual('65765', theme2Subtheme2.SubthemeId__c, 'Field should match value from json');
        Assert.areEqual(
            'c3e1ee3b-a9b4-420c-8ec8-def50e83d054',
            theme1Subtheme1.IA_CooperationTheme__r.PlanId__c,
            'Lookupfield should be set'
        );
        Assert.areEqual(
            'c3e1ee3b-a9b4-420c-8ec8-def50e83d054',
            theme2Subtheme1.IA_CooperationTheme__r.PlanId__c,
            'Lookupfield should be set'
        );
        Assert.areEqual(
            'c3e1ee3b-a9b4-420c-8ec8-def50e83d054',
            theme2Subtheme2.IA_CooperationTheme__r.PlanId__c,
            'Lookupfield should be set'
        );
    }

    @IsTest
    static void should_Handle_Multiple_Messages() {
        List<KafkaMessage__c> messages = [
            SELECT CRM_Topic__c, CRM_Value__c, CRM_Key__c
            FROM KafkaMessage__c
            WHERE CRM_Key__c LIKE '1000%'
        ];

        System.debug(messages.size());
        Test.startTest();
        FiaCooperationHandler handler = new FiaCooperationHandler();
        handler.processMessages(messages);
        System.debug(handler);
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
        List<KafkaMessage__c> messages = [
            SELECT CRM_Topic__c, CRM_Value__c, CRM_Key__c
            FROM KafkaMessage__c
            WHERE CRM_Key__c = :KEY_1
        ];

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
        List<KafkaMessage__c> messages = [
            SELECT CRM_Topic__c, CRM_Value__c, CRM_Key__c
            FROM KafkaMessage__c
            WHERE CRM_Key__c LIKE '999901'
        ];

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
        List<KafkaMessage__c> messages = [
            SELECT CRM_Topic__c, CRM_Value__c, CRM_Key__c
            FROM KafkaMessage__c
            WHERE CRM_Key__c LIKE '999902'
        ];

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
}
