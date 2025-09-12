@isTest
private without sharing class SharedIntegrationFunctionsTest {
    @isTest
    private static void testfetchUsersByTitle() {
        User u = TAG_TestDataFactory.createStandardUser('Last UNIQUE NAME');
        u.title = 'testTitle';
        update u;

        Test.StartTest();
        Map<String, User> userMap = SharedIntegrationFunctions.fetchUsersByTitle(new Set<String>{ 'testTitle' });
        Test.StopTest();

        System.assertEquals(1, userMap.size(), 'Only one user added');
        System.assertEquals(u.Id, userMap.get('testTitle').Id, 'Same user as created');
    }

    @IsTest
    static void convertNorwegianTimeToGmt_Should_Convert_Winter_Time() {
        // Winter time in Norway (UTC+1)
        // Test data: 2024-01-15 14:30:00 Norwegian time should be 2024-01-15 13:30:00 GMT
        String winterTime = '2024-01-15T14:30:00.123456';

        Test.startTest();
        DateTime result = SharedIntegrationFunctions.convertNorwegianTimeToGmt(winterTime);
        Test.stopTest();

        DateTime expected = DateTime.newInstanceGmt(2024, 1, 15, 13, 30, 0);
        System.assertEquals(expected, result, 'Winter time should be converted correctly (UTC+1)');
    }

    @IsTest
    static void convertNorwegianTimeToGmt_Should_Convert_Summer_Time() {
        // Summer time in Norway (UTC+2)
        // Test data: 2024-07-15 14:30:00 Norwegian time should be 2024-07-15 12:30:00 GMT
        String summerTime = '2024-07-15T14:30:00.123456';

        Test.startTest();
        DateTime result = SharedIntegrationFunctions.convertNorwegianTimeToGmt(summerTime);
        Test.stopTest();

        DateTime expected = DateTime.newInstanceGmt(2024, 7, 15, 12, 30, 0);
        System.assertEquals(expected, result, 'Summer time should be converted correctly (UTC+2)');
    }

    @IsTest
    static void convertNorwegianTimeToGmt_Should_Handle_Null_Input() {
        Test.startTest();
        DateTime result = SharedIntegrationFunctions.convertNorwegianTimeToGmt(null);
        Test.stopTest();

        System.assertEquals(null, result, 'Null input should return null');
    }

    @IsTest
    static void convertNorwegianTimeToGmt_Should_Handle_Empty_String() {
        Test.startTest();
        DateTime result = SharedIntegrationFunctions.convertNorwegianTimeToGmt('');
        Test.stopTest();

        System.assertEquals(null, result, 'Empty string should return null');
    }

    @IsTest
    static void convertNorwegianTimeToGmt_Should_Handle_Whitespace_String() {
        Test.startTest();
        DateTime result = SharedIntegrationFunctions.convertNorwegianTimeToGmt('   ');
        Test.stopTest();

        System.assertEquals(null, result, 'Whitespace string should return null');
    }

    @IsTest
    static void convertNorwegianTimeToGmt_Should_Handle_Edge_Cases() {
        Test.startTest();

        // Test midnight
        DateTime result = SharedIntegrationFunctions.convertNorwegianTimeToGmt('2024-01-15T00:00:00.000000');
        DateTime expected = DateTime.newInstanceGmt(2024, 1, 14, 23, 0, 0); // Previous day in GMT
        System.assertEquals(expected, result, 'Should handle midnight correctly');

        // Test end of year
        result = SharedIntegrationFunctions.convertNorwegianTimeToGmt('2024-12-31T23:59:59.999999');
        expected = DateTime.newInstanceGmt(2024, 12, 31, 22, 59, 59); // Winter time UTC+1
        System.assertEquals(expected, result, 'Should handle end of year correctly');

        Test.stopTest();
    }

    @IsTest
    static void convertNorwegianTimeToGmt_Should_Reject_Invalid_Years() {
        Test.startTest();

        // Test year too low
        DateTime result = SharedIntegrationFunctions.convertNorwegianTimeToGmt('1600-01-15T14:30:00.000000');
        System.assertEquals(null, result, 'Should return null for year < 1700');

        // Test year too high
        result = SharedIntegrationFunctions.convertNorwegianTimeToGmt('5000-01-15T14:30:00.000000');
        System.assertEquals(null, result, 'Should return null for year > 4000');

        Test.stopTest();
    }

    @IsTest
    static void convertNorwegianTimeToGmt_Should_Handle_DST_Transition() {
        Test.startTest();

        // Test date just before DST starts (last Sunday in March)
        // 2024: DST starts March 31st at 2:00 AM
        DateTime result = SharedIntegrationFunctions.convertNorwegianTimeToGmt('2024-03-30T14:30:00.000000');
        DateTime expected = DateTime.newInstanceGmt(2024, 3, 30, 13, 30, 0); // Winter time UTC+1
        System.assertEquals(expected, result, 'Should handle time before DST transition');

        // Test date just after DST starts
        result = SharedIntegrationFunctions.convertNorwegianTimeToGmt('2024-04-01T14:30:00.000000');
        expected = DateTime.newInstanceGmt(2024, 4, 1, 12, 30, 0); // Summer time UTC+2
        System.assertEquals(expected, result, 'Should handle time after DST transition');

        Test.stopTest();
    }

    @IsTest
    static void convertNorwegianTimeToGmt_Should_Handle_Invalid_Format() {
        Test.startTest();
        DateTime result = SharedIntegrationFunctions.convertNorwegianTimeToGmt('invalid-datetime-format');
        Test.stopTest();

        System.assertEquals(null, result, 'Should return null for invalid format');
    }
}
