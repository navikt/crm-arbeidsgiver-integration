public without sharing class KafkaToiAvtaleHandler extends KafkaMessageProcessor implements IKafkaMessageConsumer {
    private Map<String, KafkaToiAvtaleHandler_Model> keyToAvtale = new Map<String, KafkaToiAvtaleHandler_Model>();
    public Id avtaleRecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Measure Agreement'].id;

    public void processMessages(List<KafkaMessage__c> messages) {
        for (KafkaMessage__c msg : messages) {
            try {
                KafkaToiAvtaleHandler_Model avtale = (KafkaToiAvtaleHandler_Model) parse(
                    KafkaToiAvtaleHandler_Model.class,
                    msg
                );
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

            Schema.SObjectField f = Contract__c.Fields.KafkaId__c;
            Database.UpsertResult[] cr = Database.upsert(avtaler, f, false);
        } catch (Exception e) {
            String errorRef = logger.logError(e.getMessage() + '/n' + e.getStackTraceString());
            logger.setMessageErrors(messages, errorRef);
        }
    }

    private void convertAndUpsertActivity(List<KafkaMessage__c> messages) {
        List<ArenaActivity__c> activities = new List<ArenaActivity__c>();
        try {
            activities = toSObjectsActivity();

            Schema.SObjectField f = ArenaActivity__c.Fields.KafkaId__c;
            Database.UpsertResult[] upsertResults = Database.upsert(activities, f, false);
            Map<String, KafkaMessage__c> messageMap = new Map<String, KafkaMessage__c>();

            for (KafkaMessage__c message : messages) {
                messageMap.put(message.CRM_Key__c, message);
            }

            for (Integer i = 0; i < upsertResults.size(); i++) {
                if (!upsertResults[i].isSuccess()) {
                    Database.Error error = upsertResults[i].getErrors()[0];
                    String errorMessage = error.getMessage();
                    String errorRef = logger.logError(errorMessage);
                    KafkaMessage__c failedMessage = messageMap.get(activities[i].KafkaId__c);
                    logger.setMessageErrors(new List<KafkaMessage__c>{ failedMessage }, errorRef);
                }
            }
        } catch (Exception e) {
            String errorRef = logger.logError(e.getMessage() + '/n' + e.getStackTraceString());
            logger.setMessageErrors(messages, errorRef);
        }
    }

    private List<Contract__c> toSObjects() {
        Map<String, Account> accountMap = getOrgNumberAccountMap();
        Map<String, User> navIdentMapAllProfile = getNavIdentMap();
        Map<String, User> navIdentMap = getNavIdentMapWithProfile();
        Map<String, NavUnit__c> navUnitMap = getNavUnitsMap();
        Map<String, NavUnit__c> navUnitMapWithQueues = getNavUnitsMapWithQueues();
        List<Contract__c> contracts = new List<Contract__c>();

        for (KafkaToiAvtaleHandler_Model model : keyToAvtale.values()) {
            Contract__c c = new Contract__c(
                RecordTypeId = avtaleRecordTypeId,
                ExternalId__c = model.avtaleNr,
                TAG_Status__c = model.avtaleStatus,
                KafkaId__c = model.key,
                TAG_Category__c = model.tiltakstype,
                NavIdent__c = model?.veilederNavIdent,
                TAG_EmployerContactPhone__c = model?.arbeidsgiverTlf,
                TAG_ActionType__c = model?.hendelseType,
                TAG_ContentType__c = model?.innholdType,
                TAG_ContractId__c = model.avtaleId
            );

            if (model.startDato != null && Date.valueof(model.startDato).year() > 1700) {
                c.TAG_StartDate__c = Date.valueof(model.startDato);
            }

            if (model.sluttDato != null && Date.valueof(model.sluttDato).year() < 4000) {
                c.TAG_EndDate__c = Date.valueof(model.sluttDato);
            }

            if (model.deltakerFornavn != null & model.deltakerEtternavn != null) {
                c.TAG_MeasureParticipant__c = model.deltakerFornavn.left(31) + ' ' + model.deltakerEtternavn.left(32);
            }

            if (model.arbeidsgiverFornavn != null & model.arbeidsgiverEtternavn != null) {
                c.TAG_EmployerContact__c =
                    model.arbeidsgiverFornavn.left(31) +
                    ' ' +
                    model.arbeidsgiverEtternavn.left(32);
            }

            if (model.mentorFornavn != null & model.mentorEtternavn != null) {
                c.TAG_Mentor__c = model.mentorFornavn.left(31) + ' ' + model.mentorEtternavn.left(32);
            }

            if (model.bedriftNr != null) {
                c.TAG_ExternalURL__c =
                    'https://arbeidsgiver.nav.no/tiltaksgjennomforing/avtale/' +
                    model.avtaleId +
                    '?bedrift=' +
                    model.bedriftnr;
            } else {
                c.TAG_ExternalURL__c = 'https://arbeidsgiver.nav.no/tiltaksgjennomforing/avtale/' + model.avtaleId;
            }

            if (navIdentMapAllProfile.containsKey(model.veilederNavIdent)) {
                User us = navIdentMapAllProfile.get(model.veilederNavIdent);
                c.TAG_InternalContact__c = us.id;
            }

            if (navIdentMap.containsKey(model.veilederNavIdent)) {
                User us = navIdentMap.get(model.veilederNavIdent);
                c.OwnerId = us.id;
            } else if (
                !navIdentMap.containsKey(model.veilederNavIdent) &&
                navUnitMapWithQueues.containsKey(model.enhetOppfolging)
            ) {
                c.OwnerId = navUnitMapWithQueues.get(model.enhetOppfolging).CRM_QueueId__c;
            } else if (
                !navIdentMap.containsKey(model.veilederNavIdent) &&
                !navUnitMapWithQueues.containsKey(model.enhetOppfolging)
            ) {
                c.OwnerId = getSystemAsynkronUser();
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
        Map<String, Account> accountMap = getOrgNumberAccountMap();
        Map<String, User> navIdentMapAllProfile = getNavIdentMap();
        Map<String, NavUnit__c> navUnitMap = getNavUnitsMap();
        List<ArenaActivity__c> activities = new List<ArenaActivity__c>();

        for (KafkaToiAvtaleHandler_Model model : keyToAvtale.values()) {
            ArenaActivity__c aa = new ArenaActivity__c(
                Aktivitetsgruppekode__c = 'TLTAK',
                AktivitetStatuskode__c = model?.avtaleStatus,
                AktivitetsKode__c = ' ',
                Aktivitetstype__c = model?.tiltakstype,
                KafkaId__c = model.key,
                NAVIdent__c = model?.veilederNavIdent,
                TAG_Source__c = 'Tiltaksløsning'
            );

            if (model.opprettetTidspunkt != null) {
                aa.DateRegistered__c = dateTimeValue(model.opprettetTidspunkt).date();
                aa.DateTimeRegistered__c = dateTimeValue(model.opprettetTidspunkt);
            }

            if (model.startDato != null && Date.valueof(model.startDato).year() > 1700) {
                aa.DateFrom__c = Date.valueof(model.startDato);
            }

            if (model.sluttDato != null && Date.valueof(model.sluttDato).year() < 4000) {
                aa.DateTo__c = Date.valueof(model.sluttDato);
            }

            if (accountMap.containsKey(model.bedriftnr)) {
                aa.Account__c = accountMap.get(model.bedriftnr).Id;
            }

            if (navUnitMap.containsKey(model.enhetOppfolging)) {
                aa.NAV_Kontor__c = navUnitMap.get(model.enhetOppfolging).Id;
            }

            if (navIdentMapAllProfile.containsKey(model.veilederNavIdent)) {
                User us = navIdentMapAllProfile.get(model.veilederNavIdent);
                aa.CaseWorker__c = us.id;
            }
            activities.add(aa);
        }
        return activities;
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

    public Map<String, NAVUnit__c> getNavUnitsMapWithQueues() {
        Map<String, NAVUnit__c> navUnitMap = new Map<String, NAVUnit__c>();
        List<NAVUnit__c> units = [
            SELECT Id, Name, CRM_QueueId__c, INT_UnitNumber__c
            FROM NAVUnit__c
            WHERE INT_UnitNumber__c IN :navUnits AND IsDeleted = FALSE AND CRM_QueueId__c != NULL
        ];

        for (NAVUnit__c n : units) {
            navUnitMap.put(n.INT_UnitNumber__c, n);
        }
        return navUnitMap;
    }

    public Id getSystemAsynkronUser() {
        return [SELECT Id FROM User WHERE Name = 'Systembruker Asynkron Prosessering' LIMIT 1].id;
    }
}
