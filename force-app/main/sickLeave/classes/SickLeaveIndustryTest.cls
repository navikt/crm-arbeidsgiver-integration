@IsTest
public with sharing class SickLeaveIndustryTest {
    private static final string JSON = 
    '{\n' +
       ' "kategori": "NÆRING", \n' +
       '  "kode": "12",\n' +
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
        SickLeaveIndustry model = SickLeaveIndustry.parse(JSON, null, null);
        System.assertEquals('NÆRING', model.kategori);
        System.assertEquals('12', model.kode);

        System.assertEquals(2020, model.sistePubliserteKvartal.arstall);
        System.assertEquals(2, model.sistePubliserteKvartal.kvartal);
        System.assertEquals(2, model.sistePubliserteKvartal.prosent);
        System.assertEquals(10000000.0, model.sistePubliserteKvartal.tapteDagsverk);
        System.assertEquals(500000000.0, model.sistePubliserteKvartal.muligeDagsverk);
        System.assertEquals(2500000, model.sistePubliserteKvartal.antallPersoner);
        System.assertEquals(false, model.sistePubliserteKvartal.erMaskert);

        System.assertEquals(1.9, model.siste4Kvartal.prosent);
        System.assertEquals(38000000.0, model.siste4Kvartal.tapteDagsverk);
        System.assertEquals(2000000000.0, model.siste4Kvartal.muligeDagsverk);
        System.assertEquals(false, model.sistePubliserteKvartal.erMaskert);

        System.assertEquals(2020, model.siste4Kvartal.kvartaler[0].arstall, 'assert arstall from [0] in list kvartaler');
        System.assertEquals(2, model.siste4Kvartal.kvartaler[0].kvartal, 'assert kvartal from [0] in list kvartaler');
        System.assertEquals(2020, model.siste4Kvartal.kvartaler[1].arstall, 'assert arstall from [1] in list kvartaler');
        System.assertEquals(1, model.siste4Kvartal.kvartaler[1].kvartal, 'assert kvartal from [1] in list kvartaler');
        System.assertEquals(2019, model.siste4Kvartal.kvartaler[2].arstall, 'assert arstall from [2] in list kvartaler');
        System.assertEquals(4, model.siste4Kvartal.kvartaler[2].kvartal, 'assert kvartal from [2] in list kvartaler');
        System.assertEquals(2019, model.siste4Kvartal.kvartaler[3].arstall, 'assert arstall from [3] in list kvartaler');
        System.assertEquals(3, model.siste4Kvartal.kvartaler[3].kvartal, 'assert kvartal from [3] in list kvartaler');
    }
}