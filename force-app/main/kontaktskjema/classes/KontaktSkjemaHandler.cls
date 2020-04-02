@RestResource(urlMapping = '/ContactForm/*')
global with sharing class KontaktSkjemaHandler {

	private static List<String> PILOT_MUNICIPALITIES = new List<String> { '3033', '3034', '3003', '3035', '3020' };

	public static Id inclusionRecordType = Schema.SObjectType.CustomOpportunity__c.getRecordTypeInfosByDeveloperName().get( 'Inclusion' ).getRecordTypeId();
	public static Id IARecordType = Schema.SObjectType.CustomOpportunity__c.getRecordTypeInfosByDeveloperName().get( 'Inclusive_Employment' ).getRecordTypeId();

	public class RequestWrapper {

		String type;
		String municipalityCode;
		String regionCode;
		String organisationName;
		String organisationNumber;
		String firstName;
		String lastName;
		String email;
		String phoneNo;

		String jsonPayload;
	}

	@HttpPost
	global static String doPost( ) {

		String requestString = RestContext.request.requestBody.toString();
		RequestWrapper rw = (RequestWrapper) JSON.deserialize( requestString, RequestWrapper.class );
		rw.jsonPayload = requestString;

		if ( !PILOT_MUNICIPALITIES.contains( rw.municipalityCode ) ) {
			return null;
		}

		SharedIntegrationFunctions_Helper.ContactWrapper wrapper = new SharedIntegrationFunctions_Helper.ContactWrapper();
		wrapper.firstName = rw.firstName;
		wrapper.lastName = rw.lastName;
		wrapper.phone = rw.phoneNo;
		wrapper.email = rw.email;
		wrapper.companyNumber = rw.organisationNumber;
		List<SharedIntegrationFunctions_Helper.ContactWrapper> wrapperList = new List<SharedIntegrationFunctions_Helper.ContactWrapper> { wrapper };

		Map<String, Account> accountMap = SharedIntegrationFunctions.fetchAccounts( new List<String> { rw.organisationNumber } );
		Id accountId = accountMap.containsKey( rw.organisationNumber ) ? accountMap.get( rw.organisationNumber ).Id : null;
		Map<String, Contact> contactMap = SharedIntegrationFunctions.fetchOrCreateContact( wrapperList, accountMap );
		Id contactId = contactMap.containsKey( rw.email ) ? contactMap.get( rw.email ).Id : null;

		CustomOpportunity__c co = new CustomOpportunity__c(
			Account__c = accountId,
			Contact__c = contactId,
			Source__c = 'Kontaktskjema',
			TAG_OrganizationNameFromForm__c = rw.organisationName,
			INT_MunicipalityNumber__c = rw.municipalityCode,
			InquiryCategory__c = getType( rw.type ),
			RecordTypeId = getRecordType( rw.type ),
			InclusionStage__c = 'Ny henvendelse' );

		if ( Date.today().year() == 2020 ) { co.JsonPayload__c = rw.jsonPayload; }

		if ( isIA( rw.type ) ) {
			co.INT_RegionNumber__c = rw.regionCode;
		}

		insert co;

		return [SELECT Name FROM CustomOpportunity__c WHERE Id = : co.Id LIMIT 1].Name;
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