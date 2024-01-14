public without sharing class SickLeaveMetadataHandler extends KafkaMessageProcessor implements IKafkaMessageConsumer {
    private Map<String, SickLeaveMetadataModel> keyToSickLeave = new Map<String, SickLeaveMetadataModel>();
    private Set<Integer> Years = new Set<Integer>();
    private Set<Integer> Quarters = new Set<Integer>();

    public void processMessages(List<KafkaMessage__c> messages) {
        for (KafkaMessage__c msg : messages) {
            try {
                SickLeaveMetadataModel sickLeave = (SickLeaveMetadataModel) parse(
                    SickLeaveMetadataModel.class,
                    msg
                );
                mapSickLeave(sickLeave);
                Years.add(Integer.valueOf(sickLeave.arstall));
                Quarters.add(Integer.valueOf(sickLeave.kvartal));
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
        Map<String, Absence__c> landMap = getCountryId();

        List<Absence__c> absences = new List<Absence__c>();

        for (SickLeaveMetadataModel model : keyToSickLeave.values()) {

            Absence__c a = new Absence__c(
                CRM_Key__c = model.orgnr + model.arstall + model.kvartal,
                CRM_AbsenceCategory__c = 'VIRKSOMHET',
                CRM_Year__c = integer.valueOf(model.arstall),
                CRM_Quarter__c = integer.valueOf(model.kvartal),
                CRM_OrganizationNumber__c = model.orgnr,
                CRM_IndustryCode__c = model?.naringskode,
                CRM_IndustryMainCode__c = model?.naring,
                CRM_BranchCode__c = model?.bransje,
                CRM_SectorCode__c = model?.sektor,
                JsonPayload__c = model.jsonPayload
            );
            if (!landMap.isEmpty() && landMap.containsKey(model.arstall + model.kvartal)) {
                a.CRM_AbsenceCountry__c = landMap.get(model.arstall + model.kvartal).Id;
            }

            if (!industryCodeMap.isEmpty() && industryCodeMap.containsKey(model.naringskode + model.arstall + model.kvartal)) {
                a.CRM_AbsenceIndustryCode__c = industryCodeMap.get(model.naringskode + model.arstall + model.kvartal).Id;
            }

            if (!industryMainMap.isEmpty() && industryMainMap.containsKey(model.naring + model.arstall + model.kvartal)) {
                a.CRM_AbsenceIndustry__c = industryMainMap.get(model.naring + model.arstall + model.kvartal).Id;
            }

            if (!branchMap.isEmpty() && branchMap.containsKey(model.bransje + model.arstall + model.kvartal)) {
                a.CRM_AbsenceBranch__c = branchMap.get(model.bransje + model.arstall + model.kvartal).Id;
            }

            if (!sectorMap.isEmpty() && sectorMap.containsKey(model.sektor + model.arstall + model.kvartal)) {
                a.CRM_AbsenceSector__c = sectorMap.get(model.sektor + model.arstall + model.kvartal).Id;
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
            WHERE CRM_AbsenceCategory__c = 'NÆRINGSKODE' AND CRM_Year__c IN :Years AND CRM_Quarter__c IN :Quarters 
        ];
        if(absences.size() >0) {
            for (Absence__c a : absences) {
                industryCodeMap.put(a.CRM_Code__c + string.valueOf(a.CRM_Year__c) + string.valueOf(a.CRM_Quarter__c), a);
            }
        }
        return industryCodeMap;
    }

    private Map<String, Absence__c> getIndustryMainAbsenceMap() {
        Map<String, Absence__c> industryMainMap = new Map<String, Absence__c>();
        List<Absence__c> absences = [
            SELECT Id, CRM_Year__c, CRM_Quarter__c, CRM_Code__c, CRM_AbsenceCategory__c
            FROM Absence__c
            WHERE CRM_AbsenceCategory__c = 'NÆRING' AND CRM_Year__c IN :Years AND CRM_Quarter__c IN :Quarters 
        ];

        if(absences.size() >0) {
            for (Absence__c a : absences) {
                industryMainMap.put(a.CRM_Code__c + string.valueOf(a.CRM_Year__c) + string.valueOf(a.CRM_Quarter__c), a);
            }
        }
        return industryMainMap;
    }

    private Map<String, Absence__c> getBranchCodeAbsenceMap() {
        Map<String, Absence__c> branchMap = new Map<String, Absence__c>();
        List<Absence__c> absences = [
            SELECT Id, CRM_Year__c, CRM_Quarter__c, CRM_Code__c, CRM_AbsenceCategory__c
            FROM Absence__c
            WHERE CRM_AbsenceCategory__c = 'BRANSJE' AND CRM_Year__c IN :Years AND CRM_Quarter__c IN :Quarters 
        ];
        if(absences.size() >0) {
            for (Absence__c a : absences) {
                branchMap.put(a.CRM_Code__c + string.valueOf(a.CRM_Year__c) + string.valueOf(a.CRM_Quarter__c), a);
            }
        }
        return branchMap;
    }

    private Map<String, Absence__c> getSectorCodeAbsenceMap() {
        Map<String, Absence__c> sectorMap = new Map<String, Absence__c>();
        List<Absence__c> absences = [
            SELECT Id, CRM_Year__c, CRM_Quarter__c, CRM_Code__c, CRM_AbsenceCategory__c
            FROM Absence__c
            WHERE CRM_AbsenceCategory__c = 'SEKTOR' AND CRM_Year__c IN :Years AND CRM_Quarter__c IN :Quarters 
        ];
        if(absences.size() >0) {
            for (Absence__c a : absences) {
                sectorMap.put(a.CRM_Code__c + string.valueOf(a.CRM_Year__c) + string.valueOf(a.CRM_Quarter__c), a);
            }
        }
        return sectorMap;
    }

    private Map<String, Absence__c> getCountryId() {
        Map<String, Absence__c> landMap = new Map<String, Absence__c>();
        List<Absence__c> absences = [
            SELECT Id, CRM_Year__c, CRM_Quarter__c, CRM_AbsenceCategory__c, CRM_YearQuarter__c
            FROM Absence__c
            WHERE CRM_AbsenceCategory__c = 'LAND' AND CRM_Year__c IN :Years AND CRM_Quarter__c IN :Quarters 
        ];
        if(absences.size() > 0) {
            for (Absence__c a : absences) {
            landMap.put(string.valueOf(a.CRM_Year__c) + string.valueOf(a.CRM_Quarter__c), a);
            }
        }
        return landMap;
    }
}