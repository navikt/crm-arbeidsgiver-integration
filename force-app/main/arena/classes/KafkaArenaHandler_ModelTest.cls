@IsTest
public class KafkaArenaHandler_ModelTest {
    public static String json =
        '{' +
        '    \"aktivitetStatuskode\": \"FULLF\",' +
        '    \"bedriftsnr\": 973113631,' +
        '    \"beskrivelse\": \"Bedriftsøkonomstudiet 20 vt\\nHøgskolekandidatstudiet med retning for regnskapsførere. 20vt\",' +
        '    \"orgnrMorselskap\": 971228865,' +
        '    \"saksbehandler\": \"JEI1812\",' +
        '    \"aktivitetskode\": \"UTDYRK\",' +
        '    \"fraDato\": \"2003-01-01\",' +
        '    \"tilDato\": \"2004-12-31\",' +
        '    \"regDato\": \"2003-03-25\",' +
        '    \"regUser\": \"GL1812\",' +
        '    \"aktivitetsgruppekode\": \"TLTAK\",' +
        '    \"aktivitetstypebeskrivelse\": null,' +
        '    \"aktivitetstypenavn\": \"Utdanning\",' +
        '    \"fornavn\": \"Jonn Egil\",' +
        '    \"etternavn\": \"Indrevoll\",' +
        '    \"navIdent\": \"I111345\"' +
        '}';
    private static testMethod void testParse() {
        KafkaArenaHandler_Model obj = KafkaArenaHandler_Model.parse(json, null, null);
        System.assert(obj != null);
    }

    @IsTest
    private static void testGetMessageAge() {
        KafkaArenaHandler_Model obj = KafkaArenaHandler_Model.parse(json, null, null);
        System.assert(obj != null);
    }

    @IsTest
    private static void should_attempt_to_map_timestamp_from_key_when_parsing() {
        KafkaArenaHandler_Model activityWithTimestamp = KafkaArenaHandler_Model.parse(
            json,
            '2024-01-15T14:30:00.123456',
            null
        );
        Assert.areEqual(
            activityWithTimestamp.timeStampFromMessage,
            DateTime.newInstanceGmt(2024, 1, 15, 13, 30, 0),
            'Timestamp should be parsed correctly from key: Norway is UTC+1 in winter, so 14:30 Norway time = 13:30 GMT.'
        );

        KafkaArenaHandler_Model activityWithoutTimestamp = KafkaArenaHandler_Model.parse(
            json,
            '-not--a--valid--timestamp-',
            null
        );
        Assert.areEqual(
            activityWithoutTimestamp.timeStampFromMessage,
            null,
            'Timestamp should be null when key is not datetime'
        );
    }

    @IsTest
    private static void should_calculate_message_age_correctly() {
        KafkaArenaHandler_Model activityWithTimestamp = KafkaArenaHandler_Model.parse(
            json,
            '2024-01-15T14:30:00.123456',
            null
        ); // 14:30 Norway time.  Norway is UTC+1 in winter, so 14:30 Norway time = 13:30 GMT
        DateTime processedTimeGmt = DateTime.newInstanceGmt(2024, 1, 15, 13, 50, 0); // 13:50 GMT, 20 minutes after the above time

        Integer activityWithTimestampAge = activityWithTimestamp.getMessageAge(processedTimeGmt);
        Assert.areEqual(activityWithTimestampAge, 20, 'Message age should be 20 minutes');

        KafkaArenaHandler_Model activityWithoutTimestamp = KafkaArenaHandler_Model.parse(
            json,
            'not-a-valid-timestamp',
            null
        );
        Integer activityWithoutTimestampAge = activityWithoutTimestamp.getMessageAge(processedTimeGmt);
        Assert.areEqual(activityWithoutTimestampAge, null, 'Message age should be null when timestamp is not datetime');
    }
}
