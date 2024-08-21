/**
 * @description Model for completed Fia asessments
 */
public with sharing class FiaAssessment implements IKafkaMessageParser {
    public String behovsvurderingId;
    public String saksnummer;
    //public String prosessId;
    public String fullfortTidspunkt;

    public String jsonPayload;
    public String hash;
    public String key;

    /**
     * @description Implementation of parse-method from IKafkaMessageParser
     * @param json Payload as json-string
     * @param key Kafka message Id
     * @param hash Hashed value of payload
     * @return New object instance
     */
    public static FiaAssessment parse(String json, String key, String hash) {
        String formattedJSON = json.replaceAll('"fullførtTidspunkt":', '"fullfortTidspunkt":');
        FiaAssessment model = (FiaAssessment) System.JSON.deserialize(formattedJSON, FiaAssessment.class);
        model.jsonPayload = json;
        model.hash = hash;
        model.key = key;

        return model;
    }
}
