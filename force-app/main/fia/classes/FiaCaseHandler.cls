public without sharing class FiaCaseHandler extends KafkaMessageProcessor implements IKafkaMessageConsumer {
    Map<String,FiaCase> keyToFiaCase = new Map<String,FiaCase>();

    public void processMessages(List<KafkaMessage__c> messages) {
        for (KafkaMessage__c msg : messages) {
            try {
               FiaCase fia = (FiaCase) parse(FiaCase.class, msg);
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

    private void mapFiaCase(FiaCase fiaCase) {
        String key = fiaCase.key;
        if (!keyToFiaCase.containsKey(key)) {
            keyToFiaCase.put(key, fiaCase);

        } else if (isMostRecent(fiaCase.endretTidspunkt, keyToFiaCase.get(key).endretTidspunkt)) {
            keyToFiaCase.put(key, fiaCase);
        }
    }

    private void convertAndUpsertFiaCases(List<KafkaMessage__c> messages) {
        List<IACase__c> fiaCases = new List<IACase__c>();
        try {
            fiaCases = convertToSObject(); 

            Schema.SObjectField field = IACase__c.Fields.KafkaId__c;
            Database.UpsertResult [] results = Database.upsert(fiaCases, field, false);

        } catch (Exception e) {
            String errorRef = logger.logError(e.getMessage() + '/n' + e.getStackTraceString());
            logger.setMessageErrors(messages, errorRef);
        }
    }

    private List<IACase__c> convertToSObject() {
        Map<String, String> lastSaved = getLastSaved(IACase__c.class, keyToFiaCase.keyset());
        Map<String, Account> accountMap = getOrgNumberAccountMap();
        Map<String, User> navIdentMap = getNavIdentMap();
        List<IACase__c> fiaCases = new List<IACase__c>();
        for (FiaCase model : keyToFiaCase.values()) {
            if (!isNewOrChanged(model.key, model.hash, lastSaved)) {
                continue;
            } 
            IACase__c iaCase = new IACase__c();
            iaCase.Name = model.saksnummer;
            iaCase.CaseOwnerNavIdent__c = model.eierAvSak;
            iaCase.CaseStatus__c = model.status;
            iaCase.IACreatedDate__c = dateTimeValue(model.opprettetTidspunkt);
            iaCase.IALastModifiedDate__c = dateTimeValue(model.endretTidspunkt);
            iaCase.KafkaId__c = model.key;
            iaCase.KafkaHash__c = model.hash;
            iaCase.JsonPayload__c = model.jsonPayload;
            iaCase.Account__c = accountMap.get(model.orgnr).Id;              

            if (navIdentMap.containsKey(model.eierAvSak)) {
                User us = navIdentMap.get(model.eierAvSak);
                iaCase.CaseOwner__c = us.id;  
            }

            fiaCases.add(iaCase);  
        }
        return fiaCases;
    }

}

    