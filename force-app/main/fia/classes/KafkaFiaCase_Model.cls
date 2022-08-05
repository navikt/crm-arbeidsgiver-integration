public with sharing class KafkaFiaCase_Model implements IKafkaMessageParser{
    public String saksnummer { get; set; }
    public String orgnr { get; set; }
    public String eierAvSak { get; set; }
    public String endretAvHendelseId { get; set; }
    public String status { get; set; }
    public String opprettetTidspunkt { get; set; }
    public String endretTidspunkt { get; set; }

    public String jsonPayload { get; set; }
    public String hash { get; set; }
    public String key { get; set; }

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
