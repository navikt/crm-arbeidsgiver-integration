@IsTest
public with sharing class SykefravaerLandTest {
    private static final string JSON = 
    '{\n' +
       ' "kategori": "LAND", \n' +
       '  "kode": "NO",\n' +
       '  "sistePubliserteKvartal": { \n' +
            '  "årstall": 2020,\n' +
            '  "kvartal": 2,\n' +
            '  "prosent": 2.0,\n' +
            '  "tapteDagsverk": 10000000.0,\n' +
            '  "muligeDagsverk": 500000000.0,\n' +
            '   "antallPersoner": 2500000,\n' +
            '  "erMaskert": false}, \n' +
       '"siste4Kvartal": { \n' +
            '  "prosent": 1.9,\n' +
            '  "tapteDagsverk": 38000000.0,\n' +
            '  "muligeDagsverk": 2000000000.0,\n' +
            '  "erMaskert": false,\n' +
            '  "kvartaler": [\n' +
                '    {\n' +
                '      "årstall": 2020,\n' +
                '      "kvartal": 2\n' +
                '    },\n' +
                '    {\n' +
                '      "årstall": 2020,\n' +
                '      "kvartal": 1\n' +
                '    },\n' +
                '    {\n' +
                '      "årstall": 2019,\n' +
                '      "kvartal": 4\n' +
                '    },\n' +
                '    {\n' +
                '      "årstall": 2019,\n' +
                '      "kvartal": 3\n' +
                '    }\n' +
                '  ]\n' +
            ' }\n' +
    '  } ' ;

    @IsTest

    static void parse(){
        SykefravaerLand model = SykefravaerLand.parse(JSON, null, null);
        System.assertEquals('LAND', model.kategori);
        System.assertEquals('NO', model.kode);

        System.assertEquals('2020', model.sistePubliserteKvartal.arstall);
        System.assertEquals('2', model.sistePubliserteKvartal.kvartal);
        System.assertEquals('2', model.sistePubliserteKvartal.prosent);
        System.assertEquals('10000000.0', model.sistePubliserteKvartal.tapteDagsverk);
        System.assertEquals('500000000.0', model.sistePubliserteKvartal.muligeDagsverk);
        System.assertEquals('2500000', model.sistePubliserteKvartal.antallPersoner);
        System.assertEquals('false', model.sistePubliserteKvartal.erMaskert);

        System.assertEquals('1.9', model.siste4Kvartal.prosent);
        System.assertEquals('38000000.0', model.siste4Kvartal.tapteDagsverk);
        System.assertEquals('2000000000.0', model.siste4Kvartal.muligeDagsverk);
        System.assertEquals('false', model.sistePubliserteKvartal.erMaskert);
        System.assertEquals('2020', model.siste4Kvartal.Kvartaler.arstall);

    }
}