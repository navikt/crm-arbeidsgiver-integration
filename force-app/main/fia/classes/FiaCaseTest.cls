@IsTest
public with sharing class FiaCaseTest {
    private static final String JSON =
        '{\n' +
        '   "saksnummer": "a240d1adtuasydt",\n' +
        '   "orgnr": "197056333",\n' +
        '   "eierAvSak": "C156986",\n' +
        '   "endretAvHendelseId": "sdfhoisdyfio49856",\n' +
        '   "status": "ny",\n' +
        '   "opprettetTidspunkt": "2022-02-18T07:07:07.064711",\n' +
        '   "endretTidspunkt": "2022-02-18T07:19:21.575794"\n' +
        '}';

    @IsTest
    static void parse() {
        FiaCase model = FiaCase.parse(JSON, null, null);

        System.assertEquals('a240d1adtuasydt', model.saksnummer);
        System.assertEquals('197056333', model.orgnr);
        System.assertEquals('C156986', model.eierAvSak);
        System.assertEquals('sdfhoisdyfio49856', model.endretAvHendelseId);
        System.assertEquals('ny', model.status);
        System.assertEquals('2022-02-18T07:07:07.064711', model.opprettetTidspunkt);
        System.assertEquals('2022-02-18T07:19:21.575794', model.endretTidspunkt);
        System.assertEquals(DateTime.newInstance(2022, 2, 18, 7, 19, 21), model.timeStampFromMessage);
    }
}
