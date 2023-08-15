 public without sharing class KafkaFiaDeliveryHandler extends KafkaMessageProcessor implements IKafkaMessageConsumer{
   Map<String, KafkaFiaDelivery_Model> keyToFiaDelivery = new Map<String, KafkaFiaDelivery_Model>();
  public Set<String> CaseNumbers;

  public KafkaFiaDeliveryHandler(){
    this.CaseNumbers = new Set<String>();
  }

    public void processMessages(List<KafkaMessage__c> messages) {
        for (KafkaMessage__c msg : messages) {
            try {
                KafkaFiaDelivery_Model ia = (KafkaFiaDelivery_Model) parse(KafkaFiaDelivery_Model.class, msg);
                mapFiaDelivery(ia);
                addCaseNumber(ia?.saksnummer);
                addNavIdent(ia?.opprettetAv);
                addNavUnit(ia?.enhetsnummer);
                msg.CRM_Status__c = KafkaMessageService.STATUS_PROCESSED;
            } catch (Exception e) {
                msg.CRM_Status__c = KafkaMessageService.STATUS_ERROR;
                msg.CRM_ErrorMessage__c = e.getMessage() + ' (' + e.getLineNumber() + ')';
                logger.addError();
            }
        }
        convertAndUpsertFiaDeliveries(messages);
        logger.publish();
    } 

    public KafkaMessageProcessor addCaseNumber(String caseNumber) {
        if (caseNumber != null) {
            caseNumbers.add(caseNumber);
        }
        return this;
    }
 
    public Map<String, IACase__c> getCaseNumberIACaseMap() {
        Map<String, IACase__c> IACaseMap = new Map<String, IACase__c>();

        List<IACase__c> IACases = [
            SELECT Id, Name
            FROM IACase__c
            WHERE Name IN :CaseNumbers
        ]; 

        for (IACase__c a : IACases) {
          IACaseMap.put(a.Name, a);
        }
        return IACaseMap;
    }

    private void mapFiaDelivery(KafkaFiaDelivery_Model fiaDelivery) {
        String key = fiaDelivery.key;
        if (!keyToFiaDelivery.containsKey(key)){
            keyToFiaDelivery.put(key, fiaDelivery);

        } else if (isMostRecent(fiaDelivery.sistEndret, keyToFiaDelivery.get(key).sistEndret)) {
            keyToFiaDelivery.put(key, fiaDelivery);
        }
    }

    private void convertAndUpsertFiaDeliveries(List<KafkaMessage__c> messages) {
        List<IADelivery__c> FiaDeliveries = new List<IADelivery__c>();
        try {
            FiaDeliveries = convertToSObject(); 
            upsert FiaDeliveries IADelivery__c.KafkaId__c;
        } catch (Exception e) {
            String errorRef = logger.logError(e.getMessage() + '/n' + e.getStackTraceString());
            logger.setMessageErrors(messages, errorRef);  
        }
    }

    private List<IADelivery__c> convertToSObject() {
    Map<String, String> lastSaved = getLastSaved(IADelivery__c.class, keyToFiaDelivery.keyset());
    Map<String, NavUnit__c> navUnitMap = getNavUnitsMap();
    Map<String, IACase__c> iaCaseMap = getCaseNumberIACaseMap();
    Map<String, User> navIdentMap = getNavIdentMap();
    List<IADelivery__c> FiaDeliveries = new List<IADelivery__c>();
 
    for (KafkaFiaDelivery_Model model : keyToFiaDelivery.values()) {
        if (!isNewOrChanged(model.key, model.hash, lastSaved)) {
            continue;
        } 
        IADelivery__c iad = new IADelivery__c();
        iad.Name = String.valueOf(model.id);
        iad.IACase__c = iaCaseMap.get(model.saksnummer).id;
     //   iad.Module__c = model.getModuleName();
     //   iad.IAService__c = model.modul.iaTjeneste.navn;
        iad.Deadline__c = Date.valueOf(model.frist);
        iad.Status__c = model.status;
        iad.DeliveryCreatedBy__c = model.opprettetAv;
        iad.DeliveryLastModifiedDate__c = dateTimeValue(model.sistEndret);
        iad.DeliveryLastModifiedBy__c = model.sistEndretAv;
        iad.DeliveryLastModifiedByRole__c = model.sistEndretAvRolle;
        
        if (model.fullfort != null) {
            iad.CompletedDate__c = dateTimeValue(model.fullfort);
        }
       
        if (navIdentMap.containsKey(model.opprettetAv)) {
            iad.DeliveryCreatedByUser__c = navIdentMap.get(model.opprettetAv).Id; 
        }

        if (navUnitMap.containsKey(model.enhetsnummer)) {
            iad.NAVUnit__c = navUnitMap.get(model.enhetsnummer).Id;
        }

        iad.KafkaId__c = model.key;
        iad.KafkaHash__c = model.hash;
        iad.JsonPayload__c = model.jsonPayload;
    
        FiaDeliveries.add(iad);
    }
     
    return FiaDeliveries;
} 
} 