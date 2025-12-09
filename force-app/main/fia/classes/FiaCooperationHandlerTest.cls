@isTest
private class FiaCooperationHandlerTest {
    private static final String TOPIC = 'pia.samarbeidsplan-v1';
    private static final String TEST_ACCOUNT_ORGNR = '987654001';
    private static final String TEST_IA_CASE_NAME = 'X6mPvf2qYP7r42I';
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
            new Account(Name = 'Allsidig Produksjon AS', INT_OrganizationNumber__c = TEST_ACCOUNT_ORGNR)
        };
        insert new List<IaCase__c>{
            new IaCase__c(
                Name = TEST_IA_CASE_NAME,
                Account__r = new Account(INT_OrganizationNumber__c = TEST_ACCOUNT_ORGNR)
            )
        };

        insert new List<IACooperation__c>{
            new IACooperation__c(
                Name = 'Existing Cooperation',
                CooperationId__c = '500',
                status__c = 'AKTIV',
                PlanId__c = 'plan-500',
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

    // ========================================
    // HELPER METHODS
    // ========================================

    /**
     * Helper method to create FiaCooperation object for unit tests
     */
    private static FiaCooperation createFiaCooperation(String id, String status) {
        return createFiaCooperation(id, status, null, null, null, null);
    }

    /**
     * Helper method to create FiaCooperation with full data
     */
    private static FiaCooperation createFiaCooperation(
        String id,
        String status,
        String name,
        Date startDate,
        Date endDate,
        String planId
    ) {
        FiaCooperation fc = new FiaCooperation();
        fc.orgnr = TEST_ACCOUNT_ORGNR;
        fc.saksnummer = TEST_IA_CASE_NAME;
        fc.key = 'test-key-' + id;
        fc.jsonPayload = 'test-payload-' + id;
        fc.hash = 'test-hash-' + id;

        fc.samarbeid = new FiaCooperation.Samarbeid();
        fc.samarbeid.id = id;
        fc.samarbeid.status = status;
        if (name != null)
            fc.samarbeid.navn = name;
        if (startDate != null)
            fc.samarbeid.startDato = startDate;
        if (endDate != null)
            fc.samarbeid.sluttDato = endDate;
        fc.samarbeid.endretTidspunkt = '2025-11-19T09:54:55.128822';
        fc.cooperationLastModified = Datetime.newInstance(2025, 11, 19, 9, 54, 55);

        if (planId != null) {
            fc.plan = new FiaCooperation.Plan();
            fc.plan.id = planId;
            fc.plan.status = 'AKTIV';
            fc.plan.sistEndret = '2025-11-19T13:14:37.702151';
            fc.planLastModified = Datetime.newInstance(2025, 11, 19, 13, 14, 37);
        }

        return fc;
    }

    /**
     * Helper method to create KafkaMessage__c with cooperation JSON
     */
    private static KafkaMessage__c createKafkaMessage(String cooperationId, String cooperationStatus) {
        String json = buildMinimalCooperationJson(cooperationId, cooperationStatus);
        return new KafkaMessage__c(
            CRM_Key__c = 'test-key-' + cooperationId + '-' + System.now().getTime(),
            CRM_Topic__c = TOPIC,
            CRM_Status__c = 'Pending',
            CRM_Value__c = EncodingUtil.base64Encode(Blob.valueOf(json))
        );
    }

    /**
     * Helper to build minimal cooperation JSON
     */
    private static String buildMinimalCooperationJson(String cooperationId, String status) {
        return '{"orgnr":"' +
            TEST_ACCOUNT_ORGNR +
            '",' +
            '"saksnummer":"' +
            TEST_IA_CASE_NAME +
            '",' +
            '"samarbeid":{"id":"' +
            cooperationId +
            '","navn":"Cooperation ' +
            cooperationId +
            '",' +
            '"status":"' +
            status +
            '","endretTidspunkt":"2025-11-19T09:54:55.128822"}}';
    }

    // ========================================
    // UNIT TESTS - Parsing
    // ========================================

    @isTest
    static void extractData_should_parse_valid_message_and_mark_as_processed() {
        // Arrange
        KafkaMessage__c message = createKafkaMessage('100', 'AKTIV');

        // Act
        Test.startTest();
        List<FiaCooperation> result = new FiaCooperationHandler().extractData(new List<KafkaMessage__c>{ message });
        Test.stopTest();

        // Assert
        Assert.areEqual(1, result.size(), 'Should parse one cooperation');
        Assert.areEqual('100', result[0].samarbeid.id, 'Should have correct cooperation ID');
        Assert.areEqual('AKTIV', result[0].samarbeid.status, 'Should have correct status');
        Assert.areEqual('Processed', message.CRM_Status__c, 'Message should be marked as processed');
    }

    @isTest
    static void extractData_should_handle_invalid_json_and_mark_as_error() {
        // Arrange
        KafkaMessage__c message = new KafkaMessage__c(
            CRM_Key__c = 'test-invalid',
            CRM_Topic__c = TOPIC,
            CRM_Status__c = 'Pending',
            CRM_Value__c = EncodingUtil.base64Encode(Blob.valueOf('invalid json'))
        );

        // Act
        Test.startTest();
        List<FiaCooperation> result = new FiaCooperationHandler().extractData(new List<KafkaMessage__c>{ message });
        Test.stopTest();

        // Assert
        Assert.areEqual(0, result.size(), 'Should not parse invalid message');
        Assert.areEqual('Error', message.CRM_Status__c, 'Message should be marked as error');
    }

    @isTest
    static void extractData_should_return_empty_list_when_input_is_empty() {
        // Act
        Test.startTest();
        List<FiaCooperation> result = new FiaCooperationHandler().extractData(new List<KafkaMessage__c>());
        Test.stopTest();

        // Assert
        Assert.areEqual(0, result.size(), 'Should return empty list');
    }

    // ========================================
    // UNIT TESTS - Merge Logic
    // ========================================

    @isTest
    static void combineMessageData_should_merge_cooperation_fields_with_null_safe_updates() {
        // Arrange - First message has name, second has dates
        FiaCooperation message1 = createFiaCooperation('1', 'AKTIV', 'Cooperation Name', null, null, null);
        FiaCooperation message2 = createFiaCooperation(
            '1',
            'AKTIV',
            null,
            Date.newInstance(2025, 1, 1),
            Date.newInstance(2025, 12, 31),
            null
        );

        // Act
        Test.startTest();
        Map<String, FiaCooperation> result = new FiaCooperationHandler()
            .combineMessageData(new List<FiaCooperation>{ message1, message2 });
        Test.stopTest();

        // Assert
        FiaCooperation merged = result.get('1');
        Assert.areEqual('Cooperation Name', merged.samarbeid.navn, 'Should preserve name from message1');
        Assert.areEqual(
            Date.newInstance(2025, 1, 1),
            merged.samarbeid.startDato,
            'Should have start date from message2'
        );
        Assert.areEqual(
            Date.newInstance(2025, 12, 31),
            merged.samarbeid.sluttDato,
            'Should have end date from message2'
        );
    }

    @isTest
    static void combineMessageData_should_replace_plan_atomically() {
        // Arrange - Two plans should result in last one winning
        FiaCooperation message1 = createFiaCooperation('1', 'AKTIV', null, null, null, 'plan-1');
        message1.plan.status = 'AKTIV';

        FiaCooperation message2 = createFiaCooperation('1', 'AKTIV', null, null, null, 'plan-2');
        message2.plan.status = 'FULLFØRT';

        // Act
        Test.startTest();
        Map<String, FiaCooperation> result = new FiaCooperationHandler()
            .combineMessageData(new List<FiaCooperation>{ message1, message2 });
        Test.stopTest();

        // Assert
        FiaCooperation merged = result.get('1');
        Assert.areEqual('plan-2', merged.plan.id, 'Should have plan ID from message2 (last wins)');
        Assert.areEqual('FULLFØRT', merged.plan.status, 'Should have plan status from message2');
    }

    @isTest
    static void combineMessageData_should_skip_deleted_cooperations() {
        // Arrange
        FiaCooperation message1 = createFiaCooperation('1', 'AKTIV');
        FiaCooperation message2 = createFiaCooperation('1', 'SLETTET');

        // Act
        Test.startTest();
        Map<String, FiaCooperation> result = new FiaCooperationHandler()
            .combineMessageData(new List<FiaCooperation>{ message1, message2 });
        Test.stopTest();

        // Assert
        Assert.isTrue(
            result.get('1').samarbeid.status == 'AKTIV',
            'Deleted cooperation should be skipped during merge'
        );
    }

    @isTest
    static void combineMessageData_should_wrap_tracking_fields_with_delimiter() {
        // Arrange
        FiaCooperation message1 = createFiaCooperation('1', 'AKTIV');
        message1.jsonPayload = 'payload1'.leftPad(32768, 'X');
        message1.hash = 'hash1';

        FiaCooperation message2 = createFiaCooperation('1', 'AKTIV');
        message2.jsonPayload = 'payload2';
        message2.hash = 'hash2';

        FiaCooperation message3 = createFiaCooperation('1', 'AKTIV');
        message3.jsonPayload = 'payload3';
        message3.hash = 'hash3';

        // Act
        Test.startTest();
        Map<String, FiaCooperation> result = new FiaCooperationHandler()
            .combineMessageData(new List<FiaCooperation>{ message1, message2, message3 });
        Test.stopTest();

        // Assert
        FiaCooperation merged = result.get('1');
        Assert.isTrue(merged.jsonPayload.contains('#END#'), 'jsonPayload should contain delimiter');
        Assert.isTrue(merged.hash.contains('#END#'), 'hash should contain delimiter');
        Assert.isTrue(merged.jsonPayload.contains('payload1'), 'Should contain first payload');
        Assert.isTrue(merged.jsonPayload.startsWith('...'), 'Should be abbreviated at start');
        Assert.areEqual(32768, merged.jsonPayload.length(), 'Should be abbreviated to max length');
        Assert.isTrue(merged.jsonPayload.contains('payload2'), 'Should contain second payload');
        Assert.isTrue(merged.jsonPayload.contains('payload3'), 'Should contain third payload');
    }

    @isTest
    static void combineMessageData_should_handle_single_message() {
        // Arrange
        FiaCooperation message = createFiaCooperation(
            '1',
            'AKTIV',
            'Name',
            Date.today(),
            Date.today().addDays(30),
            'plan-1'
        );

        // Act
        Test.startTest();
        Map<String, FiaCooperation> result = new FiaCooperationHandler()
            .combineMessageData(new List<FiaCooperation>{ message });
        Test.stopTest();

        // Assert
        Assert.areEqual(1, result.size(), 'Should have one cooperation');
        Assert.areEqual('Name', result.get('1').samarbeid.navn, 'Should preserve all fields');
    }

    @isTest
    static void combineMessageData_should_return_empty_map_when_input_is_empty() {
        // Act
        Test.startTest();
        Map<String, FiaCooperation> result = new FiaCooperationHandler().combineMessageData(new List<FiaCooperation>());
        Test.stopTest();

        // Assert
        Assert.areEqual(0, result.size(), 'Should return empty map');
    }

    // ========================================
    // UNIT TESTS - Deletion Logic
    // ========================================

    @isTest
    static void isCooperationDeleted_should_return_true_when_status_is_SLETTET() {
        // Arrange
        FiaCooperation cooperation = createFiaCooperation('1', 'SLETTET');

        // Act
        Test.startTest();
        Boolean result = new FiaCooperationHandler().isCooperationDeleted(cooperation);
        Test.stopTest();

        // Assert
        Assert.isTrue(result, 'Should return true for SLETTET status');
    }

    @isTest
    static void isCooperationDeleted_should_return_false_when_status_is_not_deleted() {
        // Arrange
        FiaCooperation cooperation = createFiaCooperation('1', 'AKTIV');

        // Act
        Test.startTest();
        Boolean result = new FiaCooperationHandler().isCooperationDeleted(cooperation);
        Test.stopTest();

        // Assert
        Assert.isFalse(result, 'Should return false for non-deleted cooperation');
    }

    @isTest
    static void isPlanDeleted_should_return_true_when_plan_status_is_SLETTET() {
        // Arrange
        FiaCooperation cooperation = createFiaCooperation('1', 'AKTIV', null, null, null, 'plan-1');
        cooperation.plan.status = 'SLETTET';

        // Act
        Test.startTest();
        Boolean result = new FiaCooperationHandler().isPlanDeleted(cooperation);
        Test.stopTest();

        // Assert
        Assert.isTrue(result, 'Should return true when plan status is SLETTET');
    }

    @isTest
    static void isPlanDeleted_should_return_false_when_plan_status_is_not_deleted() {
        // Arrange
        FiaCooperation cooperation = createFiaCooperation('1', 'AKTIV', null, null, null, 'plan-1');
        cooperation.plan.status = 'AKTIV';

        // Act
        Test.startTest();
        Boolean result = new FiaCooperationHandler().isPlanDeleted(cooperation);
        Test.stopTest();

        // Assert
        Assert.isFalse(result, 'Should return false when plan is not deleted');
    }

    @isTest
    static void deleteRecords_should_successfully_delete_records() {
        // Arrange
        List<IACooperation__c> recordsToDelete = new List<IACooperation__c>{
            new IACooperation__c(
                CooperationId__c = '999',
                Name = 'Test 1',
                IACase__r = new IACase__c(Name = TEST_IA_CASE_NAME),
                Account__r = new Account(INT_OrganizationNumber__c = TEST_ACCOUNT_ORGNR)
            ),
            new IACooperation__c(
                CooperationId__c = '998',
                Name = 'Test 2',
                IACase__r = new IACase__c(Name = TEST_IA_CASE_NAME),
                Account__r = new Account(INT_OrganizationNumber__c = TEST_ACCOUNT_ORGNR)
            )
        };
        insert recordsToDelete;

        // Act
        Test.startTest();
        new FiaCooperationHandler().deleteRecords(recordsToDelete);
        Test.stopTest();

        // Assert
        List<IACooperation__c> deletedRecords = [
            SELECT Id
            FROM IACooperation__c
            WHERE CooperationId__c IN ('999', '998')
        ];
        Assert.areEqual(0, deletedRecords.size(), 'Records should be deleted');
    }

    @isTest
    static void logTimeDeviations_should_handle_empty_list() {
        // Act
        Test.startTest();
        new FiaCooperationHandler().logTimeDeviations(new List<FiaCooperation>());
        Test.stopTest();

        // Assert - No exception should be thrown
        Assert.isTrue(true, 'Should handle empty list without errors');
    }

    // ========================================
    // INTEGRATION TESTS - Happy Path
    // ========================================
    @isTest
    static void processMessages_should_merge_multiple_updates_and_create_cooperation_with_themes() {
        String message1 =
            '{"orgnr":"' +
            TEST_ACCOUNT_ORGNR +
            '","saksnummer":"' +
            TEST_IA_CASE_NAME +
            '","samarbeid":{"id":1,"navn":"Samarbeid X","status":"AKTIV","endretTidspunkt":"2025-11-19T09:54:55.128822"}}';
        // Plan is added
        String message2 =
            '{"orgnr":"' +
            TEST_ACCOUNT_ORGNR +
            '","saksnummer":"' +
            TEST_IA_CASE_NAME +
            '","samarbeid":{"id":1,"navn":"Samarbeid X","status":"AKTIV","endretTidspunkt":"2025-11-19T09:54:55.128822","startDato":"2025-10-28","sluttDato":"2027-01-01"},' +
            '"plan":{"id":"123-456-abc","status": "AKTIV","sistEndret":"2025-11-19T13:14:37.702151",' +
            '"temaer":[{"id": 1,"navn": "TEMA 1","inkludert": true,"undertemaer": [{"id": 1,"navn": "UNDERTEMA 1","inkludert": true, "status": "PLANLAGT","startDato": "2025-10-28","sluttDato": "2027-01-01"}]}]}}';
        // Subtheme status on plan is updated
        String message3 =
            '{"orgnr":"' +
            TEST_ACCOUNT_ORGNR +
            '","saksnummer":"' +
            TEST_IA_CASE_NAME +
            '","samarbeid":{"id":1,"navn":"Samarbeid X","status":"AKTIV","endretTidspunkt":"2025-11-19T09:54:55.128822","startDato":"2025-10-28","sluttDato":"2027-01-01"},' +
            '"plan":{"id":"123-456-abc","status": "AKTIV","sistEndret":"2025-11-19T13:14:37.702151",' +
            '"temaer":[{"id": 1,"navn": "TEMA 1","inkludert": true,"undertemaer": [{"id": 1,"navn": "UNDERTEMA 1","inkludert": true, "status": "PÅGÅR","startDato": "2025-10-28","sluttDato": "2027-01-01"}]}]}}';

        // Subtheme sluttDato is updated
        String message4 =
            '{"orgnr":"' +
            TEST_ACCOUNT_ORGNR +
            '","saksnummer":"' +
            TEST_IA_CASE_NAME +
            '","samarbeid":{"id":1,"navn":"Samarbeid X","status":"AKTIV","endretTidspunkt":"2025-11-19T09:54:55.128822","startDato":"2025-10-28","sluttDato":"2027-01-31"},' +
            '"plan":{"id":"123-456-abc","status": "AKTIV","sistEndret":"2025-11-19T13:17:12.821800",' +
            '"temaer":[{"id": 1,"navn": "TEMA 1","inkludert": true,"undertemaer": [{"id": 1,"navn": "UNDERTEMA 1","inkludert": true, "status": "PÅGÅR","startDato": "2025-10-28","sluttDato": "2027-01-31"}]}]}}';

        List<KafkaMessage__c> messages = new List<KafkaMessage__c>{
            new KafkaMessage__c(
                CRM_Topic__c = TOPIC,
                CRM_Key__c = TEST_IA_CASE_NAME + '-1',
                CRM_Value__c = EncodingUtil.base64Encode(Blob.valueOf(message1))
            ),
            new KafkaMessage__c(
                CRM_Topic__c = TOPIC,
                CRM_Key__c = TEST_IA_CASE_NAME + '-1-123-456-abc',
                CRM_Value__c = EncodingUtil.base64Encode(Blob.valueOf(message2))
            ),
            new KafkaMessage__c(
                CRM_Topic__c = TOPIC,
                CRM_Key__c = TEST_IA_CASE_NAME + '-1-123-456-abc',
                CRM_Value__c = EncodingUtil.base64Encode(Blob.valueOf(message3))
            ),
            new KafkaMessage__c(
                CRM_Topic__c = TOPIC,
                CRM_Key__c = TEST_IA_CASE_NAME + '-1-123-456-abc',
                CRM_Value__c = EncodingUtil.base64Encode(Blob.valueOf(message4))
            )
        };

        FiaCooperationHandler handler = new FiaCooperationHandler();
        handler.processMessages(messages);

        IACooperation__c cooperationRecord = [
            SELECT
                CooperationId__c,
                Name,
                IACase__r.Name,
                Account__r.INT_OrganizationNumber__c,
                PlanId__c,
                (
                    SELECT Id, (SELECT Id, Status__c, StartDate__c, EndDate__c FROM IA_Subthemes__r)
                    FROM IA_Themes__r
                    ORDER BY ThemeId__c
                )
            FROM IACooperation__c
            WHERE CooperationId__c = '1'
            LIMIT 1
        ];

        Assert.areEqual('1', cooperationRecord.CooperationId__c, 'Id on record should match.');
        Assert.areEqual('Samarbeid X', cooperationRecord.Name, 'Name on record should match.');
        Assert.areEqual('123-456-abc', cooperationRecord.PlanId__c, 'Plan Id should match.');
        Assert.areEqual(TEST_IA_CASE_NAME, cooperationRecord.IACase__r.Name, 'Should be related to test case.');
        Assert.areEqual(
            TEST_ACCOUNT_ORGNR,
            cooperationRecord.Account__r.INT_OrganizationNumber__c,
            'Should be related to test account.'
        );
        Assert.areEqual(1, cooperationRecord.IA_Themes__r.size(), 'Should have 1 theme');
        Assert.areEqual(1, cooperationRecord.IA_Themes__r[0].IA_Subthemes__r.size(), 'Should have 1 subtheme');
        IA_Subtheme__c subthemeRecord = cooperationRecord.IA_Themes__r[0].IA_Subthemes__r[0];
        Assert.areEqual('PÅGÅR', subthemeRecord.Status__c, 'Subtheme status should be updated to PÅGÅR');
        Assert.areEqual(
            Date.newInstance(2027, 1, 31),
            subthemeRecord.EndDate__c,
            'Subtheme sluttDato should be updated to 2027-01-31'
        );
    }

    @isTest
    static void processMessages_should_handle_deleted_plan_then_updated_then_deleted_cooperation() {
        // Plan is deleted
        String message1 =
            '{"orgnr":"' +
            TEST_ACCOUNT_ORGNR +
            '","saksnummer":"' +
            TEST_IA_CASE_NAME +
            '","samarbeid":{"id":500,"navn":"Samarbeid X","status":"AKTIV","endretTidspunkt":"2024-01-19T09:00:00.128822"},' +
            '"plan":{"id":"plan-500","status": "SLETTET","sistEndret":"2025-11-19T09:54:55.128822",' +
            '"temaer":[{"id": 500,"navn": "TEMA 1","inkludert": false,"undertemaer": [{"id": 500,"navn": "UNDERTEMA 1","inkludert": false, "status": "PÅGÅR"}]}]}}';
        // Samarbeid is updated
        String message2 =
            '{"orgnr":"' +
            TEST_ACCOUNT_ORGNR +
            '","saksnummer":"' +
            TEST_IA_CASE_NAME +
            '","samarbeid":{"id":500,"navn":"Samarbeid X","status":"AVBRUTT","endretTidspunkt":"2025-11-19T09:54:55.548388"}}';
        // Samarbeid is deleted
        String message3 =
            '{"orgnr":"' +
            TEST_ACCOUNT_ORGNR +
            '","saksnummer":"' +
            TEST_IA_CASE_NAME +
            '","samarbeid":{"id":500,"navn":"Samarbeid X","status":"SLETTET","endretTidspunkt":"2025-11-19T09:54:55.661896"}}';

        List<KafkaMessage__c> messages = new List<KafkaMessage__c>{
            new KafkaMessage__c(
                CRM_Topic__c = TOPIC,
                CRM_Key__c = TEST_IA_CASE_NAME + '-500-plan-500',
                CRM_Value__c = EncodingUtil.base64Encode(Blob.valueOf(message1))
            ),
            new KafkaMessage__c(
                CRM_Topic__c = TOPIC,
                CRM_Key__c = TEST_IA_CASE_NAME + '-500',
                CRM_Value__c = EncodingUtil.base64Encode(Blob.valueOf(message2))
            ),
            new KafkaMessage__c(
                CRM_Topic__c = TOPIC,
                CRM_Key__c = TEST_IA_CASE_NAME + '-500',
                CRM_Value__c = EncodingUtil.base64Encode(Blob.valueOf(message3))
            )
        };

        FiaCooperationHandler handler = new FiaCooperationHandler();
        handler.processMessages(messages);

        List<IACooperation__c> cooperationRecords = [
            SELECT id
            FROM IACooperation__c
            WHERE CooperationId__c = '500'
        ];
        Assert.areEqual(0, cooperationRecords.size(), 'Cooperation should be deleted');
    }

    @isTest
    static void processMessages_should_replace_deleted_plan_with_new_plan() {
        // Plan is deleted
        String message1 =
            '{"orgnr":"' +
            TEST_ACCOUNT_ORGNR +
            '","saksnummer":"' +
            TEST_IA_CASE_NAME +
            '","samarbeid":{"id":500,"navn":"Samarbeid X","status":"AKTIV"},' +
            '"plan":{"id":"plan-500","status": "SLETTET","sistEndret":"2025-11-19T09:54:55.128822",' +
            '"temaer":[{"id": 500,"navn": "TEMA 1","inkludert": false,"undertemaer": [{"id": 500,"navn": "UNDERTEMA 1","inkludert": false, "status": "PÅGÅR"}]}]}}';

        // New plan is added
        String message2 =
            '{"orgnr":"' +
            TEST_ACCOUNT_ORGNR +
            '","saksnummer":"' +
            TEST_IA_CASE_NAME +
            '","samarbeid":{"id":500,"navn":"Samarbeid X","status":"AKTIV","startDato":"2025-10-28","sluttDato":"2027-01-31"},' +
            '"plan":{"id":"plan-501","status": "AKTIV","sistEndret":"2025-11-19T13:17:12.821800",' +
            '"temaer":[{"id": 501,"navn": "TEMA 1","inkludert": true,"undertemaer": [{"id": 501,"navn": "UNDERTEMA 1","inkludert": true, "status": "PÅGÅR","startDato": "2025-10-28","sluttDato": "2027-01-31"}]}]}}';

        List<KafkaMessage__c> messages = new List<KafkaMessage__c>{
            new KafkaMessage__c(
                CRM_Topic__c = TOPIC,
                CRM_Key__c = TEST_IA_CASE_NAME + '-500-plan-500',
                CRM_Value__c = EncodingUtil.base64Encode(Blob.valueOf(message1))
            ),
            new KafkaMessage__c(
                CRM_Topic__c = TOPIC,
                CRM_Key__c = TEST_IA_CASE_NAME + '-500-plan-501',
                CRM_Value__c = EncodingUtil.base64Encode(Blob.valueOf(message2))
            )
        };

        FiaCooperationHandler handler = new FiaCooperationHandler();
        handler.processMessages(messages);

        List<IACooperation__c> cooperationRecords = [
            SELECT
                PlanId__c,
                (
                    SELECT ThemeId__c, (SELECT SubthemeId__c FROM IA_Subthemes__r)
                    FROM IA_Themes__r
                    ORDER BY ThemeId__c
                )
            FROM IACooperation__c
            WHERE CooperationId__c = '500'
        ];
        Assert.areEqual(1, cooperationRecords.size(), 'Should have 1 cooperation record');
        Assert.areEqual('plan-501', cooperationRecords[0].PlanId__c, 'PlanId should be updated to new plan');
        Assert.areEqual(1, cooperationRecords[0].IA_Themes__r.size(), 'Should have 1 theme');
        Assert.areEqual(1, cooperationRecords[0].IA_Themes__r[0].IA_Subthemes__r.size(), 'Should have 1 subtheme');
        Assert.areEqual(
            '501',
            cooperationRecords[0].IA_Themes__r[0].ThemeId__c,
            'ThemeId should be updated to new plan theme'
        );
        Assert.areEqual(
            '501',
            cooperationRecords[0].IA_Themes__r[0].IA_Subthemes__r[0].SubthemeId__c,
            'SubthemeId should also be updated'
        );
    }

    @IsTest
    static void processMessages_should_create_cooperation_with_themes_and_subthemes_from_kafka_message() {
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
        Assert.areEqual(TEST_IA_CASE_NAME, cooperationRecord.IACase__r.Name, 'Should be related to test case.');
        Assert.areEqual(
            TEST_ACCOUNT_ORGNR,
            cooperationRecord.Account__r.INT_OrganizationNumber__c,
            'Should be related to test account.'
        );
        Assert.areEqual(3, cooperationRecord.IA_Themes__r.size(), 'Should have 3 themes');
        Assert.areEqual(1, cooperationRecord.IA_Themes__r[0].IA_Subthemes__r.size(), 'Should have 1 subtheme');
        Assert.areEqual(4, cooperationRecord.IA_Themes__r[1].IA_Subthemes__r.size(), 'Should have 4 subthemes');
        Assert.areEqual(6, cooperationRecord.IA_Themes__r[2].IA_Subthemes__r.size(), 'Should have 6 subthemes');

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
    static void processMessages_should_log_error_when_ia_case_is_missing() {
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

        Assert.areEqual('Error', messages[0].CRM_Status__c, 'Message status should be updated to Error');
    }

    @IsTest
    static void processMessages_should_log_error_when_parsing_fails() {
        List<KafkaMessage__c> messages = new List<KafkaMessage__c>{
            new KafkaMessage__c(CRM_Topic__c = TOPIC, CRM_Key__c = 'anykey', CRM_Value__c = 'bad data...')
        };

        Test.startTest();
        FiaCooperationHandler handler = new FiaCooperationHandler();
        handler.processMessages(messages);
        Test.stopTest();

        Assert.areEqual('Error', messages[0].CRM_Status__c, 'Message status should be updated to Error');
    }

    @IsTest
    static void processMessages_should_log_error_when_upsert_fails() {
        List<KafkaMessage__c> messages = new List<KafkaMessage__c>{ createKafkaMessage(null, null) };
        Test.startTest();
        FiaCooperationHandler handler = new FiaCooperationHandler();
        handler.processMessages(messages);
        Test.stopTest();

        Assert.areEqual('Error', messages[0].CRM_Status__c, 'Message status should be updated to Error');
    }

    @IsTest
    static void processMessages_should_delete_old_plan_and_create_new_plan() {
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
                            '        "endretTidspunkt": "2024-09-16T11:20:10.000000"' +
                            '    },' +
                            '    "plan": {' +
                            '        "id": "plan-500",' +
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
                            '        "id": "plan-501",' +
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
        Assert.areEqual('plan-501', cooperationRecords[0].PlanId__c);
    }

    @IsTest
    static void processMessages_should_handle_old_message_formats_without_timestamps() {
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

        Assert.areEqual('Processed', messages[0].CRM_Status__c, 'Message status should be updated to Processed');
        Assert.areEqual('Processed', messages[1].CRM_Status__c, 'Message status should be updated to Processed');
        Assert.areEqual('Processed', messages[2].CRM_Status__c, 'Message status should be updated to Processed');
        Assert.areEqual('Processed', messages[3].CRM_Status__c, 'Message status should be updated to Processed');
    }

    @IsTest
    static void processMessages_should_delete_cooperation_when_status_is_SLETTET() {
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
                            '        "endretTidspunkt": "2024-09-10T10:10:00.000000"' +
                            '    },' +
                            '    "plan": {' +
                            '        "id": "plan-500",' +
                            '        "sistEndret":  "2024-09-16T11:30:20.000000",' +
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
                            '        "endretTidspunkt": "2024-09-16T11:30:20.000000"' +
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
    static void deleteRecords_should_remove_records_from_database() {
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
    static void testlogTimeDeviations_Should_Handle_Empty_List() {
        List<FiaCooperation> cooperations = new List<FiaCooperation>();
        Test.startTest();
        new FiaCooperationHandler().logTimeDeviations(cooperations);

        Test.stopTest();
    }

    @isTest
    static void combineMessageData_should_merge_multiple_updates() {
        List<FiaCooperation> cooperations = new List<FiaCooperation>();
        // Samarbeid opprettes, deretter opprettes plan
        FiaCooperation message1 = createFiaCooperation('1', 'AKTIV', 'Cooperation Name', null, null, null);
        cooperations.add(message1);
        FiaCooperation message2 = createFiaCooperation(
            '1',
            'AKTIV',
            'Cooperation Name',
            Date.newInstance(2025, 1, 1),
            Date.newInstance(2025, 12, 31),
            'plan-1'
        );
        cooperations.add(message2);

        // Plan fullføres, deretter fullføres samarbeid
        FiaCooperation message3 = createFiaCooperation(
            '2',
            'AKTIV',
            'Cooperation Name',
            Date.newInstance(2025, 1, 1),
            Date.newInstance(2025, 12, 31),
            'plan-2'
        );
        message3.plan.status = 'FULLFØRT';
        cooperations.add(message3);
        FiaCooperation message4 = createFiaCooperation('2', 'FULLFØRT', 'Cooperation Name', null, null, null);
        cooperations.add(message4);

        FiaCooperation result = new FiaCooperation();
        Test.startTest();
        FiaCooperationHandler handler = new FiaCooperationHandler();
        Map<String, FiaCooperation> newestUpdates = handler.combineMessageData(cooperations);
        Test.stopTest();

        result = newestUpdates.get('1');
        Assert.areEqual('Cooperation Name', result.samarbeid.navn, 'Name should be from message1');
        Assert.areEqual(Date.newInstance(2025, 1, 1), result.samarbeid.startDato, 'Start date should be from message2');
        Assert.areEqual(Date.newInstance(2025, 12, 31), result.samarbeid.sluttDato, 'End date should be from message2');
        Assert.isNotNull(result.plan, 'Should have plan');

        result = newestUpdates.get('2');
        Assert.areEqual(Date.newInstance(2025, 1, 1), result.samarbeid.startDato, 'Start date should be from message3');
        Assert.areEqual(Date.newInstance(2025, 12, 31), result.samarbeid.sluttDato, 'End date should be from message3');
        Assert.isNotNull(result.plan, 'Should have plan');
        Assert.areEqual('plan-2', result.plan.id, 'Plan ID should be from message3');
        Assert.areEqual('FULLFØRT', result.samarbeid.status, 'Cooperation 2 status should be FULLFØRT');
        Assert.areEqual('FULLFØRT', result.plan.status, 'Plan 2 status should be FULLFØRT');
    }
}
