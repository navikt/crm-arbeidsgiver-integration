public without sharing class KafkaModiaDialogMoteHandler extends KafkaMessageProcessor implements IKafkaMessageConsumer {
    private Map<String, KafkaModiaDialogMote_Model> keyToDialogMote = new Map<String, KafkaModiaDialogMote_Model>();

    public void processMessages(List<KafkaMessage__c> messages) {
        for (KafkaMessage__c msg : messages) {
            try {
                KafkaModiaDialogMote_Model dialogMote = (KafkaModiaDialogMote_Model) parse(
                    KafkaModiaDialogMote_Model.class,
                    msg
                );
                mapDialogMote(dialogMote);
                addOrgNumber(dialogMote?.virksomhetsnummer);
                msg.CRM_Status__c = KafkaMessageService.STATUS_PROCESSED;
            } catch (Exception e) {
                msg.CRM_Status__c = KafkaMessageService.STATUS_ERROR;
                msg.CRM_ErrorMessage__c = e.getMessage() + ' (' + e.getLineNumber() + ')';
                logger.addError();
            }
        }
        convertAndUpsertDialogMote(messages);
        logger.publish();
    }

    private void mapDialogMote(KafkaModiaDialogMote_Model dialogMote) {
        String key = dialogMote.key;

        if (!keyToDialogMote.containsKey(key)) {
            keyToDialogMote.put(key, dialogMote);
        } else if (isMostRecent(dialogMote.statusEndringTidspunkt, keyToDialogMote.get(key).statusEndringTidspunkt)) {
            keyToDialogMote.put(key, dialogMote);
        }
    }

    private void convertAndUpsertDialogMote(List<KafkaMessage__c> messages) {
        try {
            List<ArenaActivity__c> arenaActivities = toSObject();

            Schema.SObjectField f = ArenaActivity__c.Fields.KafkaId__c;
            Database.UpsertResult [] cr = Database.upsert(arenaActivities , f, false);

        } catch (Exception e) {
            String errorRef = logger.logError(e.getMessage() + '/n' + e.getStackTraceString());
            logger.setMessageErrors(messages, errorRef);
        }
    }

    private List<ArenaActivity__c> toSObject() {
        Map<String, String> lastSaved = getLastSaved(ArenaActivity__c.class, keyToDialogMote.keyset());
        Map<String, Account> accountMap = getOrgNumberAccountMap();
        List<ArenaActivity__c> activities = new List<ArenaActivity__c>();

        for (KafkaModiaDialogMote_Model model : keyToDialogMote.values()) {
            if (!isNewOrChanged(model.key, model.hash, lastSaved)) {
                continue;
            }

            ArenaActivity__c aa = new ArenaActivity__c(
                DateRegistered__c = dateTimeValue(model.statusEndringTidspunkt).date(),
                DateFrom__c = dateTimeValue(model.dialogmoteTidspunkt).date(),
                DateTimeRegistered__c = dateTimeValue(model.statusEndringTidspunkt),
                DateTimeFrom__c = dateTimeValue(model.dialogmoteTidspunkt),
                TilfelleStartdato__c = dateTimeValue(model.tilfelleStartdato),
                Aktivitetstype__c = 'Dialogmøte',
                NAVIdent__c = model.navIdent,
                NAVenhet__c = model.enhetNr,
                JsonPayload__c = model.jsonPayload,
                KafkaHash__c = model.hash,
                KafkaId__c = model.key,
                TAG_Source__c = 'Modia'
            );

            if (model.statusEndringType != 'NYTT_TID_STED') {
                aa.AktivitetStatuskode__c = model.statusEndringType;
            }

            if (accountMap.containsKey(model.virksomhetsnummer)) {
                aa.Account__c = accountMap.get(model.virksomhetsnummer).Id;
            }

            activities.add(aa);
        }
        return activities;
    }
}
