public without sharing class KafkaFiaDeliveryHandler extends KafkaMessageProcessor implements IKafkaMessageConsumer{
    Map<String, KafkaFiaDelivery_Model> keyToFiaDelivery = new Map<String, KafkaFiaDelivery_Model>();
    public Set<String> caseNumbers;

public KafkaFiaDeliveryHandler(){
   this.caseNumbers = new Set<String>();
}

    public void processMessages(List<KafkaMessage__c> messages) {
        for (KafkaMessage__c msg : messages) {
            try {
                KafkaFiaDelivery_Model fiaDelivery = (KafkaFiaDelivery_Model) parse(
                    KafkaFiaDelivery_Model.class, msg
                    ); 
                    mapFiaDelivery(fiaDelivery);
                    addNavIdent(fiaDelivery?.opprettetAv);
                    addCaseNumber(fiaDelivery?.saksnummer);
                    msg.CRM_Status__c = KafkaMessageService.STATUS_PROCESSED; 
            } catch (Exeption e){
                msg.CRM_Status__c = KafkaMessageService.STATUS_ERROR;
                msg.CRM_ErrorMessage__c = e.getMessage() + ' (' + e.getLineNumber() + ')';
                logger.addError();
            }
        }
        convertAndUpsertFiaDeliveries(messages);
        logger.public;
    }

    private void addCaseNumber(String caseNumber){
        String caseNr = caseNumber?.saksnummer;
        caseNumbers.add(caseNr);

    }

    private void mapFiaDelivery(KafkaFiaDelivery_Model fiaDelivery) {
        String key = fiaDelivery.leveranseId;
   //litt usikker på hva denne gjør. Hvorfor sjekker vi etter sist endret?
        if (!keyToFiaDelivery.containsKey(key)) {
            keyToFiaDelivery.put(key,fiaDelivery);
        } else if (isMostRecent(fiaDelivery.sistEndret, keyToFiaDelivery.get(key).sistEndret)){
            keyToFiaDelivery.put(key, fiaDelivery);
        }
    }
//Skal listen være FiaSak__c? 
    private void convertAndUpsertFiaDeliveries(List<KafkaMessage__c> messages) {
        List<FiaSak__c> fiaDelivieries = new List<FiaSak__c>();
        try{
            fiaDelivieries = getFiaDelivieriesSObjects();
            update fiaDelivieries;
        } catch (Exception e) {
            String errorRef = logger.logError(e.getMessage() + '/n' + e.getStackTraceString());
            logger.setMessageErrors(messages, errorRef);
        }
    }

    private FiaSak__c convertToSObject(
        KafkaFiaDelivery_Model model,
        Map<String, User> navIdentMap
    ){



        Map<String, String> lastSaved = getLastSaved(FiaSak__c.class, keyToFiaDelivery.keySet());
        List<FiaSak__c> fiaDeliveries = new List<FiaSak__c>();
        Map<String, Account> accountMap = getOrgNumberAccountMap();
        Map<String, User> navIdentMap = getNavIdentMap();
        for(KafkaFiaDelivery_Model model : keyToFiaDelivery.values()) {
            if(isNewOrChanged(model.leveranseId, model.hash, lastSaved) && accountMap.containsKey(model.leveranseId)) {
                //skal vi bruke account? elelr fiasak kanskje?
                //https://github.com/navikt/crm-arbeidsgiver-integration/blob/e2a52a10fa94320fcb1d00a8faeeab3a78514ec5/force-app/main/toiAvtale/classes/KafkaToiAvtaleHandler.cls
                //https://github.com/navikt/crm-arbeidsgiver-integration/blob/e2a52a10fa94320fcb1d00a8faeeab3a78514ec5/force-app/main/modia/classes/KafkaModiaDialogMoteHandler.cls
                
            }
    }


  //Bruk en av de 3 nederst funksjonene i kafkamessageprocessor, for å finne id ti lfiasak, 
  //vi legger i map for å unngå sqlqueries i loops. vi legger den i map, også henter vi de tilbake fra map for unngå sql quieries i loops. 
  //Derfor querier vi ikke direkte, da kræsjer det
}
}