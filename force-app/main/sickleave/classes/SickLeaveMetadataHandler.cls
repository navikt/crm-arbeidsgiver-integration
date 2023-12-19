public without sharing class SickLeaveMetadataHandler extends KafkaMessageProcessor implements IKafkaMessageConsumer {
    private Map<String, SickLeaveMetadataModel> keyToSickLeave = new Map<String, SickLeaveMetadataModel>();
    private Integer Year;
    private Integer Quarter;

    public void processMessages(List<KafkaMessage__c> messages) {
        for (KafkaMessage__c msg : messages) {
            try {
                SickLeaveMetadataModel sickLeave = (SickLeaveMetadataModel) parse(
                    SickLeaveMetadataModel.class,
                    msg
                );
                mapSickLeave(sickLeave);
                if(Year == null || Quarter == null) {
                    Year = Integer.valueOf(sickLeave.arstall);
                    Quarter = Integer.valueOf(sickLeave.kvartal);
                }
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

   private void mapSickLeave(SickLeaveMetadataModel sickLeave) {
        String key = sickLeave.key;

        if (!keyToSickLeave.containsKey(key)) {
            keyToSickLeave.put(key, sickLeave);
        }
    }

   private void convertAndUpsertSickLeave(List<KafkaMessage__c> messages) {
    try {
        List<Absence__c> absences = toSObject();

        Schema.SObjectField f = Absence__c.Fields.CRM_Key__c;
        Database.UpsertResult [] cr = Database.upsert(absences , f, false);

    } catch (Exception e) {
        String errorRef = logger.logError(e.getMessage() + '/n' + e.getStackTraceString());
        logger.setMessageErrors(messages, errorRef);
        }
    }

    private List<Absence__c> toSObject() {
        Map<String, Absence__c> industryCodeMap = getIndustryCodeAbsenceMap();
        Map<String, Absence__c> industryMainMap = getIndustryMainAbsenceMap();
        Map<String, Absence__c> branchMap = getBranchCodeAbsenceMap();
        Map<String, Absence__c> sectorMap = getSectorCodeAbsenceMap();
        Id absenceCountryId = getCountryId();

        List<Absence__c> absences = new List<Absence__c>();

        for (SickLeaveMetadataModel model : keyToSickLeave.values()) {

            Absence__c a = new Absence__c(
                CRM_Key__c = model.orgnr + model.arstall + model.kvartal,
                CRM_AbsenceCategory__c = 'VIRKSOMHET',
                CRM_Year__c = integer.valueOf(model.arstall),
                CRM_Quarter__c = integer.valueOf(model.kvartal),
                CRM_OrganizationNumber__c = model.orgnr,
                CRM_IndustryCode__c = model.naringskode,
                CRM_IndustryMainCode__c = model.naring,
                CRM_BranchCode__c = model.bransje,
                CRM_SectorCode__c = model.sektor,
                JsonPayload__c = model.jsonPayload
            );

            if (absenceCountryId != null) {
                a.CRM_AbsenceCountry__c = absenceCountryId;
            }

            if (industryCodeMap.containsKey(model.naringskode)) {
                a.CRM_AbsenceIndustryCode__c = industryCodeMap.get(model.naringskode).Id;
            }

            if (!industryMainMap.isEmpty() && industryMainMap.containsKey(model.naring)) {
                a.CRM_AbsenceIndustry__c = industryMainMap.get(model.naring).Id;
            }

            if (!branchMap.isEmpty() && branchMap.containsKey(model.bransje)) {
                a.CRM_AbsenceBranch__c = branchMap.get(model.bransje).Id;
            }

            if (!sectorMap.isEmpty() && sectorMap.containsKey(model.sektor)) {
                a.CRM_AbsenceSector__c = sectorMap.get(model.sektor).Id;
            } 

            absences.add(a);
        }
        return absences;
    }

    private Map<String, Absence__c> getIndustryCodeAbsenceMap() {
        Map<String, Absence__c> industryCodeMap = new Map<String, Absence__c>();
        List<Absence__c> absences = [
            SELECT Id, CRM_Year__c, CRM_Quarter__c, CRM_Code__c, CRM_AbsenceCategory__c
            FROM Absence__c
            WHERE CRM_AbsenceCategory__c = 'NÆRINGSKODE' AND CRM_Year__c = :Year AND CRM_Quarter__c = :Quarter 
        ];
        if(absences.size() >0) {
            for (Absence__c a : absences) {
                industryCodeMap.put(a.CRM_Code__c, a);
            }
        }
        return industryCodeMap;
    }

    private Map<String, Absence__c> getIndustryMainAbsenceMap() {
        Map<String, Absence__c> industryMainMap = new Map<String, Absence__c>();
        List<Absence__c> absences = [
            SELECT Id, CRM_Year__c, CRM_Quarter__c, CRM_Code__c, CRM_AbsenceCategory__c
            FROM Absence__c
            WHERE CRM_AbsenceCategory__c = 'NÆRING' AND CRM_Year__c = :Year AND CRM_Quarter__c = :Quarter 
        ];

        if(absences.size() >0) {
            for (Absence__c a : absences) {
                industryMainMap.put(a.CRM_Code__c, a);
            }
        }
        return industryMainMap;
    }

    private Map<String, Absence__c> getBranchCodeAbsenceMap() {
        Map<String, Absence__c> branchMap = new Map<String, Absence__c>();
        List<Absence__c> absences = [
            SELECT Id, CRM_Year__c, CRM_Quarter__c, CRM_Code__c, CRM_AbsenceCategory__c
            FROM Absence__c
            WHERE CRM_AbsenceCategory__c = 'BRANSJE' AND CRM_Year__c = :Year AND CRM_Quarter__c = :Quarter 
        ];
        if(absences.size() >0) {
            for (Absence__c a : absences) {
                branchMap.put(a.CRM_Code__c, a);
            }
        }
        return branchMap;
    }

    private Map<String, Absence__c> getSectorCodeAbsenceMap() {
        Map<String, Absence__c> sectorhMap = new Map<String, Absence__c>();
        List<Absence__c> absences = [
            SELECT Id, CRM_Year__c, CRM_Quarter__c, CRM_Code__c, CRM_AbsenceCategory__c
            FROM Absence__c
            WHERE CRM_AbsenceCategory__c = 'SEKTOR' AND CRM_Year__c = :Year AND CRM_Quarter__c = :Quarter 
        ];
        if(absences.size() >0) {
            for (Absence__c a : absences) {
                sectorhMap.put(a.CRM_Code__c, a);
            }
        }
        return sectorhMap;
    }

    private Id getCountryId() {
        Id absenceCountryId;
        List<Absence__c> absences = [
            SELECT Id, CRM_Year__c, CRM_Quarter__c, CRM_AbsenceCategory__c
            FROM Absence__c
            WHERE CRM_AbsenceCategory__c = 'LAND' AND CRM_Year__c = :Year AND CRM_Quarter__c = :Quarter 
        ];
        if(absences.size() > 0) {
            absenceCountryId = absences[0].Id;
        }
        return absenceCountryId;
    }
}