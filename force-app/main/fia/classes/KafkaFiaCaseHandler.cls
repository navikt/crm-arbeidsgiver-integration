public with sharing class KafkaFiaCaseHandler extends KafkaMessageProcessor implements IKafkaMessageConsumer{
    Map<String, KafkaFiaCase_Model> keyToFiaCase = new Map<String, KafkaFiaCase_Model>();

    public void processMessages(List<KafkaMessage__c> messages) {
        for (KafkaMessage__c msg : messages) {
            try {
                KafkaFiaCase_Model fia = (KafkaFiaCase_Model) parse(KafkaFiaCase_Model.class, msg);
                mapFiaCase(fia);
                msg.CRM_Status__c = KafkaMessageService.STATUS_PROCESSED;
            } catch (Exception e) {
                msg.CRM_Status__c = KafkaMessageService.STATUS_ERROR;
                msg.CRM_ErrorMessage__c = e.getMessage() + ' (' + e.getLineNumber() + ')';
            }
        }
        convertAndUpsertFiaCases(messages);
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
            update fiaCases;
        } catch (Exception e) {
            String errorRef = logError(e.getMessage() + '/n' + e.getStackTraceString());
            setMessageErrors(messages, errorRef);
        }
    }

    private List<Account> getFiaCasesSObjects() {
        Map<String, String> lastSaved = getLastSavedFiaCase(Account.class, keyToFiaCase.keyset());
        List<Account> fiaCases = new List<Account>();

        for (KafkaFiaCase_Model model : keyToFiaCase.values()) {
 
            if (isNewOrChanged(model.key, model.hash, lastSaved)) {
                Account fiaCase = convertToSObject(model);
                fiaCases.add(fiaCase);
            }
        }
        return fiaCases;
    }

    private Account convertToSObject(KafkaFiaCase_Model model) {
        Account a = [SELECT Id, INT_OrganizationNumber__c, TAG_FiaCaseNr__c, TAG_FiaCaseOwner__c, TAG_FiaCaseStatus__c, TAG_FiaStartDate__c, TAG_FiaLastModifiedDate__c, TAG_FiaKafkaId__c, KafkaHash__c, JsonPayload__c FROM Account WHERE INT_OrganizationNumber__c =:model.orgnr];
            a.TAG_FiaCaseNr__c = model.saksnummer;
            a.TAG_FiaCaseOwner__c = model.eierAvSak;
            a.TAG_FiaCaseStatus__c = model.status;
            a.TAG_FiaStartDate__c = dateTimeValue(model.opprettetTidspunkt);
            a.TAG_FiaLastModifiedDate__c = dateTimeValue(model.endretTidspunkt);
            a.TAG_FiaKafkaId__c = model.key;
            a.KafkaHash__c = model.hash;
            a.JsonPayload__c = model.jsonPayload;

        return a;
    }

    public Map<String, String> getLastSavedFiaCase(Type className, Set<String> kafkaIds) {
        String query = 'SELECT KafkaHash__c, TAG_FiaKafkaId__c FROM Account WHERE TAG_FiaKafkaId__c IN: kafkaIds';
        Map<String, String> keyToExistingHash = new Map<String, String>();

        for (SObject obj : Database.query(query)) {
            if (obj.get('KafkaHash__c') != null) {
                keyToExistingHash.put(obj.get('TAG_FiaKafkaId__c').toString(), obj.get('KafkaHash__c').toString());
            }
        }
        return keyToExistingHash;
    }
}
