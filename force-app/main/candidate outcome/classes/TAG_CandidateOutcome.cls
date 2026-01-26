/**
 * @description This TAG_CandidateOutcome class sets the model for json strings read from kafka topic toi.kandidatutfall
 *
 * @author Andre Colle <andre.colle@nav.no>
 * @since 2026-01-22 Created.
 *
 * @see [License](https://github.com/navikt/crm-arbeidsgiver-integration/blob/main/LICENSE)
 * @see [Github](https://github.com/navikt/crm-arbeidsgiver-integration)
 * @see TAG_CandidateOutcomeHandler
 * @see TAG_CandidateOutcomeTest
 *
 * @group TAG Candidate Outcome Integration
 */

public with sharing class TAG_CandidateOutcome implements IKafkaMessageParser {
    public String aktorId;
    public String utfall;
    public String navIdent;
    public String navKontor;
    public String kandidatlisteId;
    public String stillingsId;
    public String tidspunkt;
    public String stillingskategori;

    public String jsonPayload;
    public String hash;
    public String key;

    public static TAG_CandidateOutcome parse(String json, String key, String hash) {
        String formattedJSON = json.replaceAll('"aktørId":', '"aktorId":');
        TAG_CandidateOutcome model = (TAG_CandidateOutcome) System.JSON.deserialize(formattedJSON, TAG_CandidateOutcome.class);
        model.jsonPayload = json;
        model.hash = hash;
        model.key = key;

        return model;
    }
}
