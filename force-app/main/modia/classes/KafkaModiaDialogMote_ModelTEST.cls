@isTest
public with sharing class KafkaModiaDialogMote_ModelTEST {
    private static final String JSON =
        '{' +
        '   \"dialogmoteUuid\": \"a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e\",' +
        '   \"statusEndringTidspunkt\": \"1970-01-19T18:46:52.748Z\",' +
        '   \"dialogmoteTidspunkt\": \"1970-01-19T18:55:30.540Z\",' +
        '   \"tilfelleStartdato\": \"1970-01-01T00:00:18.779Z\",' +
        '   \"virksomhetsnummer\": \"974574861",' +
        '   \"statusEndringType\": \"AVLYST\",' +
        '   \"personIdent\": \"05087321470\",' +
        '   \"navIdent\": \"Z994911\",' +
        '   \"arbeidstaker\": true,' +
        '   \"arbeidsgiver\": true,' +
        '   \"sykmelder\": false,' +
        '   \"enhetNr\": \"1805\"' +
        '}';

    @isTest
    static void parse() {
        KafkaModiaDialogMote_Model model = KafkaModiaDialogMote_Model.parse(JSON, null, null);

        System.assertEquals('a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e', model.dialogmoteUuid);
        System.assertEquals('1970-01-19T18:46:52.748Z', model.statusEndringTidspunkt);
        System.assertEquals('1970-01-19T18:55:30.540Z', model.dialogmoteTidspunkt);
        System.assertEquals('1970-01-01T00:00:18.779Z', model.tilfelleStartdato);
        System.assertEquals('974574861', model.virksomhetsnummer);
        System.assertEquals('AVLYST', model.statusEndringType);
        System.assertEquals('05087321470', model.personIdent);
        System.assertEquals('Z994911', model.navIdent);
        System.assertEquals(true, model.arbeidstaker);
        System.assertEquals(true, model.arbeidsgiver);
        System.assertEquals(false, model.sykmelder);
        System.assertEquals('1805', model.enhetNr);
    }
}
