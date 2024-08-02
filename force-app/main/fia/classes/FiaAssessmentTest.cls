@IsTest
public with sharing class FiaAssessmentTest {
    private static final String JSON =
        '{\n' +
        '   "behovsvurderingId": "4cce71a2-ffba-4d4a-865d-fca20b482598",\n' +
        '   "saksnummer": "1234567",\n' +
        '   "fullførtTidspunkt": "2022-02-18T07:07:07.064711"\n' +
        '}';

    @IsTest
    static void parse() {
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(JSON));
        FiaAssessment model = FiaAssessment.parse(JSON, '4cce71a2-ffba-4d4a-865d-fca20b482598', encodedValue);

        System.assertEquals(
            '4cce71a2-ffba-4d4a-865d-fca20b482598',
            model.behovsvurderingId,
            'Should match value from json-string'
        );
        System.assertEquals('1234567', model.saksnummer, 'Should match value from json-string');
        System.assertEquals(
            '2022-02-18T07:07:07.064711',
            model.fullfortTidspunkt,
            'Should match value from json-string'
        );
        System.assertEquals('4cce71a2-ffba-4d4a-865d-fca20b482598', model.key, 'Should match value from json-string');
    }
}
