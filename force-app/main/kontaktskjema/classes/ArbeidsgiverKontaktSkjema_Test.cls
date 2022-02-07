@IsTest
public class ArbeidsgiverKontaktSkjema_Test {
    private static final String JSON =
        '{' +
        '   \"temaType\": \"REKRUTTERING\",' +
        '   \"fylkesenhetsnr\": \"0300\",' +
        '   \"kommunenr\": \"3033\",' +
        '   \"bedriftsnavn\": \"Finstadtunet\",' +
        '   \"orgnr\": \"960507878\",' +
        '   \"epost\": \"test@test.no\",' +
        '   \"telefonnr\": \"90080900\",' +
        '   \"navn\": \"TestNavn\"' +
        '}';

    @isTest
    static void parse() {
        ArbeidsgiverKontaktSkjema model = ArbeidsgiverKontaktSkjema.parse(JSON);

        System.assertEquals('Finstadtunet', model.organisationName);
        System.assertEquals('960507878', model.organisationNumber);
        System.assertEquals('3033', model.municipalityCode);
        System.assertEquals('90080900', model.phoneNumber);
        System.assertEquals('test@test.no', model.email);
        System.assertEquals('REKRUTTERING', model.type);
        System.assertEquals('TestNavn', model.fullName);
        System.assertEquals('0300', model.RegionCode);
    }
}
