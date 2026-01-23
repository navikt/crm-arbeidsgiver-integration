/**
 * @description This TAG_CandidateOutcomeHandler class handles the processing of candidate outcomes from kafka topic toi.kandidatutfall
 *
 * @author Andre Colle <andre.colle@nav.no>
 * @since 2026-01-22 Created.
 *
 * @see [License](https://github.com/navikt/crm-arbeidsgiver-integration/blob/main/LICENSE)
 * @see [Github](https://github.com/navikt/crm-arbeidsgiver-integration)
 * @see TAG_CandidateOutcome
 * @see TAG_CandidateOutcomeHandlerTest
 *
 * @group TAG Candidate Outcome Integration
 */

public without sharing class TAG_CandidateOutcomeHandler extends KafkaMessageProcessor implements IKafkaMessageConsumer {
    private Map<String, TAG_CandidateOutcome> keyToCandidateOutcome = new Map<String, TAG_CandidateOutcome>();

    public void processMessages(List<KafkaMessage__c> messages) {
        for (KafkaMessage__c msg : messages) {
            try {
                TAG_CandidateOutcome candidateOutcome = (TAG_CandidateOutcome) parse(
                    TAG_CandidateOutcome.class,
                    msg
                );

                addNavUnit(candidateOutcome?.navKontor);
                msg.CRM_Status__c = KafkaMessageService.STATUS_PROCESSED;
            } catch (Exception e) {
                msg.CRM_Status__c = KafkaMessageService.STATUS_ERROR;
                msg.CRM_ErrorMessage__c = e.getMessage() + ' (' + e.getLineNumber() + ')';
                logger.addError();
            }
        }
        convertAndUpsertCandidateOutcome(messages);

        logger.publish();
    }

    private void mapCandidateOutcome(TAG_CandidateOutcome candidateOutcome) {
        String key = candidateOutcome.key;

        if (!keyToCandidateOutcome.containsKey(key)) {
            keyToCandidateOutcome.put(key, candidateOutcome);
        } else if (isMostRecent(candidateOutcome.tidspunkt, keyToCandidateOutcome.get(key).tidspunkt)) {
            keyToCandidateOutcome.put(key, candidateOutcome);
        }
    }

    private void convertAndUpsertCandidateOutcome(List<KafkaMessage__c> messages) {
        List<CandidateOutcome__c> candidateOutcomeUpsert = new List<CandidateOutcome__c>();
        try {
            candidateOutcomeUpsert = toSObjects();

            Schema.SObjectField f = CandidateOutcome__c.Fields.KafkaId__c;
            Database.UpsertResult[] cr = Database.upsert(candidateOutcomeUpsert, f, false);
        } catch (Exception e) {
            String errorRef = logger.logError(e.getMessage() + '/n' + e.getStackTraceString());
            logger.setMessageErrors(messages, errorRef);
        }
    }

    private List<CandidateOutcome__c> toSObjects() {
        Map<String, String> lastSaved = getLastSaved(CandidateOutcome__c.class, keyToCandidateOutcome.keyset());
        Map<String, NavUnit__c> navUnitMap = getNavUnitsMap();
        List<CandidateOutcome__c> candidateOutcomeList = new List<CandidateOutcome__c>();

        for (TAG_CandidateOutcome model : keyToCandidateOutcome.values()) {
            if (!isNewOrChanged(model.key, model.hash, lastSaved)) {
                continue;
            }

            CandidateOutcome__c co = new CandidateOutcome__c(
                CandidateId__c = model.aktorId,
                Result__c = model.utfall,
                NavIdent__c = model.navIdent,
                CandidateListId__c = model?.kandidatlisteId,
                JobPostingId__c = model?.stillingsId,
                TimeRegistered__c = dateTimeValue(model.tidspunkt),
                Category__c = model?.stillingskategori,
                Type__c = 'Etterregistrering',
                KafkaId__c = model.key,
                KafkaHash__c = model.hash
            );

            if (navUnitMap.containsKey(model.navKontor)) {
                co.NavUnit__c = navUnitMap.get(model.navKontor).Id;
            }

            candidateOutcomeList.add(co);
        }
        return candidateOutcomeList;
    }
}
