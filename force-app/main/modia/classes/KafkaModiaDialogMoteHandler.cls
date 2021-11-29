public without sharing class KafkaModiaDialogMoteHandler extends ImportedActivity implements IKafkaMessageConsumer {
    Map<String, KafkaModiaDialogMote_Model> keyToDialogMote = new Map<String, KafkaModiaDialogMote_Model>();

    public void processMessages(List<KafkaMessage__c> messages) {
        List<ArenaActivity__c> activities = new List<ArenaActivity__c>();

        for (KafkaMessage__c msg : messages) {
            try {
                KafkaModiaDialogMote_Model dialogMote = convertMessageToDialogMote(msg);
                mapDialogMote(dialogMote);
                addOrgNumber(dialogMote?.virksomhetsnummer);
                msg.CRM_Status__c = KafkaMessageService.STATUS_PROCESSED;
            } catch (Exception e) {
                msg.CRM_Status__c = KafkaMessageService.STATUS_ERROR;
                msg.CRM_ErrorMessage__c = e.getMessage() + ' (' + e.getLineNumber() + ')';
            }
        }

        getExistingActivities(keyToDialogMote.keySet());
        activities = toSObject();

        upsert activities ArenaActivity__c.KafkaId__c;
    }

    private KafkaModiaDialogMote_Model convertMessageToDialogMote(KafkaMessage__c message) {
        String decodedValue = KafkaMessageUtils.base64ULSafeDecode(message.CRM_Value__c).toString();
        KafkaModiaDialogMote_Model model = KafkaModiaDialogMote_Model.parse(
            decodedValue,
            message.CRM_Key__c,
            message.CRM_Value__c
        );
        return model;
    }

    private void mapDialogMote(KafkaModiaDialogMote_Model dialogMote) {
        String key = dialogMote.key;

        if (!keyToDialogMote.containsKey(key)) {
            keyToDialogMote.put(key, dialogMote);
        } else if (isMostRecent(dialogMote.statusEndringTidspunkt, keyToDialogMote.get(key).statusEndringTidspunkt)) {
            keyToDialogMote.put(key, dialogMote);
        }
    }

    private List<ArenaActivity__c> toSObject() {
        Map<String, Account> accountMap = getOrgNumberAccountMap(orgNumbers);
        List<ArenaActivity__c> activities = new List<ArenaActivity__c>();

        for (KafkaModiaDialogMote_Model model : keyToDialogMote.values()) {
            if (!isNewOrChanged(model.key, model.hash)) {
                continue;
            }

            ArenaActivity__c aa = new ArenaActivity__c(
                // TODO: updated field mappings
                //DateRegistered__c = dateTimeValue(model.statusEndringTidspunkt),
                //DateFrom__c = dateTimeValue(model.dialogmoteTidspunkt),
                //NAVIdent__c = model.navIdent,
                //NAVenhet__c = model.enhetNr,
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
