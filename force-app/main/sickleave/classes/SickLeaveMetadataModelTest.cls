@IsTest
public with sharing class SickLeaveMetadataModelTest {
    private static final string JSON = 
    '{\n' +
       ' "orgnr": "999999999", \n' +
       '  "arstall": 2023,\n' +
       '  "kvartal": 2,\n' +
       '  "naring": "86",\n' +
       '  "naringskode": "86101",\n' +
       '  "bransje": "SYKEHUS",\n' +
       '  "sektor": "STATLIG"\n' +
    '  } ' ;

    @IsTest
    static void parse(){
        SickLeaveMetadataModel model = SickLeaveMetadataModel.parse(JSON, null, null);
        System.assertEquals('999999999', model.orgnr);
        System.assertEquals(2023, model.arstall);
        System.assertEquals(2, model.kvartal);
        System.assertEquals('86', model.naring);
        System.assertEquals('86101', model.naringskode);
        System.assertEquals('SYKEHUS', model.bransje);
        System.assertEquals('STATLIG', model.sektor);
    }
}