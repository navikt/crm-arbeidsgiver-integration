public without sharing class KafkaToiAvtaleHandler extends KafkaMessageProcessor implements IKafkaMessageConsumer {
    private Map<String, KafkaToiAvtaleHandler_Model> keyToAvtale = new Map<String, KafkaToiAvtaleHandler_Model>();
    public Id avtaleRecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Measure Agreement'].id;

    public void processMessages(List<KafkaMessage__c> messages) {
        for (KafkaMessage__c msg : messages) {
            try {
                KafkaToiAvtaleHandler_Model avtale = (KafkaToiAvtaleHandler_Model) parse(KafkaToiAvtaleHandler_Model.class, msg);
                mapAvtale(avtale);
                addOrgNumber(avtale?.bedriftNr);
                addNavIdent(avtale?.veilederNavIdent);
                addNavUnit(avtale?.enhetOppfolging);
                msg.CRM_Status__c = KafkaMessageService.STATUS_PROCESSED;
            } catch (Exception e) {
                msg.CRM_Status__c = KafkaMessageService.STATUS_ERROR;
                msg.CRM_ErrorMessage__c = e.getMessage() + ' (' + e.getLineNumber() + ')';
                logger.addError();
            }
        }
        convertAndUpsertAvtale(messages);
        convertAndUpsertActivity(messages);
        logger.publish();
    }

    private void mapAvtale(KafkaToiAvtaleHandler_Model avtale) {
        String key = avtale.key;

        if (!keyToAvtale.containsKey(key)) {
            keyToAvtale.put(key, avtale);
        } else if (isMostRecent(avtale.sistEndret, keyToAvtale.get(key).sistEndret)) {
            keyToAvtale.put(key, avtale);
        }
    }

    private void convertAndUpsertAvtale(List<KafkaMessage__c> messages) {
        List<Contract__c> avtaler = new List<Contract__c>();
        try {
            avtaler = toSObjects();
            upsert avtaler;
        } catch (Exception e) {
            String errorRef = logger.logError(e.getMessage() + '/n' + e.getStackTraceString());
            logger.setMessageErrors(messages, errorRef);
        }
    }

    private void convertAndUpsertActivity(List<KafkaMessage__c> messages) {
        List<ArenaActivity__c> activities = new List<ArenaActivity__c>();
        try {
            activities = toSObjectsActivity();
            upsert activities;
        } catch (Exception e) {
            String errorRef = logger.logError(e.getMessage() + '/n' + e.getStackTraceString());
            logger.setMessageErrors(messages, errorRef);
        }
    }

    private List<Contract__c> toSObjects() {
        Map<String, String> lastSaved = getLastSaved(Contract__c.class, keyToAvtale.keyset());
        Map<String, Account> accountMap = getOrgNumberAccountMap();
        Map<String, User> navIdentMap = getNavIdentMap();
        Map<String, NavUnit__c> navUnitMap = getNavUnitsMap();
        List<Contract__c> contracts = new List<Contract__c>();

        for (KafkaToiAvtaleHandler_Model model : keyToAvtale.values()) {
            if (!isNewOrChanged(model.key, model.hash, lastSaved)) {
                continue;
            }
 
            Contract__c c = new Contract__c(
                RecordTypeId = avtaleRecordTypeId,
                ExternalId__c = model.avtaleNr,
                TAG_Status__c = model.avtaleStatus,
                TAG_ExternalURL__c = 'https://arbeidsgiver.labs.nais.io/tiltaksgjennomforing/avtale/' + model.avtaleId + '?bedrift=' + model.bedriftnr,
                KafkaHash__c = model.hash,
                KafkaId__c = model.key,
                TAG_Category__c = model.tiltakstype,
                NavIdent__c = model?.veilederNavIdent,
                TAG_EmployerContactPhone__c = model?.arbeidsgiverTlf
            );

            if (model.startDato != null) {
                c.TAG_StartDate__c = Date.valueof(model.startDato);
            }

            if (model.sluttDato != null) {
                c.TAG_EndDate__c = Date.valueof(model.sluttDato);
            }

            if (model.deltakerFornavn != null & model.deltakerEtternavn != null) {
                c.TAG_MeasureParticipant__c = model.deltakerFornavn + ' ' + model.deltakerEtternavn;
            }

            if (model.arbeidsgiverFornavn != null & model.arbeidsgiverEtternavn != null) {
                c.TAG_EmployerContact__c = model.arbeidsgiverFornavn + ' ' + model.arbeidsgiverEtternavn;
            }

            if (model.mentorFornavn != null & model.mentorEtternavn != null) {
                c.TAG_Mentor__c = model.mentorFornavn + ' ' + model.mentorEtternavn;
            }

            if (navIdentMap.containsKey(model.veilederNavIdent)) {
                User us = navIdentMap.get(model.veilederNavIdent);
                c.TAG_InternalContact__c = us.id;
                c.OwnerId = us.id;
            }   else if (!navIdentMap.containsKey(model.veilederNavIdent) && navUnitMap.containsKey(model.enhetOppfolging)) {
                c.OwnerId = navUnitMap.get(model.enhetOppfolging).CRM_QueueId__c;
            }

            if (accountMap.containsKey(model.bedriftnr)) {
                c.TAG_Account__c = accountMap.get(model.bedriftnr).Id;
            }

             if (navUnitMap.containsKey(model.enhetOppfolging)) {
                 c.TAG_NAVUnit__c = navUnitMap.get(model.enhetOppfolging).Id;
             }

            contracts.add(c);
        }
        return contracts;
    }

    private List<ArenaActivity__c> toSObjectsActivity() {
        Map<String, String> lastSaved = getLastSaved(ArenaActivity__c.class, keyToAvtale.keyset());
        Map<String, Account> accountMap = getOrgNumberAccountMap();
        Map<String, User> navIdentMap = getNavIdentMap();
        Map<String, NavUnit__c> navUnitMap = getNavUnitsMap();
        List<ArenaActivity__c> activities = new List<ArenaActivity__c>();

        for (KafkaToiAvtaleHandler_Model model : keyToAvtale.values()) {
            if (!isNewOrChanged(model.key, model.hash, lastSaved)) {
                continue;
            }

            ArenaActivity__c aa = new ArenaActivity__c(
                    DateRegistered__c = dateTimeValue(model.opprettetTidspunkt).date(),
                    DateFrom__c = Date.valueof(model.startDato),
                    DateTo__c = Date.valueof(model.sluttDato),
                    DateTimeRegistered__c = dateTimeValue(model.opprettetTidspunkt),
                    Aktivitetsgruppekode__c = 'TLTAK',
                    AktivitetStatuskode__c = model.avtaleStatus,
                    AktivitetsKode__c = ' ',
                    Aktivitetstype__c = model.tiltakstype,
                    KafkaId__c = model.key,
                    KafkaHash__c = model.hash,
                    NAVIdent__c = model?.veilederNavIdent,
                    TAG_Source__c = 'Tiltaksløsning'
            );


            if (accountMap.containsKey(model.bedriftnr)) {
                aa.Account__c = accountMap.get(model.bedriftnr).Id;
            }

             if (navUnitMap.containsKey(model.enhetOppfolging)) {
                 aa.NAV_Kontor__c = navUnitMap.get(model.enhetOppfolging).Id;
             }

            if (navIdentMap.containsKey(model.veilederNavIdent)) {
                User us = navIdentMap.get(model.veilederNavIdent);
                aa.CaseWorker__c = us.id;
                aa.OwnerId = us.id;
            }
            activities.add(aa);
        }
        return activities;
    }
}
