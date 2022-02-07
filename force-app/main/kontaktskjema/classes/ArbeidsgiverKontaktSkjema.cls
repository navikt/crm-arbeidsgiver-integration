public with sharing class ArbeidsgiverKontaktSkjema {
    public String organisationNumber { get; set; }
    public String municipalityCode { get; set; }
    public String organisationName { get; set; }
    public String phoneNumber { get; set; }
    public String regionCode { get; set; }
    public String fullName { get; set; }
    public String email { get; set; }
    public String type { get; set; }

    public String jsonPayload { get; set; }

    public ArbeidsgiverKontaktSkjema(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'temaType') {
                        this.type = parser.getText();
                    } else if (text == 'kommunenr') {
                        this.municipalityCode = parser.getText();
                    } else if (text == 'orgnr') {
                        this.organisationNumber = parser.getText();
                    } else if (text == 'bedriftsnavn') {
                        this.organisationName = parser.getText();
                    } else if (text == 'navn') {
                        this.fullName = parser.getText();
                    } else if (text == 'epost') {
                        this.email = parser.getText();
                    } else if (text == 'telefonnr') {
                        this.phoneNumber = parser.getText();
                    } else if (text == 'fylkesenhetsnr') {
                        this.regionCode = parser.getText();
                    }
                }
            }
        }
    }

    public static ArbeidsgiverKontaktSkjema parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);

        ArbeidsgiverKontaktSkjema p = new ArbeidsgiverKontaktSkjema(parser);
        p.jsonPayload = json;

        return p;
    }
}
