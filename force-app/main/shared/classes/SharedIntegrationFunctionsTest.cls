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
    static void convertNorwegianTimeToGmt_Should_Handle_Valid_Conversions() {
        Test.startTest();

        // Winter time in Norway (UTC+1)
        DateTime result = SharedIntegrationFunctions.convertNorwegianTimeToGmt('2024-01-15T14:30:00.123456');
        DateTime expected = DateTime.newInstanceGmt(2024, 1, 15, 13, 30, 0);
        System.assertEquals(expected, result, 'Winter time should be converted correctly (UTC+1)');

        // Summer time in Norway (UTC+2)
        result = SharedIntegrationFunctions.convertNorwegianTimeToGmt('2024-07-15T14:30:00.123456');
        expected = DateTime.newInstanceGmt(2024, 7, 15, 12, 30, 0);
        System.assertEquals(expected, result, 'Summer time should be converted correctly (UTC+2)');

        // Midnight edge case
        result = SharedIntegrationFunctions.convertNorwegianTimeToGmt('2024-01-15T00:00:00.000000');
        expected = DateTime.newInstanceGmt(2024, 1, 14, 23, 0, 0); // Previous day in GMT
        System.assertEquals(expected, result, 'Should handle midnight correctly');

        // End of year
        result = SharedIntegrationFunctions.convertNorwegianTimeToGmt('2024-12-31T23:59:59.999999');
        expected = DateTime.newInstanceGmt(2024, 12, 31, 22, 59, 59); // Winter time UTC+1
        System.assertEquals(expected, result, 'Should handle end of year correctly');

        // DST transition period
        result = SharedIntegrationFunctions.convertNorwegianTimeToGmt('2024-03-30T14:30:00.000000');
        expected = DateTime.newInstanceGmt(2024, 3, 30, 13, 30, 0); // Before DST
        System.assertEquals(expected, result, 'Should handle time before DST transition');

        result = SharedIntegrationFunctions.convertNorwegianTimeToGmt('2024-04-01T14:30:00.000000');
        expected = DateTime.newInstanceGmt(2024, 4, 1, 12, 30, 0); // After DST
        System.assertEquals(expected, result, 'Should handle time after DST transition');

        Test.stopTest();
    }

    @IsTest
    static void convertNorwegianTimeToGmt_Should_Return_Null_For_Invalid_Input() {
        Test.startTest();

        // Null and empty inputs
        System.assertEquals(
            null,
            SharedIntegrationFunctions.convertNorwegianTimeToGmt(null),
            'Null input should return null'
        );
        System.assertEquals(
            null,
            SharedIntegrationFunctions.convertNorwegianTimeToGmt(''),
            'Empty string should return null'
        );
        System.assertEquals(
            null,
            SharedIntegrationFunctions.convertNorwegianTimeToGmt('   '),
            'Whitespace string should return null'
        );

        // Invalid format
        System.assertEquals(
            null,
            SharedIntegrationFunctions.convertNorwegianTimeToGmt('invalid-datetime-format'),
            'Invalid format should return null'
        );

        // Invalid years (outside 1700-4000 range)
        System.assertEquals(
            null,
            SharedIntegrationFunctions.convertNorwegianTimeToGmt('1600-01-15T14:30:00.000000'),
            'Should return null for year < 1700'
        );
        System.assertEquals(
            null,
            SharedIntegrationFunctions.convertNorwegianTimeToGmt('5000-01-15T14:30:00.000000'),
            'Should return null for year > 4000'
        );

        Test.stopTest();
    }

    @IsTest
    static void calculateMinutesBetween_Should_Handle_Valid_Scenarios() {
        Test.startTest();

        DateTime baseTime = DateTime.newInstanceGmt(2024, 1, 15, 10, 0, 0);

        // Basic difference calculation
        Integer result = SharedIntegrationFunctions.calculateMinutesBetween(baseTime, baseTime.addMinutes(5));
        System.assertEquals(5, result, 'Should return 5 minutes difference');

        // Zero difference
        result = SharedIntegrationFunctions.calculateMinutesBetween(baseTime, baseTime);
        System.assertEquals(0, result, 'Should return 0 for same timestamps');

        // Sub-minute precision (30 seconds should round down to 0)
        result = SharedIntegrationFunctions.calculateMinutesBetween(baseTime, baseTime.addSeconds(30));
        System.assertEquals(0, result, 'Should return 0 minutes for sub-minute differences');

        // Large difference (24 hours)
        result = SharedIntegrationFunctions.calculateMinutesBetween(baseTime, baseTime.addDays(1));
        System.assertEquals(1440, result, 'Should return 1440 minutes for 24 hour difference');

        // Cross-day boundary
        DateTime lateEvening = DateTime.newInstanceGmt(2024, 1, 15, 23, 50, 0);
        DateTime earlyMorning = DateTime.newInstanceGmt(2024, 1, 16, 0, 10, 0);
        result = SharedIntegrationFunctions.calculateMinutesBetween(lateEvening, earlyMorning);
        System.assertEquals(20, result, 'Should handle cross-day boundary correctly');

        Test.stopTest();
    }

    @IsTest
    static void calculateMinutesBetween_Should_Return_Null_For_Invalid_Input() {
        Test.startTest();

        DateTime validTime = DateTime.newInstanceGmt(2024, 1, 15, 10, 0, 0);

        // All null scenarios
        System.assertEquals(
            null,
            SharedIntegrationFunctions.calculateMinutesBetween(null, validTime),
            'Should return null when past is null'
        );
        System.assertEquals(
            null,
            SharedIntegrationFunctions.calculateMinutesBetween(validTime, null),
            'Should return null when present is null'
        );
        System.assertEquals(
            null,
            SharedIntegrationFunctions.calculateMinutesBetween(null, null),
            'Should return null when both are null'
        );

        // Negative difference (past after present)
        DateTime earlier = validTime.addMinutes(-5);
        System.assertEquals(
            null,
            SharedIntegrationFunctions.calculateMinutesBetween(validTime, earlier),
            'Should return null when past is after present'
        );

        Test.stopTest();
    }

    @isTest
    static void parseISODateTime() {
        DateTime dateTimeGMT = DateTime.newInstanceGMT(2020, 5, 31, 22, 30, 0);
        System.assertEquals(
            dateTimeGMT,
            SharedIntegrationFunctions.parseISODateTime('2020-05-31T22:30:00.000Z'),
            'Expected Z offset to be parsed as GMT time'
        );
        System.assertEquals(
            dateTimeGMT,
            SharedIntegrationFunctions.parseISODateTime('2020-05-31T22:30:00.000'),
            'Expected undefined offset to be parsed as GMT time'
        );
        System.assertEquals(
            dateTimeGMT,
            SharedIntegrationFunctions.parseISODateTime('2020-06-01T00:30:00.000+0200'),
            'Expected +0200 offset to be parsed as GMT time'
        );
    }
}
