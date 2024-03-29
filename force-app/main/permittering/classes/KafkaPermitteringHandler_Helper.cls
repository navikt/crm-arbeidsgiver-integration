public inherited sharing class KafkaPermitteringHandler_Helper {
    public static List<KafkaPermitteringHandler_Model> convertKafkaToPermittering(List<KafkaMessage__c> messages) {
        List<KafkaPermitteringHandler_Model> permitteringer = new List<KafkaPermitteringHandler_Model>();
        for (KafkaMessage__c msg : messages) {
            try {
                msg.CRM_Status__c = KafkaMessageService.STATUS_PROCESSED;
                String decodedValue = KafkaMessageUtils.base64ULSafeDecode(msg.CRM_Value__c).toString();
                KafkaPermitteringHandler_Model p = KafkaPermitteringHandler_Model.parse(decodedValue);
                permitteringer.add(p);
            } catch (Exception e) {
                msg.CRM_Status__c = KafkaMessageService.STATUS_ERROR;
                msg.CRM_ErrorMessage__c = e.getMessage() + ' (' + e.getLineNumber() + ')';
            }
        }

        return permitteringer;
    }

    public static List<String> getOrgNumbersFromPermittering(List<KafkaPermitteringHandler_Model> permitteringer) {
        List<String> organisationNumbers = new List<String>();
        for (KafkaPermitteringHandler_Model p : permitteringer) {
            organisationNumbers.add(p.bedriftsnummer);
        }

        return organisationNumbers;
    }

    public static List<SharedFunctions_ContactModel> convertPermitteringToContactWrapper(
        List<KafkaPermitteringHandler_Model> permitteringer
    ) {
        List<SharedFunctions_ContactModel> wrapperList = new List<SharedFunctions_ContactModel>();

        for (KafkaPermitteringHandler_Model p : permitteringer) {
            List<String> name = p.kontaktNavn.split(' ');
            String lastName = name[name.size() - 1];
            String firstName = p.kontaktNavn.removeEnd(' ' + lastName);
            SharedFunctions_ContactModel wrapper = new SharedFunctions_ContactModel();
            wrapper.firstName = firstName.left(39);
            wrapper.lastName = lastName;
            wrapper.phone = p.kontaktTlf;
            wrapper.email = p.kontaktEpost;
            wrapper.source = 'Permittering';
            wrapper.companyNumber = p.bedriftsnummer;
            wrapperList.add(wrapper);
        }

        return wrapperList;
    }

    public static List<TemporaryLayoff__c> convertPermitteringToLayoff(
        List<KafkaPermitteringHandler_Model> permitteringer,
        Map<String, Account> accountMap,
        Map<String, Contact> contactMap
    ) {
        List<TemporaryLayoff__c> layoffs = new List<TemporaryLayoff__c>();
        for (KafkaPermitteringHandler_Model p : permitteringer) {
            layoffs.add(jsonToTemporaryLayoff(p, accountMap, contactMap));
        }

        return layoffs;
    }

    public static TemporaryLayoff__c jsonToTemporaryLayoff(
        KafkaPermitteringHandler_Model p,
        Map<String, Account> accountMap,
        Map<String, Contact> contactMap
    ) {
        TemporaryLayoff__c tl = new TemporaryLayoff__c();
        if (accountMap.containsKey(p.bedriftsnummer)) {
            tl.Account__c = accountMap.get(p.bedriftsnummer).Id;
        }
        if (contactMap.containsKey(p.kontaktEpost.toLowerCase())) {
            tl.Contact__c = contactMap.get(p.kontaktEpost.toLowerCase()).Id;
        }

        tl.JsonPayload__c = p.jsonPayload;
        tl.KafkaId__c = p.id;
        tl.NumberOfEmployees__c = p.antallBerorte;
        tl.Type__c = p.type;
        tl.ContactEmail__c = SharedFunctions_FetchOrCreateContact.checkIfValidEmail(p.kontaktEpost)
            ? p.kontaktEpost
            : null;
        tl.StartDate__c = p.startDato;
        tl.EndDate__c = p.sluttDato;
        tl.OtherComments__c = p.fritekst;

        List<String> professions = new List<String>();
        if (p.yrkeskategorier != null) {
            for (KafkaPermitteringHandler_Model.Yrkeskategorier profession : p.yrkeskategorier) {
                professions.add(profession.label);
            }
        }

        if (p.fritekst.contains('### Annet')) {
            List<String> otherComments = p.fritekst.split('### Annet\\n');
            if (otherComments.size() == 2) {
                tl.OtherField__c = otherComments[1];
            }
        }

        tl.Profession__c = String.join(professions, ';');
        tl.Reason__c = p.arsakskode;
        tl.ReasonOther__c = p.arsakstekst;

        return tl;
    }

    public static List<TemporaryLayoff__c> removeExistingTempLayoffs(List<TemporaryLayoff__c> layoffs) {
        Set<String> uuids = new Set<String>();

        for (TemporaryLayoff__c layoff : layoffs) {
            uuids.add(layoff.KafkaId__c);
        }

        Set<String> existingLayoffUuids = new Set<String>();
        for (TemporaryLayoff__c layoff : [SELECT Id, KafkaId__c FROM TemporaryLayoff__c WHERE KafkaId__c IN :uuids]) {
            existingLayoffUuids.add(layoff.KafkaId__c);
        }

        List<TemporaryLayoff__c> filteredLayoffs = new List<TemporaryLayoff__c>();
        for (TemporaryLayoff__c layoff : layoffs) {
            if (!existingLayoffUuids.contains(layoff.KafkaId__c)) {
                filteredLayoffs.add(layoff);
            }
        }

        return filteredLayoffs;
    }

    public static List<TemporaryLayoff__c> removeDuplicateTempLayoffsInList(List<TemporaryLayoff__c> layoffs) {
        Map<String, TemporaryLayoff__c> layoffMap = new Map<String, TemporaryLayoff__c>();
        for (TemporaryLayoff__c layoff : layoffs) {
            if (!layoffMap.containsKey(layoff.KafkaId__c)) {
                layoffMap.put(layoff.KafkaId__c, layoff);
            }
        }

        return layoffMap.values();
    }
}
