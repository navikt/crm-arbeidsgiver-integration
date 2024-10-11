/**
 * @description Model for IA Cooperation.
 */

public with sharing class FiaCooperation implements IKafkaMessageParser {
    public String orgnr;
    public String saksnummer;
    public Samarbeid samarbeid;
    public Plan plan;
    public String jsonPayload;
    public String hash;
    public String key;

    public class Samarbeid {
        public String id;
        public String navn;
        public String status;
    }

    public class Plan {
        public String id;
        public Datetime sistEndret;
        public Date sistPublisert;
        public List<Tema> temaer;
    }

    public class Tema {
        public String id;
        public Integer rekkefolge;
        public String navn;
        public Boolean planlagt; // planlagt på tema og undertema endres til inkludert - Betyr at den ikke er en del av planen. Ikke lenger synlig i fia. Må legge til logikk for å tolke inkludert
        public Boolean inkludert; // inkludert
        public List<Undertema> undertemaer;
    }

    public class Undertema {
        public String id;
        public Integer rekkefolge;
        public String navn;
        public String malsetning;
        public Boolean planlagt; // endres til inkludert
        public Boolean inkludert; // inkludert
        public String status;
        public Date startDato;
        public Date sluttDato;
    }

    public static FiaCooperation parse(String json, String key, String hash) {
        String formattedJSON = json.replaceAll('"rekkefølge":', '"rekkefolge":');
        formattedJSON = formattedJSON.replaceAll('"målsetning":', '"malsetning":');
        FiaCooperation model = (FiaCooperation) System.JSON.deserialize(formattedJSON, FiaCooperation.class);
        model.jsonPayload = json;
        model.hash = hash;
        model.key = key;

        return model;
    }
}
