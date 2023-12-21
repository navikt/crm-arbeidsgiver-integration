@IsTest
public class SickLeaveMetadataHandlerTest {
    @TestSetup
    static void makeData(){
        Account acc = new Account(Name = 'Test Employer 1', INT_OrganizationNumber__c = '919300760', INT_IndustryCode__c = '43.210');
            insert acc;
        Account acc2 = new Account(Name = 'Test Employer 2', INT_OrganizationNumber__c = '12345678', INT_IndustryCode__c = '43.210');
            insert acc2;

        List<KafkaMessage__c> messagesTopics = new List<KafkaMessage__c>();

        String jsonC = '{"kategori":"LAND","kode":"NO","sistePubliserteKvartal":{"årstall":2023,"kvartal":2,"prosent":2.0,"tapteDagsverk":10000000.0,"muligeDagsverk":500000000.0,"antallPersoner":2500000,"erMaskert":false},"siste4Kvartal":{"prosent":1.9,"tapteDagsverk":38000000.0,"muligeDagsverk":2000000000.0,"erMaskert":true,"kvartaler":[{"årstall":2020,"kvartal": 2},{"årstall":2020,"kvartal":1},{"årstall":2019,"kvartal":4},{"årstall":2019,"kvartal":3}]}}';
        String encodedValueC = EncodingUtil.base64Encode(Blob.valueOf(jsonC));

        KafkaMessage__c msgC = new KafkaMessage__c();
        msgC.CRM_Topic__c = 'arbeidsgiver.sykefravarsstatistikk-land-v1';
        msgC.CRM_Key__c = 'ewogICJrYXRlZ29yaSI6ICJCUkFOU0pFIiwKICAia29kZSI6ICJTWUtFSFVTIiwKICAia3ZhcnRhbCI6ICIyIiwKICAiw6Vyc3RhbGwiOiAiMjAyMyIKfQ==';
        msgC.CRM_Value__c = encodedValueC;

        messagesTopics.add(msgC);

        String jsonN = '{"kategori":"NÆRING","kode":"01","sistePubliserteKvartal":{"årstall":2023,"kvartal":2,"prosent":2.0,"tapteDagsverk":10000000.0,"muligeDagsverk":500000000.0,"antallPersoner":2500000,"erMaskert":false},"siste4Kvartal":{"prosent":1.9,"tapteDagsverk":38000000.0,"muligeDagsverk":2000000000.0,"erMaskert":true,"kvartaler":[{"årstall":2020,"kvartal": 2},{"årstall":2020,"kvartal":1},{"årstall":2019,"kvartal":4},{"årstall":2019,"kvartal":3}]}}';
        String encodedValueN = EncodingUtil.base64Encode(Blob.valueOf(jsonN));

        KafkaMessage__c msgN = new KafkaMessage__c();
        msgN.CRM_Topic__c = 'arbeidsgiver.sykefravarsstatistikk-naring-v1';
        msgN.CRM_Key__c = 'ewgICJrYXRlZ29yaSI6ICJCUkFOU0pFIiwKICAia29kZSI6ICJTWUtFSFVTIiwKICAia3ZhcnRhbCI6ICIyIiwKICAiw6Vyc3RhbGwiOiAiMjAyMyIKfQ==';
        msgN.CRM_Value__c = encodedValueN;

        messagesTopics.add(msgN);

        String jsonNK = '{"kategori":"NÆRINGSKODE","kode":"01001","sistePubliserteKvartal":{"årstall":2023,"kvartal":2,"prosent":2.0,"tapteDagsverk":10000000.0,"muligeDagsverk":500000000.0,"antallPersoner":2500000,"erMaskert":false},"siste4Kvartal":{"prosent":1.9,"tapteDagsverk":38000000.0,"muligeDagsverk":2000000000.0,"erMaskert":true,"kvartaler":[{"årstall":2020,"kvartal": 2},{"årstall":2020,"kvartal":1},{"årstall":2019,"kvartal":4},{"årstall":2019,"kvartal":3}]}}';
        String encodedValueNK = EncodingUtil.base64Encode(Blob.valueOf(jsonNK));

        KafkaMessage__c msgNK = new KafkaMessage__c();
        msgNK.CRM_Topic__c = 'arbeidsgiver.sykefravarsstatistikk-naringskode-v1';
        msgNK.CRM_Key__c = 'ewogICJrYXRlZ29yaS6ICJCUkFOU0pFIiwKICAia29kZSI6ICJTWUtFSFVTIiwKICAia3ZhcnRhbCI6ICIyIiwKICAiw6Vyc3RhbGwiOiAiMjAyMyIKfQ==';
        msgNK.CRM_Value__c = encodedValueNK;

        messagesTopics.add(msgNK);

        String jsonB = '{"kategori":"BRANSJE","kode":"SYKEHUS","sistePubliserteKvartal":{"årstall":2023,"kvartal":2,"prosent":2.0,"tapteDagsverk":10000000.0,"muligeDagsverk":500000000.0,"antallPersoner":2500000,"erMaskert":false},"siste4Kvartal":{"prosent":1.9,"tapteDagsverk":38000000.0,"muligeDagsverk":2000000000.0,"erMaskert":true,"kvartaler":[{"årstall":2020,"kvartal": 2},{"årstall":2020,"kvartal":1},{"årstall":2019,"kvartal":4},{"årstall":2019,"kvartal":3}]}}';
        String encodedValueB = EncodingUtil.base64Encode(Blob.valueOf(jsonB));

        KafkaMessage__c msgB = new KafkaMessage__c();
        msgB.CRM_Topic__c = 'arbeidsgiver.sykefravarsstatistikk-bransje-v1';
        msgB.CRM_Key__c = 'ewogICJrYXRlZ29yaSI6ICJCUkFOU0pFIiwKICAi29kZSI6ICJTWUtFSFVTIiwKICAia3ZhcnRhbCI6ICIyIiwKICAiw6Vyc3RhbGwiOiAiMjAyMyIKfQ==';
        msgB.CRM_Value__c = encodedValueB;

        messagesTopics.add(msgB);

        String jsonS = '{"kategori":"SEKTOR","kode":"STAT","sistePubliserteKvartal":{"årstall":2023,"kvartal":2,"prosent":2.0,"tapteDagsverk":10000000.0,"muligeDagsverk":500000000.0,"antallPersoner":2500000,"erMaskert":false},"siste4Kvartal":{"prosent":1.9,"tapteDagsverk":38000000.0,"muligeDagsverk":2000000000.0,"erMaskert":true,"kvartaler":[{"årstall":2020,"kvartal": 2},{"årstall":2020,"kvartal":1},{"årstall":2019,"kvartal":4},{"årstall":2019,"kvartal":3}]}}';
        String encodedValueS = EncodingUtil.base64Encode(Blob.valueOf(jsonS));

        KafkaMessage__c msgS = new KafkaMessage__c();
        msgS.CRM_Topic__c = 'arbeidsgiver.sykefravarsstatistikk-sektor-v1';
        msgS.CRM_Key__c = 'ewogICJrYXRlZ29yaSI6ICJCUkFOU0pFiwKICAia29kZSI6ICJTWUtFSFVTIiwKICAia3ZhcnRhbCI6ICIyIiwKICAiw6Vyc3RhbGwiOiAiMjAyMyIKfQ==';
        msgS.CRM_Value__c = encodedValueS;

        messagesTopics.add(msgS);

        insert messagesTopics;

        new KafkaMessageService(messagesTopics).handleMessages();
    }
    
    @IsTest
    public static void testHandleMessageInsert() {
        // Create KafkaMessage with Base64 encoded JSON-payloads
        List<KafkaMessage__c> messages = new List<KafkaMessage__c>();

        String json = '{"orgnr":"999999999","arstall":"2023","kvartal":"2","naring":"86","naringskode":"86101","bransje":"SYKEHUS","sektor":"STAT"}';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(json));

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'arbeidsgiver.sykefravarsstatistikk-metadata-virksomhet-v1';
        msg1.CRM_Key__c = '{"orgnr":"999999999","arstall":"2023","kvartal":"2"}';
        msg1.CRM_Value__c = encodedValue;

        messages.add(msg1);

        insert messages;

        List<KafkaMessage__c> km = [
            SELECT Id
            FROM KafkaMessage__c
        ];
        System.assertEquals(6, km.size(), 'Messages Inserted');

        Test.startTest();
        SickLeaveMetadataHandler handler = new SickLeaveMetadataHandler();
        handler.processMessages(messages);        
        Test.stopTest();

        List<Absence__c> result = [
            SELECT
                Id,
                CRM_Key__c,
                CRM_AbsenceCategory__c,
                CRM_Code__c,
                CRM_Year__c,
                CRM_Quarter__c,
                CRM_OrganizationNumber__c,
                CRM_IndustryMainCode__c,
                CRM_IndustryCode__c,
                CRM_BranchCode__c,
                CRM_SectorCode__c
            FROM Absence__c
            WHERE CRM_AbsenceCategory__c = 'VIRKSOMHET'
        ];
        System.assertEquals(1, result.size());
        System.assertEquals(2, result[0].CRM_Quarter__c);
        System.assertEquals(2023, result[0].CRM_Year__c);
        System.assertEquals('99999999920232', result[0].CRM_Key__c);
        System.assertEquals('86', result[0].CRM_IndustryMainCode__c);
        System.assertEquals('86101', result[0].CRM_IndustryCode__c);
        System.assertEquals('SYKEHUS', result[0].CRM_BranchCode__c);
        System.assertEquals('STAT', result[0].CRM_SectorCode__c);
    }

    @IsTest
    public static void testHandleMessageUpdateWhenEmployerInserted() {
        // Create KafkaMessage with Base64 encoded JSON-payloads
        List<KafkaMessage__c> messages = new List<KafkaMessage__c>();

        String json = '{"kategori":"VIRKSOMHET","kode":"12345678","sistePubliserteKvartal":{"årstall":2023,"kvartal":2,"prosent":2.0,"tapteDagsverk":1000.0,"muligeDagsverk":5000.0,"antallPersoner":200,"erMaskert":false},"siste4Kvartal":{"prosent":1.9,"tapteDagsverk":300.0,"muligeDagsverk":2000.0,"erMaskert":false,"kvartaler":[{"årstall":2020,"kvartal": 2},{"årstall":2020,"kvartal":1},{"årstall":2019,"kvartal":4},{"årstall":2019,"kvartal":3}]}}';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(json));

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'arbeidsgiver.sykefravarsstatistikk-virksomhet-v1';
        msg1.CRM_Key__c = 'ewogICJrYXRlZ29yaSI6ICJCUkFOU0pFIiwKICAia29kZSI6ICJTWUtFSFVTIiwKICAia3ZhcnRhbCI6ICIyIiwKICAiw6Vyc3RhbGwiOiAiMjAyMyIKfQ==';
        msg1.CRM_Value__c = encodedValue;

        messages.add(msg1);

        insert messages;

        new KafkaMessageService(messages).handleMessages();

        List<Absence__c> result = [
            SELECT
                Id,
                CRM_Key__c,
                CRM_Account__c,
                CRM_AbsenceCategory__c,
                CRM_Code__c,
                CRM_Year__c,
                CRM_Quarter__c,
                CRM_Percent__c,
                CRM_LostDaysWork__c,
                CRM_PossibleDaysWork__c,
                CRM_NumberOfPeople__c,
                CRM_IsHidden__c,
                CRM_Last4QuartersPercent__c,
                CRM_Last4QuartersLostDaysWork__c,
                CRM_Last4QuartersPossibleDaysWork__c,
                CRM_Last4QuartersIsHidden__c
            FROM Absence__c
            WHERE CRM_AbsenceCategory__c = 'VIRKSOMHET'
        ];

        List<Account> acc2 = [SELECT Id FROM Account WHERE INT_OrganizationNumber__c = '12345678'];

        System.assertEquals(1, result.size());
        System.assertEquals(2, result[0].CRM_Quarter__c);
        System.assertEquals(2023, result[0].CRM_Year__c);
        System.assertEquals(acc2[0].Id, result[0].CRM_Account__c);
        System.assertEquals(false, result[0].CRM_IsHidden__c);
        System.assertEquals('1234567820232', result[0].CRM_Key__c);
        System.assertEquals(200, result[0].CRM_NumberOfPeople__c);
        System.assertEquals(5000.0, result[0].CRM_PossibleDaysWork__c);
        System.assertEquals(1000.0, result[0].CRM_LostDaysWork__c);
        System.assertEquals(2.0, result[0].CRM_Percent__c);
        System.assertEquals(300.0, result[0].CRM_Last4QuartersLostDaysWork__c);
        System.assertEquals(2000.0, result[0].CRM_Last4QuartersPossibleDaysWork__c);
        System.assertEquals(1.9, result[0].CRM_Last4QuartersPercent__c);
        System.assertEquals(false, result[0].CRM_Last4QuartersIsHidden__c);
        
        // Create KafkaMessage with Base64 encoded JSON-payloads
        List<KafkaMessage__c> messagesUpdate = new List<KafkaMessage__c>();

        String json2 = '{"orgnr":"12345678","arstall":"2023","kvartal":"2","naring":"86","naringskode":"86101","bransje":"SYKEHUS","sektor":"STAT"}';
        String encodedValue2 = EncodingUtil.base64Encode(Blob.valueOf(json2));

        KafkaMessage__c msg2 = new KafkaMessage__c();
        msg2.CRM_Topic__c = 'arbeidsgiver.sykefravarsstatistikk-metadata-virksomhet-v1';
        msg2.CRM_Key__c = '{"orgnr":"12345678","arstall":"2023","kvartal":"2"}';
        msg2.CRM_Value__c = encodedValue2;

        messagesUpdate.add(msg2);

        insert messagesUpdate;

        Test.startTest();
        SickLeaveMetadataHandler handler = new SickLeaveMetadataHandler();
        handler.processMessages(messagesUpdate);        
        Test.stopTest();

        List<Absence__c> resultUpdated = [
            SELECT
                Id,
                CRM_Key__c,
                CRM_AbsenceCategory__c,
                CRM_Account__c,
                CRM_Code__c,
                CRM_Year__c,
                CRM_Quarter__c,
                CRM_OrganizationNumber__c,
                CRM_IndustryMainCode__c,
                CRM_IndustryCode__c,
                CRM_BranchCode__c,
                CRM_SectorCode__c,
                CRM_Percent__c,
                CRM_LostDaysWork__c,
                CRM_PossibleDaysWork__c,
                CRM_NumberOfPeople__c,
                CRM_IsHidden__c,
                CRM_Last4QuartersPercent__c,
                CRM_Last4QuartersLostDaysWork__c,
                CRM_Last4QuartersPossibleDaysWork__c,
                CRM_Last4QuartersIsHidden__c
            FROM Absence__c
            WHERE CRM_AbsenceCategory__c = 'VIRKSOMHET'
        ];
        System.assertEquals(1, resultUpdated.size());
        System.assertEquals(2, resultUpdated[0].CRM_Quarter__c);
        System.assertEquals(2023, resultUpdated[0].CRM_Year__c);
        System.assertEquals('1234567820232', resultUpdated[0].CRM_Key__c);
        System.assertEquals('86', resultUpdated[0].CRM_IndustryMainCode__c);
        System.assertEquals('86101', resultUpdated[0].CRM_IndustryCode__c);
        System.assertEquals('SYKEHUS', resultUpdated[0].CRM_BranchCode__c);
        System.assertEquals('STAT', resultUpdated[0].CRM_SectorCode__c);
        System.assertEquals(1, resultUpdated.size());
        System.assertEquals(2, resultUpdated[0].CRM_Quarter__c);
        System.assertEquals(2023, resultUpdated[0].CRM_Year__c);
        System.assertEquals(acc2[0].Id, resultUpdated[0].CRM_Account__c);
        System.assertEquals(false, resultUpdated[0].CRM_IsHidden__c);
        System.assertEquals('1234567820232', resultUpdated[0].CRM_Key__c);
        System.assertEquals(200, resultUpdated[0].CRM_NumberOfPeople__c);
        System.assertEquals(5000.0, resultUpdated[0].CRM_PossibleDaysWork__c);
        System.assertEquals(1000.0, resultUpdated[0].CRM_LostDaysWork__c);
        System.assertEquals(2.0, resultUpdated[0].CRM_Percent__c);
        System.assertEquals(300.0, resultUpdated[0].CRM_Last4QuartersLostDaysWork__c);
        System.assertEquals(2000.0, resultUpdated[0].CRM_Last4QuartersPossibleDaysWork__c);
        System.assertEquals(1.9, resultUpdated[0].CRM_Last4QuartersPercent__c);
        System.assertEquals(false, resultUpdated[0].CRM_Last4QuartersIsHidden__c);
    }

    @IsTest
    public static void testHandleMessageInsertWithCountry() {
        List<KafkaMessage__c> messages = new List<KafkaMessage__c>();

        String json = '{"orgnr":"999999999","arstall":"2023","kvartal":"2","naring":"86","naringskode":"86101","bransje":"SYKEHUS","sektor":"STAT"}';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(json));

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'arbeidsgiver.sykefravarsstatistikk-metadata-virksomhet-v1';
        msg1.CRM_Key__c = '{"orgnr":"999999999","arstall":"2023","kvartal":"2"}';
        msg1.CRM_Value__c = encodedValue;

        messages.add(msg1);

        insert messages;

        Test.startTest();
        SickLeaveMetadataHandler handler = new SickLeaveMetadataHandler();
        handler.processMessages(messages);        
        Test.stopTest();

        List<Absence__c> result = [
            SELECT
                Id,
                CRM_Key__c,
                CRM_AbsenceCategory__c,
                CRM_Code__c,
                CRM_Year__c,
                CRM_Quarter__c,
                CRM_OrganizationNumber__c,
                CRM_IndustryMainCode__c,
                CRM_IndustryCode__c,
                CRM_BranchCode__c,
                CRM_SectorCode__c,
                CRM_AbsenceCountry__c
            FROM Absence__c
            WHERE CRM_AbsenceCategory__c = 'VIRKSOMHET'
        ];
        List<Absence__c> resultCOuntry = [
            SELECT
                Id
            FROM Absence__c
            WHERE CRM_AbsenceCategory__c = 'LAND'
        ];

        System.assertEquals(1, result.size());
        System.assertEquals(2, result[0].CRM_Quarter__c);
        System.assertEquals(2023, result[0].CRM_Year__c);
        System.assertEquals('99999999920232', result[0].CRM_Key__c);
        System.assertEquals('86', result[0].CRM_IndustryMainCode__c);
        System.assertEquals('86101', result[0].CRM_IndustryCode__c);
        System.assertEquals('SYKEHUS', result[0].CRM_BranchCode__c);
        System.assertEquals('STAT', result[0].CRM_SectorCode__c);
        System.assertEquals(resultCOuntry[0].Id, result[0].CRM_AbsenceCountry__c);
    }

    @IsTest
    public static void testHandleMessageInsertWithAllTopics() {
        List<KafkaMessage__c> messages = new List<KafkaMessage__c>();

        String json = '{"orgnr":"999999999","arstall":"2023","kvartal":"2","naring":"01","naringskode":"01001","bransje":"SYKEHUS","sektor":"STAT"}';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(json));

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'arbeidsgiver.sykefravarsstatistikk-metadata-virksomhet-v1';
        msg1.CRM_Key__c = '{"orgnr":"999999999","arstall":"2023","kvartal":"2"}';
        msg1.CRM_Value__c = encodedValue;

        messages.add(msg1);

        insert messages;

        Test.startTest();
        SickLeaveMetadataHandler handler = new SickLeaveMetadataHandler();
        handler.processMessages(messages);        
        Test.stopTest();

        List<Absence__c> result = [
            SELECT
                Id,
                CRM_Key__c,
                CRM_AbsenceCategory__c,
                CRM_Code__c,
                CRM_Year__c,
                CRM_Quarter__c,
                CRM_OrganizationNumber__c,
                CRM_IndustryMainCode__c,
                CRM_IndustryCode__c,
                CRM_BranchCode__c,
                CRM_SectorCode__c,
                CRM_AbsenceCountry__c,
                CRM_AbsenceSector__c,
                CRM_AbsenceBranch__c,
                CRM_AbsenceIndustryCode__c,
                CRM_AbsenceIndustry__c
            FROM Absence__c
            WHERE CRM_AbsenceCategory__c = 'VIRKSOMHET'
        ];
        List<Absence__c> resultCountry = [
            SELECT
                Id
            FROM Absence__c
            WHERE CRM_AbsenceCategory__c = 'LAND'
        ];
        List<Absence__c> resultIndustryCode = [
            SELECT
                Id
            FROM Absence__c
            WHERE CRM_AbsenceCategory__c = 'NÆRINGSKODE'
        ];
        List<Absence__c> resultIndustry = [
            SELECT
                Id
            FROM Absence__c
            WHERE CRM_AbsenceCategory__c = 'NÆRING'
        ];
        List<Absence__c> resultBranch = [
            SELECT
                Id
            FROM Absence__c
            WHERE CRM_AbsenceCategory__c = 'BRANSJE'
        ];
        List<Absence__c> resultSector = [
            SELECT
                Id
            FROM Absence__c
            WHERE CRM_AbsenceCategory__c = 'SEKTOR'
        ];
        List<Absence__c> results = [
            SELECT
                Id
            FROM Absence__c
        ];
        
        System.assertEquals(6, results.size());
        System.assertEquals(1, result.size());
        System.assertEquals(2, result[0].CRM_Quarter__c);
        System.assertEquals(2023, result[0].CRM_Year__c);
        System.assertEquals('99999999920232', result[0].CRM_Key__c);
        System.assertEquals('01', result[0].CRM_IndustryMainCode__c);
        System.assertEquals('01001', result[0].CRM_IndustryCode__c);
        System.assertEquals('SYKEHUS', result[0].CRM_BranchCode__c);
        System.assertEquals('STAT', result[0].CRM_SectorCode__c);
        System.assertEquals(resultCountry[0].Id, result[0].CRM_AbsenceCountry__c);
        System.assertEquals(resultIndustryCode[0].Id, result[0].CRM_AbsenceIndustryCode__c);
        System.assertEquals(resultIndustry[0].Id, result[0].CRM_AbsenceIndustry__c);
        System.assertEquals(resultBranch[0].Id, result[0].CRM_AbsenceBranch__c);
        System.assertEquals(resultSector[0].Id, result[0].CRM_AbsenceSector__c);
    }

    @IsTest
    public static void testHandleMessageWithNullsPositive() {
        List<KafkaMessage__c> messages = new List<KafkaMessage__c>();

        String json = '{"orgnr":"919300760","arstall":"2023","kvartal":"2","naring":"86","naringskode":"86101","bransje":null,"sektor":null}';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(json));

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'arbeidsgiver.sykefravarsstatistikk-metadata-virksomhet-v1';
        msg1.CRM_Key__c = '{"orgnr":"919300760","arstall":"2023","kvartal":"2"}';
        msg1.CRM_Value__c = encodedValue;

        messages.add(msg1);

        insert messages;

        Test.startTest();
        SickLeaveMetadataHandler handler = new SickLeaveMetadataHandler();
        handler.processMessages(messages);        
        Test.stopTest();

        List<Absence__c> result = [
            SELECT
                Id,
                CRM_Key__c,
                CRM_AbsenceCategory__c,
                CRM_Code__c,
                CRM_Year__c,
                CRM_Quarter__c,
                CRM_OrganizationNumber__c,
                CRM_IndustryMainCode__c,
                CRM_IndustryCode__c,
                CRM_BranchCode__c,
                CRM_SectorCode__c
            FROM Absence__c
            WHERE CRM_AbsenceCategory__c = 'VIRKSOMHET'
        ];
        System.assertEquals(1, result.size());
        System.assertEquals(2, result[0].CRM_Quarter__c);
        System.assertEquals(2023, result[0].CRM_Year__c);
        System.assertEquals('91930076020232', result[0].CRM_Key__c);
        System.assertEquals('86', result[0].CRM_IndustryMainCode__c);
        System.assertEquals('86101', result[0].CRM_IndustryCode__c);
        System.assertEquals(null, result[0].CRM_BranchCode__c);
        System.assertEquals(null, result[0].CRM_SectorCode__c);  
    }

    @IsTest
    public static void testHandleMessageWithNullsNegative() {
        List<KafkaMessage__c> messages = new List<KafkaMessage__c>();

        String json = '{"orgnr":"919300760","arstall":null,"kvartal":"2","naring":"86","naringskode":"86101","bransje":null,"sektor":null}';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(json));

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'arbeidsgiver.sykefravarsstatistikk-metadata-virksomhet-v1';
        msg1.CRM_Key__c = '{"orgnr":"919300760","arstall":"2023","kvartal":"2"}';
        msg1.CRM_Value__c = encodedValue;
        messages.add(msg1);

        insert messages;

        Test.startTest();
        SickLeaveMetadataHandler handler = new SickLeaveMetadataHandler();
        handler.processMessages(messages);        
        Test.stopTest();

        List<Absence__c> result = [
            SELECT
                Id,
                CRM_Key__c,
                CRM_AbsenceCategory__c,
                CRM_Code__c,
                CRM_Year__c,
                CRM_Quarter__c,
                CRM_OrganizationNumber__c,
                CRM_IndustryMainCode__c,
                CRM_IndustryCode__c,
                CRM_BranchCode__c,
                CRM_SectorCode__c
            FROM Absence__c
            WHERE CRM_AbsenceCategory__c = 'VIRKSOMHET'
        ];

        System.assertEquals('Error', messages[0].CRM_Status__c, 'Expecting CRM_Status__c = Error as arstall is null');
        System.assertEquals(0, result.size(), 'Expecting list to be empty(0) as the arstall is null');
    }
}