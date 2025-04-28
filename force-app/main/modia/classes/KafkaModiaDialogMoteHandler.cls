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
                addNavUnit(dialogMote?.enhetNr);
                addNavIdent(dialogMote?.navIdent);
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
            List<DialogueMeeting__c> dmactivities = toSObject();

            Schema.SObjectField f = DialogueMeeting__c.Fields.KafkaId__c;
            Database.UpsertResult[] upsertResults = Database.upsert(dmactivities, f, false);
            Map<String, KafkaMessage__c> messageMap = new Map<String, KafkaMessage__c>();

            for (KafkaMessage__c message : messages) {
                messageMap.put(message.CRM_Key__c, message);
            }

            for (Integer i = 0; i < upsertResults.size(); i++) {
                if (!upsertResults[i].isSuccess()) {
                    Database.Error error = upsertResults[i].getErrors()[0];
                    String errorMessage = error.getMessage();
                    String errorRef = logger.logError(errorMessage);
                    KafkaMessage__c failedMessage = messageMap.get(dmactivities[i].KafkaId__c);
                    logger.setMessageErrors(new List<KafkaMessage__c>{ failedMessage }, errorRef);
                }
            }
        } catch (Exception e) {
            String errorRef = logger.logError(e.getMessage() + '/n' + e.getStackTraceString());
            logger.setMessageErrors(messages, errorRef);
        }
    }

    private List<DialogueMeeting__c> toSObject() {
        Map<String, String> lastSaved = getLastSaved(DialogueMeeting__c.class, keyToDialogMote.keyset());
        Map<String, Account> accountMap = getOrgNumberAccountMap();
        Map<String, NavUnit__c> navUnitMap = getNavUnitsMap();
        Map<String, User> navIdentMap = getNavIdentMapWithProfile();
        List<DialogueMeeting__c> activities = new List<DialogueMeeting__c>();

        for (KafkaModiaDialogMote_Model model : keyToDialogMote.values()) {
            if (!isNewOrChanged(model.key, model.hash, lastSaved)) {
                continue;
            }

            DialogueMeeting__c dm = new DialogueMeeting__c(
                Name = 'Dialogmøte ' + model.dialogmoteTidspunkt.substring(0, 10),
                DialogueMeetingId__c = model.dialogmoteUuid,
                MeetingTime__c = dateTimeValue(model.dialogmoteTidspunkt),
                StatusChangeTime__c = dateTimeValue(model.statusEndringTidspunkt),
                CaseStartDate__c = dateTimeValue(model.tilfelleStartdato),
                UserNavIdent__c = model.navIdent,
                IsEmployeeParticipating__c = model.arbeidstaker,
                IsEmployerParticipating__c = model.arbeidsgiver,
                IsSickLeaveIssuerParticipating__c = model.sykmelder,
                KafkaId__c = model.key
            );

            if (model.statusEndringType != 'NYTT_TID_STED') {
                dm.Status__c = model.statusEndringType;
            }

            if (accountMap.containsKey(model.virksomhetsnummer)) {
                dm.Account__c = accountMap.get(model.virksomhetsnummer).Id;
            }

            if (navUnitMap.containsKey(model.enhetNr)) {
                dm.NavUnit__c = navUnitMap.get(model.enhetNr).Id;
            }

            if (navIdentMap.containsKey(model.navIdent)) {
                User us = navIdentMap.get(model.navIdent);
                dm.OwnerId = us.id;
            }

            activities.add(dm);
        }
        return activities;
    }

    public Map<String, User> getNavIdentMapWithProfile() {
        Map<String, User> navIdentMap = new Map<String, User>();
        List<User> users = [
            SELECT Id, firstName, lastName, CRM_NAV_Ident__c, ProfileId
            FROM User
            WHERE IsActive = TRUE AND Profile.Name = 'NAV Kontor' AND CRM_NAV_Ident__c IN :navIdents
        ];

        for (User u : users) {
            navIdentMap.put(u.CRM_NAV_Ident__c, u);
        }
        return navIdentMap;
    }
}
