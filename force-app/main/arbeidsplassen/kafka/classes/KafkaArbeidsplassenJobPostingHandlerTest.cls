@isTest
public with sharing class KafkaArbeidsplassenJobPostingHandlerTest {
    @IsTest
    static void processSingleMessage_success() {
        Account acc = new Account(Name = 'Test Employer 1', INT_OrganizationNumber__c = '123456789');
        insert acc;

        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(ArbeidsplassenJobPostingTest.JSON));

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'teampam.stilling-ekstern-1';
        msg1.CRM_Key__c = 'a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e';
        msg1.CRM_Value__c = encodedValue;

        KafkaArbeidsplassenJobPostingHandler handler = new KafkaArbeidsplassenJobPostingHandler();
        handler.processMessages(new List<KafkaMessage__c>{ msg1 });

        List<JobPosting__c> jobPostings = [
            SELECT
                Id,
                Account__c,
                KafkaId__c,
                KafkaHash__c,
                Title__c,
                LastUpdated__c,
                Published__c,
                Created__c,
                Expires__c,
                UUID__c,
                SourceURL__c,
                ProfessionCategoryCode__c,
                WorkplaceCity__c,
                EmployerReference__c,
                JobPoster__c,
                EngagementType__c,
                Extent__c,
                Status__c,
                Source__c,
                Medium__c
            FROM JobPosting__c
        ];

        System.assertEquals('2022-02-18 07:19:21', String.valueOf(jobPostings[0].LastUpdated__c));
        System.assertEquals('2022-02-18 07:07:07', String.valueOf(jobPostings[0].Published__c));
        System.assertEquals('2022-02-18 07:17:50', String.valueOf(jobPostings[0].Created__c));
        System.assertEquals('2022-03-31 00:00:00', String.valueOf(jobPostings[0].Expires__c));
        System.assertEquals('8e019569-0a0b-4f34-8d43-4498b9f0b32b', jobPostings[0].UUID__c);
        System.assertEquals('https://www.finn.no/248749509', jobPostings[0].SourceURL__c);
        System.assertEquals('STYRK08', jobPostings[0].ProfessionCategoryCode__c);
        System.assertEquals('HEDALEN, OSLO', jobPostings[0].WorkplaceCity__c);
        System.assertEquals('248749509', jobPostings[0].EmployerReference__c);
        System.assertEquals('Hedda Hytter AS', jobPostings[0].JobPoster__c);
        System.assertEquals('Fast', jobPostings[0].EngagementType__c);
        System.assertEquals('Heltid', jobPostings[0].Extent__c);
        System.assertEquals('ACTIVE', jobPostings[0].Status__c);
        System.assertEquals('FINN', jobPostings[0].Source__c);
        System.assertEquals('FINN', jobPostings[0].Medium__c);
        System.assertEquals(1, jobPostings.size());
        System.assertEquals('Medarbeider søkes', jobPostings[0].Title__c);
        System.assertEquals(msg1.CRM_Value__c, jobPostings[0].KafkaHash__c, 'Correct KafkaId');
        System.assertEquals(msg1.CRM_Key__c, jobPostings[0].KafkaId__c, 'Correct KafkaId');
        System.assertEquals(acc.id, jobPostings[0].Account__c);
    }

    @IsTest
    static void processSingleMessage_nulls() {
        final String JSON_WITH_NULLS =
            '{\n' +
            '  "uuid": "8e019569-0a0b-4f34-8d43-4498b9f0b32b",\n' +
            '  "title": null,\n' +
            '  "status": "ACTIVE",\n' +
            '  "published": "2022-02-18T07:07:07.064711",\n' +
            '  "expires": "2022-03-31T00:00:00",\n' +
            '  "created": "2022-02-18T07:17:50.477069",\n' +
            '  "updated": "2021-02-18T07:19:21.575794",\n' +
            '  "source": null,\n' +
            '  "medium": null,\n' +
            '  "reference": "248749509",\n' +
            '  "businessName": "Hedda Hytter AS"\n' +
            '}';

        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(JSON_WITH_NULLS));

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'teampam.stilling-ekstern-1';
        msg1.CRM_Key__c = 'a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e';
        msg1.CRM_Value__c = encodedValue;

        KafkaArbeidsplassenJobPostingHandler handler = new KafkaArbeidsplassenJobPostingHandler();
        handler.processMessages(new List<KafkaMessage__c>{ msg1 });

        List<JobPosting__c> jobPostings = [SELECT Id, Account__c, KafkaId__c, KafkaHash__c FROM JobPosting__c];

        System.assertEquals(msg1.CRM_Value__c, jobPostings[0].KafkaHash__c, 'Correct KafkaId');
        System.assertEquals(msg1.CRM_Key__c, jobPostings[0].KafkaId__c, 'Correct KafkaId');
        System.assertEquals(1, jobPostings.size(), 'Job Posting Inserted');
    }

    @IsTest
    static void processSingleMessage_InvalidJson() {
        String INVALID_JSON =
            '{\n' +
            '  "uuid": "8e019569-0a0b-4f34-8d43-4498b9f0b32b",\n' +
            '  "title": null,\n' +
            '  "status": "ACTIVE"';

        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(INVALID_JSON));

        List<KafkaMessage__c> messages = new List<KafkaMessage__c>();
        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'teampam.stilling-ekstern-1';
        msg1.CRM_Key__c = 'a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e';
        msg1.CRM_Value__c = encodedValue;
        messages.add(msg1);

        KafkaArbeidsplassenJobPostingHandler handler = new KafkaArbeidsplassenJobPostingHandler();
        handler.processMessages(messages);

        System.assertEquals(KafkaMessageService.STATUS_ERROR, messages[0].CRM_Status__c);
        System.assert(String.isNotBlank(messages[0].CRM_ErrorMessage__c));
    }

    @isTest
    static void processSingleMessage_updateExisting() {
        String encodedValue1 = EncodingUtil.base64Encode(Blob.valueOf(ArbeidsplassenJobPostingTest.JSON_WITH_NULLS));
        String encodedValue2 = EncodingUtil.base64Encode(Blob.valueOf(ArbeidsplassenJobPostingTest.JSON));

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'teampam.stilling-ekstern-1';
        msg1.CRM_Key__c = 'a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e';
        msg1.CRM_Value__c = encodedValue2;

        JobPosting__c jobPosting = new JobPosting__c(
            KafkaId__c = msg1.CRM_Key__c,
            KafkaHash__c = encodedValue1,
            Expires__c = Date.Today()
        );
        insert jobPosting;

        KafkaArbeidsplassenJobPostingHandler handler = new KafkaArbeidsplassenJobPostingHandler();
        handler.processMessages(new List<KafkaMessage__c>{ msg1 });

        List<JobPosting__c> jobPostings = [SELECT Id, Expires__c, KafkaId__c, KafkaHash__c FROM JobPosting__c];

        System.assertEquals(1, jobPostings.size(), 'Still only one job posting');
        System.assertNotEquals(jobPosting.expires__c, jobPostings[0].Expires__c, 'Expired date updated');
        System.assertEquals(msg1.CRM_Key__c, jobPostings[0].KafkaId__c, 'Correct KafkaId');
        System.assertEquals(msg1.CRM_Value__c, jobPostings[0].KafkaHash__c, 'Updated Kafka hash');
    }

    @isTest
    static void multipleMessage_SameKey() {
        String encodedValue1 = EncodingUtil.base64Encode(Blob.valueOf(ArbeidsplassenJobPostingTest.JSON_WITH_NULLS));
        String encodedValue2 = EncodingUtil.base64Encode(Blob.valueOf(ArbeidsplassenJobPostingTest.JSON));

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'teampam.stilling-ekstern-1';
        msg1.CRM_Key__c = 'a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e';
        msg1.CRM_Value__c = encodedValue1;

        KafkaMessage__c msg2 = new KafkaMessage__c();
        msg2.CRM_Topic__c = 'teampam.stilling-ekstern-1';
        msg2.CRM_Key__c = 'a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e';
        msg2.CRM_Value__c = encodedValue2;

        KafkaArbeidsplassenJobPostingHandler handler = new KafkaArbeidsplassenJobPostingHandler();
        handler.processMessages(new List<KafkaMessage__c>{ msg1, msg2 });

        List<JobPosting__c> jobPostings = [
            SELECT Id, Expires__c, LastUpdated__c, KafkaId__c, KafkaHash__c
            FROM JobPosting__c
        ];

        System.assertEquals(1, jobPostings.size(), 'Only one job posting added');
        System.assertEquals(
            '2022-02-18 07:19:21',
            String.valueOf(jobPostings[0].LastUpdated__c),
            'Most recent message was used.'
        );
    }

    @isTest
    static void runJobBulk_insertAndUpdate() {
        String encodedValue1 = EncodingUtil.base64Encode(Blob.valueOf(ArbeidsplassenJobPostingTest.JSON_WITH_NULLS));
        String encodedValue2 = EncodingUtil.base64Encode(Blob.valueOf(ArbeidsplassenJobPostingTest.JSON));

        // Same key update Existing Job Posting
        KafkaMessage__c msg = new KafkaMessage__c();
        msg.CRM_Topic__c = 'teampam.stilling-ekstern-1';
        msg.CRM_Key__c = 'a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e';
        msg.CRM_Value__c = encodedValue1;

        // New key new Job Posting
        KafkaMessage__c msg2 = msg.clone();
        msg2.CRM_Key__c = 'a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1f';

        // Ignore inactive status
        KafkaMessage__c msg3 = msg.clone();
        msg3.CRM_Key__c = 'a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1g';
        msg3.CRM_Value__c = encodedValue2;

        JobPosting__c jobPosting = new JobPosting__c(
            KafkaId__c = msg.CRM_Key__c,
            KafkaHash__c = encodedValue2,
            Expires__c = Date.Today()
        );
        insert jobPosting;
        insert new List<KafkaMessage__c>{ msg, msg2, msg3 };

        Test.StartTest();
        AsyncRequestSchedulable.enqueueAsyncJobs();
        Test.StopTest();

        List<JobPosting__c> jobPostings = [
            SELECT Id, Expires__c, LastUpdated__c, KafkaId__c, KafkaHash__c
            FROM JobPosting__c
        ];

        System.assertEquals(3, jobPostings.size(), '2 new, 1 updated');
    }

    @IsTest
    static void processSingleMessage_tooLongTitle() {
        final String JSON_WITH_LONG_TITLE =
            '{\n' +
            '  "uuid": "8e019569-0a0b-4f34-8d43-4498b9f0b32b",\n' +
            '  "title": "Er du engasjert i politikk, samfunn og næringsliv? Vi ser etter deg som har god kunnskap om og gjerne erfaring fra politiske styrings- og beslutningsstrukturer på nasjonalt nivå. Du evner å se helheten og setter deg raskt inn i komplekse saker. Vil du være med å jobbe for politiske gjennomslag, delta i trepartssamarbeidet, bygge Virkes omdømme og fremme våre medlemmers interesser på arbeidslivsfeltet? Er du særlig interessert i inkludering og mangfold, og likestilling og diskriminering eller noe annet",\n' +
            '  "status": "ACTIVE",\n' +
            '  "published": "2022-02-18T07:07:07.064711",\n' +
            '  "expires": "2022-03-31T00:00:00",\n' +
            '  "created": "2022-02-18T07:17:50.477069",\n' +
            '  "updated": "2021-02-18T07:19:21.575794",\n' +
            '  "source": null,\n' +
            '  "medium": null,\n' +
            '  "reference": "248749509",\n' +
            '  "businessName": "Hedda Hytter AS"\n' +
            '}';

        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(JSON_WITH_LONG_TITLE));

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'teampam.stilling-ekstern-1';
        msg1.CRM_Key__c = 'a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e';
        msg1.CRM_Value__c = encodedValue;

        KafkaArbeidsplassenJobPostingHandler handler = new KafkaArbeidsplassenJobPostingHandler();
        handler.processMessages(new List<KafkaMessage__c>{ msg1 });

        List<JobPosting__c> jobPostings = [SELECT Id, Account__c, Title__c, KafkaId__c, KafkaHash__c FROM JobPosting__c];

        System.assertEquals(msg1.CRM_Value__c, jobPostings[0].KafkaHash__c, 'Correct KafkaId');
        System.assertEquals(msg1.CRM_Key__c, jobPostings[0].KafkaId__c, 'Correct KafkaId');
        System.assertEquals(1, jobPostings.size(), 'Job Posting Inserted');
        System.assertEquals('Er du engasjert i politikk, samfunn og næringsliv? Vi ser etter deg som har god kunnskap om og gjerne erfaring fra politiske styrings- og beslutningsstrukturer på nasjonalt nivå. Du evner å se helheten og setter deg raskt inn i komplekse saker. Vil du væ', jobPostings[0].Title__c, 'Correct Title');
    }
}
