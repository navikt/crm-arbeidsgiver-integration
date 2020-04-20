public inherited sharing class KafkaPermitteringHandler_Helper {

	public static List<String> getOrgNumbersFromPermittering( List<KafkaPermitteringHandler_Model> permitteringer ) {
		List<String> organisationNumbers = new List<String>();
		for ( KafkaPermitteringHandler_Model p : permitteringer ) {
			organisationNumbers.add( p.bedriftsnummer );
		}

		return organisationNumbers;
	}

	public static List<KafkaPermitteringHandler_Model> convertKafkaToPermittering( List<KafkaMessage__c> messages ) {
		List<KafkaPermitteringHandler_Model> permitteringer = new List<KafkaPermitteringHandler_Model>();
		for ( KafkaMessage__c msg : messages ) {
			try {
				msg.CRM_IsProcessed__c = true;
				String decodedValue = EncodingUtil.base64Decode( msg.CRM_Value__c ).toString();
				KafkaPermitteringHandler_Model p = KafkaPermitteringHandler_Model.parse( decodedValue );
				permitteringer.add( p );
			} catch ( Exception e ) {
				msg.CRM_Error__c = e.getMessage() + ' (' + e.getLineNumber() + ')';
			}
		}

		return permitteringer;
	}

	public static List<SharedIntegrationFunctions_Helper.ContactWrapper> convertPermitteringToContactWrapper( List<KafkaPermitteringHandler_Model> permitteringer ) {
		List<SharedIntegrationFunctions_Helper.ContactWrapper> wrapperList = new List<SharedIntegrationFunctions_Helper.ContactWrapper>();

		for ( KafkaPermitteringHandler_Model p : permitteringer ) {
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

	public static List<TemporaryLayoff__c> convertPermitteringToLayoff( List<KafkaPermitteringHandler_Model> permitteringer, Map<String, Account> accountMap, Map<String, Contact> contactMap ) {
		List<TemporaryLayoff__c> layoffs = new List<TemporaryLayoff__c>();
		for ( KafkaPermitteringHandler_Model p : permitteringer ) {
			layoffs.add( jsonToTemporaryLayoff( p, accountMap, contactMap ) );
		}

		return layoffs;
	}

	public static TemporaryLayoff__c jsonToTemporaryLayoff( KafkaPermitteringHandler_Model p, Map<String, Account> accountMap, Map<String, Contact> contactMap ) {

		TemporaryLayoff__c tl = new TemporaryLayoff__c();

		if ( accountMap.containsKey( p.bedriftsnummer ) ) { tl.Account__c = accountMap.get( p.bedriftsnummer ).Id; }
		if ( contactMap.containsKey( p.kontaktEpost ) ) { tl.Contact__c = contactMap.get( p.kontaktEpost ).Id; }
		if ( Date.today().year() == 2020 ) { tl.JsonPayload__c = p.jsonPayload; }

		tl.NumberOfEmployees__c = p.antallBerorte;
		tl.Type__c = p.type;
		tl.ContactEmail__c = SharedIntegrationFunctions_Helper.checkIfValidEmail( p.kontaktEpost ) ? p.kontaktEpost : null;
		tl.StartDate__c = p.startDato;
		tl.EndDate__c = p.sluttDato;
		tl.OtherComments__c = p.fritekst;

		List<String> professions = new List<String>();
		for ( KafkaPermitteringHandler_Model.Yrkeskategorier profession : p.yrkeskategorier ) {
			professions.add( profession.label );
		}

		tl.OtherField__c = p.fritekst.split( '### Annet\\n' )[1];
		tl.Profession__c = String.join( professions, ';' );
		tl.Reason__c = p.arsakskode;
		tl.ReasonOther__c = p.arsakskode == 'ANDRE_ÅRSAKER' ? p.arsakstekst : null;

		return tl;
	}
}
