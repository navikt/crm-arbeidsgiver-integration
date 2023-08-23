public with sharing class KafkaFiaCase_Model implements IKafkaMessageParser{

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

    public static KafkaFiaCase_Model parse(String json, String key, String hash) {
        KafkaFiaCase_Model model = (KafkaFiaCase_Model) System.JSON.deserialize(
            json,
            KafkaFiaCase_Model.class
        );
        model.jsonPayload = json;
        model.hash = hash;
        model.key = key;

        return model;
    }

}
