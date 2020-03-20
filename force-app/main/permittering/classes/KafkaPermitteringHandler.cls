public inherited sharing class KafkaPermitteringHandler implements IKafkaMessageConsumer {

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
		Boolean ukjentSluttDato;
		String fritekst;
		Integer antallBerorte;
	}

	public void processMessages( List<KafkaMessage__c> messages ) {
		System.debug( 'tetetetet' );
		List<Permittering> permitteringer = new List<Permittering>();
		for ( KafkaMessage__c msg : messages ) {
			try {
				msg.CRM_IsProcessed__c = true;
				String decodedValue = EncodingUtil.base64Decode( msg.CRM_Value__c ).toString();
				Permittering p = (Permittering) JSON.deserialize( decodedValue, KafkaPermitteringHandler.Permittering.class );
				permitteringer.add( p );
			} catch ( Exception e ) {
				msg.CRM_Error__c = e.getMessage() + ' (' + e.getLineNumber() + ')';
			}
		}

		List<String> organisationNumbers = new List<String>();
		List<TemporaryLayoff__c> layoffs = new List<TemporaryLayoff__c>();
		for ( Permittering p : permitteringer ) {
			organisationNumbers.add( p.bedriftsnummer );
		}

		Map<String, Account> accountMap = fetchAccounts( organisationNumbers );
		Map<String, Contact> contactMap = fetchOrCreateContact( permitteringer, accountMap );

		for ( Permittering p : permitteringer ) {
			layoffs.add( jsonToTemporaryLayoff( p, accountMap, contactMap ) );
		}
		insert layoffs;

	}

	public static Map<String, Account> fetchAccounts( List<String> organisationNumbers ) {
		List<Account> accounts = [SELECT Id, INT_OrganizationNumber__c, INT_MunicipalityNumber__c FROM Account

		                          WHERE
		                              ( INT_OrganizationNumber__c IN : organisationNumbers ) AND
		                              ( INT_OrganizationNumber__c != null ) AND
		                              ( IsPersonAccount = false )];


		Map<String, Account> accountMap = new Map<String, Account>();
		for ( Account acc : accounts ) {
			accountMap.put( acc.INT_OrganizationNumber__c, acc );
		}

		return accountMap;
	}

	public static Map<String, Contact> fetchOrCreateContact( List<Permittering> permitteringer, Map<String, Account> accountMap ) {

		List<String> emails = new List<String>();
		for ( Permittering p : permitteringer ) {
			emails.add( p.kontaktEpost );
		}

		List<Contact> existingContacts = [SELECT Id, Email FROM Contact WHERE Email IN : emails];
		Map<String, Contact> contactMap = new Map<String, Contact>();

		for ( Contact con : existingContacts ) {
			contactMap.put( con.Email, con );
		}

		List<Contact> newContacts = new List<Contact>();
		for ( Permittering p : permitteringer ) {

			if ( !contactMap.containsKey( p.kontaktEpost ) ) {

				List<String> name = p.kontaktNavn.split( ' ' );
				String lastName = name[name.size() - 1];
				String firstName = p.kontaktNavn.removeEnd( ' ' + lastName );
				Id accountId = accountMap.containsKey( p.bedriftsnummer ) ? accountMap.get( p.bedriftsnummer ).Id : null;
				Contact con = new Contact( FirstName = firstName, LastName = lastName, Email = p.kontaktEpost, MobilePhone = p.kontaktTlf, AccountId = accountId, TAG_Informed__c = true );
				newContacts.add( con );
			}
		}
		insert newContacts;

		for ( Contact con : newContacts ) {
			contactMap.put( con.Email, con );
		}

		return contactMap;
	}


	public static TemporaryLayoff__c jsonToTemporaryLayoff( Permittering p, Map<String, Account> accountMap, Map<String, Contact> contactMap ) {

		TemporaryLayoff__c tl = new TemporaryLayoff__c();

		if ( accountMap.containsKey( p.bedriftsnummer ) ) { tl.Account__c = accountMap.get( p.bedriftsnummer ).Id; }
		if ( contactMap.containsKey( p.kontaktEpost ) ) { tl.Contact__c = contactMap.get( p.kontaktEpost ).Id; }

		tl.EndDate__c = p.sluttDato;

		tl.NumberOfEmployees__c = p.antallBerorte;
		tl.OtherComments__c = p.fritekst;
		tl.StartDate__c = p.startDato;
		tl.Type__c = p.type;

		// tl.NAV_Unit__c = null;
		// tl.Profession__c = ?????????
		// tl.Reason__c = ????????????

		return tl;
	}
}
