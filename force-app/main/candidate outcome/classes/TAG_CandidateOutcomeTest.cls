@IsTest
public with sharing class TAG_CandidateOutcomeTest {
    private static final String JSON =
    '{\n' +
    '   "aktørId": "2171954836936",\n' +
    '   "utfall": "FATT_JOBBEN",\n' +
    '   "navIdent": "Z990248",\n' +
    '   "navKontor": "0300",\n' +
    '   "kandidatlisteId": "880e8678-3e04-4a3c-a81a-37fe25998ebf",\n' +
    '   "stillingsId": "016a90-75ad-4a39-8fb4-c65e4ed3c6689b",\n' +
    '   "tidspunkt": "2026-01-20T08:48:52.988",\n' +
    '   "stillingskategori": "FORMIDLING"\n' +
    '}';

    @IsTest
    static void parse() {
        TAG_CandidateOutcome model = TAG_CandidateOutcome.parse(JSON, null, null);

        System.assertEquals('2171954836936', model.aktorId);
        System.assertEquals('FATT_JOBBEN', model.utfall);
        System.assertEquals('Z990248', model.navIdent);
        System.assertEquals('0300', model.navKontor);
        System.assertEquals('880e8678-3e04-4a3c-a81a-37fe25998ebf', model.kandidatlisteId);
        System.assertEquals('016a90-75ad-4a39-8fb4-c65e4ed3c6689b', model.stillingsId);
        System.assertEquals('2026-01-20T08:48:52.988', model.tidspunkt);
        System.assertEquals('FORMIDLING', model.stillingskategori);
    }
}