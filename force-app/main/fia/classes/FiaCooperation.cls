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
        public String endretTidspunkt; // Timestamp is sent in user timezone. Store as string for later conversion. "2025-09-04T10:28:29.106545"
        public Datetime getLastModifiedDate() {
            return convertNorwegianTimeToGmt(endretTidspunkt);
        }
    }

    public class Plan {
        public String id;
        public String sistEndret; // Timestamp is sent in user timezone. Store as string for later conversion.
        public Date sistPublisert;
        public List<Tema> temaer;
        public string status;

        public Datetime getLastModifiedDate() {
            return convertNorwegianTimeToGmt(sistEndret);
        }
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

    /**
     * Converts a Norwegian datetime string to GMT.
     */
    private static DateTime convertNorwegianTimeToGmt(String datetimeString) {
        if (datetimeString == null || String.isBlank(datetimeString.trim())) {
            return null;
        }
        String formattedDateTime = datetimeString.replaceAll('T', ' ');
        TimeZone norwegianTz = TimeZone.getTimeZone('Europe/Oslo');
        DateTime tempDateTime = DateTime.valueOfGmt(formattedDateTime);

        Integer offsetMilliseconds = norwegianTz.getOffset(tempDateTime);
        DateTime gmtDateTime = tempDateTime.addSeconds(-offsetMilliseconds / 1000);
        if (gmtDateTime.year() < 1700 || gmtDateTime.year() > 4000) {
            return null;
        }
        return gmtDateTime;
    }
}
