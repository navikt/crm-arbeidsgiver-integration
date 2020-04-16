@IsTest
public class KafkaArenaHandler_ModelTest {

	public static String json = '{' +
	                            '    \"aktivitetStatuskode\": \"FULLF\",' +
	                            '    \"bedriftsnr\": 973113631,' +
	                            '    \"beskrivelse\": \"Bedriftsøkonomstudiet 20 vt\\nHøgskolekandidatstudiet med retning for regnskapsførere. 20vt\",' +
	                            '    \"orgnrMorselskap\": 971228865,' +
	                            '    \"saksbehandler\": \"JEI1812\",' +
	                            '    \"aktivitetskode\": \"UTDYRK\",' +
	                            '    \"fraDato\": \"2003-01-01\",' +
	                            '    \"tilDato\": \"2004-12-31\",' +
	                            '    \"regDato\": \"2003-03-25\",' +
	                            '    \"regUser\": \"GL1812\",' +
	                            '    \"aktivitetsgruppekode\": \"TLTAK\",' +
	                            '    \"aktivitetstypebeskrivelse\": null,' +
	                            '    \"aktivitetstypenavn\": \"Utdanning\",' +
	                            '    \"fornavn\": \"Jonn Egil\",' +
	                            '    \"etternavn\": \"Indrevoll\",' +
	                            '    \"navIdent\": \"I111345\"' +
	                            '}';
	private static testMethod void testParse() {
		KafkaArenaHandler_Model obj = KafkaArenaHandler_Model.parse( json );
		System.assert (obj != null);
	}
}