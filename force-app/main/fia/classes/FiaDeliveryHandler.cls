public without sharing class FiaDeliveryHandler extends KafkaMessageProcessor implements IKafkaMessageConsumer{
    Map<String, FiaDelivery> keyToFiaDelivery = new Map<String, FiaDelivery>();
    public Set<String> CaseNumbers;
    public Set<String> fiaDeliveriesToDelete;

    public FiaDeliveryHandler(){
        this.CaseNumbers = new Set<String>();
        this.fiaDeliveriesToDelete = new Set<String>();
    }

    public void processMessages(List<KafkaMessage__c> messages) {
        for (KafkaMessage__c msg : messages) {
            try {
                FiaDelivery ia = (FiaDelivery) parse(FiaDelivery.class, msg);

                if (ia.status == 'SLETTET') {
                    addFiaDeliveriesToDelete(ia.key);
                    msg.CRM_Status__c = KafkaMessageService.STATUS_PROCESSED;
                    continue;
                }

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

        if (!fiaDeliveriesToDelete.isEmpty()) {
            deleteFiaDeliveries(messages);
        } 

        logger.publish();
    } 

    public FiaDeliveryHandler addCaseNumber(String caseNumber) {
        if (caseNumber != null) {
            caseNumbers.add(caseNumber);
        }
        return this;
    }

    public FiaDeliveryHandler addFiaDeliveriesToDelete(String fiaDeliveryToDelete) {
        if (fiaDeliveryToDelete != null) {
            fiaDeliveriesToDelete.add(fiaDeliveryToDelete);
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

    private void mapFiaDelivery(FiaDelivery fiaDelivery) {
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

    private void deleteFiaDeliveries(List<KafkaMessage__c> messages) {
        Map<String, IADelivery__c> fiaDeliveryMap = getFiaDeliveriesToDelete();
        List<IADelivery__c> fiaDeliveries = new List<IADelivery__c>();
        try {
            for (IADelivery__c iad : fiaDeliveryMap.values()) {
                fiaDeliveries.add(iad);
            }
            Delete fiaDeliveries;

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
 
    for (FiaDelivery model : keyToFiaDelivery.values()) {
        if (!isNewOrChanged(model.key, model.hash, lastSaved)) {
            continue;
        } 
        IADelivery__c iad = new IADelivery__c();
        iad.Name = String.valueOf(model.id);
        iad.IACase__c = iaCaseMap.get(model.saksnummer).id; 
        iad.Deadline__c = Date.valueOf(model.frist);
        iad.Status__c = model.status;
        iad.DeliveryCreatedBy__c = model.opprettetAv;
        iad.DeliveryLastModifiedBy__c = model.sistEndretAv;
        iad.DeliveryLastModifiedByRole__c = model.sistEndretAvRolle;

        if (model.modul.navn != null) {
            iad.Module__c = model.modul.navn;
        }

        if (model.modul.iaTjeneste.navn != null) {
            iad.IAService__c = model.modul.iaTjeneste.navn;
        }

        if (model.fullfort != null) {
            iad.CompletedDate__c = dateTimeValue(model.fullfort);
        }
        if (model.sistEndret != null) {
            iad.DeliveryLastModifiedDate__c = dateTimeValue(model.sistEndret);
        }
        if (model.opprettetTidspunkt != null) {
            iad.CreatedDate__c = dateTimeValue(model.opprettetTidspunkt);
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

private Map<String, IADelivery__c> getFiaDeliveriesToDelete() {
    Map<String, IADelivery__c> fiaDeliveriesToDeleteMap = new Map<String, IADelivery__c>();
    List<IADelivery__c> fiaDeliveries = [
        SELECT Id, Name, KafkaId__c
        FROM IADelivery__c
        WHERE KafkaId__c IN :fiaDeliveriesToDelete
    ];

    for (IADelivery__c iad : fiaDeliveries) {
        fiaDeliveriesToDeleteMap.put(iad.KafkaId__c, iad);
    }
    return fiaDeliveriesToDeleteMap;
}

} 