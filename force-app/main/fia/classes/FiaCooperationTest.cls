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
        '        "endretTidspunkt": "2024-09-20T11:37:35.150172",' +
        '        "startDato": "2024-09-01",' +
        '        "sluttDato": "2024-12-01"' +
        '    },' +
        '    "plan": {' +
        '        "id": "9220e758-d84c-4d33-8375-c0e55b4b0f49",' +
        '        "sistEndret": "2024-09-20T11:37:35.150172",' +
        '        "sistPublisert": "2024-09-18",' +
        '        "status": "AKTIV",' +
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
    static void convertNorwegianTimeToGmt_Should_Convert_Winter_Time() {
        // Winter time in Norway (UTC+1)
        // Test data: 2024-01-15 14:30:00 Norwegian time should be 2024-01-15 13:30:00 GMT
        FiaCooperation.Samarbeid samarbeid = new FiaCooperation.Samarbeid();
        samarbeid.endretTidspunkt = '2024-01-15T14:30:00.123456';

        DateTime result = samarbeid.getLastModifiedDate();

        DateTime expected = DateTime.newInstanceGmt(2024, 1, 15, 13, 30, 0);
        Assert.areEqual(expected, result, 'Winter time should be converted correctly (UTC+1)');
    }

    @IsTest
    static void convertNorwegianTimeToGmt_Should_Convert_Summer_Time() {
        // Summer time in Norway (UTC+2)
        // Test data: 2024-07-15 14:30:00 Norwegian time should be 2024-07-15 12:30:00 GMT
        FiaCooperation.Samarbeid samarbeid = new FiaCooperation.Samarbeid();
        samarbeid.endretTidspunkt = '2024-07-15T14:30:00.123456';

        DateTime result = samarbeid.getLastModifiedDate();

        DateTime expected = DateTime.newInstanceGmt(2024, 7, 15, 12, 30, 0);
        Assert.areEqual(expected, result, 'Summer time should be converted correctly (UTC+2)');
    }

    @IsTest
    static void convertNorwegianTimeToGmt_Should_Handle_Null_Input() {
        FiaCooperation.Samarbeid samarbeid = new FiaCooperation.Samarbeid();
        samarbeid.endretTidspunkt = null;

        DateTime result = samarbeid.getLastModifiedDate();

        Assert.isNull(result, 'Null input should return null');
    }

    @IsTest
    static void convertNorwegianTimeToGmt_Should_Handle_Empty_String() {
        FiaCooperation.Samarbeid samarbeid = new FiaCooperation.Samarbeid();
        samarbeid.endretTidspunkt = '';

        DateTime result = samarbeid.getLastModifiedDate();

        Assert.isNull(result, 'Empty string should return null');
    }

    @IsTest
    static void convertNorwegianTimeToGmt_Should_Handle_Whitespace_String() {
        FiaCooperation.Samarbeid samarbeid = new FiaCooperation.Samarbeid();
        samarbeid.endretTidspunkt = '   ';

        DateTime result = samarbeid.getLastModifiedDate();

        Assert.isNull(result, 'Whitespace string should return null');
    }

    @IsTest
    static void convertNorwegianTimeToGmt_Should_Handle_Edge_Cases() {
        FiaCooperation.Samarbeid samarbeid = new FiaCooperation.Samarbeid();

        // Test midnight
        samarbeid.endretTidspunkt = '2024-01-15T00:00:00.000000';
        DateTime result = samarbeid.getLastModifiedDate();
        DateTime expected = DateTime.newInstanceGmt(2024, 1, 14, 23, 0, 0); // Previous day in GMT
        Assert.areEqual(expected, result, 'Should handle midnight correctly');

        // Test end of year
        samarbeid.endretTidspunkt = '2024-12-31T23:59:59.999999';
        result = samarbeid.getLastModifiedDate();
        expected = DateTime.newInstanceGmt(2024, 12, 31, 22, 59, 59); // Winter time UTC+1
        Assert.areEqual(expected, result, 'Should handle end of year correctly');
    }

    @IsTest
    static void convertNorwegianTimeToGmt_Should_Reject_Invalid_Years() {
        FiaCooperation.Samarbeid samarbeid = new FiaCooperation.Samarbeid();

        // Test year too low
        samarbeid.endretTidspunkt = '1600-01-15T14:30:00.000000';
        DateTime result = samarbeid.getLastModifiedDate();
        Assert.isNull(result, 'Should return null for year < 1700');

        // Test year too high
        samarbeid.endretTidspunkt = '5000-01-15T14:30:00.000000';
        result = samarbeid.getLastModifiedDate();
        Assert.isNull(result, 'Should return null for year > 4000');
    }

    @IsTest
    static void convertNorwegianTimeToGmt_Should_Handle_DST_Transition() {
        FiaCooperation.Samarbeid samarbeid = new FiaCooperation.Samarbeid();

        // Test date just before DST starts (last Sunday in March)
        // 2024: DST starts March 31st at 2:00 AM
        samarbeid.endretTidspunkt = '2024-03-30T14:30:00.000000';
        DateTime result = samarbeid.getLastModifiedDate();
        DateTime expected = DateTime.newInstanceGmt(2024, 3, 30, 13, 30, 0); // Winter time UTC+1
        Assert.areEqual(expected, result, 'Should handle time before DST transition');

        // Test date just after DST starts
        samarbeid.endretTidspunkt = '2024-04-01T14:30:00.000000';
        result = samarbeid.getLastModifiedDate();
        expected = DateTime.newInstanceGmt(2024, 4, 1, 12, 30, 0); // Summer time UTC+2
        Assert.areEqual(expected, result, 'Should handle time after DST transition');
    }
}
