@IsTest
public with sharing class FiaCooperationTest {
    private static final String JSON =
        '{' +
        '    "orgnr": "311837192",' +
        '    "saksnummer": "01HNA9BAQFBN660D8TDCNV1R77",' +
        '    "samarbeid": {' +
        '        "id": 12345678,' +
        '        "navn": "FYSIO-avdeling",' +
        '        "status": "AKTIV",' +
        '        "sistEndret": "2024-09-20T11:37:35.150172",' +
        '        "startDato": "2024-09-01",' +
        '        "sluttDato": "2024-12-01"' +
        '    },' +
        '    "plan": {' +
        '        "id": "9220e758-d84c-4d33-8375-c0e55b4b0f49",' +
        '        "sistEndret": "2024-09-20T11:37:35.150172",' +
        '        "sistPublisert": null,' +
        '        "temaer": [' +
        '            {' +
        '                "id": 175,' +
        '                "navn": "Partssamarbeid",' +
        '                "inkludert": true,' +
        '                "undertemaer": [' +
        '                    {' +
        '                        "id": 628,' +
        '                        "navn": "Utvikle partssamarbeidet",' +
        '                        "målsetning": "Styrke og strukturere samarbeidet mellom leder, tillitsvalgt og verneombud, samt øke kunnskap og ferdigheter for å jobbe systematisk og forebyggende med sykefravær og arbeidsmiljø.",' +
        '                        "inkludert": true,' +
        '                        "status": "PÅGÅR",' +
        '                        "startDato": "2024-09-01",' +
        '                        "sluttDato": "2024-12-01"' +
        '                    }' +
        '                ]' +
        '            },' +
        '            {' +
        '                "id": 176,' +
        '                "navn": "Sykefraværsarbeid",' +
        '                "inkludert": true,' +
        '                "undertemaer": [' +
        '                    {' +
        '                        "id": 632,' +
        '                        "navn": "Sykefravær - enkeltsaker",' +
        '                        "målsetning": "Øke kompetanse og ferdigheter for hvordan man tar tak i, følger opp og løser enkeltsaker.",' +
        '                        "inkludert": false,' +
        '                        "status": null,' +
        '                        "startDato": null,' +
        '                        "sluttDato": null' +
        '                    },' +
        '                    {' +
        '                        "id": 629,' +
        '                        "navn": "Sykefraværsrutiner",' +
        '                        "målsetning": "Jobbe systematisk og forebyggende med sykefravær, samt forbedre rutiner og oppfølging av ansatte som er sykmeldte eller står i fare for å bli det.",' +
        '                        "inkludert": true,' +
        '                        "status": "PLANLAGT",' +
        '                        "startDato": "2024-09-20",' +
        '                        "sluttDato": "2024-10-20"' +
        '                    },' +
        '                    {' +
        '                        "id": 630,' +
        '                        "navn": "Oppfølgingssamtaler",' +
        '                        "målsetning": "Øke kompetanse og ferdigheter for hvordan man gjennomfører gode oppfølgingssamtaler, både gjennom teori og praksis.",' +
        '                        "inkludert": true,' +
        '                        "status": "PLANLAGT",' +
        '                        "startDato": "2024-09-01",' +
        '                        "sluttDato": "2024-12-01"' +
        '                    },' +
        '                    {' +
        '                        "id": 631,' +
        '                        "navn": "Tilretteleggings- og medvirkningsplikt",' +
        '                        "målsetning": "Utvikle rutiner og kultur for tilrettelegging og medvirkning, samt kartlegging av tilretteleggingsmuligheter på arbeidsplassen.",' +
        '                        "inkludert": false,' +
        '                        "status": null,' +
        '                        "startDato": null,' +
        '                        "sluttDato": null' +
        '                    }' +
        '                ]' +
        '            },' +
        '            {' +
        '                "id": 177,' +
        '                "navn": "Arbeidsmiljø",' +
        '                "inkludert": false,' +
        '                "undertemaer": [' +
        '                    {' +
        '                        "id": 636,' +
        '                        "navn": "Livsfaseorientert personalpolitikk",' +
        '                        "målsetning": "Utvikle kultur og personalpolitikk som ivaretar medarbeideres ulike behov, krav, begrensninger og muligheter i ulike livsfaser.",' +
        '                        "inkludert": false,' +
        '                        "status": null,' +
        '                        "startDato": null,' +
        '                        "sluttDato": null' +
        '                    },' +
        '                    {' +
        '                        "id": 637,' +
        '                        "navn": "Psykisk helse",' +
        '                        "målsetning": "Gi innsikt i hvordan psykiske utfordringer kan komme til uttrykk i arbeidshverdagen og øke ferdigheter for hvordan man møter medarbeidere med psykiske helseutfordringer.",' +
        '                        "inkludert": false,' +
        '                        "status": null,' +
        '                        "startDato": null,' +
        '                        "sluttDato": null' +
        '                    },' +
        '                    {' +
        '                        "id": 633,' +
        '                        "navn": "Utvikle arbeidsmiljøet",' +
        '                        "målsetning": "Øke anvendelse og kompetanse innen verktøy og bransjerettet kunnskap for å jobbe målrettet og kunnskapsbasert med eget arbeidsmiljø.",' +
        '                        "inkludert": false,' +
        '                        "status": null,' +
        '                        "startDato": null,' +
        '                        "sluttDato": null' +
        '                    },' +
        '                    {' +
        '                        "id": 634,' +
        '                        "navn": "Endring og omstilling",' +
        '                        "målsetning": "Øke kompetansen for hvordan man ivaretar arbeidsmiljø og forebygger sykefravær under endring og omstilling.",' +
        '                        "inkludert": false,' +
        '                        "status": null,' +
        '                        "startDato": null,' +
        '                        "sluttDato": null' +
        '                    },' +
        '                    {' +
        '                        "id": 635,' +
        '                        "navn": "Oppfølging av arbeidsmiljøundersøkelser",' +
        '                        "målsetning": "Øke ferdigheter og gi støtte til hvordan man kan jobbe med forhold på arbeidsplassen som belyses i egne arbeidsmiljøundersøkelser.",' +
        '                        "inkludert": false,' +
        '                        "status": null,' +
        '                        "startDato": null,' +
        '                        "sluttDato": null' +
        '                    },' +
        '                    {' +
        '                        "id": 638,' +
        '                        "navn": "HelseIArbeid",' +
        '                        "målsetning": "Øke kompetansen og få ansatte til å mestre jobb, selv med muskel/skjelett- og psykiske helseplager.",' +
        '                        "inkludert": false,' +
        '                        "status": null,' +
        '                        "startDato": null,' +
        '                        "sluttDato": null' +
        '                    }' +
        '                ]' +
        '            }' +
        '        ]' +
        '    }' +
        '}';

    @IsTest
    static void json_Should_Be_Parsed_To_Model() {
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(JSON));
        FiaCooperation model = FiaCooperation.parse(JSON, '12345678', encodedValue);

        Assert.areEqual(JSON, model.jsonPayload, 'Json payload should be added to model');
        Assert.areEqual('12345678', model.key, 'Key should be added to model');
        Assert.areEqual(encodedValue, model.hash, 'Encoded value should be added to model hash');

        //Samarbeid
        Assert.areEqual('311837192', model.orgnr, 'Shoud be parsed to model: "orgnr": "311837192"');
        Assert.areEqual(
            '01HNA9BAQFBN660D8TDCNV1R77',
            model.saksnummer,
            'Shoud be parsed to model: "saksnummer": "01HNA9BAQFBN660D8TDCNV1R77"'
        );
        Assert.areEqual('12345678', model.samarbeid.id, 'Shoud be parsed to model:  "id": 12345678');
        Assert.areEqual('FYSIO-avdeling', model.samarbeid.navn, 'Shoud be parsed to model: "navn": "FYSIO-avdeling"');
        Assert.areEqual('AKTIV', model.samarbeid.status, 'Shoud be parsed to model: "status": "AKTIV"');
        Assert.areEqual(
            Date.newInstance(2024, 9, 1),
            model.samarbeid.startDato,
            'Shoud be parsed to model: "startDato": "2024-09-01"'
        );
        Assert.areEqual(
            Date.newInstance(2024, 12, 1),
            model.samarbeid.sluttDato,
            'Shoud be parsed to model: "sluttDato": "2024-12-01"'
        );

        //Plan
        Assert.areEqual(
            '9220e758-d84c-4d33-8375-c0e55b4b0f49',
            model.plan.id,
            'Shoud be parsed to model: "id": "9220e758-d84c-4d33-8375-c0e55b4b0f49"'
        );
        Assert.areEqual(
            Datetime.newInstanceGMT(2024, 9, 20, 11, 37, 35),
            model.plan.sistEndret,
            'Shoud be parsed to model: "sistEndret": "2024-09-20T11:37:35.150172"'
        );

        //Tema
        Assert.areEqual('175', model.plan.temaer[0].id, 'Shoud be parsed to model: "id": 175');
        Assert.areEqual(
            'Partssamarbeid',
            model.plan.temaer[0].navn,
            'Shoud be parsed to model: "navn": "Partssamarbeid"'
        );
        Assert.areEqual(true, model.plan.temaer[0].inkludert, 'Shoud be parsed to model: "inkludert": true');
        //Undertema
        Assert.areEqual('628', model.plan.temaer[0].undertemaer[0].id, 'Shoud be parsed to model: "id": 628');
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
            true,
            model.plan.temaer[0].undertemaer[0].inkludert,
            'Shoud be parsed to model: "inkludert": true'
        );
        Assert.areEqual(
            'PÅGÅR',
            model.plan.temaer[0].undertemaer[0].status,
            'Shoud be parsed to model: "status": "PÅGÅR"'
        );
        Assert.areEqual(
            Date.newInstance(2024, 9, 1),
            model.plan.temaer[0].undertemaer[0].startDato,
            'Shoud be parsed to model: "startDato": "2024-09-01"'
        );
        Assert.areEqual(
            Date.newInstance(2024, 12, 1),
            model.plan.temaer[0].undertemaer[0].sluttDato,
            'Shoud be parsed to model: "sluttDato": "2024-12-01"'
        );
    }

    @IsTest
    static void should_Check_Included_Themes() {
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(JSON));
        FiaCooperation model = FiaCooperation.parse(JSON, '12345678', encodedValue);
        Assert.isTrue(model.includesSykefravaersarbeid());
        Assert.isFalse(model.includesArbeidsmiljo());
        Assert.isTrue(model.includesPartssamarbeid());
    }

    @IsTest
    static void should_Identify_Newest_Message_By_Available_Timestamps() {
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(JSON));
        FiaCooperation model = FiaCooperation.parse(JSON, '12345678', encodedValue);
        FiaCooperation modelToCompare = FiaCooperation.parse(JSON, '12345678', encodedValue);

        model.samarbeid.sistEndret = Datetime.newInstanceGMT(2023, 9, 20, 11, 37, 35);
        model.plan.sistEndret = Datetime.newInstanceGMT(2024, 9, 20, 11, 37, 35);
        modelToCompare.samarbeid.sistEndret = Datetime.newInstanceGMT(2023, 9, 20, 11, 37, 35);
        modelToCompare.plan.sistEndret = Datetime.newInstanceGMT(2023, 9, 20, 11, 37, 35);
        Assert.isTrue(model.isNewer(modelToCompare));

        model.samarbeid.sistEndret = Datetime.newInstanceGMT(2023, 9, 20, 11, 37, 35);
        model.plan.sistEndret = Datetime.newInstanceGMT(2023, 9, 20, 11, 37, 35);
        modelToCompare.samarbeid.sistEndret = Datetime.newInstanceGMT(2024, 9, 20, 11, 37, 35);
        modelToCompare.plan.sistEndret = Datetime.newInstanceGMT(2023, 9, 20, 11, 37, 35);
        Assert.isFalse(model.isNewer(modelToCompare));

        model.samarbeid.sistEndret = Datetime.newInstanceGMT(2023, 9, 20, 11, 37, 35);
        model.plan.sistEndret = Datetime.newInstanceGMT(2023, 9, 20, 11, 37, 35);
        modelToCompare.samarbeid.sistEndret = Datetime.newInstanceGMT(2024, 9, 20, 11, 37, 35);
        modelToCompare.plan = null;
        Assert.isFalse(model.isNewer(modelToCompare));

        model.samarbeid.sistEndret = null;
        model.plan.sistEndret = Datetime.newInstanceGMT(2024, 9, 20, 11, 37, 35);
        modelToCompare.samarbeid.sistEndret = null;
        modelToCompare.plan = null;
        Assert.isTrue(model.isNewer(modelToCompare));

        modelToCompare = null;
        Assert.isTrue(model.isNewer(modelToCompare), 'Is newer when compared to nothing');
    }
}
