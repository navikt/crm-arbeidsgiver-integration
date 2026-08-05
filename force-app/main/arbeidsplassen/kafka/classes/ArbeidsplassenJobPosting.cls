/**
 * @description This class represents a job posting from Arbeidsplassen.
 * The structure of the class is based on the Avro schema defined in the StillingEkstern.avdl file, which can be found in the following GitHub repository:
 * https://github.com/navikt/pam-ad-broapplikasjoner/blob/main/pam-stilling-stilling-ekstern/src/main/avro/StillingEkstern.avdl
 */
@SuppressWarnings('PMD.ExcessivePublicCount,PMD.ApexDoc,PMD.PropertyNamingConventions')
public with sharing class ArbeidsplassenJobPosting implements IKafkaMessageParser {
    private static final String JANZZ_CATEGORY_TYPE = 'JANZZ';
    public List<Classification> classifications { get; set; }
    public List<Property> properties { get; set; }
    public List<Location> locations { get; set; }
    public List<Contact> contacts { get; set; }
    public List<StyrkCategory> categories { get; set; }
    public Company employer { get; set; }
    public Admin administration { get; set; }

    public String businessName { get; set; }
    public String published { get; set; }
    public String reference { get; set; }
    public String expires { get; set; }
    public String created { get; set; }
    public String updated { get; set; }
    public String status { get; set; }
    public String medium { get; set; }
    public String source { get; set; }
    public String title { get; set; }
    public String uuid { get; set; }

    public Map<String, String> propertyMap { get; set; }
    public String jsonPayload { get; set; }
    public String hash { get; set; }
    public String key { get; set; }

    /**
     * Classifications inneholder kodeverk for yrker. Beskrivelse av variablene fra StillingEkstern.avdl:
     *  categoryType: STYRK08, STYRK08NAV, ESCO eller JANZZ
     *  code: F.eks styrkkode eller esco kode. For janzz er det konseptid, i esco så er det en url
     *  name: F.eks butikkmedarbeider
     *  score: Score er mellom 0.0 og 1.0. En score på 1.0 antyder manuell bruk. F.eks av NKS eller SBL
     *  janzzParentId: Janzz konseptid som er knyttet til klassifiseringen. For categoryType=JANZZ så bør dette vare det samme som code
     */
    public class Classification {
        public String categoryType { get; set; }
        public String code { get; set; }
        public String name { get; set; }
        public Double score { get; set; }
        public String janzzParentId { get; set; }
    }

    public class Location {
        public String municipal_code { get; set; }
        public String county_code { get; set; }
        public String postalCode { get; set; }
        public String municipal { get; set; }
        public String longitude { get; set; }
        public String latitude { get; set; }
        public String country { get; set; }
        public String address { get; set; }
        public String county { get; set; }
        public String city { get; set; }
    }

    public class Property {
        public String value { get; set; }
        public String key { get; set; }
    }

    public class StyrkCategory {
        public String styrkCode { get; set; }
        public String name { get; set; }
    }

    public class Contact {
        public String email { get; set; }
        public String phone { get; set; }
        public String title { get; set; }
        public String role { get; set; }
        public String name { get; set; }
    }

    public class Company {
        public String parentOrgnr { get; set; }
        public String publicName { get; set; }
        public String orgform { get; set; }
        public String orgnr { get; set; }
        public String name { get; set; }
    }

    public class Admin {
        public String status { get; set; }
        //public String remarks { get; set; } Ignore for now as it is not used. Can be re-added later if needed.
        public String comments { get; set; }
        public String reportee { get; set; }
        public String navIdent { get; set; }
    }

    /**
     * @description Returns the name of the classification with categoryType JANZZ.
     * @return Name of the classification with categoryType JANZZ, or null if not found.
     */
    public String getJanzzName() {
        if (classifications == null) {
            return null;
        }
        for (Classification c : classifications) {
            if (c.categoryType == JANZZ_CATEGORY_TYPE) {
                return c.name;
            }
        }
        return null;
    }
    /**
     * @description Returns JANZZ code if present in classifications.
     * @return Code of the classification with categoryType JANZZ, or null if not found.
     */
    public String getJanzzCode() {
        if (classifications == null) {
            return null;
        }
        for (Classification c : classifications) {
            if (c.categoryType == JANZZ_CATEGORY_TYPE) {
                return c.code;
            }
        }
        return null;
    }

    public String getProperty(String propertyName) {
        if (properties == null) {
            return null;
        }

        if (propertyMap == null) {
            propertyMap = new Map<String, String>();

            for (Property prop : properties) {
                propertyMap.put(prop.key, prop.value);
            }
        }

        return propertyMap.containsKey(propertyName) ? propertyMap.get(propertyName) : null;
    }

    public String getCategoryCodes() {
        String codes = '';

        if (categories == null) {
            return codes;
        }

        for (StyrkCategory c : categories) {
            if (c.styrkCode != null) {
                codes += c.styrkCode + ', ';
            }
        }
        return codes.trim().removeEnd(',');
    }

    public String getCategoryNames() {
        String names = '';

        if (categories == null) {
            return names;
        }

        for (StyrkCategory c : categories) {
            if (c.name != null) {
                names += c.name + ', ';
            }
        }
        return names.trim().removeEnd(',');
    }

    public String getCities() {
        String cities = '';

        if (locations == null) {
            return cities;
        }

        for (Location l : locations) {
            if (l.city != null) {
                cities += l.city + ', ';
            }
        }
        return cities.trim().removeEnd(',');
    }

    public static ArbeidsplassenJobPosting parse(String json, String key, String hash) {
        ArbeidsplassenJobPosting model = (ArbeidsplassenJobPosting) System.JSON.deserialize(
            json,
            ArbeidsplassenJobPosting.class
        );
        model.jsonPayload = json;
        model.hash = hash;
        model.key = key;

        return model;
    }

    public Integer getMessageAge(DateTime currentTime) {
        DateTime timestampFromMessage = SharedIntegrationFunctions.convertNorwegianTimeToGmt(this.updated);

        if (currentTime == null || timestampFromMessage == null) {
            return null;
        }
        return SharedIntegrationFunctions.calculateMinutesBetween(timestampFromMessage, currentTime);
    }
}
