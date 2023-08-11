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

            Schema.SObjectField f = IADelivery__c.Fields.KafkaId__c;
            Database.UpsertResult [] cr = Database.upsert(FiaDeliveries , f, false);

        } catch (Exception e) {
            String errorRef = logger.logError(e.getMessage() + '/n' + e.getStackTraceString());
            logger.setMessageErrors(messages, errorRef);
        }
    }

private List<IADelivery__c> convertToSObject() {
    Map<String, String> lastSaved = getLastSaved(IADelivery__c.class, keyToFiaDelivery.keyset());
    Map<String, IACase__c> iaCaseMap = getCaseNumberIACaseMap();
    Map<String, User> navIdentMap = getNavIdentMap();
    List<IADelivery__c> FiaDeliveries = new List<IADelivery__c>();

    for (KafkaFiaCase_Model model : keyToFiaDelivery.values()) {
        if (!isNewOrChanged(model.key, model.hash, lastSaved)) {
            continue;
        } 
        IADelivery__c id = new IADelivery__c();
        id.Name = model.id;
        id.IACase__c = model.saksnummer;
        id.Module__c = model.modul;
        id.IAService__c = model.iaTjeneste;
        id.Deadline__c = dateTimeValue(model.frist);
        id.Status__c = model.status;
        id.DeliveryCreatedBy__c = model.opprettetAv;
        id.IALastModifiedDate__c = dateTimeValue(model.frist);
        id.DeliveryLastModifiedBy__c = model.sistEndretAv;
        id.DeliveryLastModifiedByRole__c = model.sistEndretAvRolle;
        id.CompletedDate__c = dateTimeValue(model.fullfort);
       
        if (navIdentMap.containsKey(model.opprettetAv)) {
            User us = navIdentMap.get(model.opprettetAv);
            id.DeliveryCreatedByUser__c = us.id;  
        }

        if (navUnitMap.containsKey(model.enhetsnummer)) {
          //  id.NAVUnit__c = model.enhetsnummer;
            id.NAVUnit__c = navUnitMap.get(model.enhetsnummer).Id;
        }

        id.KafkaId__c = model.key;
        id.KafkaHash__c = model.hash;
        id.JsonPayload__c = model.jsonPayload;
    
        FiaDeliveries.add(id);  
    }
    return FiaDeliveries;
}
}