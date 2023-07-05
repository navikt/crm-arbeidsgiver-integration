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
//Kan denne fjernes?
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
          //  fiaCases = getFiaCasesSObjects(); //dead now.
            update fiaCases;
        } catch (Exception e) {
            String errorRef = logger.logError(e.getMessage() + '/n' + e.getStackTraceString());
            logger.setMessageErrors(messages, errorRef);
        }
    }

    private Account convertToSObject(
        KafkaFiaCase_Model model,
        Map<String, Account> accountMap,
        Map<String, User> navIdentMap
    ) {

        Map<String, String> lastSaved = getLastSaved(Account.class, keyToFiaCase.keyset());
        List<Account> fiaCases = new List<Account>();
       // Map<String, Account> accountMap = getOrgNumberAccountMap();
        //Map<String, User> navIdentMap = getNavIdentMap();


        //Gjør det fra en record til en liste med fiacases 
        //oppretter en ny record av fiacase for hver gang man henter.

       // List<FiaCase__c> fiaCasesList = new List<FiaCases__c>();

        Account a = accountMap.get(model.orgnr);
        
    /*     for(String key : accountMap.keySet()){
            for(Account account: accountMap.get(key)){
                System.debug(account);
          // fiaCase__c a;
            a.TAG_FiaCaseNr__c = account.saksnummer;
            a.TAG_FiaCaseOwner__c = account.eierAvSak;
            a.TAG_FiaCaseStatus__c = account.status;
            a.TAG_FiaStartDate__c = dateTimeValue(account.opprettetTidspunkt);
            a.TAG_FiaLastModifiedDate__c = dateTimeValue(account.endretTidspunkt);
            a.TAG_FiaKafkaId__c = account.key;
            a.KafkaHash__c = account.hash;
            a.JsonPayload__c = account.jsonPayload;
        

            //dette kan gi en heftig loop hvis jeg ikke er forsiktig. Må finne en god måte å debuge det på. Start her i morgen, 
            //Sjekk om denne lagrer det jeg tror den lagrer, som skal være fiacases. 
        // fiaCasesList.add(a);
            system.debug('hello');
        }
            //Set<KafkaFiaCase_Model>model = model.orgnr; //accountMap.get(key);

            a.TAG_FiaCaseNr__c = model.saksnummer;
            a.TAG_FiaCaseOwner__c = model.eierAvSak;
            a.TAG_FiaCaseStatus__c = model.status;
            a.TAG_FiaStartDate__c = dateTimeValue(model.opprettetTidspunkt);
            a.TAG_FiaLastModifiedDate__c = dateTimeValue(model.endretTidspunkt);
            a.TAG_FiaKafkaId__c = model.key;
            a.KafkaHash__c = model.hash;
            a.JsonPayload__c = model.jsonPayload;

        } */


        if (navIdentMap.containsKey(model.eierAvSak)) {
            User us = navIdentMap.get(model.eierAvSak);
            a.TAG_FiaCaseOwnerName__c = us.FirstName + ' ' + us.LastName;
        }

        return a;
    }
}