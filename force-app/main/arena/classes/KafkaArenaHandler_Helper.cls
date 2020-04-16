public inherited sharing class KafkaArenaHandler_Helper {

	public static List<KafkaArenaHandler_Model> convertKafkaToArenaModel( List<KafkaMessage__c> messages ) {
		List<KafkaArenaHandler_Model> arenaModels = new List<KafkaArenaHandler_Model>();
		for ( KafkaMessage__c msg : messages ) {
			try {
				msg.CRM_IsProcessed__c = true;
				String decodedValue = EncodingUtil.base64Decode( msg.CRM_Value__c ).toString();
				KafkaArenaHandler_Model arenaModel = KafkaArenaHandler_Model.parse( decodedValue );
				arenaModels.add( arenaModel );
			} catch ( Exception e ) {
				msg.CRM_Error__c = e.getMessage() + ' (' + e.getLineNumber() + ')';
			}
		}

		return arenaModels;
	}

	public static Set<String> getOrgNumbers( List<KafkaArenaHandler_Model> models ) {
		Set<String> orgNumbers = new Set<String>();
		for ( KafkaArenaHandler_Model model : models ) {
			orgNumbers.add( String.valueOf( model.bedriftsnr ) );
		}

		return orgNumbers;
	}

	public static Set<String> getUserTitles( List<KafkaArenaHandler_Model> models ) {
		Set<String> userTitles = new Set<String>();
		for ( KafkaArenaHandler_Model model : models ) {
			userTitles.add( model.regUser );
			userTitles.add( model.saksbehandler );
		}

		return userTitles;
	}

	public static List<ArenaActivity__c> convertArenaModelToSObject( List<KafkaArenaHandler_Model> models, Map<String, User> userMap, Map<String, Account> accountMap ) {

		List<ArenaActivity__c> arenaActivities = new List<ArenaActivity__c>();

		for ( KafkaArenaHandler_Model model : models ) {

			ArenaActivity__c aa = new ArenaActivity__c(
				AktivitetstypeBeskrivelse__c = model.AktivitetstypeBeskrivelse,
				Aktivitetsgruppekode__c = model.Aktivitetsgruppekode,
				AktivitetStatuskode__c = model.AktivitetStatuskode,
				AktivitetsKode__c = model.AktivitetsKode,
				Aktivitetstype__c = model.aktivitetstypenavn,
				DateRegistered__c = stringToDate( model.regDato ),
				Description__c = model.beskrivelse,
				DateFrom__c = stringToDate( model.fraDato ),
				DateTo__c = stringToDate( model.tilDato )
				);

			aa.RegisteredBy__c = userMap.containsKey( model.regUser ) ? userMap.get( model.regUser ).Id : null;
			aa.Account__c = accountMap.containsKey( String.valueOf( model.bedriftsnr ) ) ? accountMap.get( String.valueOf( model.bedriftsnr ) ).Id : null;
			if ( userMap.containsKey( model.saksbehandler ) ) { aa.OwnerId = userMap.get( model.saksbehandler ).Id; }

			arenaActivities.add( aa );
		}

		return arenaActivities;
	}

	public static Date stringToDate( String dateString ) {
		try {
			return Date.valueOf( dateString.replace( 'T', ' ' ) );
		} catch ( Exception e ) {
			return null;
		}
	}
}
