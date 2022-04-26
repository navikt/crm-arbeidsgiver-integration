public without sharing class KafkaModiaDialogMoteHandler extends KafkaMessageProcessor implements IKafkaMessageConsumer {
    Map<String, KafkaModiaDialogMote_Model> keyToDialogMote = new Map<String, KafkaModiaDialogMote_Model>();

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
            }
        }

        convertAndUpsertDialogMote(messages);
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
            upsert arenaActivities ArenaActivity__c.KafkaId__c;
        } catch (Exception e) {
            String errorRef = logError(e.getMessage() + '/n' + e.getStackTraceString());
            setMessageErrors(messages, errorRef);
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
                KafkaId__c = model.key
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
