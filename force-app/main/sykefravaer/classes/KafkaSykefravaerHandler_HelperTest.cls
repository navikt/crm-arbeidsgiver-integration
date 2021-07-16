@IsTest
public class KafkaSykefravaerHandler_HelperTest {
    @IsTest
    private static void testConvertKafkaToSykefravaer() {
        String testJson = KafkaSykefravaerHandler_ModelTest.json;
        List<KafkaSykefravaerHandler_Model> expected = new List<KafkaSykefravaerHandler_Model>{
            KafkaSykefravaerHandler_Model.parse(testJson, 'd60775ed-249f-49e6-bd15-ff790b56cc07')
        };

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'arbeidsgiver.sykefravarsstatistikk-v1';
        msg1.CRM_Key__c = 'd60775ed-249f-49e6-bd15-ff790b56cc07';
        msg1.CRM_Value__c = 'eyJ2aXJrc29taGV0U3lrZWZyYXbDpnIiOnsib3JnbnIiOiIxMjM0NTY3OCIsIm5hdm4iOiJFTEVLVFJPIFRFU1QgQVMiLCLDpXJzdGFsbCI6MjAyMCwia3ZhcnRhbCI6MywidGFwdGVEYWdzdmVyayI6MjU2LjIsIm11bGlnZURhZ3N2ZXJrIjoxOTg3LjcsImFudGFsbFBlcnNvbmVyIjozMywicHJvc2VudCI6MTIuOSwiZXJNYXNrZXJ0IjpmYWxzZSwia2F0ZWdvcmkiOiJWSVJLU09NSEVUIn0sIm7DpnJpbmc1U2lmZmVyU3lrZWZyYXbDpnIiOlt7ImthdGVnb3JpIjoiTsOGUklORzVTSUZGRVIiLCJrb2RlIjoiNDMyMTAiLCLDpXJzdGFsbCI6MjAyMCwia3ZhcnRhbCI6MywidGFwdGVEYWdzdmVyayI6Ijg1MzU5LjMiLCJtdWxpZ2VEYWdzdmVyayI6MjA3MzI2NC4wLCJhbnRhbGxQZXJzb25lciI6MzYzNTgsInByb3NlbnQiOjQuMSwiZXJNYXNrZXJ0IjpmYWxzZX1dLCJuw6ZyaW5nU3lrZWZyYXbDpnIiOnsia2F0ZWdvcmkiOiJOw4ZSSU5HMlNJRkZFUiIsImtvZGUiOiI0MyIsIsOlcnN0YWxsIjoyMDIwLCJrdmFydGFsIjozLCJ0YXB0ZURhZ3N2ZXJrIjoiMzQ2NjU3LjkiLCJtdWxpZ2VEYWdzdmVyayI6NzUzOTE1Mi42LCJhbnRhbGxQZXJzb25lciI6MTM1MDA3LCJwcm9zZW50Ijo0LjYsImVyTWFza2VydCI6ZmFsc2V9LCJzZWt0b3JTeWtlZnJhdsOmciI6eyJrYXRlZ29yaSI6IlNFS1RPUiIsImtvZGUiOiIzIiwiw6Vyc3RhbGwiOjIwMjAsImt2YXJ0YWwiOjMsInRhcHRlRGFnc3ZlcmsiOiIzOTM2NjIwLjYiLCJtdWxpZ2VEYWdzdmVyayI6OTUxMzI5NjAuNywiYW50YWxsUGVyc29uZXIiOjE5NDEzNzMsInByb3NlbnQiOjQuMSwiZXJNYXNrZXJ0IjpmYWxzZX0sImxhbmRTeWtlZnJhdsOmciI6eyJrYXRlZ29yaSI6IkxBTkQiLCJrb2RlIjoiTk8iLCLDpXJzdGFsbCI6MjAyMCwia3ZhcnRhbCI6MywidGFwdGVEYWdzdmVyayI6IjY0NzQ4ODUuNyIsIm11bGlnZURhZ3N2ZXJrIjoxNDM5NzExMDcuNSwiYW50YWxsUGVyc29uZXIiOjI5ODYzMTUsInByb3NlbnQiOjQuNSwiZXJNYXNrZXJ0IjpmYWxzZX19';

        Test.StartTest();
        List<KafkaSykefravaerHandler_Model> actual = KafkaSykefravaerHandler_Helper.convertKafkaToSykefravaer(
            new List<KafkaMessage__c>{ msg1 }
        );
        Test.StopTest();

        System.assertEquals('12345678', actual[0].orgnr);
        System.assertEquals(expected[0].orgnr, actual[0].orgnr);
    }

    @IsTest
    private static void testGetOrgNumbersFromSykefravaer() {
        String testJson = KafkaSykefravaerHandler_ModelTest.json;
        List<KafkaSykefravaerHandler_Model> sykefravaer = new List<KafkaSykefravaerHandler_Model>{
            KafkaSykefravaerHandler_Model.parse(testJson, 'd60775ed-249f-49e6-bd15-ff790b56cc07')
        };

        Test.StartTest();
        List<String> orgNumbers = KafkaSykefravaerHandler_Helper.getOrgNumbersFromSykefravaer(sykefravaer);
        Test.StopTest();

        System.assertEquals(1, orgNumbers.size(), 'Only one json sent in');
        System.assertEquals('12345678', orgNumbers[0], 'Only one json sent in');
    }

    @IsTest
    private static void testFetchAccounts() {
        Account acc1 = new Account(
            Name = 'Test Employer 1',
            INT_OrganizationNumber__c = '99999999',
            INT_IndustryCode__c = '41.110'
        );
        Account acc2 = new Account(Name = 'Test Employer 2', INT_OrganizationNumber__c = '77777777');
        insert new List<Account>{ acc1, acc2 };

        Test.StartTest();
        Map<String, Account> result = KafkaSykefravaerHandler_Helper.fetchAccounts(
            new List<String>{ acc1.INT_OrganizationNumber__c, acc2.INT_OrganizationNumber__c }
        );
        Test.StopTest();

        System.assertEquals(acc1.Id, result.get(acc1.INT_OrganizationNumber__c).Id, 'Should be same account');
        System.assertEquals(acc2.Id, result.get(acc2.INT_OrganizationNumber__c).Id, 'Should be same account');
    }

    @IsTest
    private static void testConvertSykefravaerToAbsence() {
        Account acc = new Account(
            Name = 'Test Employer 1',
            INT_OrganizationNumber__c = '12345678',
            INT_IndustryCode__c = '43.210'
        );
        insert acc;

        String testJson = KafkaSykefravaerHandler_ModelTest.json;
        List<KafkaSykefravaerHandler_Model> sykefravaer = new List<KafkaSykefravaerHandler_Model>{
            KafkaSykefravaerHandler_Model.parse(testJson, 'd60775ed-249f-49e6-bd15-ff790b56cc07')
        };

        List<String> organisationNumbers = KafkaSykefravaerHandler_Helper.getOrgNumbersFromSykefravaer(sykefravaer);

        Map<String, Account> accountMap = KafkaSykefravaerHandler_Helper.fetchAccounts(organisationNumbers);

        Test.StartTest();
        List<Absence__c> result = KafkaSykefravaerHandler_Helper.convertSykefravaerToAbsence(sykefravaer, accountMap);
        Test.StopTest();

        System.assertEquals(1, result.size(), 'Only 1 sykefravaer');
        System.assertEquals(acc.Id, result[0].CRM_Account__c, 'Should have used the existing account');
        System.assertEquals('d60775ed-249f-49e6-bd15-ff790b56cc07', result[0].CRM_Key__c);
        System.assertEquals(2020, result[0].CRM_Year__c);
        System.assertEquals(256.2, result[0].CRM_VirksomhetTapteDagsverk__c);
        System.assertEquals(36358, result[0].CRM_NaeringAntallPersoner__c);
        System.assertEquals(4.1, result[0].CRM_SektorProsent__c);
        System.assertEquals(143971107.5, result[0].CRM_LandMuligeDagsverk__c);
    }
}
