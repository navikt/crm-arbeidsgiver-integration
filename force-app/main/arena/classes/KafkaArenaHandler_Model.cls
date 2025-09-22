public with sharing class KafkaArenaHandler_Model {
    public Integer orgnrMorselskap { get; set; }
    public Integer bedriftsnr { get; set; }
    public String aktivitetStatuskode { get; set; }
    public String beskrivelse { get; set; }
    public String saksbehandler { get; set; }
    public String aktivitetskode { get; set; }
    public String fraDato { get; set; }
    public String tilDato { get; set; }
    public String regDato { get; set; }
    public String regUser { get; set; }
    public String aktivitetsgruppekode { get; set; }
    public String aktivitetstypebeskrivelse { get; set; }
    public String aktivitetstypenavn { get; set; }
    public String fornavn { get; set; }
    public String etternavn { get; set; }
    public String navIdent { get; set; }

    public String key { get; set; }
    public String hash { get; set; }
    public String jsonPayload { get; set; }
    public DateTime timeStampFromMessage { get; set; }

    public static KafkaArenaHandler_Model parse(String json, String key, String hash) {
        KafkaArenaHandler_Model model = (KafkaArenaHandler_Model) System.JSON.deserialize(
            json,
            KafkaArenaHandler_Model.class
        );
        model.key = key;
        model.hash = hash;
        model.jsonPayload = json;
        model.timeStampFromMessage = SharedIntegrationFunctions.convertNorwegianTimeToGmt(model.key);
        return model;
    }
    /**
     * @description Calculate age of message in minutes from timestamp in key to current time
     * @param currentTime Current time in GMT
     * @return Age of message in minutes, or null if timestamp is missing or invalid
     */
    public Integer getMessageAge(DateTime currentTime) {
        if (currentTime == null || timeStampFromMessage == null) {
            return null;
        }
        Integer minutes = SharedIntegrationFunctions.calculateMinutesBetween(timeStampFromMessage, currentTime);
        return minutes;
    }

    // Extract DateTime from key
    private static DateTime extractMessageTimeStampFromKey(String key) {
        // Verify that key looks like a datetime
        if (key == null || key.length() != 26) {
            return null;
        }
        DateTime dt = SharedIntegrationFunctions.convertNorwegianTimeToGmt(key);
        return dt;
    }
}
