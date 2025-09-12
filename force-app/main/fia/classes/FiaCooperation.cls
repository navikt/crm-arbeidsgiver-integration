/**
 * @description Model for IA Cooperation.
 */

public with sharing class FiaCooperation implements IKafkaMessageParser {
    // =============================================================================
    // MODEL DATA - Core domain entities and infrastructure data
    // =============================================================================
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
        return calculateMessageAgeInMinutes(currentTime);
    }

    // =============================================================================
    // PRIVATE HELPER METHODS - Implementation details
    // =============================================================================

    /**
     * @description Domain helper for theme inclusion logic
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
     * @description Message age calculation logic
     */
    private Integer calculateMessageAgeInMinutes(DateTime currentTime) {
        // Validate input parameter
        if (currentTime == null) {
            return null;
        }

        Datetime sourceTime;
        // If message is an update for plan, then a plan id will be included in the message key.
        if (this.isPlanUpdate()) {
            // Source system timestamp is in the plan.sistEndret field.
            if (plan == null || String.isBlank(plan.sistEndret)) {
                return null;
            }
            sourceTime = plan.getLastModifiedDate();
        } else {
            // Source system timestamp is in the samarbeid.endretTidspunkt field.
            if (samarbeid == null || String.isBlank(samarbeid.endretTidspunkt)) {
                return null;
            }
            sourceTime = samarbeid.getLastModifiedDate();
        }

        // Check if date conversion was successful
        if (sourceTime == null) {
            return null;
        }

        Long sourceTimeAsLong;
        Long currentTimeAsLong;

        try {
            sourceTimeAsLong = sourceTime.getTime();
            currentTimeAsLong = currentTime.getTime();
        } catch (System.NullPointerException e) {
            // Log specific null pointer issues for debugging
            System.debug(LoggingLevel.WARN, 'Null value encountered in time calculation: ' + e.getMessage());
            return null;
        } catch (System.TypeException e) {
            // Handle invalid datetime format or conversion errors
            System.debug(LoggingLevel.WARN, 'Invalid datetime format in age calculation: ' + e.getMessage());
            return null;
        }

        Long ageInMilliseconds = currentTimeAsLong - sourceTimeAsLong;
        if (ageInMilliseconds < 0) {
            // Future timestamps indicate data quality issues
            System.debug(
                LoggingLevel.WARN,
                'Message timestamp is in the future. sourceTime: ' + sourceTime + ', currentTime: ' + currentTime
            );
            return null;
        }

        try {
            Long ageInMinutes = ageInMilliseconds / 60000;
            return ageInMinutes.intValue();
        } catch (System.MathException e) {
            System.debug(LoggingLevel.WARN, 'Math calculation error in age calculation: ' + e.getMessage());
            return null;
        }
    }

    /**
     * @description Entity classification helpers
     */
    private boolean isPlanUpdate() {
        if (plan == null) {
            return false;
        }
        String planidKey = saksnummer + '-' + samarbeid?.id + '-' + plan?.id;
        return key != null && key == planidKey;
    }
    private boolean isSamarbeidUpdate() {
        String samarbeidKey = saksnummer + '-' + samarbeid?.id;
        return key != null && key == samarbeidKey;
    }
}
