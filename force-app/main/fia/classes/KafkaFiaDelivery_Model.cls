public with sharing class KafkaFiaDelivery_Model implements IKafkaMessageParser{
    public List<Modul> modules { get; set; }
    public List<IaTjeneste> iaservices { get; set; }
    
    public Integer id { get; set; }
    public String saksnummer { get; set; }
    //public Modul modul { get; set; }
    public String frist { get; set; }
    public String status { get; set; }
    public String opprettetAv { get; set; }
    public String sistEndret { get; set; }
    public String sistEndretAv { get; set; }
    public String sistEndretAvRolle { get; set; }
    public String fullfort { get; set; }
    public String enhetsnummer { get; set; }
    public String enhetsnavn{ get; set; }

    public class Modul {
        public Integer id;
        public IaTjeneste iaTjeneste { get; set; }
        public String navn;
        public Boolean deaktivert;
    }

    public class IaTjeneste {
        public Integer id { get; set; }
        public String navn { get; set; }
        public Boolean deaktivert { get; set; }
    }

    public String jsonPayload { get; set; }
    public String hash { get; set; }
    public String key { get; set; }

    public String getModuleName() {
        String names = '';

        if (modules == null) {
            return names;
        }

        for (Modul m : modules) {
            if (m.navn != null) {
                names += m.navn + ', ';
            }
        }
        return names.trim().removeEnd(',');
    }

    public static KafkaFiaDelivery_Model parse(String json, String key, String hash) {
        //meldingen er jsona her. så det failer på det under. 
        KafkaFiaDelivery_Model model = (KafkaFiaDelivery_Model) System.JSON.deserialize(
            json, 
            KafkaFiaDelivery_Model.class
        );
        model.jsonPayload = json;
        model.hash = hash;
        model.key = key;

        return model;
        //jeg lurer på om det failer her. mulig min testkode er feil. mest sannsynlig
        //keytoexistinghash er null
        //så den failer på getlastsaved? linje 75 i handler 
    }
}