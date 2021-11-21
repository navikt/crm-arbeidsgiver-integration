public with sharing class KafkaKontaktSkjemaHandler_Model {
    public String type {get;set;} 
	public String municipalityCode {get;set;} 
	public String organisationName {get;set;} 
	public String organisationNumber {get;set;} 
	public String firstName {get;set;} 
	public String lastName {get;set;} 
    public String name {get;set;} 
	public String email {get;set;} 
	public String phoneNo {get;set;} 
	public String RegionCode {get;set;} 

    public String jsonPayload { get; set; }
    public String key { get; set; }

    public KafkaKontaktSkjemaHandler_Model(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'type') {
						type = parser.getText();
					} else if (text == 'municipalityCode') {
						municipalityCode = parser.getText();
					} else if (text == 'organisationName') {
						organisationName = parser.getText();
					} else if (text == 'organisationNumber') {
						organisationNumber = parser.getText();
					} else if (text == 'firstName') {
						firstName = parser.getText();
					} else if (text == 'lastName') {
						lastName = parser.getText();
					} else if (text == 'email') {
						email = parser.getText();
					} else if (text == 'phoneNo') {
						phoneNo = parser.getText();
					} else if (text == 'RegionCode') {
						RegionCode = parser.getText();
					} else {
						System.debug(LoggingLevel.WARN, 'JSON2Apex consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
    }

    public static KafkaKontaktSkjemaHandler_Model parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);

        KafkaKontaktSkjemaHandler_Model p = new KafkaKontaktSkjemaHandler_Model(parser);
        p.jsonPayload = json;

        return p;
    }

    public static void consumeObject(System.JSONParser parser) {
        Integer depth = 0;
        do {
            System.JSONToken curr = parser.getCurrentToken();
            if (curr == System.JSONToken.START_OBJECT || curr == System.JSONToken.START_ARRAY) {
                depth++;
            } else if (curr == System.JSONToken.END_OBJECT || curr == System.JSONToken.END_ARRAY) {
                depth--;
            }
        } while (depth > 0 && parser.nextToken() != null);
    }
}
