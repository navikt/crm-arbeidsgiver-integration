
@isTest
public with sharing class KafkaFiaDelivery_ModelTEST {
    private static final String JSON =
        '{\n' +
        '   "id": "",\n' +
        '   "saksnummer": "a240d1adtuasydt",\n' +
        '   "modul": "",\n' +
        '   "iaTjeneste": "",\n' +
        '   "frist": "",\n' +
        '   "status": "ny",\n' +
        '   "opprettetAv": "",\n' +
        '   "sistEndret": "",\n' +
        '   "sistEndretAv": "",\n' +
        '   "sistEndretAvRolle": "",\n' +
        '   "fullfort": "",\n' +
        '   "enhetsnummer": "",\n' +
        '   "enhetsnavn": "",\n' +
        '}';

    @isTest
    static void parse() {
        KafkaFiaDelivery_Model model = KafkaFiaDelivery_Model.parse(JSON, null, null);

        System.assertEquals('', model.id);
        System.assertEquals('a240d1adtuasydt', model.saksnummer);
        System.assertEquals('', model.modul);
        System.assertEquals('', model.iaTjeneste);
        System.assertEquals('', model.frist);
        System.assertEquals('ny', model.status);
        System.assertEquals('', model.opprettetAv);
        System.assertEquals('', model.sistEndret);
        System.assertEquals('', model.sistEndretAv);
        System.assertEquals('', model.sistEndretAvRolle);
        System.assertEquals('', model.fullfort);
        System.assertEquals('', model.enhetsnummer);
        System.assertEquals('', model.enhetsnavn);
    }
}