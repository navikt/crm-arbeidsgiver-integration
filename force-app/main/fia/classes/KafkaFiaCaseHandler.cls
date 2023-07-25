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
        String key = fiaCase.key;

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
            upsert fiaCases;
        } catch (Exception e) {
            String errorRef = logger.logError(e.getMessage() + '/n' + e.getStackTraceString());
            logger.setMessageErrors(messages, errorRef);
        }
    }

    private List<FiaSak__c> convertToSObject() {
        Map<String, String> lastSaved = getLastSaved(FiaSak__c.class, keyToFiaCase.keyset());
        Map<String, Account> accountMap = getOrgNumberAccountMap();
        Map<String, User> navIdentMap = getNavIdentMap();
        List<FiaSak__c > fiaSaker = new List<FiaSak__c> ();
        
        for (KafkaFiaCase_Model model : keyToFiaCase.values()) {
            if (!isNewOrChanged(model.key, model.hash, lastSaved)) {
                continue;
            }

        FiaSak__c fs = new FiaSak__c (
        name = model.saksnummer,
        CaseOwner__c = model.eierAvSak,
        CaseStatus__c = model.status,
        StartDate__c = dateTimeValue(model.opprettetTidspunkt),
        LastModifiedDate__c = dateTimeValue(model.endretTidspunkt),
        KafkaId__c = model.key,
        KafkaHash__c = model.hash,
        JsonPayload__c = model.jsonPayload
        );

        if (navIdentMap.containsKey(model.eierAvSak)) {
            fs.Owner = navIdentMap.get(model.eierAvSak);
        }

        if (accountMap.containsKey(model.orgnr)) {
            fs.Account__c = accountMap.get(model.orgnr).Id;
        }
        
        fiaSaker.add(fs);
    }
        return fiaSaker;
    }
}
