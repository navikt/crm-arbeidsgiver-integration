public with sharing class FiaDelivery implements IKafkaMessageParser{
    
    public Integer id;
    public String saksnummer;
    //public Modul modul;
    public Integer iaTjenesteId;
    public String iaTjenesteNavn;
    public Integer iaModulId;
    public String iaModulNavn;
    public String frist;
    public String status;
    public String opprettetAv;
    public String sistEndret;
    public String sistEndretAv;
    public String sistEndretAvRolle;
    public String fullfort;
    public String enhetsnummer;
    public String enhetsnavn;
    public String opprettetTidspunkt;

    public String jsonPayload;
    public String hash;
    public String key;

    /*public class Modul {
        public Integer id;
        public IaTjeneste iaTjeneste;
        public String navn;
        public Boolean deaktivert;
    }

    public class IaTjeneste {
        public Integer id;
        public String navn;
        public Boolean deaktivert;
    }*/

    public static FiaDelivery parse(String json, String key, String hash) {
        String formattedJSON = json.replaceAll('"fullført":', '"fullfort":');
        FiaDelivery model = (FiaDelivery) System.JSON.deserialize(
            formattedJSON, 
            FiaDelivery.class
        );
        model.jsonPayload = json;
        model.hash = hash;
        model.key = key;

        return model;
         
    }
}