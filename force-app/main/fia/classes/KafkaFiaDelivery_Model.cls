public with sharing class KafkaFiaDelivery_Model implements IKafkaMessageParser{
    public String id { get; set; }
    public String saksnummer { get; set; }
    public String modul { get; set; }
    public String iaTjeneste { get; set; }
    public String frist { get; set; }
    public String status { get; set; }
    public String opprettetAv { get; set; }
    public String sistEndret { get; set; }
    public String sistEndretAv { get; set; }
    public String sistEndretAvRolle { get; set; }
    public String fullfort { get; set; }
    public String enhetsnummer { get; set; }
    public String enhetsnavn{ get; set; }

    public String jsonPayload { get; set; }
    public String hash { get; set; }
    public String key { get; set; }

    public static KafkaFiaDelivery_Model parse(String json, String key, String hash) {
        KafkaFiaDelivery_Model model = (KafkaFiaDelivery_Model) System.JSON.deserialize(
            json, 
            KafkaFiaDelivery_Model.class
        );
        model.jsonPayload = json;
        model.hash = hash;
        model.key = key;

        return model;
    }
}