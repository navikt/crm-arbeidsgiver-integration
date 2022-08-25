public with sharing class KafkaFiaCaseHandler extends KafkaMessageProcessor implements IKafkaMessageConsumer{
    Map<String, KafkaFiaCase_Model> keyToFiaCase = new Map<String, KafkaFiaCase_Model>();
    private Set<String> navIdents;
    private List<User> users = [SELECT Id, firstName, lastName, CRM_NAV_Ident__c FROM User WHERE CRM_NAV_Ident__c IN: navIdents];

    private KafkaFiaCaseHandler(){
        navIdents = new Set<String>();
    }

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
        Map<String, Account> accountMap = getOrgNumberAccountMap();

        for (KafkaFiaCase_Model model : keyToFiaCase.values()) {
 
            if (isNewOrChanged(model.key, model.hash, lastSaved) && accountMap.containsKey(model.orgnr)) {
                Account fiaCase = convertToSObject(model, accountMap);
                fiaCases.add(fiaCase);
            }
        }
        return fiaCases;
    }

    private Account convertToSObject(KafkaFiaCase_Model model, Map<String, Account> accountMap) {
            Map<String, String> navIdentMap = getNavIdentMap();

            Account a = accountMap.get(model.orgnr);
            a.TAG_FiaCaseNr__c = model.saksnummer;
            a.TAG_FiaCaseOwner__c = model.eierAvSak;
            a.TAG_FiaCaseStatus__c = model.status;
            a.TAG_FiaStartDate__c = dateTimeValue(model.opprettetTidspunkt);
            a.TAG_FiaLastModifiedDate__c = dateTimeValue(model.endretTidspunkt);
            a.TAG_FiaKafkaId__c = model.key;
            a.KafkaHash__c = model.hash;
            a.JsonPayload__c = model.jsonPayload;

            if (navIdentMap.containsKey(model.eierAvSak)){
                String fullName = navIdentMap.get(model.eierAvSak);
                a.TAG_FiaCaseOwnerName__c = fullName;
            }

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

    private void addNavIdent(String navIdent) {
        if (navIdent != null){
            navIdents.add(navIdent);
        }
    }

    private Map<String, String> getNavIdentMap() {
        Map<String, String> navIdentMap = new Map<String, String>();
        for (User u : users){
            String name = u.firstName + ' ' + u.lastName; 
            navIdentMap.put(u.CRM_NAV_Ident__c, name);
        }
    
        return navIdentMap;
    }
}
