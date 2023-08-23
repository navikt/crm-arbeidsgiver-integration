public with sharing class KafkaFiaDelivery_Model implements IKafkaMessageParser{
    
    public Integer id;
    public String saksnummer;
    public Modul modul;
    public String frist;
    public String status;
    public String opprettetAv;
    public String sistEndret;
    public String sistEndretAv;
    public String sistEndretAvRolle;
    public String fullfort;
    public String enhetsnummer;
    public String enhetsnavn;

    public String jsonPayload;
    public String hash;
    public String key;

    public class Modul {
        public Integer id;
        public IaTjeneste iaTjeneste;
        public String navn;
        public Boolean deaktivert;
    }

    public class IaTjeneste {
        public Integer id;
        public String navn;
        public Boolean deaktivert;
    }

    public static KafkaFiaDelivery_Model parse(String json, String key, String hash) {
        String formattedJSON = json.replaceAll('"fullført":', '"fullfort":');
        KafkaFiaDelivery_Model model = (KafkaFiaDelivery_Model) System.JSON.deserialize(
            formattedJSON, 
            KafkaFiaDelivery_Model.class
        );
        model.jsonPayload = json;
        model.hash = hash;
        model.key = key;

        return model;
         
    }
}