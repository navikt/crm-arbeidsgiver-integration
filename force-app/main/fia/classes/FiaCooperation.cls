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
        public Date startDato;
        public Date sluttDato;
        public Datetime sistEndret;
    }

    public class Plan {
        public String id;
        public Datetime sistEndret;
        public Date sistPublisert;
        public List<Tema> temaer;
    }

    public class Tema {
        public String id;
        public String navn;
        public Boolean inkludert;
        public List<Undertema> undertemaer;
    }

    public class Undertema {
        public String id;
        public String navn;
        public String malsetning;
        public Boolean inkludert;
        public String status;
        public Date startDato;
        public Date sluttDato;
    }

    public static FiaCooperation parse(String json, String key, String hash) {
        String formattedJSON = json.replaceAll('"målsetning":', '"malsetning":');
        FiaCooperation model = (FiaCooperation) System.JSON.deserialize(formattedJSON, FiaCooperation.class);
        model.jsonPayload = json;
        model.hash = hash;
        model.key = key;

        return model;
    }

    public Boolean includesArbeidsmiljo() {
        return includesTema('Arbeidsmiljø');
    }
    public Boolean includesSykefravaersarbeid() {
        return includesTema('Sykefraværsarbeid');
    }
    public Boolean includesPartssamarbeid() {
        return includesTema('Partssamarbeid');
    }

    private Boolean includesTema(String name) {
        boolean isIncluded = false;
        if (plan == null || plan.temaer == null) {
            return isIncluded;
        }
        for (Tema t : plan.temaer) {
            if (t.navn == name && t.inkludert) {
                isIncluded = true;
                break;
            }
        }
        return isIncluded;
    }

    public Datetime getLastModifiedDatetime() {
        if (plan == null || plan.sistEndret == null || plan.sistEndret < samarbeid.sistEndret) {
            return samarbeid.sistEndret;
        } else {
            return plan.sistEndret;
        }
    }

    public Boolean isNewer(FiaCooperation ojectToCompare) {
        if (ojectToCompare == null || ojectToCompare.getLastModifiedDatetime() == null) {
            return true;
        } else if (this.getLastModifiedDatetime() >= ojectToCompare.getLastModifiedDatetime()) {
            return true;
        } else {
            return false;
        }
    }
}
