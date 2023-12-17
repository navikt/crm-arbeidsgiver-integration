@IsTest
public class SickLeaveEmployerHandlerTest {

    @IsTest
    public static void testHandleMessageInsert() {
        List<Account> accounts = new List<Account>();
        Account a1 = new Account();
        a1.Name = 'Test Employer 1';
        a1.INT_OrganizationNumber__c = '919300760';
        a1.INT_IndustryCode__c = '43.210';
        accounts.add(a1);

        Account a2 = new Account();
        a2.Name = 'Test Employer 2';
        a2.INT_OrganizationNumber__c = '12345678';
        a2.INT_IndustryCode__c = '43.210';
        accounts.add(a2);

        insert accounts;

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

        Test.startTest();
        new KafkaMessageService(messages).handleMessages();
        Test.stopTest();

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
        ];
        System.assertEquals(1, result.size());
        System.assertEquals(2, result[0].CRM_Quarter__c);
        System.assertEquals(2023, result[0].CRM_Year__c);
        System.assertEquals(a2.Id, result[0].CRM_Account__c);
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
    }
}