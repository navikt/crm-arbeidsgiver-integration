public inherited sharing class KafkaPermitteringHandler_Helper {

	public class Permittering {
		String id;
		String bedriftsnummer;
		Datetime sendtInnTidspunkt;
		String type;
		String kontaktNavn;
		String kontaktTlf;
		String kontaktEpost;
		Date varsletAnsattDato;
		Date varsletNavDato;
		Date startDato;
		Date sluttDato;
		String fritekst;
		Integer antallBerorte;

		String jsonPayload;
	}

	public static List<String> getOrgNumbersFromPermittering( List<Permittering> permitteringer ) {
		List<String> organisationNumbers = new List<String>();
		for ( Permittering p : permitteringer ) {
			organisationNumbers.add( p.bedriftsnummer );
		}

		return organisationNumbers;
	}

	public static List<Permittering> convertKafkaToPermittering( List<KafkaMessage__c> messages ) {
		List<Permittering> permitteringer = new List<Permittering>();
		for ( KafkaMessage__c msg : messages ) {
			try {
				msg.CRM_IsProcessed__c = true;
				String decodedValue = EncodingUtil.base64Decode( msg.CRM_Value__c ).toString();
				Permittering p = (Permittering) JSON.deserialize( decodedValue, Permittering.class );
				p.jsonPayload = decodedValue;
				permitteringer.add( p );
			} catch ( Exception e ) {
				msg.CRM_Error__c = e.getMessage() + ' (' + e.getLineNumber() + ')';
			}
		}

		return permitteringer;
	}

	public static List<SharedIntegrationFunctions_Helper.ContactWrapper> convertPermitteringToContactWrapper( List<Permittering> permitteringer ) {
		List<SharedIntegrationFunctions_Helper.ContactWrapper> wrapperList = new List<SharedIntegrationFunctions_Helper.ContactWrapper>();

		for ( Permittering p : permitteringer ) {
			List<String> name = p.kontaktNavn.split( ' ' );
			String lastName = name[name.size() - 1];
			String firstName = p.kontaktNavn.removeEnd( ' ' + lastName );
			SharedIntegrationFunctions_Helper.ContactWrapper wrapper = new SharedIntegrationFunctions_Helper.ContactWrapper();
			wrapper.firstName = firstName;
			wrapper.lastName = lastName;
			wrapper.phone = p.kontaktTlf;
			wrapper.email = p.kontaktEpost;
			wrapper.companyNumber = p.bedriftsnummer;
			wrapperList.add( wrapper );
		}

		return wrapperList;
	}

	public static List<TemporaryLayoff__c> convertPermitteringToLayoff( List<Permittering> permitteringer, Map<String, Account> accountMap, Map<String, Contact> contactMap ) {
		List<TemporaryLayoff__c> layoffs = new List<TemporaryLayoff__c>();
		for ( Permittering p : permitteringer ) {
			layoffs.add( jsonToTemporaryLayoff( p, accountMap, contactMap ) );
		}

		return layoffs;
	}

	public static TemporaryLayoff__c jsonToTemporaryLayoff( Permittering p, Map<String, Account> accountMap, Map<String, Contact> contactMap ) {

		TemporaryLayoff__c tl = new TemporaryLayoff__c();

		if ( accountMap.containsKey( p.bedriftsnummer ) ) { tl.Account__c = accountMap.get( p.bedriftsnummer ).Id; }
		if ( contactMap.containsKey( p.kontaktEpost ) ) { tl.Contact__c = contactMap.get( p.kontaktEpost ).Id; }
		if ( Date.today().year() == 2020 ) { tl.JsonPayload__c = p.jsonPayload; }

		tl.NumberOfEmployees__c = p.antallBerorte;
		tl.Type__c = p.type.replace( '_', ' ' );
		tl.ContactEmail__c = SharedIntegrationFunctions_Helper.checkIfValidEmail( p.kontaktEpost ) ? p.kontaktEpost : null;
		tl.StartDate__c = p.startDato;
		tl.EndDate__c = p.sluttDato;
		tl.OtherComments__c = p.fritekst;

		return tl;
	}

}