public without sharing class KafkaToiAvtaleHandler extends KafkaMessageProcessor implements IKafkaMessageConsumer {
    private Map<String, KafkaToiAvtaleHandler_Model> keyToAvtale = new Map<String, KafkaToiAvtaleHandler_Model>();
    private Set<String> navIdents;
    private Set<String> navUnits;

    public Id avtaleRecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Measure Agreement'].id;
    //Schema.SObjectType.Contract__c.getRecordTypeInfosByName().get('MeasureAgreement').getRecordTypeId();

    public KafkaToiAvtaleHandler() {
        navIdents = new Set<String>();
        navUnits = new Set<String>();
    }

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
            upsert avtaler Contract__c.KafkaId__c;
        } catch (Exception e) {
            String errorRef = logger.logError(e.getMessage() + '/n' + e.getStackTraceString());
            logger.setMessageErrors(messages, errorRef);
        }
    }

    private List<Contract__c> toSObjects() {
        Map<String, String> lastSaved = getLastSaved(Contract__c.class, keyToAvtale.keyset());
        Map<String, Account> accountMap = getOrgNumberAccountMap();
        Map<String, String> navIdentMap = getNavIdentMap();
        Map<String, NavUnit__c> navUnitMap = getNavUnitsMap();
        List<Contract__c> contracts = new List<Contract__c>();

        for (KafkaToiAvtaleHandler_Model model : keyToAvtale.values()) {
            if (!isNewOrChanged(model.key, model.hash, lastSaved)) {
                continue;
            }
 
            Contract__c c = new Contract__c(
                RecordTypeId = avtaleRecordTypeId,
                TAG_StartDate__c = dateTimeValue(model.startDato).date(),
                TAG_EndDate__c = dateTimeValue(model.sluttDato).date(),
                ExternalId__c = model.avtaleNr,
                TAG_Status__c = model.avtaleStatus,
                TAG_MeasureParticipant__c = model.deltakerFornavn + ' ' + model.deltakerEtternavn,
                TAG_EmployerContact__c = model.arbeidsgiverFornavn + ' ' + model.arbeidsgiverEtternavn,
                TAG_Mentor__c = model.mentorFornavn + ' ' + model.mentorEtternavn,
                TAG_ExternalURL__c = 'https://arbeidsgiver.labs.nais.io/tiltaksgjennomforing/avtale/' + model.id + '?bedrift=' + model.bedriftnr,
                KafkaHash__c = model.hash,
                KafkaId__c = model.key
            );

            if (model.tiltakstype == 'MIDLERTIDIG_LONNSTILSKUDD') {
                c.TAG_Category__c = 'Midlertidig lønnstilskudd';
            }

            if (navIdentMap.containsKey(model.veilederNavIdent)) {
                c.TAG_InternalContact__c = navIdentMap.get(model.veilederNavIdent);
                c.OwnerId = navIdentMap.get(model.veilederNavIdent);
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

    private void addNavIdent(String navIdent) {
        if (navIdent != null) {
            navIdents.add(navIdent);
        }
    }

    public void addNavUnit(String navUnit) {
        if (navUnit != null) {
            navUnits.add(navUnit);
        }
    }

    private Map<String, String> getNavIdentMap() {
        Map<String, String> navIdentMap = new Map<String, String>();
        List<User> users = [
            SELECT Id, firstName, lastName, CRM_NAV_Ident__c
            FROM User
            WHERE CRM_NAV_Ident__c IN :navIdents
        ];

        for (User u : users) {
            navIdentMap.put(u.CRM_NAV_Ident__c, u.Id);
        }

        return navIdentMap;
    }

    private Map<String, NAVUnit__c> getNavUnitsMap() {
        Map<String, NAVUnit__c> navUnitMap = new Map<String, NAVUnit__c>();
        List<NAVUnit__c> navUnits = [
            SELECT Id, Name, CRM_QueueId__c, INT_UnitNumber__c
            FROM NAVUnit__c
            WHERE INT_UnitNumber__c IN :navUnits AND IsDeleted = FALSE
        ];

        for (NAVUnit__c n : navUnits) {
            navUnitMap.put(n.INT_UnitNumber__c, n);
        }
        return navUnitMap;
    }
}
