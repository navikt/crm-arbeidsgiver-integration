@IsTest
public class KafkaSykefravaerHandlerTest {

    @IsTest
    public static void testHandleMessagesInsert() {
        List<Account> accounts = new List<Account>();
        Account a1 = new Account();
        a1.Name = 'Test Employer 1';
        a1.INT_OrganizationNumber__c = '919300760';
        accounts.add(a1);

        Account a2 = new Account();
        a2.Name = 'Test Employer 2';
        a2.INT_OrganizationNumber__c = '12345678';
        accounts.add(a2);

        insert accounts;

        // Create KafkaMessage with Base64 encoded JSON-payloads matching account Test Employer 1
        List<KafkaMessage__c> messages = new List<KafkaMessage__c>();
        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'arbeidsgiver.sykefravarsstatistikk-v1';
        msg1.CRM_Key__c = 'd60775ed-249f-49e6-bd15-ff790b56cc07';
        msg1.CRM_Value__c = 'eyJ2aXJrc29taGV0U3lrZWZyYXbDpnIiOnsib3JnbnIiOiI5MTkzMDA3NjAiLCJuYXZuIjoiSEdOIEVMRUtUUk8gQVMiLCLDpXJzdGFsbCI6MjAyMCwia3ZhcnRhbCI6MywidGFwdGVEYWdzdmVyayI6MjU2LjIsIm11bGlnZURhZ3N2ZXJrIjoxOTg3LjcsImFudGFsbFBlcnNvbmVyIjozMywicHJvc2VudCI6MTIuOSwiZXJNYXNrZXJ0IjpmYWxzZSwia2F0ZWdvcmkiOiJWSVJLU09NSEVUIn0sIm7DpnJpbmc1U2lmZmVyU3lrZWZyYXbDpnIiOlt7ImthdGVnb3JpIjoiTsOGUklORzVTSUZGRVIiLCJrb2RlIjoiNDMyMTAiLCLDpXJzdGFsbCI6MjAyMCwia3ZhcnRhbCI6MywidGFwdGVEYWdzdmVyayI6Ijg1MzU5LjMiLCJtdWxpZ2VEYWdzdmVyayI6MjA3MzI2NC4wLCJhbnRhbGxQZXJzb25lciI6MzYzNTgsInByb3NlbnQiOjQuMSwiZXJNYXNrZXJ0IjpmYWxzZX1dLCJuw6ZyaW5nU3lrZWZyYXbDpnIiOnsia2F0ZWdvcmkiOiJOw4ZSSU5HMlNJRkZFUiIsImtvZGUiOiI0MyIsIsOlcnN0YWxsIjoyMDIwLCJrdmFydGFsIjozLCJ0YXB0ZURhZ3N2ZXJrIjoiMzQ2NjU3LjkiLCJtdWxpZ2VEYWdzdmVyayI6NzUzOTE1Mi42LCJhbnRhbGxQZXJzb25lciI6MTM1MDA3LCJwcm9zZW50Ijo0LjYsImVyTWFza2VydCI6ZmFsc2V9LCJzZWt0b3JTeWtlZnJhdsOmciI6eyJrYXRlZ29yaSI6IlNFS1RPUiIsImtvZGUiOiIzIiwiw6Vyc3RhbGwiOjIwMjAsImt2YXJ0YWwiOjMsInRhcHRlRGFnc3ZlcmsiOiIzOTM2NjIwLjYiLCJtdWxpZ2VEYWdzdmVyayI6OTUxMzI5NjAuNywiYW50YWxsUGVyc29uZXIiOjE5NDEzNzMsInByb3NlbnQiOjQuMSwiZXJNYXNrZXJ0IjpmYWxzZX0sImxhbmRTeWtlZnJhdsOmciI6eyJrYXRlZ29yaSI6IkxBTkQiLCJrb2RlIjoiTk8iLCLDpXJzdGFsbCI6MjAyMCwia3ZhcnRhbCI6MywidGFwdGVEYWdzdmVyayI6IjY0NzQ4ODUuNyIsIm11bGlnZURhZ3N2ZXJrIjoxNDM5NzExMDcuNSwiYW50YWxsUGVyc29uZXIiOjI5ODYzMTUsInByb3NlbnQiOjQuNSwiZXJNYXNrZXJ0IjpmYWxzZX19';
        messages.add(msg1);

        insert messages;

        Test.startTest();
        new KafkaMessageService(messages).handleMessages();
        Test.stopTest();

        List<Absence__c> result = [
            SELECT
                Id,
                CRM_Quarter__c,
                CRM_Year__c,
                CRM_Account__c,
                CRM_ErMaskert__c,
                CRM_Key__c,
                CRM_LandAntallPersoner__c,
                CRM_LandKode__c,
                CRM_LandMuligeDagsverk__c,
                CRM_LandProsent__c,
                CRM_LandTapteDagsverk__c,
                CRM_Naering5SifferKode__c,
                CRM_NaeringAntallPersoner__c,
                CRM_NaeringMuligeDagsverk__c,
                CRM_NaeringProsent__c,
                CRM_NaeringTapteDagsverk__c,
                CRM_SektorAntallPersoner__c,
                CRM_SektorKode__c,
                CRM_SektorMuligeDagsverk__c,
                CRM_SektorProsent__c,
                CRM_SektorTapteDagsverk__c,
                CRM_VirksomhetAntallPersoner__c,
                CRM_VirksomhetMuligDagsverk__c,
                CRM_VirksomhetProsent__c,
                CRM_VirksomhetTapteDagsverk__c
            FROM Absence__c
        ];
        System.assertEquals(1, result.size());
        System.assertEquals(3, result[0].CRM_Quarter__c);
        System.assertEquals(2020, result[0].CRM_Year__c);
        System.assertEquals(a1.Id, result[0].CRM_Account__c);
        System.assertEquals(false, result[0].CRM_ErMaskert__c);
        System.assertEquals('d60775ed-249f-49e6-bd15-ff790b56cc07', result[0].CRM_Key__c);
        System.assertEquals(33, result[0].CRM_VirksomhetAntallPersoner__c);
        System.assertEquals(1987.7, result[0].CRM_VirksomhetMuligDagsverk__c);
        System.assertEquals(256.2, result[0].CRM_VirksomhetTapteDagsverk__c);
        System.assertEquals(12.9, result[0].CRM_VirksomhetProsent__c);
        System.assertEquals('43210', result[0].CRM_Naering5SifferKode__c);
        System.assertEquals(36358, result[0].CRM_NaeringAntallPersoner__c);
        System.assertEquals(2073264.0, result[0].CRM_NaeringMuligeDagsverk__c);
        System.assertEquals(85359.3, result[0].CRM_NaeringTapteDagsverk__c);
        System.assertEquals(4.1, result[0].CRM_NaeringProsent__c);
        System.assertEquals(1941373, result[0].CRM_SektorAntallPersoner__c);
        System.assertEquals('3', result[0].CRM_SektorKode__c);
        System.assertEquals(95132960.7, result[0].CRM_SektorMuligeDagsverk__c);
        System.assertEquals(3936620.6, result[0].CRM_SektorTapteDagsverk__c);
        System.assertEquals(4.1, result[0].CRM_SektorProsent__c);
        System.assertEquals(2986315, result[0].CRM_LandAntallPersoner__c);
        System.assertEquals('NO', result[0].CRM_LandKode__c);
        System.assertEquals(143971107.5, result[0].CRM_LandMuligeDagsverk__c);
        System.assertEquals(6474885.7, result[0].CRM_LandTapteDagsverk__c);
        System.assertEquals(4.5, result[0].CRM_LandProsent__c);
    }
    @IsTest
    public static void testHandleMessagesUpdate() {
        Account a1 = new Account();
        a1.Name = 'Test Employer 1';
        a1.INT_OrganizationNumber__c = '919300760';
        insert a1;

        // Create KafkaMessage with Base64 encoded JSON-payloads matching account Test Employer 1
        List<KafkaMessage__c> messages = new List<KafkaMessage__c>();
        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'arbeidsgiver.sykefravarsstatistikk-v1';
        msg1.CRM_Key__c = 'd60775ed-249f-49e6-bd15-ff790b56cc07';
        msg1.CRM_Value__c = 'eyJ2aXJrc29taGV0U3lrZWZyYXbDpnIiOnsib3JnbnIiOiI5MTkzMDA3NjAiLCJuYXZuIjoiSEdOIEVMRUtUUk8gQVMiLCLDpXJzdGFsbCI6MjAyMCwia3ZhcnRhbCI6MywidGFwdGVEYWdzdmVyayI6MjU2LjIsIm11bGlnZURhZ3N2ZXJrIjoxOTg3LjcsImFudGFsbFBlcnNvbmVyIjozMywicHJvc2VudCI6MTIuOSwiZXJNYXNrZXJ0IjpmYWxzZSwia2F0ZWdvcmkiOiJWSVJLU09NSEVUIn0sIm7DpnJpbmc1U2lmZmVyU3lrZWZyYXbDpnIiOlt7ImthdGVnb3JpIjoiTsOGUklORzVTSUZGRVIiLCJrb2RlIjoiNDMyMTAiLCLDpXJzdGFsbCI6MjAyMCwia3ZhcnRhbCI6MywidGFwdGVEYWdzdmVyayI6Ijg1MzU5LjMiLCJtdWxpZ2VEYWdzdmVyayI6MjA3MzI2NC4wLCJhbnRhbGxQZXJzb25lciI6MzYzNTgsInByb3NlbnQiOjQuMSwiZXJNYXNrZXJ0IjpmYWxzZX1dLCJuw6ZyaW5nU3lrZWZyYXbDpnIiOnsia2F0ZWdvcmkiOiJOw4ZSSU5HMlNJRkZFUiIsImtvZGUiOiI0MyIsIsOlcnN0YWxsIjoyMDIwLCJrdmFydGFsIjozLCJ0YXB0ZURhZ3N2ZXJrIjoiMzQ2NjU3LjkiLCJtdWxpZ2VEYWdzdmVyayI6NzUzOTE1Mi42LCJhbnRhbGxQZXJzb25lciI6MTM1MDA3LCJwcm9zZW50Ijo0LjYsImVyTWFza2VydCI6ZmFsc2V9LCJzZWt0b3JTeWtlZnJhdsOmciI6eyJrYXRlZ29yaSI6IlNFS1RPUiIsImtvZGUiOiIzIiwiw6Vyc3RhbGwiOjIwMjAsImt2YXJ0YWwiOjMsInRhcHRlRGFnc3ZlcmsiOiIzOTM2NjIwLjYiLCJtdWxpZ2VEYWdzdmVyayI6OTUxMzI5NjAuNywiYW50YWxsUGVyc29uZXIiOjE5NDEzNzMsInByb3NlbnQiOjQuMSwiZXJNYXNrZXJ0IjpmYWxzZX0sImxhbmRTeWtlZnJhdsOmciI6eyJrYXRlZ29yaSI6IkxBTkQiLCJrb2RlIjoiTk8iLCLDpXJzdGFsbCI6MjAyMCwia3ZhcnRhbCI6MywidGFwdGVEYWdzdmVyayI6IjY0NzQ4ODUuNyIsIm11bGlnZURhZ3N2ZXJrIjoxNDM5NzExMDcuNSwiYW50YWxsUGVyc29uZXIiOjI5ODYzMTUsInByb3NlbnQiOjQuNSwiZXJNYXNrZXJ0IjpmYWxzZX19';
        messages.add(msg1);

        insert messages;

        new KafkaMessageService(messages).handleMessages();

        List<Absence__c> result = [
            SELECT
                Id,
                CRM_Quarter__c,
                CRM_Year__c,
                CRM_Account__c,
                CRM_ErMaskert__c,
                CRM_Key__c,
                CRM_NaeringTapteDagsverk__c,
                CRM_VirksomhetTapteDagsverk__c
            FROM Absence__c
        ];
        System.assertEquals(1, result.size());
        System.assertEquals(3, result[0].CRM_Quarter__c);
        System.assertEquals(2020, result[0].CRM_Year__c);
        System.assertEquals(a1.Id, result[0].CRM_Account__c);
        System.assertEquals(false, result[0].CRM_ErMaskert__c);
        System.assertEquals('d60775ed-249f-49e6-bd15-ff790b56cc07', result[0].CRM_Key__c);
        System.assertEquals(256.2, result[0].CRM_VirksomhetTapteDagsverk__c);
        System.assertEquals(85359.3, result[0].CRM_NaeringTapteDagsverk__c);

        // Create KafkaMessage with same CRM_key and changed values for CRM_VirksomhetTapteDagsverk__c CRM_NaeringTapteDagsverk__c
        List<KafkaMessage__c> messagesUpdate = new List<KafkaMessage__c>();
        KafkaMessage__c msg2 = new KafkaMessage__c();
        msg2.CRM_Topic__c = 'arbeidsgiver.sykefravarsstatistikk-v1';
        msg2.CRM_Key__c = 'd60775ed-249f-49e6-bd15-ff790b56cc07';
        msg2.CRM_Value__c = 'eyJ2aXJrc29taGV0U3lrZWZyYXbDpnIiOnsib3JnbnIiOiI5MTkzMDA3NjAiLCJuYXZuIjoiSEdOIEVMRUtUUk8gQVMiLCLDpXJzdGFsbCI6MjAyMCwia3ZhcnRhbCI6MywidGFwdGVEYWdzdmVyayI6MjExLjEsIm11bGlnZURhZ3N2ZXJrIjoxOTg3LjcsImFudGFsbFBlcnNvbmVyIjozMywicHJvc2VudCI6MTIuOSwiZXJNYXNrZXJ0IjpmYWxzZSwia2F0ZWdvcmkiOiJWSVJLU09NSEVUIn0sIm7DpnJpbmc1U2lmZmVyU3lrZWZyYXbDpnIiOlt7ImthdGVnb3JpIjoiTsOGUklORzVTSUZGRVIiLCJrb2RlIjoiNDMyMTAiLCLDpXJzdGFsbCI6MjAyMCwia3ZhcnRhbCI6MywidGFwdGVEYWdzdmVyayI6Ijg1MTExLjEiLCJtdWxpZ2VEYWdzdmVyayI6MjA3MzI2NC4wLCJhbnRhbGxQZXJzb25lciI6MzYzNTgsInByb3NlbnQiOjQuMSwiZXJNYXNrZXJ0IjpmYWxzZX1dLCJuw6ZyaW5nU3lrZWZyYXbDpnIiOnsia2F0ZWdvcmkiOiJOw4ZSSU5HMlNJRkZFUiIsImtvZGUiOiI0MyIsIsOlcnN0YWxsIjoyMDIwLCJrdmFydGFsIjozLCJ0YXB0ZURhZ3N2ZXJrIjoiMzQ2MTExLjEiLCJtdWxpZ2VEYWdzdmVyayI6NzUzOTE1Mi42LCJhbnRhbGxQZXJzb25lciI6MTM1MDA3LCJwcm9zZW50Ijo0LjYsImVyTWFza2VydCI6ZmFsc2V9LCJzZWt0b3JTeWtlZnJhdsOmciI6eyJrYXRlZ29yaSI6IlNFS1RPUiIsImtvZGUiOiIzIiwiw6Vyc3RhbGwiOjIwMjAsImt2YXJ0YWwiOjMsInRhcHRlRGFnc3ZlcmsiOiIzOTM2NjIwLjYiLCJtdWxpZ2VEYWdzdmVyayI6OTUxMzI5NjAuNywiYW50YWxsUGVyc29uZXIiOjE5NDEzNzMsInByb3NlbnQiOjQuMSwiZXJNYXNrZXJ0IjpmYWxzZX0sImxhbmRTeWtlZnJhdsOmciI6eyJrYXRlZ29yaSI6IkxBTkQiLCJrb2RlIjoiTk8iLCLDpXJzdGFsbCI6MjAyMCwia3ZhcnRhbCI6MywidGFwdGVEYWdzdmVyayI6IjY0NzQ4ODUuNyIsIm11bGlnZURhZ3N2ZXJrIjoxNDM5NzExMDcuNSwiYW50YWxsUGVyc29uZXIiOjI5ODYzMTUsInByb3NlbnQiOjQuNSwiZXJNYXNrZXJ0IjpmYWxzZX19';
        messagesUpdate.add(msg2);

        insert messagesUpdate;
        
        Test.startTest();
        new KafkaMessageService(messagesUpdate).handleMessages();
        Test.stopTest();

        List<Absence__c> resultUpdated = [
            SELECT
                Id,
                CRM_Quarter__c,
                CRM_Year__c,
                CRM_Account__c,
                CRM_ErMaskert__c,
                CRM_Key__c,
                CRM_NaeringTapteDagsverk__c,
                CRM_VirksomhetTapteDagsverk__c
            FROM Absence__c
        ];
        System.assertEquals(1, resultUpdated.size());
        System.assertEquals(3, resultUpdated[0].CRM_Quarter__c);
        System.assertEquals(2020, resultUpdated[0].CRM_Year__c);
        System.assertEquals(a1.Id, resultUpdated[0].CRM_Account__c);
        System.assertEquals(false, resultUpdated[0].CRM_ErMaskert__c);
        System.assertEquals('d60775ed-249f-49e6-bd15-ff790b56cc07', resultUpdated[0].CRM_Key__c);
        System.assertEquals(211.1, resultUpdated[0].CRM_VirksomhetTapteDagsverk__c);
        System.assertEquals(85111.1, resultUpdated[0].CRM_NaeringTapteDagsverk__c);
    }
}
