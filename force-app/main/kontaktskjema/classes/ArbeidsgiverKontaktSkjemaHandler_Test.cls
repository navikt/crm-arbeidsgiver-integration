@IsTest
public class ArbeidsgiverKontaktSkjemaHandler_Test {
    private static final String JSON_FORM =
        '{' +
        '   \"temaType\": \"REKRUTTERING\",' +
        '   \"fylkesenhetsnr\": \"0300\",' +
        '   \"kommunenr\": \"3033\",' +
        '   \"bedriftsnavn\": \"Finstadtunet\",' +
        '   \"orgnr\": \"97311363\",' +
        '   \"epost\": \"darth.vader@sith.no\",' +
        '   \"telefonnr\": \"90080900\",' +
        '   \"navn\": \"Darth Vader\"' +
        '}';

    @isTest
    static void processBulkSuccess() {
        ArbeidsgiverKontaktSkjemaHandler handler = new ArbeidsgiverKontaktSkjemaHandler();
        handler.processMessages(
            new List<KafkaMessage__c>{ toKafkaMessage(JSON_FORM), toKafkaMessage(JSON_FORM), toKafkaMessage(JSON_FORM) }
        );

        List<CustomOpportunity__c> opportunities = [SELECT Id FROM CustomOpportunity__c];

        System.assertEquals(3, opportunities.size(), '3 Opportunities inserted.');
    }

    @isTest
    static void processSuccess() {
        String json =
            '{' +
            '   \"temaType\": \"FOREBYGGE_SYKEFRAVÆR\",' +
            '   \"fylkesenhetsnr\": \"0300\",' +
            '   \"kommunenr\": \"3033\",' +
            '   \"bedriftsnavn\": \"Finstadtunet\",' +
            '   \"orgnr\": \"97311363\",' +
            '   \"epost\": \"test@test.no\",' +
            '   \"telefonnr\": \"90080900\",' +
            '   \"navn\": \"TestNavn\"' +
            '}';

        ArbeidsgiverKontaktSkjemaHandler handler = new ArbeidsgiverKontaktSkjemaHandler();
        handler.processMessages(new List<KafkaMessage__c>{ toKafkaMessage(json) });

        List<CustomOpportunity__c> opportunities = [
            SELECT Id, INT_MunicipalityNumber__c, INT_RegionNumber__c
            FROM CustomOpportunity__c
        ];

        System.assertEquals('3033', opportunities[0].INT_MunicipalityNumber__c, 'Correct municipality');
        System.assertEquals('0300', opportunities[0].INT_RegionNumber__c, 'Correct region number');
        System.assertEquals(1, opportunities.size(), 'Opportunity inserted');
    }

    @isTest
    private static void processError() {
        String json =
            '{' +
            '   \"temaType\": \"REKRUTTERING\",' +
            '   \"fylkesenhetsnr\": \"0300\",' +
            '   \"kommunenr\": \"3033\",' +
            '   \"bedriftsnavn\": \"Finstadtunet\",' +
            '   \"orgnr\": \"97311363\",' +
            '   \"epost\": \"darth.vader@sith.no\",' +
            '   \"telefonnr\": \"90080900\",' +
            '   \"navn\": \"Darth Vader\"';

        List<KafkaMessage__c> messages = new List<KafkaMessage__c>{ toKafkaMessage(json) };
        ArbeidsgiverKontaktSkjemaHandler handler = new ArbeidsgiverKontaktSkjemaHandler();
        handler.processMessages(messages);

        List<CustomOpportunity__c> opportunities = [SELECT Id, Contact__c FROM CustomOpportunity__c];

        System.assertEquals(0, opportunities.size(), 'No opportunities');
    }

    @isTest
    static void processWithExistingAccount() {
        Account acc = new Account(Name = 'Test Employer 1', INT_OrganizationNumber__c = '97311363');
        insert acc;

        ArbeidsgiverKontaktSkjemaHandler handler = new ArbeidsgiverKontaktSkjemaHandler();
        handler.processMessages(new List<KafkaMessage__c>{ toKafkaMessage(JSON_FORM) });

        List<CustomOpportunity__c> opportunities = [SELECT Id, Account__c FROM CustomOpportunity__c];

        System.assertEquals(1, opportunities.size(), 'Opportunity inserted.');
        System.assertEquals(acc.Id, opportunities[0].Account__c, 'Correct account populated');
    }

    @isTest
    static void missingOrgNumber() {
        String json =
            '{' +
            '   \"temaType\": \"REKRUTTERING\",' +
            '   \"fylkesenhetsnr\": \"0300\",' +
            '   \"kommunenr\": \"3033\",' +
            '   \"bedriftsnavn\": \"Finstadtunet\",' +
            '   \"epost\": \"test@test.no\",' +
            '   \"telefonnr\": \"90080900\",' +
            '   \"navn\": \"TestNavn\"' +
            '}';

        ArbeidsgiverKontaktSkjemaHandler handler = new ArbeidsgiverKontaktSkjemaHandler();
        handler.processMessages(new List<KafkaMessage__c>{ toKafkaMessage(json) });

        List<CustomOpportunity__c> opportunities = [SELECT Id, Account__c FROM CustomOpportunity__c];

        System.assertEquals(1, opportunities.size(), 'Opportunity inserted.');
        System.assertEquals(null, opportunities[0].Account__c, 'Correct account populated');
    }

    @isTest
    static void accountNotFound() {
        ArbeidsgiverKontaktSkjemaHandler handler = new ArbeidsgiverKontaktSkjemaHandler();
        handler.processMessages(new List<KafkaMessage__c>{ toKafkaMessage(JSON_FORM) });

        List<CustomOpportunity__c> opportunities = [SELECT Id, Account__c FROM CustomOpportunity__c];

        System.assertEquals(null, opportunities[0].Account__c, 'Correct account populated');
        System.assertEquals(1, opportunities.size(), 'Opportunity inserted.');
    }

    @isTest
    private static void processExistingContact() {
        Contact con = new Contact(
            TAG_Informed__c = true,
            FirstName = 'Darth',
            LastName = 'Vader',
            Email = 'darth.vader@sith.no'
        );
        insert con;

        ArbeidsgiverKontaktSkjemaHandler handler = new ArbeidsgiverKontaktSkjemaHandler();
        handler.processMessages(new List<KafkaMessage__c>{ toKafkaMessage(JSON_FORM) });

        List<CustomOpportunity__c> opportunities = [SELECT Id, Contact__c FROM CustomOpportunity__c];

        System.assertEquals(con.Id, opportunities[0].Contact__c, 'Existing contact populated.');
    }

    @isTest
    private static void processNewContact() {
        ArbeidsgiverKontaktSkjemaHandler handler = new ArbeidsgiverKontaktSkjemaHandler();
        handler.processMessages(new List<KafkaMessage__c>{ toKafkaMessage(JSON_FORM) });

        List<CustomOpportunity__c> opportunities = [SELECT Id, Contact__c FROM CustomOpportunity__c];
        List<Contact> contacts = [SELECT Id, AccountId FROM Contact];

        System.assertEquals(contacts[0].Id, opportunities[0].Contact__c, 'Existing contact populated.');
        System.assertEquals(1, contacts.size(), 'one contact after');
    }

    @isTest
    static void sendEmailReceiptSuccess() {
        ArbeidsgiverKontaktSkjemaHandler handler = new ArbeidsgiverKontaktSkjemaHandler();
        handler.processMessages(new List<KafkaMessage__c>{ toKafkaMessage(JSON_FORM) });

        System.assertEquals(1, [SELECT Id FROM EmailQueue__c].size(), 'should be one email after');
    }

    @isTest
    static void runJob() {
        KafkaEnhetFilter.bypassFilter = true;

        KafkaMessage__c message = toKafkaMessage(JSON_FORM);
        insert message;

        Test.StartTest();
        AsyncRequestSchedulable.enqueueAsyncJobs();
        Test.StopTest();

        List<CustomOpportunity__c> opportunities = [SELECT Id FROM CustomOpportunity__c];

        System.assertEquals(1, opportunities.size(), 'Opportunities created');
    }

    private static KafkaMessage__c toKafkaMessage(String json) {
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(json));

        KafkaMessage__c message = new KafkaMessage__c();
        message.CRM_Topic__c = 'team-innhold.arbeidsgiver-kontaktskjema';
        message.CRM_Value__c = encodedValue;
        message.CRM_Key__c = '123456';

        return message;
    }
}
