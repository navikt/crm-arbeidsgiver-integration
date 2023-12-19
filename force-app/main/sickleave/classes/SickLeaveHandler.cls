public without sharing class SickLeaveHandler extends KafkaMessageProcessor implements IKafkaMessageConsumer {
    private Map<String, SickLeaveModel> keyToSickLeave = new Map<String, SickLeaveModel>();


    public void processMessages(List<KafkaMessage__c> messages) {
        for (KafkaMessage__c msg : messages) {
            try {
                SickLeaveModel sickLeave = (SickLeaveModel) parse(
                    SickLeaveModel.class,
                    msg
                );
                mapSickLeave(sickLeave);
                msg.CRM_Status__c = KafkaMessageService.STATUS_PROCESSED;
            } catch (Exception e) {
                msg.CRM_Status__c = KafkaMessageService.STATUS_ERROR;
                msg.CRM_ErrorMessage__c = e.getMessage() + ' (' + e.getLineNumber() + ')';
                logger.addError();
            }
        }
        convertAndUpsertSickLeave(messages);
        logger.publish();
    }

    private void mapSickLeave(SickLeaveModel sickLeave) {
        String key = sickLeave.key;

        if (!keyToSickLeave.containsKey(key)) {
            keyToSickLeave.put(key, sickLeave);
        }
    }

    private void convertAndUpsertSickLeave(List<KafkaMessage__c> messages) {
        List<Absence__c> absences = new List<Absence__c>();
        try {
            absences = toSObject();

            Schema.SObjectField f = Absence__c.Fields.CRM_Key__c;
            Database.UpsertResult [] cr = Database.upsert(absences , f, false);

        } catch (Exception e) {
            String errorRef = logger.logError(e.getMessage() + '/n' + e.getStackTraceString());
            logger.setMessageErrors(messages, errorRef);
            }
        }

    private List<Absence__c> toSObject() {
        List<Absence__c> absences = new List<Absence__c>();

        for (SickLeaveModel model : keyToSickLeave.values()) {
            Absence__c a = new Absence__c(
                CRM_Key__c = model.key,
                CRM_AbsenceCategory__c = model.kategori,
                CRM_Code__c = model.kode,
                CRM_Year__c = model.sistePubliserteKvartal.arstall,
                CRM_Quarter__c = model.sistePubliserteKvartal.kvartal,
                CRM_Percent__c = model.sistePubliserteKvartal.prosent,
                CRM_LostDaysWork__c = model.sistePubliserteKvartal.tapteDagsverk,
                CRM_PossibleDaysWork__c = model.sistePubliserteKvartal.muligeDagsverk,
                CRM_NumberOfPeople__c = model.sistePubliserteKvartal.antallPersoner,
                CRM_IsHidden__c = model.sistePubliserteKvartal.erMaskert,
                CRM_Last4QuartersPercent__c = model.siste4Kvartal.prosent,
                CRM_Last4QuartersLostDaysWork__c = model.siste4Kvartal.tapteDagsverk,
                CRM_Last4QuartersPossibleDaysWork__c = model.siste4Kvartal.muligeDagsverk,
                CRM_Last4QuartersIsHidden__c = model.siste4Kvartal.erMaskert,
                JsonPayload__c = model.jsonPayload

            );

            absences.add(a);
        }
        return absences;
    }
}