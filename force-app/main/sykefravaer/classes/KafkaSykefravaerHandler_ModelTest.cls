@IsTest
public class KafkaSykefravaerHandler_ModelTest {
    public static String json =
    '{' +
    '  \"virksomhetSykefravær\": {' +
    '  \"orgnr\": \"12345678\",' +
    '  \"navn\": \"HGN ELEKTRO AS\",' +
    '  \"årstall\": 2020,' +
    '  \"kvartal\": 3,' +
    '  \"tapteDagsverk\": 256.2,' +
    '  \"muligeDagsverk\": 1987.7,' +
    '  \"antallPersoner\": 33,' +
    '  \"prosent\": 12.9,' +
    '  \"erMaskert\": false,' +
    '  \"kategori\": \"VIRKSOMHET\"' +
    '  },' +
    '  \"næring5SifferSykefravær\": [' +
    '   {' +
    '    \"kategori\": \"NÆRING5SIFFER\",' +
    '    \"kode\": \"43210\",' +
    '    \"årstall\": 2020,' +
    '    \"kvartal\": 3, '+
    '    \"tapteDagsverk\": \"85359.3\",'+
    '    \"muligeDagsverk\": 2073264.0,' +
    '    \"antallPersoner\": 36358,' +
    '    \"prosent\": 4.1,' +
    '    \"erMaskert\": false' +
    '    }' +
    '  ],' +
    ' \"næringSykefravær\": {' +
    '  \"kategori\": \"NÆRING2SIFFER\",' +
    '  \"kode\": \"43\",' +
    '  \"årstall\": 2020,' +
    '  \"kvartal\": 3,' +
    '  \"tapteDagsverk\": \"346657.9\",' +
    '  \"muligeDagsverk\": 7539152.6,' +
    '  \"antallPersoner\": 135007,' +
    '  \"prosent\": 4.6,' +
    '  \"erMaskert\": false' +
    ' },'+
    ' \"sektorSykefravær\": {' +
    '  \"kategori\": \"SEKTOR\",' +
    '  \"kode\": \"3\",' +
    '  \"årstall\": 2020,' +
    '  \"kvartal\": 3,' +
    '  \"tapteDagsverk\": \"3936620.6\",' +
    '  \"muligeDagsverk\": 95132960.7,' +
    '  \"antallPersoner\": 1941373,' +
    '  \"prosent\": 4.1,' +
    '  \"erMaskert\": false' +
    ' },' +
    ' \"landSykefravær\": {' +
    '  \"kategori\": \"LAND\",' +
    '  \"kode\": \"NO\",' +
    '  \"årstall\": 2020,' +
    '  \"kvartal\": 3,' +
    '  \"tapteDagsverk\": \"6474885.7\",' +
    '  \"muligeDagsverk\": 143971107.5,' +
    '  \"antallPersoner\": 2986315,' +
    '  \"prosent\": 4.5,' +
    '  \"erMaskert\": false' +
    ' }' +
    '}';

    static testMethod void testParse() {
        KafkaSykefravaerHandler_Model s = KafkaSykefravaerHandler_Model.parse(json, '2d727ceb-f3f1-4165-a146-2a2665d64441');
        System.assert(s != null);
        System.assertEquals('12345678', s.orgnr);
        System.assertEquals('43210', s.naering.kode);
        System.assertEquals(3936620.6, s.sektor.tapteDagsverk);
        System.assertEquals(2986315, s.land.antallPersoner);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        KafkaSykefravaerHandler_Model sNull = new KafkaSykefravaerHandler_Model(
            System.JSON.createParser(json)
        );
        System.assert(sNull != null);
        System.assert(sNull.orgnr == null);
        System.assert(sNull.naering == null);
        System.assert(sNull.sektor == null);
        System.assert(sNull.land == null);
    }
}