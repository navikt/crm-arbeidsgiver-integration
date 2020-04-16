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
			// orgNumbers.add( model.bedriftsnr );
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
		return null;
	}
}
