public inherited sharing class KafkaPermitteringHandler_Helper {

	public class LayoffWrapper {
		public List<TemporaryLayoff__c> layoffs;
		public List<TemporaryLayoffJunction__c> layoffJunction;
	}

	public static List<KafkaPermitteringHandler_Model> convertKafkaToPermittering( List<KafkaMessage__c> messages ) {
		List<KafkaPermitteringHandler_Model> permitteringer = new List<KafkaPermitteringHandler_Model>();
		for ( KafkaMessage__c msg : messages ) {
			try {
				msg.CRM_IsProcessed__c = true;
				String decodedValue = KafkaMessageUtils.base64ULSafeDecode( msg.CRM_Value__c ).toString();
				KafkaPermitteringHandler_Model p = KafkaPermitteringHandler_Model.parse( decodedValue );
				permitteringer.add( p );
			} catch ( Exception e ) {
				msg.CRM_Error__c = e.getMessage() + ' (' + e.getLineNumber() + ')';
			}
		}

		return permitteringer;
	}

	public static List<String> getOrgNumbersFromPermittering( List<KafkaPermitteringHandler_Model> permitteringer ) {
		List<String> organisationNumbers = new List<String>();
		for ( KafkaPermitteringHandler_Model p : permitteringer ) {
			organisationNumbers.add( p.bedriftsnummer );

			if ( p.bedrift != null ) {
				for ( KafkaPermitteringHandler_Model.Bedrift subsidiary : p.bedrift ) {
					if ( subsidiary.bedriftNr != null ) {
						organisationNumbers.add( subsidiary.bedriftNr );
					}
				}
			}
		}

		return organisationNumbers;
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

	public static LayoffWrapper convertPermitteringToLayoff( List<KafkaPermitteringHandler_Model> permitteringer, Map<String, Account> accountMap, Map<String, Contact> contactMap ) {

		LayoffWrapper lw = new LayoffWrapper();
		List<TemporaryLayoff__c> layoffs = new List<TemporaryLayoff__c>();
		List<TemporaryLayoffJunction__c> layoffJunctions = new List<TemporaryLayoffJunction__c>();

		for ( KafkaPermitteringHandler_Model p : permitteringer ) {

			Boolean onlySubsidiary = false;
			if ( p.bedrift != null ) {
				onlySubsidiary = p.bedrift.size() == 1;
			}

			TemporaryLayoff__c tl = jsonToTemporaryLayoff( p, accountMap, contactMap, onlySubsidiary );
			layoffs.add( tl );

			if ( p.bedrift != null && !onlySubsidiary ) {
				layoffJunctions.addAll( jsonToTemporaryLayoffJunction( p, accountMap, tl ) );
			}
		}

		lw.layoffs = layoffs;
		lw.layoffJunction = layoffJunctions;

		return lw;
	}

	public static List<TemporaryLayoffJunction__c> jsonToTemporaryLayoffJunction( KafkaPermitteringHandler_Model p, Map<String, Account> accountMap, TemporaryLayoff__c tl ) {

		List<TemporaryLayoffJunction__c> tljList = new List<TemporaryLayoffJunction__c> ();

		for ( KafkaPermitteringHandler_Model.Bedrift subsidiary : p.bedrift ) {
			TemporaryLayoffJunction__c tlj = new TemporaryLayoffJunction__c();

			if ( accountMap.containsKey( subsidiary.bedriftNr ) ) { tlj.Account__c = accountMap.get( subsidiary.bedriftNr ).Id; }
			tlj.TemporaryLayoff__r = new TemporaryLayoff__c( KafkaId__c = tl.KafkaId__c );

			tlj.NumberOfEmployees__c = subsidiary.antallBerorte;

			tljList.add( tlj );
		}

		return tljList;

	}

	public static TemporaryLayoff__c jsonToTemporaryLayoff( KafkaPermitteringHandler_Model p, Map<String, Account> accountMap, Map<String, Contact> contactMap, Boolean onlyOneSubsidiary ) {

		TemporaryLayoff__c tl = new TemporaryLayoff__c();
		if ( accountMap.containsKey( p.bedriftsnummer ) ) { tl.Account__c = accountMap.get( p.bedriftsnummer ).Id; }
		if ( contactMap.containsKey( p.kontaktEpost.toLowerCase() ) ) { tl.Contact__c = contactMap.get( p.kontaktEpost.toLowerCase() ).Id; }
		if ( Date.today().year() == 2020 ) { tl.JsonPayload__c = p.jsonPayload; }

		tl.KafkaId__c = p.id;
		tl.NumberOfEmployees__c = p.antallBerorte;
		tl.Type__c = p.type;
		tl.ContactEmail__c = SharedIntegrationFunctions_Helper.checkIfValidEmail( p.kontaktEpost ) ? p.kontaktEpost : null;
		tl.StartDate__c = p.startDato;
		tl.EndDate__c = p.sluttDato;
		tl.OtherComments__c = p.fritekst;

		List<String> professions = new List<String>();
		if ( p.yrkeskategorier != null ) {
			for ( KafkaPermitteringHandler_Model.Yrkeskategorier profession : p.yrkeskategorier ) {
				professions.add( profession.label );
			}
		}

		if ( p.fritekst.contains( '### Annet' ) ) {
			List<String> otherComments = p.fritekst.split( '### Annet\\n' );
			if ( otherComments.size() == 2 ) {
				tl.OtherField__c = otherComments[1];
			}
		}

		tl.Profession__c = String.join( professions, ';' );
		tl.Reason__c = p.arsakskode;
		tl.ReasonOther__c = p.arsakstekst;

		return tl;
	}

	public static List<TemporaryLayoff__c> removeExistingTempLayoffs( List<TemporaryLayoff__c> layoffs ) {

		Set<String> uuids = new Set<String>();

		for ( TemporaryLayoff__c layoff : layoffs ) {
			uuids.add( layoff.KafkaId__c );
		}

		Set<String> existingLayoffUuids = new Set<String>();
		for ( TemporaryLayoff__c layoff : [SELECT Id, KafkaId__c FROM TemporaryLayoff__c WHERE KafkaId__c IN : uuids] ) {
			existingLayoffUuids.add( layoff.KafkaId__c );
		}

		List<TemporaryLayoff__c> filteredLayoffs = new List<TemporaryLayoff__c>();
		for ( TemporaryLayoff__c layoff : layoffs ) {
			if ( !existingLayoffUuids.contains( layoff.KafkaId__c ) ) {
				filteredLayoffs.add( layoff );
			}
		}

		return filteredLayoffs;
	}

	public static List<TemporaryLayoff__c> removeDuplicateTempLayoffsInList( List<TemporaryLayoff__c> layoffs ) {

		Map<String, TemporaryLayoff__c> layoffMap = new Map<String, TemporaryLayoff__c>();
		for ( TemporaryLayoff__c layoff : layoffs ) {
			if ( !layoffMap.containsKey( layoff.KafkaId__c ) ) {
				layoffMap.put( layoff.KafkaId__c, layoff );
			}
		}

		return layoffMap.values();
	}
}
