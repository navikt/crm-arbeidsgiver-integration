@IsTest
public with sharing class FiaCooperationTest {
    private static final String JSON =
        '{ "orgnr": "987654321", ' +
        '"saksnummer": "01HNA9BAQFBN660D8TDCNV1R77", ' +
        '"samarbeid": { "id": 12345678, "navn": "Fysio", "status": "AKTIV" }, ' +
        '"plan": { "id": "c3e1ee3b-a9b4-420c-8ec8-def50e83d054", ' +
        '"sistEndret": "2024-09-17T10:17:59.054765", ' +
        '"sistPublisert": "2024-09-18", ' +
        '"temaer": [ { "id": 9847, "rekkefølge": 1, "navn": "Partssamarbeid", ' +
        '"inkludert": false, "undertemaer": [ { "id": 345, "rekkefølge": 1, ' +
        '"navn": "Utvikle partssamarbeidet", ' +
        '"målsetning": "Styrke og strukturere samarbeidet mellom leder, tillitsvalgt og verneombud, ' +
        'samt øke kunnskap og ferdigheter for å jobbe systematisk og forebyggende med sykefravær og arbeidsmiljø.", ' +
        '"inkludert": false, "status": null, "startDato": null, "sluttDato": null } ] }, ' +
        '{ "id": 6576, "rekkefølge": 2, "navn": "Sykefraværsarbeid", ' +
        '"inkludert": true, "undertemaer": [ { "id": 76576, "rekkefølge": 1, ' +
        '"navn": "Sykefraværsrutiner", ' +
        '"målsetning": "Jobbe systematisk og forebyggende med sykefravær, samt forbedre rutiner og oppfølging av ansatte ' +
        'som er sykmeldte eller står i fare for å bli det.", ' +
        '"inkludert": true, "status": "PLANLAGT", "startDato": "2010-01-01", "sluttDato": "2025-02-02" }, ' +
        '{ "id": 65765, "rekkefølge": 2, "navn": "Oppfølgingssamtaler", ' +
        '"målsetning": "Øke kompetanse og ferdigheter for hvordan man gjennomfører gode oppfølgingssamtaler, ' +
        'både gjennom teori og praksis.", ' +
        '"inkludert": true, "status": "PLANLAGT", "startDato": "2010-01-01", "sluttDato": "2025-02-02" } ] } ] } }';

    @IsTest
    static void json_Should_Be_Parsed_To_Model() {
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(JSON));
        FiaCooperation model = FiaCooperation.parse(JSON, '12345678', encodedValue);

        Assert.areEqual(JSON, model.jsonPayload, 'Json payload should be added to model');
        Assert.areEqual('12345678', model.key, 'Key should be added to model');
        Assert.areEqual(encodedValue, model.hash, 'Encoded value should be added to model hash');

        //Samarbeid
        Assert.areEqual('987654321', model.orgnr, 'Shoud be parsed to model: "orgnr": "987654321"');
        Assert.areEqual(
            '01HNA9BAQFBN660D8TDCNV1R77',
            model.saksnummer,
            'Shoud be parsed to model: "saksnummer": "01HNA9BAQFBN660D8TDCNV1R77"'
        );
        Assert.areEqual('12345678', model.samarbeid.id, 'Shoud be parsed to model:  "id": 12345678');
        Assert.areEqual('Fysio', model.samarbeid.navn, 'Shoud be parsed to model: "navn": "Fysio"');
        Assert.areEqual('AKTIV', model.samarbeid.status, 'Shoud be parsed to model: "status": "AKTIV"');
        //Plan
        Assert.areEqual(
            'c3e1ee3b-a9b4-420c-8ec8-def50e83d054',
            model.plan.id,
            'Shoud be parsed to model: "id": "c3e1ee3b-a9b4-420c-8ec8-def50e83d054"'
        );
        Assert.areEqual(
            Datetime.newInstanceGMT(2024, 9, 17, 10, 17, 59),
            model.plan.sistEndret,
            'Shoud be parsed to model: "sistEndret": "2024-09-17T10:17:59.054765"'
        );
        Assert.areEqual(
            Date.newInstance(2024, 9, 18),
            model.plan.sistPublisert,
            'Shoud be parsed to model: "sistPublisert": "2024-09-18"'
        );
        //Tema
        Assert.areEqual('9847', model.plan.temaer[0].id, 'Shoud be parsed to model: "id": 9847');
        Assert.areEqual(1, model.plan.temaer[0].rekkefolge, 'Shoud be parsed to model: "rekkefølge": 1');
        Assert.areEqual(
            'Partssamarbeid',
            model.plan.temaer[0].navn,
            'Shoud be parsed to model: "navn": "Partssamarbeid"'
        );
        Assert.areEqual(false, model.plan.temaer[0].inkludert, 'Shoud be parsed to model: "inkludert": false');
        //Undertema
        Assert.areEqual('345', model.plan.temaer[0].undertemaer[0].id, 'Shoud be parsed to model: "id": 345');
        Assert.areEqual(1, model.plan.temaer[0].undertemaer[0].rekkefolge, 'Shoud be parsed to model: "rekkefølge": 1');
        Assert.areEqual(
            'Utvikle partssamarbeidet',
            model.plan.temaer[0].undertemaer[0].navn,
            'Shoud be parsed to model: "navn": "Utvikle partssamarbeidet"'
        );
        Assert.areEqual(
            'Styrke og strukturere samarbeidet mellom leder, tillitsvalgt og verneombud, samt øke kunnskap og ferdigheter for å jobbe systematisk og forebyggende med sykefravær og arbeidsmiljø.',
            model.plan.temaer[0].undertemaer[0].malsetning,
            'Shoud be parsed to model: "målsetning": "Styrke og strukturere samarbeidet mellom leder, tillitsvalgt og verneombud, samt øke kunnskap og ferdigheter for å jobbe systematisk og forebyggende med sykefravær og arbeidsmiljø."'
        );
        Assert.areEqual(
            false,
            model.plan.temaer[0].undertemaer[0].inkludert,
            'Shoud be parsed to model: "inkludert": false'
        );
        //Tema
        Assert.areEqual('6576', model.plan.temaer[1].id, 'Shoud be parsed to model: "id": 6576');
        Assert.areEqual(2, model.plan.temaer[1].rekkefolge, 'Shoud be parsed to model: "rekkefølge": 2');
        Assert.areEqual(
            'Sykefraværsarbeid',
            model.plan.temaer[1].navn,
            'Shoud be parsed to model: "navn": "Sykefraværsarbeid"'
        );
        //Undertema
        Assert.areEqual('76576', model.plan.temaer[1].undertemaer[0].id, 'Shoud be parsed to model: "id": 76576');
        Assert.areEqual(1, model.plan.temaer[1].undertemaer[0].rekkefolge, 'Shoud be parsed to model: "rekkefølge": 1');
        Assert.areEqual(
            'Sykefraværsrutiner',
            model.plan.temaer[1].undertemaer[0].navn,
            'Shoud be parsed to model: "navn": "Sykefraværsrutiner"'
        );
        Assert.areEqual(
            'Jobbe systematisk og forebyggende med sykefravær, samt forbedre rutiner og oppfølging av ansatte som er sykmeldte eller står i fare for å bli det.',
            model.plan.temaer[1].undertemaer[0].malsetning,
            'Shoud be parsed to model: "målsetning": "Jobbe systematisk og forebyggende med sykefravær, samt forbedre rutiner og oppfølging av ansatte som er sykmeldte eller står i fare for å bli det."'
        );
        Assert.areEqual(
            true,
            model.plan.temaer[1].undertemaer[0].inkludert,
            'Shoud be parsed to model: "inkludert": true'
        );
        Assert.areEqual(
            'PLANLAGT',
            model.plan.temaer[1].undertemaer[0].status,
            'Shoud be parsed to model: "status": "PLANLAGT"'
        );
        Assert.areEqual(
            Date.newInstance(2010, 1, 1),
            model.plan.temaer[1].undertemaer[0].startDato,
            'Shoud be parsed to model: "startDato": "2010-01-01"'
        );
        Assert.areEqual(
            Date.newInstance(2025, 2, 2),
            model.plan.temaer[1].undertemaer[0].sluttDato,
            'Shoud be parsed to model: "sluttDato": "2025-02-02"'
        );

        Assert.areEqual('65765', model.plan.temaer[1].undertemaer[1].id, 'Shoud be parsed to model: "id": 65765');
        Assert.areEqual(2, model.plan.temaer[1].undertemaer[1].rekkefolge, 'Shoud be parsed to model: "rekkefølge": 2');
        Assert.areEqual(
            'Oppfølgingssamtaler',
            model.plan.temaer[1].undertemaer[1].navn,
            'Shoud be parsed to model: "navn": "Oppfølgingssamtaler"'
        );
    }
}
