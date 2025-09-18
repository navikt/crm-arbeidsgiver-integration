@isTest
private class ReportingDataBuilderTest {
    @isTest
    static void should_add_multiple_reporting_data_entries() {
        ReportingDataBuilder builder = new ReportingDataBuilder();
        Test.startTest();
        builder.logTimeDeviation('FiaCooperation', 'key-1', 30);
        builder.logTimeDeviation('ArbeidsplassenJobPosting', 'key-2', 15);
        builder.logTimeDeviation('ModiaDialog', 'key-3', 60);
        System.assertEquals(3, builder.getEntryCount(), 'Builder should contain three entries');
        builder.saveReportingDataEntries();

        Test.stopTest();
        System.assertEquals(0, builder.getEntryCount(), 'Builder should be empty after successful save');
        List<ReportingData__c> insertedRecords = [
            SELECT Id, TAG_Category__c, TAG_Key__c, TAG_Measurement__c
            FROM ReportingData__c
            WHERE Name = 'Tidsmåling'
        ];
        System.assertEquals(3, insertedRecords.size(), 'Three ReportingData__c records should have been inserted');
    }

    @isTest
    static void should_handle_empty_save_gracefully() {
        ReportingDataBuilder builder = new ReportingDataBuilder();
        Test.startTest();
        try {
            builder.saveReportingDataEntries();
            System.assert(true, 'Empty save should complete without errors');
        } catch (Exception e) {
            System.assert(false, 'Empty save should not throw exception: ' + e.getMessage());
        }
        Test.stopTest();
        System.assertEquals(0, builder.getEntryCount(), 'Builder should remain empty');
    }

    @isTest
    static void should_handle_null_parameters_gracefully() {
        ReportingDataBuilder builder = new ReportingDataBuilder();
        Test.startTest();
        try {
            builder.logTimeDeviation(null, 'test-key', 10);
            builder.logTimeDeviation('TestTopic', null, 20);
            builder.logTimeDeviation('TestTopic', 'test-key', null);
            System.assert(true, 'Null parameters should be handled gracefully');
        } catch (Exception e) {
            System.assert(false, 'Null parameters should not cause exceptions: ' + e.getMessage());
        }
        Test.stopTest();
        System.assertEquals(3, builder.getEntryCount(), 'Builder should handle null parameters');
    }

    @isTest
    static void should_handle_DMLExceptions_gracefully() {
        ReportingDataBuilder builder = new ReportingDataBuilder();

        Test.startTest();

        builder.logTimeDeviation(
            '----------------------------------------------test-long-topic-name----------------------------------------------',
            'test-key',
            10
        );
        System.assertEquals(1, builder.getEntryCount(), 'Builder should have 1 entry');
        builder.saveReportingDataEntries();

        Test.stopTest();
        System.assertEquals(1, builder.getEntryCount(), 'Entries should not have been cleared due to DML exception');
    }

    @isTest
    static void should_handle_bulk_operations() {
        ReportingDataBuilder builder = new ReportingDataBuilder();
        Integer bulkSize = 200;
        Test.startTest();
        try {
            for (Integer i = 0; i < bulkSize; i++) {
                builder.logTimeDeviation('BulkTopic', 'bulk-key-' + i, i * 5);
            }
            System.assertEquals(bulkSize, builder.getEntryCount(), 'Builder should handle bulk entries');
            builder.saveReportingDataEntries();
            System.assert(true, 'Bulk operations should complete without errors');
        } catch (Exception e) {
            System.assert(false, 'Bulk operations should not cause exceptions: ' + e.getMessage());
        }
        Test.stopTest();
    }
}
