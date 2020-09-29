public with sharing class SharedIntegrationFunctions {

	public static Map<String, User> fetchUsersByTitle( Set<String> userTitles ) {
		List<User> users = [SELECT Id, Title FROM User WHERE Title IN : userTitles];
		Map<String, User> userMap = new Map<String, User>();
		for ( User u : users ) {
			userMap.put( u.Title, u );
		}

		return userMap;
	}
}