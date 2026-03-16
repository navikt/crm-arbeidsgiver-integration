@IsTest
public class TAG_DeleteReportingDataBatchJobTest {
    @isTest
    static void execute_doesNotDeleteNewRecords() {
        List<ReportingData__c> records = new List<ReportingData__c>{
            new ReportingData__c(
                Name = 'Tidsmåling',
                TAG_Category__c = 'teampam.stilling-ekstern-1',
                TAG_Key__c = 'key-1',
                TAG_Measurement__c = 20
            ),
            new ReportingData__c(
                Name = 'Tidsmåling',
                TAG_Category__c = 'teamsykefravr.isdialogmote-dialogmote-statusendring',
                TAG_Key__c = 'key-2',
                TAG_Measurement__c = 20
            ),
            new ReportingData__c(
                Name = 'Tidsmåling',
                TAG_Category__c = 'pia.ia-sak-v1',
                TAG_Key__c = 'key-3',
                TAG_Measurement__c = 20
            ),
            new ReportingData__c(
                Name = 'Tidsmåling',
                TAG_Category__c = 'pia.samarbeidsplan-v1',
                TAG_Key__c = 'key-4',
                TAG_Measurement__c = 20
            ),
            new ReportingData__c(
                Name = 'Tidsmåling',
                TAG_Category__c = 'arbeidsgiver.tiltak-avtale-hendelse',
                TAG_Key__c = 'key-5',
                TAG_Measurement__c = 20
            ),
            new ReportingData__c(
                Name = 'Tidsmåling',
                TAG_Category__c = 'teamarenanais.aapen-arena-arbeidsgiveraktivitetendret-v1',
                TAG_Key__c = 'key-6',
                TAG_Measurement__c = 20
            )
        };
        insert records;

        Test.startTest();
        TAG_DeleteReportingDataBatchJob batch = new TAG_DeleteReportingDataBatchJob();
        Database.executeBatch(batch, 2000);
        Test.stopTest();

        // Records are newly created and do not match the date filter, so none should be deleted
        System.assertEquals(
            6,
            [SELECT COUNT() FROM ReportingData__c WHERE Name = 'Tidsmåling'],
            'Newly created records should not be deleted'
        );
    }

    @isTest
    static void execute_doesDeleteOldRecords() {
        // Records that should be deleted: older than 30 days for short-retention topics
        List<ReportingData__c> shortRetentionRecords = new List<ReportingData__c>{
            new ReportingData__c(
                Name = 'Tidsmåling',
                TAG_Category__c = 'teampam.stilling-ekstern-1',
                TAG_Key__c = 'key-1',
                TAG_Measurement__c = 20
            ),
            new ReportingData__c(
                Name = 'Tidsmåling',
                TAG_Category__c = 'teamsykefravr.isdialogmote-dialogmote-statusendring',
                TAG_Key__c = 'key-2',
                TAG_Measurement__c = 20
            ),
            new ReportingData__c(
                Name = 'Tidsmåling',
                TAG_Category__c = 'arbeidsgiver.tiltak-avtale-hendelse',
                TAG_Key__c = 'key-3',
                TAG_Measurement__c = 20
            ),
            new ReportingData__c(
                Name = 'Tidsmåling',
                TAG_Category__c = 'teamarenanais.aapen-arena-arbeidsgiveraktivitetendret-v1',
                TAG_Key__c = 'key-4',
                TAG_Measurement__c = 20
            )
        };
        insert shortRetentionRecords;
        DateTime oldShortDate = DateTime.now().addDays(-31);
        for (ReportingData__c r : shortRetentionRecords) {
            Test.setCreatedDate(r.Id, oldShortDate);
        }

        // Records that should be deleted: older than 6 months for IA-topics
        List<ReportingData__c> longRetentionRecords = new List<ReportingData__c>{
            new ReportingData__c(
                Name = 'Tidsmåling',
                TAG_Category__c = 'pia.ia-sak-v1',
                TAG_Key__c = 'key-5',
                TAG_Measurement__c = 20
            ),
            new ReportingData__c(
                Name = 'Tidsmåling',
                TAG_Category__c = 'pia.samarbeidsplan-v1',
                TAG_Key__c = 'key-6',
                TAG_Measurement__c = 20
            )
        };
        insert longRetentionRecords;
        DateTime oldLongDate = DateTime.now().addMonths(-7);
        for (ReportingData__c r : longRetentionRecords) {
            Test.setCreatedDate(r.Id, oldLongDate);
        }

        Test.startTest();
        TAG_DeleteReportingDataBatchJob batch = new TAG_DeleteReportingDataBatchJob();
        Database.executeBatch(batch, 2000);
        Test.stopTest();

        System.assertEquals(
            0,
            [SELECT COUNT() FROM ReportingData__c WHERE Name = 'Tidsmåling'],
            'All old records should be deleted'
        );
    }
}
