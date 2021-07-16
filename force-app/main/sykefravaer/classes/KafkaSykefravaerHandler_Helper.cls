public with sharing class KafkaSykefravaerHandler_Helper {
    public static List<KafkaSykefravaerHandler_Model> convertKafkaToSykefravaer(List<KafkaMessage__c> messages) {
        List<KafkaSykefravaerHandler_Model> sykefravaer = new List<KafkaSykefravaerHandler_Model>();
        for (KafkaMessage__c msg : messages) {
            try {
                msg.CRM_Status__c = 'Processed';
                String decodedValue = KafkaMessageUtils.base64ULSafeDecode(msg.CRM_Value__c).toString();
                KafkaSykefravaerHandler_Model s = KafkaSykefravaerHandler_Model.parse(decodedValue, msg.CRM_Key__c);
                sykefravaer.add(s);
            } catch (Exception e) {
                msg.CRM_ErrorMessage__c = e.getMessage() + ' (' + e.getLineNumber() + ')';
            }
        }
        return sykefravaer;
    }

    public static List<String> getOrgNumbersFromSykefravaer(List<KafkaSykefravaerHandler_Model> sykefravaer) {
        List<String> organisationNumbers = new List<String>();
        for (KafkaSykefravaerHandler_Model s : sykefravaer) {
            organisationNumbers.add(s.orgnr);
        }

        return organisationNumbers;
    }

    public static List<Absence__c> convertSykefravaerToAbsence(
        List<KafkaSykefravaerHandler_Model> sykefravaer,
        Map<String, Account> accountMap
    ) {
        List<Absence__c> absence = new List<Absence__c>();
        for (KafkaSykefravaerHandler_Model s : sykefravaer) {
            absence.add(jsonToAbsence(s, accountMap));
        }
        return absence;
    }

    public static Absence__c jsonToAbsence(
        KafkaSykefravaerHandler_Model s,
        Map<String, Account> accountMap
    ) {
        Absence__c a = new Absence__c();
        if (accountMap.containsKey(s.orgnr)) {
            a.CRM_Account__c = accountMap.get(s.orgnr).Id;
            for(KafkaSykefravaerHandler_Model.Naering5Siffer naeringItem: s.naering) {
                if (accountMap.get(s.orgnr).INT_IndustryCode__c != null && naeringItem.kode == accountMap.get(s.orgnr).INT_IndustryCode__c.remove('.')) {
                    a.CRM_Naering5SifferKode__c = naeringItem.kode;
                    a.CRM_NaeringTapteDagsverk__c = naeringItem.tapteDagsverk;
                    a.CRM_NaeringMuligeDagsverk__c = naeringItem.muligeDagsverk;
                    a.CRM_NaeringAntallPersoner__c = naeringItem.antallPersoner;
                    a.CRM_NaeringProsent__c = naeringItem.prosent;
                }
            }
        }
        if (s.antallPersoner >= 5 && s.erMaskert == false) {
            a.CRM_VirksomhetAntallPersoner__c = s.antallPersoner;
        }
        a.JsonPayload__c = s.jsonPayload;
        a.CRM_Key__c = s.key;
        a.CRM_Year__c = s.arstall;
        a.CRM_Quarter__c = s.kvartal;
        a.CRM_ErMaskert__c = s.erMaskert;
        a.CRM_VirksomhetTapteDagsverk__c = s.tapteDagsverk;
        a.CRM_VirksomhetMuligDagsverk__c = s.muligeDagsverk;
        a.CRM_VirksomhetProsent__c = s.prosent;
        a.CRM_SektorKode__c = s.sektor.kode;
        a.CRM_SektorTapteDagsverk__c = s.sektor.tapteDagsverk;
        a.CRM_SektorMuligeDagsverk__c = s.sektor.muligeDagsverk;
        a.CRM_SektorAntallPersoner__c = s.sektor.antallPersoner;
        a.CRM_SektorProsent__c = s.sektor.prosent;
        a.CRM_LandKode__c = s.land.kode;
        a.CRM_LandTapteDagsverk__c = s.land.tapteDagsverk;
        a.CRM_LandMuligeDagsverk__c = s.land.muligeDagsverk;
        a.CRM_LandAntallPersoner__c = s.land.antallPersoner;
        a.CRM_LandProsent__c = s.land.prosent;

        return a;
    }

    public static Map<String, Account> fetchAccounts(List<String> organisationNumbers) {
        List<Account> accounts = [
            SELECT Id, INT_OrganizationNumber__c, INT_MunicipalityNumber__c, INT_IndustryCode__c
            FROM Account
            WHERE
                INT_OrganizationNumber__c IN :organisationNumbers
                AND INT_OrganizationNumber__c != NULL
                AND IsPersonAccount = FALSE
        ];

        Map<String, Account> accountMap = new Map<String, Account>();
        for (Account acc : accounts) {
            accountMap.put(acc.INT_OrganizationNumber__c, acc);
        }

        return accountMap;
    }
}
