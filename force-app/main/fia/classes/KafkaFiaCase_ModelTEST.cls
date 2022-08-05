@isTest
public with sharing class KafkaFiaCase_ModelTEST {
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

    @isTest
    static void parse() {
        KafkaFiaCase_Model model = KafkaFiaCase_Model.parse(JSON, null, null);

        System.assertEquals('a240d1adtuasydt', model.saksnummer);
        System.assertEquals('197056333', model.orgnr);
        System.assertEquals('C156986', model.eierAvSak);
        System.assertEquals('sdfhoisdyfio49856', model.endretAvHendelseId);
        System.assertEquals('ny', model.status);
        System.assertEquals('2022-02-18T07:07:07.064711', model.opprettetTidspunkt);
        System.assertEquals('2022-02-18T07:19:21.575794', model.endretTidspunkt);
    }
}
