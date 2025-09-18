public without sharing class FiaCaseHandler extends KafkaMessageProcessor implements IKafkaMessageConsumer {
    Map<String, FiaCase> keyToFiaCase = new Map<String, FiaCase>();
    public Set<String> fiaCasesToDelete;
    private static final Integer AGE_THRESHOLD_MINUTES = 15;
    public FiaCaseHandler() {
        this.fiaCasesToDelete = new Set<String>();
    }

    public void processMessages(List<KafkaMessage__c> messages) {
        for (KafkaMessage__c msg : messages) {
            try {
                FiaCase fia = (FiaCase) parse(FiaCase.class, msg);

                if (fia.status == 'SLETTET') {
                    addFiaCasesToDelete(fia.key);
                    msg.CRM_Status__c = KafkaMessageService.STATUS_PROCESSED;
                    continue;
                }

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

        if (!fiaCasesToDelete.isEmpty()) {
            deleteFiaCases(messages);
        }
        logTimeDeviations(keyToFiaCase);
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

    public FiaCaseHandler addFiaCasesToDelete(String fiaCaseToDelete) {
        if (fiaCaseToDelete != null) {
            fiaCasesToDelete.add(fiaCaseToDelete);
        }
        return this;
    }

    private void convertAndUpsertFiaCases(List<KafkaMessage__c> messages) {
        List<IACase__c> fiaCases = new List<IACase__c>();
        try {
            fiaCases = convertToSObject();

            Schema.SObjectField field = IACase__c.Fields.KafkaId__c;
            Database.UpsertResult[] upsertResults = Database.upsert(fiaCases, field, false);
            Map<String, KafkaMessage__c> messageMap = new Map<String, KafkaMessage__c>();

            for (KafkaMessage__c message : messages) {
                messageMap.put(message.CRM_Key__c, message);
            }

            for (Integer i = 0; i < upsertResults.size(); i++) {
                if (!upsertResults[i].isSuccess()) {
                    Database.Error error = upsertResults[i].getErrors()[0];
                    String errorMessage = error.getMessage();
                    String errorRef = logger.logError(errorMessage);
                    KafkaMessage__c failedMessage = messageMap.get(fiaCases[i].KafkaId__c);
                    logger.setMessageErrors(new List<KafkaMessage__c>{ failedMessage }, errorRef);
                }
            }
        } catch (Exception e) {
            String errorRef = logger.logError(e.getMessage() + '/n' + e.getStackTraceString());
            logger.setMessageErrors(messages, errorRef);
        }
    }

    private void deleteFiaCases(List<KafkaMessage__c> messages) {
        Map<String, IACase__c> fiaCaseMap = getFiaCasesToDelete();
        List<IACase__c> fiaCases = new List<IACase__c>();
        try {
            for (IACase__c iac : fiaCaseMap.values()) {
                fiaCases.add(iac);
            }
            delete fiaCases;
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

    private Map<String, IACase__c> getFiaCasesToDelete() {
        Map<String, IACase__c> fiaCaseToDeleteMap = new Map<String, IACase__c>();
        List<IACase__c> fiaCases = [SELECT Id, Name, KafkaId__c FROM IACase__c WHERE KafkaId__c IN :fiaCasesToDelete];

        for (IACase__c iac : fiaCases) {
            fiaCaseToDeleteMap.put(iac.KafkaId__c, iac);
        }
        return fiaCaseToDeleteMap;
    }

    @TestVisible
    private void logTimeDeviations(Map<String, FiaCase> keyToFiaCase) {
        DateTime batchProcessingTime = DateTime.now();
        ReportingDataBuilder reportingDataBuilder = new ReportingDataBuilder();
        for (FiaCase fiaCase : keyToFiaCase.values()) {
            Integer messageAge = fiaCase.getMessageAge(batchProcessingTime);
            if (messageAge > AGE_THRESHOLD_MINUTES) {
                reportingDataBuilder.logTimeDeviation('pia.ia-sak-v1', fiaCase.key, messageAge);
            }
        }
        reportingDataBuilder.saveReportingDataEntries();
    }
}
