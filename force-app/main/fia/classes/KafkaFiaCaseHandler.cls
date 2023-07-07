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


    public Boolean testKlasse(Boolean b){
      /*   // List<FiaCase__c> fiaCasesList = new List<FiaCases__c>();
        fiaCasesList.add(fiaCase);
        System.debug('It works');
      for(FiaCase__c fiaCase1 : fiaCasesList ){
      System.debug(fiaCase1);
        System.debug('lol');
        } */
       b = true;
        return b;
    }



    private void convertAndUpsertFiaCases(List<KafkaMessage__c> messages) {
        
        List<FiaSak__c> fiaCases = new List<FiaSak__c>();
        //List<Account> fiaCases = new List<Account>();
        try {
            fiaCases = getFiaCasesSObjects(); 
            update fiaCases;
            System.debug(JSON.serializePretty(fiaCases));
        } catch (Exception e) {
            String errorRef = logger.logError(e.getMessage() + '/n' + e.getStackTraceString());
            logger.setMessageErrors(messages, errorRef);
        }
    }


    //DENNE trenger kun å hente ut all info til fiasak. så legger vi den i liste på getfiacasesobjects! 

   // Nå legges accountene i liste, men vi vil kanskje ha fiasakene i liste og ikke accountene? fiasakene skal jo legges i under account
    private  FiaSak__c convertToSObject(  
        KafkaFiaCase_Model model,
        Map<String, Account> accountMap,
        Map<String, User> navIdentMap 
    ) {
    
       
       // Gjør det fra en record til en liste med fiacases 
       // oppretter en ny record av fiacase for hver gang man henter.
        FiaSak__c fiaSak = new FiaSak__c();
        fiaSak.CaseNr__c = model.saksnummer;
        fiaSak.CaseOwner__c = model.eierAvSak;
        fiaSak.CaseStatus__c = model.status;
        fiaSak.StartDate__c = dateTimeValue(model.opprettetTidspunkt);
        fiaSak.LastModifiedDate__c = dateTimeValue(model.endretTidspunkt);
        fiaSak.KafkaId__c = model.key;
        fiaSak.KafkaHash__c = model.hash;
        fiaSak.JSONPayload__c = model.jsonPayload;
        
        return fiaSak;
    }  


    public List<FiaSak__c> getFiaCasesSObjects() {
        List<FiaSak__c> fiaCases = new List<FiaSak__c>();
       // List<Account> fiaCases = new List<Account>();
        Map<String, Account> accountMap = getOrgNumberAccountMap();
        Map<String, User> navIdentMap = getNavIdentMap();
        System.debug(JSON.serializePretty(keyToFiaCase.values()));
  
        for (KafkaFiaCase_Model model : keyToFiaCase.values()) {

           FiaSak__c fiaCase = convertToSObject(model, accountMap, navIdentMap);
            fiaCases.add(fiaCase);
                         
        //      Account fiaCase = new Account();            
               
              /*   fiaCases.add(fiaCase);
                system.debug(fiaCase);
                system.debug(fiaCases);  */
        }
        return fiaCases;
    }
}