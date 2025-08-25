@IsTest
public class SickLeaveHandlerTest {
    @IsTest
    public static void testHandleMessageInsert() {
        // Create KafkaMessage with Base64 encoded JSON-payloads
        List<KafkaMessage__c> messages = new List<KafkaMessage__c>();

        String json = '{"kategori":"BRANSJE","kode":"SYKEHUS","sistePubliserteKvartal":{"årstall":2023,"kvartal":2,"prosent":2.0,"tapteDagsverk":10000000.0,"muligeDagsverk":500000000.0,"antallPersoner":2500000,"erMaskert":false},"siste4Kvartal":{"prosent":1.9,"tapteDagsverk":38000000.0,"muligeDagsverk":2000000000.0,"erMaskert":true,"kvartaler":[{"årstall":2020,"kvartal": 2},{"årstall":2020,"kvartal":1},{"årstall":2019,"kvartal":4},{"årstall":2019,"kvartal":3}]}}';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(json));

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'pia.sykefravarsstatistikk-bransje-v1';
        msg1.CRM_Key__c = 'ewogICJrYXRlZ29yaSI6ICJCUkFOU0pFIiwKICAia29kZSI6ICJTWUtFSFVTIiwKICAia3ZhcnRhbCI6ICIyIiwKICAiw6Vyc3RhbGwiOiAiMjAyMyIKfQ==';
        //msg1.CRM_Value__c = 'eyJrYXRlZ29yaSI6IkJSQU5TSkUiLCJrb2RlIjoiU1lLRUhVUyIsInNpc3RlUHVibGlzZXJ0ZUt2YXJ0YWwiOnsiw6Vyc3RhbGwiOjIwMjMsImt2YXJ0YWwiOjIsInByb3NlbnQiOjIuMCwidGFwdGVEYWdzdmVyayI6MTAwMDAwMDAuMCwibXVsaWdlRGFnc3ZlcmsiOjUwMDAwMDAwMC4wLCJhbnRhbGxQZXJzb25lciI6MjUwMDAwMCwiZXJNYXNrZXJ0IjpmYWxzZX0sInNpc3RlNEt2YXJ0YWwiOnsicHJvc2VudCI6MS45LCJ0YXB0ZURhZ3N2ZXJrIjozODAwMDAwMC4wLCJtdWxpZ2VEYWdzdmVyayI6MjAwMDAwMDAwMC4wLCJlck1hc2tlcnQiOmZhbHNlLCJrdmFydGFsZXIiOlt7IsOlcnN0YWxsIjoyMDIwLCJrdmFydGFsIjogMn0seyLDpXJzdGFsbCI6MjAyMCwia3ZhcnRhbCI6MX0seyLDpXJzdGFsbCI6MjAxOSwia3ZhcnRhbCI6NH0seyLDpXJzdGFsbCI6MjAxOSwia3ZhcnRhbCI6M31dfX0=';
        msg1.CRM_Value__c = encodedValue;

        messages.add(msg1);

        insert messages;

        Test.startTest();
        new KafkaMessageService(messages).handleMessages();
        Test.stopTest();

        List<Absence__c> result = [
            SELECT
                Id,
                CRM_Key__c,
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
        ];
        System.assertEquals(1, result.size());
        System.assertEquals(2, result[0].CRM_Quarter__c);
        System.assertEquals(2023, result[0].CRM_Year__c);
        System.assertEquals(false, result[0].CRM_IsHidden__c);
        System.assertEquals('BRANSJE', result[0].CRM_AbsenceCategory__c);
        System.assertEquals('ewogICJrYXRlZ29yaSI6ICJCUkFOU0pFIiwKICAia29kZSI6ICJTWUtFSFVTIiwKICAia3ZhcnRhbCI6ICIyIiwKICAiw6Vyc3RhbGwiOiAiMjAyMyIKfQ==', result[0].CRM_Key__c);
        System.assertEquals(2500000, result[0].CRM_NumberOfPeople__c);
        System.assertEquals(500000000.0, result[0].CRM_PossibleDaysWork__c);
        System.assertEquals(10000000.0, result[0].CRM_LostDaysWork__c);
        System.assertEquals(2.0, result[0].CRM_Percent__c);
        System.assertEquals(38000000.0, result[0].CRM_Last4QuartersLostDaysWork__c);
        System.assertEquals(2000000000.0, result[0].CRM_Last4QuartersPossibleDaysWork__c);
        System.assertEquals(1.9, result[0].CRM_Last4QuartersPercent__c);
        System.assertEquals(true, result[0].CRM_Last4QuartersIsHidden__c);

    }

    @IsTest
    public static void testHandleMessageUpdate() {
        List<KafkaMessage__c> messages = new List<KafkaMessage__c>();

        String json1 = '{"kategori":"NÆRING","kode":"03","sistePubliserteKvartal":{"årstall":2023,"kvartal":3,"prosent":5.0,"tapteDagsverk":1000.0,"muligeDagsverk":5000.0,"antallPersoner":250,"erMaskert":false},"siste4Kvartal":{"prosent":3.9,"tapteDagsverk":3800.0,"muligeDagsverk":3000.0,"erMaskert":false,"kvartaler":[{"årstall":2020,"kvartal": 2},{"årstall":2020,"kvartal":1},{"årstall":2019,"kvartal":4},{"årstall":2019,"kvartal":3}]}}';
        String encodedValue1 = EncodingUtil.base64Encode(Blob.valueOf(json1));

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'pia.sykefravarsstatistikk-naring-v1';
        msg1.CRM_Key__c = 'ewogICJrYXRlZ29yaSI6ICJCUkFOU0pFIiwKICAia29kZSI6ICJTWUtFSFVTIiwKICAia3ZhcnRhbCI6ICIyIiwKICAiw6Vyc3RhbGwiOiAiMjAyMyIKfQ==';
        msg1.CRM_Value__c = encodedValue1;

        messages.add(msg1);

        insert messages;

        List<KafkaMessage__c> km = [
            SELECT Id
            FROM KafkaMessage__c
        ];
        System.assertEquals(1, km.size(), 'Messages Inserted');

        SickLeaveHandler handler = new SickLeaveHandler();
        handler.processMessages(messages);

        List<Absence__c> result = [
            SELECT
                Id,
                CRM_Key__c,
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
        ];
        System.assertEquals(1, result.size());
        System.assertEquals(3, result[0].CRM_Quarter__c);
        System.assertEquals(2023, result[0].CRM_Year__c);
        System.assertEquals(false, result[0].CRM_IsHidden__c);
        System.assertEquals('ewogICJrYXRlZ29yaSI6ICJCUkFOU0pFIiwKICAia29kZSI6ICJTWUtFSFVTIiwKICAia3ZhcnRhbCI6ICIyIiwKICAiw6Vyc3RhbGwiOiAiMjAyMyIKfQ==', result[0].CRM_Key__c);
        System.assertEquals(5.0, result[0].CRM_Percent__c);
        System.assertEquals(3000.0, result[0].CRM_Last4QuartersPossibleDaysWork__c);
        System.assertEquals(3.9, result[0].CRM_Last4QuartersPercent__c);

        // Create KafkaMessage with same CRM_key and changed values
        List<KafkaMessage__c> messagesUpdate = new List<KafkaMessage__c>();
        String json2 = '{"kategori":"NÆRING","kode":"03","sistePubliserteKvartal":{"årstall":2023,"kvartal":3,"prosent":4.0,"tapteDagsverk":1000.0,"muligeDagsverk":5000.0,"antallPersoner":250,"erMaskert":false},"siste4Kvartal":{"prosent":3.9,"tapteDagsverk":3800.0,"muligeDagsverk":2000.0,"erMaskert":false,"kvartaler":[{"årstall":2020,"kvartal": 2},{"årstall":2020,"kvartal":1},{"årstall":2019,"kvartal":4},{"årstall":2019,"kvartal":3}]}}';
        String encodedValue2 = EncodingUtil.base64Encode(Blob.valueOf(json2));

        KafkaMessage__c msg2 = new KafkaMessage__c();
        msg2.CRM_Topic__c = 'pia.sykefravarsstatistikk-naring-v1';
        msg2.CRM_Key__c = 'ewogICJrYXRlZ29yaSI6ICJCUkFOU0pFIiwKICAia29kZSI6ICJTWUtFSFVTIiwKICAia3ZhcnRhbCI6ICIyIiwKICAiw6Vyc3RhbGwiOiAiMjAyMyIKfQ==';
        msg2.CRM_Value__c = encodedValue2;

        messagesUpdate.add(msg2); 

        Test.startTest();
        SickLeaveHandler handlerUpdate = new SickLeaveHandler();
        handlerUpdate.processMessages(messagesUpdate);
        Test.stopTest();

        List<Absence__c> resultUpdated = [
            SELECT
                Id,
                CRM_Key__c,
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
        ];

        System.assertEquals(1, resultUpdated.size());
        System.assertEquals(3, resultUpdated[0].CRM_Quarter__c);
        System.assertEquals(2023, resultUpdated[0].CRM_Year__c);
        System.assertEquals(false, resultUpdated[0].CRM_IsHidden__c);
        System.assertEquals('ewogICJrYXRlZ29yaSI6ICJCUkFOU0pFIiwKICAia29kZSI6ICJTWUtFSFVTIiwKICAia3ZhcnRhbCI6ICIyIiwKICAiw6Vyc3RhbGwiOiAiMjAyMyIKfQ==', result[0].CRM_Key__c);
        System.assertEquals(4.0, resultUpdated[0].CRM_Percent__c);
        System.assertEquals(2000.0, resultUpdated[0].CRM_Last4QuartersPossibleDaysWork__c);
        System.assertEquals(3.9, resultUpdated[0].CRM_Last4QuartersPercent__c);
    }

    @IsTest
    public static void testHandleMessageInsertWithNullsMaskert() {
        // Create KafkaMessage with Base64 encoded JSON-payloads
        List<KafkaMessage__c> messages = new List<KafkaMessage__c>();

        String json = '{"kategori":"BRANSJE","kode":"SYKEHUS","sistePubliserteKvartal":{"årstall":2023,"kvartal":2,"prosent":null,"tapteDagsverk":null,"muligeDagsverk":null,"antallPersoner":2500000,"erMaskert":true},"siste4Kvartal":{"prosent":1.9,"tapteDagsverk":null,"muligeDagsverk":null,"erMaskert":true,"kvartaler":[{"årstall":2020,"kvartal": 2},{"årstall":2020,"kvartal":1},{"årstall":2019,"kvartal":4},{"årstall":2019,"kvartal":3}]}}';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(json));

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'pia.sykefravarsstatistikk-bransje-v1';
        msg1.CRM_Key__c = 'ewogICJrYXRlZ29yaSI6ICJCUkFOU0pFIiwKICAia29kZSI6ICJTWUtFSFVTIiwKICAia3ZhcnRhbCI6ICIyIiwKICAiw6Vyc3RhbGwiOiAiMjAyMyIKfQ==';
        msg1.CRM_Value__c = encodedValue;

        messages.add(msg1);

        insert messages;

        Test.startTest();
        new KafkaMessageService(messages).handleMessages();
        Test.stopTest();

        List<Absence__c> result = [
            SELECT
                Id,
                CRM_Key__c,
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
        ];
        System.assertEquals(1, result.size());
        System.assertEquals(2, result[0].CRM_Quarter__c);
        System.assertEquals(2023, result[0].CRM_Year__c);
        System.assertEquals(true, result[0].CRM_IsHidden__c);
        System.assertEquals('ewogICJrYXRlZ29yaSI6ICJCUkFOU0pFIiwKICAia29kZSI6ICJTWUtFSFVTIiwKICAia3ZhcnRhbCI6ICIyIiwKICAiw6Vyc3RhbGwiOiAiMjAyMyIKfQ==', result[0].CRM_Key__c);
        System.assertEquals(2500000, result[0].CRM_NumberOfPeople__c);
        System.assertEquals(null, result[0].CRM_PossibleDaysWork__c);
        System.assertEquals(null, result[0].CRM_LostDaysWork__c);
        System.assertEquals(null, result[0].CRM_Percent__c);
        System.assertEquals(null, result[0].CRM_Last4QuartersLostDaysWork__c);
        System.assertEquals(null, result[0].CRM_Last4QuartersPossibleDaysWork__c);
        System.assertEquals(1.9, result[0].CRM_Last4QuartersPercent__c);
        System.assertEquals(true, result[0].CRM_Last4QuartersIsHidden__c);

    }
}