@IsTest
public class KafkaPermitteringHandler_ModelTest {
    // This test method should give 100% coverage
    public static String json =
        '{' +
        '  \"id\" : \"2d727ceb-f3f1-4165-a146-2a2665d64441\",' +
        '  \"bedriftsnummer\" : \"920845908\",' +
        '  \"sendtInnTidspunkt\" : \"2020-04-19T16:02:22.033420Z\",' +
        '  \"type\" : \"PERMITTERING_UTEN_LØNN\",' +
        '  \"kontaktNavn\" : \"test nav\",' +
        '  \"kontaktTlf\" : \"80080900\",' +
        '  \"kontaktEpost\" : \"ververvr@test.com\",' +
        '  \"varsletAnsattDato\" : \"2020-04-19\",' +
        '  \"varsletNavDato\" : \"2020-04-19\",' +
        '  \"startDato\" : \"2020-03-14\",' +
        '  \"sluttDato\" : \"2020-04-26\",' +
        '  \"fritekst\" : \"\\n### Årsak\\nCorona-virus\\n### Yrker\\nKafemedarbeider, Daglig leder\\n### Annet\\nHar tidligere sendt inn permitteringsvarsel fra dag 1 (14. mars 2020). Dette er varsel om forlenging frem til 27, april 2020. \",' +
        '  \"antallBerorte\" : 2,' +
        '  \"årsakskode\" : \"ANDRE_ÅRSAKER\",' +
        '  \"årsakstekst\" : \"Corona-virus\",' +
        '  \"yrkeskategorier\" : [ {' +
        '    \"konseptId\" : 70029,' +
        '    \"styrk08\" : \"5246\",' +
        '    \"label\" : \"Kafemedarbeider\"' +
        '  }, {' +
        '    \"konseptId\" : 313808,' +
        '    \"styrk08\" : \"1120\",' +
        '    \"label\" : \"Daglig leder\"' +
        '  } ],' +
        '  \"bedrift\": [' +
        '    {' +
        '      \"bedriftNr\": \"12345678\",' +
        '      \"bedriftNavn\": \"test\",' +
        '      \"antallBerorte\": 12' +
        '    },' +
        '    {' +
        '      \"bedriftNr\": \"87654321\",' +
        '      \"bedriftNavn\": \"test2\",' +
        '      \"antallBerorte\": 124' +
        '    }' +
        '  ]' +
        '}';
    static testMethod void testParse() {
        KafkaPermitteringHandler_Model r = KafkaPermitteringHandler_Model.parse(
            json
        );
        System.assert(r != null);
        System.assertEquals(r.arsakskode, 'ANDRE_ÅRSAKER');

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        KafkaPermitteringHandler_Model objKafkaPermitteringHandler_Model = new KafkaPermitteringHandler_Model(
            System.JSON.createParser(json)
        );
        System.assert(objKafkaPermitteringHandler_Model != null);
        System.assert(objKafkaPermitteringHandler_Model.id == null);
        System.assert(objKafkaPermitteringHandler_Model.bedriftsnummer == null);
        System.assert(
            objKafkaPermitteringHandler_Model.sendtInnTidspunkt == null
        );
        System.assert(objKafkaPermitteringHandler_Model.type == null);
        System.assert(objKafkaPermitteringHandler_Model.kontaktNavn == null);
        System.assert(objKafkaPermitteringHandler_Model.kontaktTlf == null);
        System.assert(objKafkaPermitteringHandler_Model.kontaktEpost == null);
        System.assert(
            objKafkaPermitteringHandler_Model.varsletAnsattDato == null
        );
        System.assert(objKafkaPermitteringHandler_Model.varsletNavDato == null);
        System.assert(objKafkaPermitteringHandler_Model.startDato == null);
        System.assert(objKafkaPermitteringHandler_Model.sluttDato == null);
        System.assert(objKafkaPermitteringHandler_Model.fritekst == null);
        System.assert(objKafkaPermitteringHandler_Model.antallBerorte == null);
        System.assert(objKafkaPermitteringHandler_Model.arsakskode == null);
        System.assert(objKafkaPermitteringHandler_Model.arsakstekst == null);
        System.assert(
            objKafkaPermitteringHandler_Model.yrkeskategorier == null
        );
        System.assert(objKafkaPermitteringHandler_Model.bedrift == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        KafkaPermitteringHandler_Model.Yrkeskategorier objYrkeskategorier = new KafkaPermitteringHandler_Model.Yrkeskategorier(
            System.JSON.createParser(json)
        );
        System.assert(objYrkeskategorier != null);
        System.assert(objYrkeskategorier.konseptId == null);
        System.assert(objYrkeskategorier.styrk08 == null);
        System.assert(objYrkeskategorier.label == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        KafkaPermitteringHandler_Model.Bedrift objBedrift = new KafkaPermitteringHandler_Model.Bedrift(
            System.JSON.createParser(json)
        );
        System.assert(objBedrift != null);
        System.assert(objBedrift.bedriftNr == null);
        System.assert(objBedrift.bedriftNavn == null);
        System.assert(objBedrift.antallBerorte == null);
    }
}
