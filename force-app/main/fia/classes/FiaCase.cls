public with sharing class FiaCase implements IKafkaMessageParser {
    public String saksnummer;
    public String orgnr;
    public String eierAvSak;
    public String endretAvHendelseId;
    public String status;
    public String opprettetTidspunkt;
    public String endretTidspunkt;

    public String jsonPayload;
    public String hash;
    public String key;

    public DateTime timeStampFromMessage { get; set; }

    public static FiaCase parse(String json, String key, String hash) {
        FiaCase model = (FiaCase) System.JSON.deserialize(json, FiaCase.class);
        model.jsonPayload = json;
        model.hash = hash;
        model.key = key;
        model.timeStampFromMessage = SharedIntegrationFunctions.convertNorwegianTimeToGmt(model.endretTidspunkt); // model.endretTidspunkt is in Norwegian time zone
        return model;
    }

    /**
     * @description Calculates age in minutes from provided timestamp.
     */
    public Integer getMessageAge(DateTime currentTime) {
        if (this.timeStampFromMessage == null) {
            return null;
        }
        return SharedIntegrationFunctions.calculateMinutesBetween(this.timeStampFromMessage, currentTime);
    }
}
