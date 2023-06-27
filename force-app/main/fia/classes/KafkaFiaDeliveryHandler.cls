public without sharing class KafkaFiaDeliveryHandler extends KafkaMessageProcessor implements IKafkaMessageConsumer{
    Map<String, KafkaFiaDelivery_Model> keyToFiaDelivery = new Map<String, KafkaFiaDelivery_Model>();


    public void processMessages(List<KafkaMessage__c> messages) {
        for (KafkaMessage__c msg : messages) {
            try {
                KafkaFiaDelivery_Model fiaDelivery = (KafkaFiaDelivery_Model) parse(
                    KafkaFiaDelivery_Model.class, msg
                    ); 
                    mapFiaDelivery(fiaDelivery);

            }
        }
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
//Skal listen være FiaSak? 
    private void convertAndUpsertFiaDeliveries(List<KafkaMessage__c> messages) {
        List<FiaSak> fiaDelivieries = new List<FiaSak>();
        try{
            fiaDelivieries = getFiaDelivieriesSObjects();
            update fiaDelivieries;
        } catch (Exception e) {
            String errorRef = logger.logError(e.getMessage() + '/n' + e.getStackTraceString());
            logger.setMessageErrors(messages, errorRef);
        }
    }

//Skal listen være FiaSak? 
    private List<FiaSak> getFiaDelivieriesSObjects(){
        //litt usikker på hva denne gjør. 
        Map<String, String> lastSaved = getLastSaved(FiaSak.class, keyToFiaDelivery.keySet());
        List<FiaSak> fiaDeliveries = new List<FiaSak>();
           //litt usikker på hva disse gjør. 
        Map<String, Account> accountMap = getOrgNumberAccountMap();
        Map<String, User> navIdentMap = getNavIdentMap();

        for(KafkaFiaDelivery_Model model : keyToFiaDelivery.values()) {
            if(isNewOrChanged(model.leveranseId, model.hash, lastSaved) && accountMap.containsKey(model.leveranseId)) {
                //skal vi bruke account? elelr fiasak kanskje?
                //https://github.com/navikt/crm-arbeidsgiver-integration/blob/e2a52a10fa94320fcb1d00a8faeeab3a78514ec5/force-app/main/toiAvtale/classes/KafkaToiAvtaleHandler.cls
                //https://github.com/navikt/crm-arbeidsgiver-integration/blob/e2a52a10fa94320fcb1d00a8faeeab3a78514ec5/force-app/main/modia/classes/KafkaModiaDialogMoteHandler.cls
                
            }
        }
 
    }


  
}