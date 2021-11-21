@IsTest
public class KafkaKontaktSkjemaHandler_ModelTest {
    public static String json = 
    '{ \"type\":\"REKRUTTERING\",\"municipalityCode\":\"3033\",\"organisationName\":\"Finstadtunet\",\"organisationNumber\":\"960507878\",\"firstName\":\"TestNavn\",\"lastName\":\"TestEtternavn\",\"email\":\"test@test.no\",\"phoneNo\":\"90080900\",\"RegionCode\":\"0200\" }';

    static testMethod void testParse() {
        KafkaKontaktSkjemaHandler_Model s = KafkaKontaktSkjemaHandler_Model.parse(
            json
        );
        System.assert(s != null);
        System.assertEquals('REKRUTTERING', s.type);
        System.assertEquals('3033', s.municipalityCode);
        System.assertEquals('Finstadtunet', s.organisationName);
        System.assertEquals('test@test.no', s.email);
        System.assertEquals('0200', s.RegionCode);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        KafkaKontaktSkjemaHandler_Model sNull = new KafkaKontaktSkjemaHandler_Model(System.JSON.createParser(json));
        System.assert(sNull != null);
        System.assert(sNull.type == null);
        System.assert(sNull.municipalityCode == null);
        System.assert(sNull.organisationName == null);
        System.assert(sNull.RegionCode == null);
    }
}
