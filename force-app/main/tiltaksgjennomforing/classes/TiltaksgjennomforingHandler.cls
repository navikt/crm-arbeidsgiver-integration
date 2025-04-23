/**
 * @description This TiltaksgjennomforingHandler class processes kafka messages that are read from the topic arbeidsgiver.tiltak-avtale-hendelse
 * and creates new records in the Workfare__c object
 *
 * @author Andre Colle <andre.colle@nav.no>
 * @since 2025-04-10 Created.
 *
 * @see [License](https://github.com/navikt/crm-arbeidsgiver-integration/blob/main/LICENSE)
 * @see [Github](https://github.com/navikt/crm-arbeidsgiver-integration)
 * @see TiltaksgjennomforingModel
 * @see TiltaksgjennomforingHandlerTest
 *
 * @group TAG Tiltaksgjennomforing Integration
 */

public without sharing class TiltaksgjennomforingHandler extends KafkaMessageProcessor implements IKafkaMessageConsumer {
    private Map<String, TiltaksgjennomforingModel> keyToAgreement = new Map<String, TiltaksgjennomforingModel>();

    public void processMessages(List<KafkaMessage__c> messages) {
        for (KafkaMessage__c msg : messages) {
            try {
                TiltaksgjennomforingModel agreement = (TiltaksgjennomforingModel) parse(
                    TiltaksgjennomforingModel.class,
                    msg
                );
                mapAgreement(agreement);
                addOrgNumber(agreement?.bedriftNr);
                addNavIdent(agreement?.veilederNavIdent);
                addNavUnit(agreement?.enhetOppfolging);
                msg.CRM_Status__c = KafkaMessageService.STATUS_PROCESSED;
            } catch (Exception e) {
                msg.CRM_Status__c = KafkaMessageService.STATUS_ERROR;
                msg.CRM_ErrorMessage__c = e.getMessage() + ' (' + e.getLineNumber() + ')';
                logger.addError();
            }
        }
        convertAndUpsertAgreement(messages);
        logger.publish();
    }

    private void mapAgreement(TiltaksgjennomforingModel agreement) {
        String key = agreement.key;

        if (!keyToAgreement.containsKey(key)) {
            keyToAgreement.put(key, agreement);
        } else if (isMostRecent(agreement.sistEndret, keyToAgreement.get(key).sistEndret)) {
            keyToAgreement.put(key, agreement);
        }
    }

    private void convertAndUpsertAgreement(List<KafkaMessage__c> messages) {
        List<Workfare__c> workfareAgreements = new List<Workfare__c>();
        try {
            workfareAgreements = toSObjects();

            Schema.SObjectField f = Workfare__c.Fields.KafkaId__c;
            Database.UpsertResult[] cr = Database.upsert(workfareAgreements, f, false);
        } catch (Exception e) {
            String errorRef = logger.logError(e.getMessage() + '/n' + e.getStackTraceString());
            logger.setMessageErrors(messages, errorRef);
        }
    }

    private List<Workfare__c> toSObjects() {
        Map<String, String> lastSaved = getLastSaved(Workfare__c.class, keyToAgreement.keyset());
        Map<String, Account> accountMap = getOrgNumberAccountMap();
        Map<String, User> navIdentMapAllProfile = getNavIdentMap();
        Map<String, User> navIdentMap = getNavIdentMapWithProfile();
        Map<String, NavUnit__c> navUnitMap = getNavUnitsMap();
        List<Workfare__c> agreementsList = new List<Workfare__c>();

        for (TiltaksgjennomforingModel model : keyToAgreement.values()) {
            if (!isNewOrChanged(model.key, model.hash, lastSaved)) {
                continue;
            }

            Workfare__c w = new Workfare__c(
                Status__c = model.avtaleStatus,
                Type__c = model.tiltakstype,
                NavIdent__c = model?.veilederNavIdent,
                EmployerContactPhone__c = model?.arbeidsgiverTlf,
                ActionType__c = model?.hendelseType,
                ContentType__c = model?.innholdType,
                AgreementId__c = model.avtaleId,
                KafkaId__c = model.key
            );

            if (model.avtaleNr != null) {
                w.Name = model.avtaleNr;
            } else {
                w.Name = 'Avtalenummer ikke opprettet enda';
            }

            if (model.startDato != null && Date.valueof(model.startDato).year() > 1700) {
                w.StartDate__c = Date.valueof(model.startDato);
            }

            if (model.sluttDato != null && Date.valueof(model.sluttDato).year() < 4000) {
                w.EndDate__c = Date.valueof(model.sluttDato);
            }

            if (model.arbeidsgiverFornavn != null & model.arbeidsgiverEtternavn != null) {
                w.EmployerContactName__c =
                    model.arbeidsgiverFornavn.left(31) +
                    ' ' +
                    model.arbeidsgiverEtternavn.left(32);
            }

            if (model.mentorFornavn != null & model.mentorEtternavn != null) {
                w.MentorName__c = model.mentorFornavn.left(31) + ' ' + model.mentorEtternavn.left(32);
            }

            if (model.bedriftNr != null) {
                w.Link__c =
                    'https://arbeidsgiver.nav.no/tiltaksgjennomforing/avtale/' +
                    model.avtaleId +
                    '?bedrift=' +
                    model.bedriftnr;
            } else {
                w.Link__c = 'https://arbeidsgiver.nav.no/tiltaksgjennomforing/avtale/' + model.avtaleId;
            }

            if (navIdentMapAllProfile.containsKey(model.veilederNavIdent)) {
                User us = navIdentMapAllProfile.get(model.veilederNavIdent);
                w.InternalContact__c = us.id;
            }

            if (navIdentMap.containsKey(model.veilederNavIdent)) {
                User us = navIdentMap.get(model.veilederNavIdent);
                w.OwnerId = us.id;
            }

            if (accountMap.containsKey(model.bedriftnr)) {
                w.Account__c = accountMap.get(model.bedriftnr).Id;
            }

            if (navUnitMap.containsKey(model.enhetOppfolging)) {
                w.NavUnit__c = navUnitMap.get(model.enhetOppfolging).Id;
            }

            agreementsList.add(w);
        }
        return agreementsList;
    }

    public Map<String, User> getNavIdentMapWithProfile() {
        Map<String, User> navIdentMap = new Map<String, User>();
        List<User> users = [
            SELECT Id, firstName, lastName, CRM_NAV_Ident__c, ProfileId
            FROM User
            WHERE IsActive = TRUE AND Profile.Name = 'NAV Kontor' AND CRM_NAV_Ident__c IN :navIdents
        ];

        for (User u : users) {
            navIdentMap.put(u.CRM_NAV_Ident__c, u);
        }
        return navIdentMap;
    }
}
