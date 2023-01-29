public without sharing class KafkaFiaCaseHandler extends KafkaMessageProcessor implements IKafkaMessageConsumer {
    Map<String, KafkaFiaCase_Model> keyToFiaCase = new Map<String, KafkaFiaCase_Model>();

    public void processMessages(List<KafkaMessage__c> messages) {
        for (KafkaMessage__c msg : messages) {
            try {
                KafkaFiaCase_Model fia = (KafkaFiaCase_Model) parse(KafkaFiaCase_Model.class, msg);
                mapFiaCase(fia);
                addOrgNumber(fia?.orgnr);
                addNavIdent(fia?.eierAvSak);
                msg.CRM_Status__c = KafkaMessageService.STATUS_PROCESSED;
            } catch (Exception e) {
                msg.CRM_Status__c = KafkaMessageService.STATUS_ERROR;
                msg.CRM_ErrorMessage__c = e.getMessage() + ' (' + e.getLineNumber() + ')';
                logger.addError();
            }
        }
        convertAndUpsertFiaCases(messages);
        logger.publish();
    }

    private void mapFiaCase(KafkaFiaCase_Model fiaCase) {
        String key = fiaCase.orgnr;

        if (!keyToFiaCase.containsKey(key)) {
            keyToFiaCase.put(key, fiaCase);
        } else if (isMostRecent(fiaCase.endretTidspunkt, keyToFiaCase.get(key).endretTidspunkt)) {
            keyToFiaCase.put(key, fiaCase);
        }
    }

    private void convertAndUpsertFiaCases(List<KafkaMessage__c> messages) {
        List<Account> fiaCases = new List<Account>();
        try {
            fiaCases = getFiaCasesSObjects();
            update fiaCases;
        } catch (Exception e) {
            String errorRef = logger.logError(e.getMessage() + '/n' + e.getStackTraceString());
            logger.setMessageErrors(messages, errorRef);
        }
    }

    private List<Account> getFiaCasesSObjects() {
        Map<String, String> lastSaved = getLastSavedFiaCase(Account.class, keyToFiaCase.keyset());
        List<Account> fiaCases = new List<Account>();
        Map<String, Account> accountMap = getOrgNumberAccountMap();
        Map<String, User> navIdentMap = getNavIdentMap();

        for (KafkaFiaCase_Model model : keyToFiaCase.values()) {
            if (isNewOrChanged(model.orgnr, model.hash, lastSaved) && accountMap.containsKey(model.orgnr)) {
                Account fiaCase = new Account();                

                if (model.status == 'SLETTET' || model.status == 'IKKE_AKTIV'){
                    fiaCase = setFiaCaseFieldsToNull(model, accountMap);
                }
                else {
                    fiaCase = convertToSObject(model, accountMap, navIdentMap);
                }

                fiaCases.add(fiaCase);
            }
        }

        return fiaCases;
    }

    private Account convertToSObject(
        KafkaFiaCase_Model model,
        Map<String, Account> accountMap,
        Map<String, User> navIdentMap
    ) {
        Account a = accountMap.get(model.orgnr);
        a.TAG_FiaCaseNr__c = model.saksnummer;
        a.TAG_FiaCaseOwner__c = model.eierAvSak;
        a.TAG_FiaCaseStatus__c = model.status;
        a.TAG_FiaStartDate__c = dateTimeValue(model.opprettetTidspunkt);
        a.TAG_FiaLastModifiedDate__c = dateTimeValue(model.endretTidspunkt);
        a.TAG_FiaKafkaId__c = model.key;
        a.KafkaHash__c = model.hash;
        a.JsonPayload__c = model.jsonPayload;

        if (navIdentMap.containsKey(model.eierAvSak)) {
            User us = navIdentMap.get(model.eierAvSak);
            a.TAG_FiaCaseOwnerName__c = us.FirstName + ' ' + us.LastName;
        }

        return a;
    }

    private Account setFiaCaseFieldsToNull(
        KafkaFiaCase_Model model,
        Map<String, Account> accountMap
    ) {
        Account a = accountMap.get(model.orgnr);
        a.TAG_FiaCaseNr__c = '';
        a.TAG_FiaCaseOwner__c = '';
        a.TAG_FiaCaseStatus__c = '';
        a.TAG_FiaStartDate__c = null;
        a.TAG_FiaLastModifiedDate__c = null;
        a.TAG_FiaCaseOwnerName__c = '';
        a.TAG_FiaKafkaId__c = '';
        a.KafkaHash__c = '';
        a.JsonPayload__c = '';

        return a;
    }

    private Map<String, String> getLastSavedFiaCase(Type className, Set<String> organizationNumbers) {
        String query = 'SELECT KafkaHash__c, INT_OrganizationNumber__c FROM Account WHERE INT_OrganizationNumber__c IN: organizationNumbers';
        Map<String, String> keyToExistingHash = new Map<String, String>();

        for (SObject obj : Database.query(query)) {
            if (obj.get('KafkaHash__c') != null) {
                keyToExistingHash.put(obj.get('INT_OrganizationNumber__c').toString(), obj.get('KafkaHash__c').toString());
            }
        }
        return keyToExistingHash;
    }
}
