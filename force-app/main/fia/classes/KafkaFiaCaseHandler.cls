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

            System.debug('key to fia casehere');
            System.debug('key to fia case' + key);
            System.debug('key to fia case' + keyToFiaCase);
        } else if (isMostRecent(fiaCase.endretTidspunkt, keyToFiaCase.get(key).endretTidspunkt)) {
            keyToFiaCase.put(key, fiaCase);
        }
    }

    private void convertAndUpsertFiaCases(List<KafkaMessage__c> messages) {
        
        List<IACase__c> fiaCases = new List<IACase__c>();
       // List<Account> fiaCases = new List<Account>();
        try {
            fiaCases = convertToSObject(); 
            upsert fiaCases;
        } catch (Exception e) {
            String errorRef = logger.logError(e.getMessage() + '/n' + e.getStackTraceString());
            logger.setMessageErrors(messages, errorRef);
        }
    }

    private List<IACase__c> convertToSObject() {
        Map<String, String> lastSaved = getLastSaved(IACase__c.class, keyToFiaCase.keyset());
        Map<String, Account> accountMap = getOrgNumberAccountMap();
        Map<String, User> navIdentMap = getNavIdentMap();
        List<IACase__c> fiaCases1 = new List<IACase__c>();
        for (KafkaFiaCase_Model model : keyToFiaCase.values()) {
             if (!isNewOrChanged(model.key, model.hash, lastSaved)) {
                continue;
            } 
            IACase__c ic = new IACase__c ();
                ic.Name = model.saksnummer;
                ic.CaseOwner__c = model.eierAvSak;
                ic.CaseStatus__c = model.status;
                ic.IACreatedDate__c = dateTimeValue(model.opprettetTidspunkt);
                ic.IALastModifiedDate__c = dateTimeValue(model.endretTidspunkt);
                ic.KafkaId__c = model.key;
                ic.KafkaHash__c = model.hash;
                ic.JsonPayload__c = model.jsonPayload;
                if (accountMap.containsKey(model.orgnr)) {
                    ic.Account__c = accountMap.get(model.orgnr).Id;
                }

            fiaCases1.add(ic);
            fiaCases1.add(ic);
            
            
/*
            if (navIdentMap.containsKey(model.eierAvSak)) {
                User us = navIdentMap.get(model.eierAvSak);
                ic.CreatedById = us.id;
            }*/

          
        }
        return fiaCases1;
    }
/* 
    public List<IACase__c> getFiaCasesSObjects() {
        List<IACase__c> fiaCases = new List<IACase__c>();
       // List<Account> fiaCases = new List<Account>();
        Map<String, Account> accountMap = getOrgNumberAccountMap();
        Map<String, User> navIdentMap = getNavIdentMap();
        System.debug('keyToFiaCase map contents: here');
        System.debug('keyToFiaCase map contents: ' + JSON.serializePretty(keyToFiaCase.values()));
        System.debug('keyToFiaCase map contents: here');
  
        for (KafkaFiaCase_Model model : keyToFiaCase.values()) {
     //   Account fiaCase = new Account();            
           IACase__c fiaCase = convertToSObject(model, accountMap, navIdentMap);
            fiaCases.add(fiaCase);
        }
        return fiaCases;
    }      
} */
}