/**
 * @description Model for IA Cooperation.
 */

public with sharing class FiaCooperation implements IKafkaMessageParser {
    // =============================================================================
    // MODEL DATA
    // =============================================================================
    public String orgnr;
    public String saksnummer;
    public Samarbeid samarbeid;
    public Plan plan;
    public String jsonPayload;
    public String hash;
    public String key;

    public DateTime cooperationLastModified { get; set; }
    public DateTime planLastModified { get; set; }

    public class Samarbeid {
        public String id;
        public String navn;
        public String status;
        public Date startDato;
        public Date sluttDato;
        public String endretTidspunkt; // Timestamp is sent in user timezone. Store as string for later conversion. "2025-09-04T10:28:29.106545"

        public Datetime getLastModifiedDate() {
            return SharedIntegrationFunctions.convertNorwegianTimeToGmt(endretTidspunkt);
        }
    }

    public class Plan {
        public String id;
        public String sistEndret; // Timestamp is sent in user timezone. Store as string for later conversion.
        public Date sistPublisert;
        public List<Tema> temaer;
        public string status;

        public Datetime getLastModifiedDate() {
            return SharedIntegrationFunctions.convertNorwegianTimeToGmt(sistEndret);
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

    // =============================================================================
    // FACTORY METHODS - Object creation and parsing
    // =============================================================================
    public static FiaCooperation parse(String json, String key, String hash) {
        String formattedJSON = json.replaceAll('"målsetning":', '"malsetning":');
        FiaCooperation model = (FiaCooperation) System.JSON.deserialize(formattedJSON, FiaCooperation.class);
        model.jsonPayload = json;
        model.hash = hash;
        model.key = key;
        model.planLastModified = SharedIntegrationFunctions.convertNorwegianTimeToGmt(model.plan?.sistEndret);
        model.cooperationLastModified = SharedIntegrationFunctions.convertNorwegianTimeToGmt(
            model.samarbeid?.endretTidspunkt
        );
        return model;
    }
    // =============================================================================
    // DOMAIN LOGIC - Business rules and computed properties
    // =============================================================================

    /**
     * @description Determine which themes are included
     */
    public Boolean includesArbeidsmiljo() {
        return includesTema('Arbeidsmiljø');
    }
    /**
     * @description Determine which themes are included
     */
    public Boolean includesSykefravaersarbeid() {
        return includesTema('Sykefraværsarbeid');
    }
    /**
     * @description Determine which themes are included
     */
    public Boolean includesPartssamarbeid() {
        return includesTema('Partssamarbeid');
    }
    /**
     * @description Calculates age in minutes from provided timestamp.
     */
    public Integer getMessageAge(DateTime currentTime) {
        DateTime timestampFromMessage = this.isPlanUpdate() ? this.planLastModified : this.cooperationLastModified;

        if (currentTime == null || timestampFromMessage == null) {
            return null;
        }
        return SharedIntegrationFunctions.calculateMinutesBetween(timestampFromMessage, currentTime);
    }

    // =============================================================================
    // PRIVATE HELPER METHODS
    // =============================================================================

    /**
     * @description Helper for theme inclusion logic
     */
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
     * @description Classification helper
     */
    private boolean isPlanUpdate() {
        if (plan == null || planLastModified == null) {
            return false;
        } else if (planLastModified != null && cooperationLastModified == null) {
            return true;
        } else if (planLastModified > cooperationLastModified) {
            return true;
        } else if (planLastModified == cooperationLastModified) {
            String planidKey = saksnummer + '-' + samarbeid?.id + '-' + plan?.id;
            return key != null && key == planidKey;
        }
        return false;
    }
    private DateTime getRelevantLastModifiedDate() {
        if (planLastModified == null) {
            return cooperationLastModified;
        }
        if (cooperationLastModified == null) {
            return planLastModified;
        }
        if (cooperationLastModified > planLastModified) {
            return cooperationLastModified;
        }
        return planLastModified;
    }

    /* Sort list of cooperations by last modified dates */
    public class FiaCooperationComparer implements Comparator<FiaCooperation> {
        public Integer compare(FiaCooperation a, FiaCooperation b) {
            DateTime aDate = a.getRelevantLastModifiedDate();
            DateTime bDate = b.getRelevantLastModifiedDate();
            if (aDate == bDate) {
                return 0;
            } else if (aDate == null) {
                return -1;
            } else if (bDate == null) {
                return 1;
            } else if (aDate < bDate) {
                return -1;
            } else {
                return 1;
            }
        }
    }
}
