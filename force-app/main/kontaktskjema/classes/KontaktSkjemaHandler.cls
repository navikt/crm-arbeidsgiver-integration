@RestResource(urlMapping = '/ContactForm/*')
global with sharing class KontaktSkjemaHandler {

	private static List<String> PILOT_MUNICIPALITIES = new List<String> { '3033', '3034', '3003', '3035', '3020' };

	public static Id inclusionRecordType = Schema.SObjectType.CustomOpportunity__c.getRecordTypeInfosByDeveloperName().get( 'Inclusion' ).getRecordTypeId();
	public static Id IARecordType = Schema.SObjectType.CustomOpportunity__c.getRecordTypeInfosByDeveloperName().get( 'Inclusive_Employment' ).getRecordTypeId();

	public class RequestWrapper {

		public String type;
		public String municipalityCode;
		public String regionCode;
		public String organisationName;
		public String organisationNumber;
		public String firstName;
		public String lastName;
		public String email;
		public String phoneNo;
	}

	@HttpPost
	global static String doPost( ) {

		String requestString = RestContext.request.requestBody.toString();
		RequestWrapper rw = (RequestWrapper) JSON.deserialize( requestString, RequestWrapper.class );

		if ( !PILOT_MUNICIPALITIES.contains( rw.municipalityCode ) ) {
			return null;
		}

		Id accountId = fetchAccount( rw.organisationNumber );
		Id contactId = fetchOrCreateContact( rw, accountId );

		CustomOpportunity__c co = new CustomOpportunity__c(
			Account__c = accountId,
			Contact__c = contactId,
			Source__c = 'Kontaktskjema',
			TAG_OrganizationNameFromForm__c = rw.organisationName,
			INT_MunicipalityNumber__c = rw.municipalityCode,
			InquiryCategory__c = getType( rw.type ),
			RecordTypeId = getRecordType( rw.type ),
			InclusionStage__c = 'Ny henvendelse' );

		if ( isIA( rw.type ) ) {
			co.INT_RegionNumber__c = rw.regionCode;
		}

		insert co;

		return [SELECT Name FROM CustomOpportunity__c WHERE Id = : co.Id LIMIT 1].Name;
	}

	public static Id fetchAccount( String organisationNumber ) {
		List<Account> acc = [SELECT Id FROM Account

		                     WHERE
		                         ( INT_OrganizationNumber__c = : organisationNumber ) AND
		                         ( INT_OrganizationNumber__c != null ) AND
		                         ( IsPersonAccount = false )

		                     LIMIT 1];

		if ( acc.size() > 0 ) { return acc[0].Id; }
		else { return null; }
	}

	public static Id fetchOrCreateContact( RequestWrapper rw, Id accountId ) {

		List<Contact> existingContact = [SELECT Id FROM Contact WHERE Email = : rw.email LIMIT 1];

		if ( existingContact.size() == 0 ) {
			Contact con = new Contact( FirstName = rw.firstName, LastName = rw.lastName, Email = rw.email, MobilePhone = rw.phoneNo, AccountId = accountId, TAG_Informed__c = true );
			insert con;

			return con.Id;
		} else {
			return existingContact[0].Id;
		}
	}

	public static Id getRecordType( String val ) {
		if ( val == 'FOREBYGGE_SYKEFRAVÆR' ) {
			return IARecordType;
		} else {
			return inclusionRecordType;
		}
	}

	public static Boolean isIA( String val ) {
		return val == 'FOREBYGGE_SYKEFRAVÆR';
	}

	public static String getType( String val ) {
		switch on val {
			when 'REKRUTTERING' {
				return 'Rekruttering';
			} when 'REKRUTTERING_MED_TILRETTELEGGING' {
				return 'Rekruttering med tilrettelegging';
			} when 'ARBEIDSTRENING' {
				return 'Arbeidstrening';
			} when 'FOREBYGGE_SYKEFRAVÆR' {
				return 'Forebygge sykefravær';
			} when else {
				return null;
			}
		}
	}
}