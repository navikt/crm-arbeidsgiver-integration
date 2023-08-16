
@isTest
public with sharing class KafkaFiaDelivery_ModelTEST {
    private static final String JSON =
        '{\n' +
        '   "id": "139",\n' +
        '   "saksnummer": "01H5MKC3T0G5Z81K7YE50J138T",\n' +
        '   "modul": {\n' +
        '       "id":10,\n' +  
        '       "iaTjeneste": {\n' +
        '           "id":2,\n' +
        '           "navn":"Forebyggende arbeidsmiljøarbeid",\n' +
        '           "deaktivert":false},\n' +
        '       "navn":"Livsfaseorientert personalpolitikk",\n' +
        '       "deaktivert":false},\n' +
        '   "frist": "2023-08-31",\n' +
        '   "status": "UNDER_ARBEID",\n' +
        '   "opprettetAv": "Z994537",\n' +
        '   "sistEndret": "2023-07-18T15:35:27.485670",\n' +
        '   "sistEndretAv": "Z994537",\n' +
        '   "sistEndretAvRolle": "SUPERBRUKER",\n' +
        '   "fullført": null,\n' +
        '   "enhetsnummer": "2970",\n' +
        '   "enhetsnavn": "Ukjent"\n' +
        '}';

    @isTest
    static void parse() {
        KafkaFiaDelivery_Model model = KafkaFiaDelivery_Model.parse(JSON, null, null);

        System.assertEquals(139, model.id);
        System.assertEquals('01H5MKC3T0G5Z81K7YE50J138T', model.saksnummer);
    //    System.assertEquals('Livsfaseorientert personalpolitikk', model.modul.navn);
    //    System.assertEquals('Forebyggende arbeidsmiljøarbeid', model.modul.iaTjeneste.navn);
        System.assertEquals('2023-08-31', model.frist);
        System.assertEquals('UNDER_ARBEID', model.status);
        System.assertEquals('Z994537', model.opprettetAv);
        System.assertEquals('2023-07-18T15:35:27.485670', model.sistEndret);
        System.assertEquals('Z994537', model.sistEndretAv);
        System.assertEquals('SUPERBRUKER', model.sistEndretAvRolle);
        System.assertEquals(null, model.fullfort);
        System.assertEquals('2970', model.enhetsnummer);
        System.assertEquals('Ukjent', model.enhetsnavn);
    }
}