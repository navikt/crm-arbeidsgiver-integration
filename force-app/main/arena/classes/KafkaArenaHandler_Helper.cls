public inherited sharing class KafkaArenaHandler_Helper {
    public static List<KafkaArenaHandler_Model> convertKafkaToArenaModel(List<KafkaMessage__c> messages) {
        List<KafkaArenaHandler_Model> arenaModels = new List<KafkaArenaHandler_Model>();
        for (KafkaMessage__c msg : messages) {
            try {
                String decodedValue = KafkaMessageUtils.base64ULSafeDecode(msg.CRM_Value__c).toString();
                KafkaArenaHandler_Model arenaModel = KafkaArenaHandler_Model.parse(
                    decodedValue,
                    msg.CRM_Key__c,
                    msg.CRM_Value__c
                );
                arenaModels.add(arenaModel);
                msg.CRM_Status__c = KafkaMessageService.STATUS_PROCESSED;
            } catch (Exception e) {
                msg.CRM_Status__c = KafkaMessageService.STATUS_ERROR;
                msg.CRM_ErrorMessage__c = e.getMessage() + ' (' + e.getLineNumber() + ')';
            }
        }

        return arenaModels;
    }

    public static List<String> getOrgNumbers(List<KafkaArenaHandler_Model> models) {
        List<String> orgNumbers = new List<String>();
        for (KafkaArenaHandler_Model model : models) {
            orgNumbers.add(String.valueOf(model.bedriftsnr));
        }

        return orgNumbers;
    }

    public static Set<String> getKafkaIds(List<KafkaArenaHandler_Model> models) {
        Set<String> kafkaIds = new Set<String>();
        for (KafkaArenaHandler_Model model : models) {
            kafkaIds.add(model.key);
        }

        return kafkaIds;
    }

    public static Map<String, ArenaActivity__c> getArenaActivity(Set<String> kafkaIds) {
        Map<String, ArenaActivity__c> aaMap = new Map<String, ArenaActivity__c>();
        List<ArenaActivity__c> arenaActivities = [
            SELECT KafkaId__c
            FROM ArenaActivity__c
            WHERE KafkaId__c IN :kafkaIds
        ];
        for (ArenaActivity__c aa : arenaActivities) {
            aaMap.put(aa.KafkaId__c, aa);
        }

        return aaMap;
    }

    public static List<ArenaActivity__c> convertArenaModelToSObject(
        List<KafkaArenaHandler_Model> models,
        Map<String, Account> accountMap,
        Map<String, ArenaActivity__c> existingActivities
    ) {
        List<ArenaActivity__c> arenaActivities = new List<ArenaActivity__c>();

        for (KafkaArenaHandler_Model model : models) {
            ArenaActivity__c aa = new ArenaActivity__c(
                AktivitetstypeBeskrivelse__c = model.AktivitetstypeBeskrivelse,
                Aktivitetsgruppekode__c = model.Aktivitetsgruppekode,
                AktivitetStatuskode__c = model.AktivitetStatuskode,
                AktivitetsKode__c = model.AktivitetsKode,
                Aktivitetstype__c = model.aktivitetstypenavn,
                DateRegistered__c = stringToDate(model.regDato),
                Description__c = model.beskrivelse,
                DateFrom__c = stringToDate(model.fraDato),
                DateTo__c = stringToDate(model.tilDato),
                KafkaId__c = model.key,
                RegisteredByNavIdent__c = model.regUser,
                CaseWorkerNavIdent__c = model.saksbehandler,
                TAG_Source__c = 'Arena' //,
                // TimeStampFromMessage__c = extractMessageTimeStampFromKey(model.key)
            );

            if (model.etternavn != null) {
                aa.CaseWorkerName__c = model.fornavn + ' ' + model.etternavn;
            }

            aa.Account__c = accountMap.containsKey(String.valueOf(model.bedriftsnr))
                ? accountMap.get(String.valueOf(model.bedriftsnr)).Id
                : null;

            arenaActivities.add(aa);
        }

        return arenaActivities;
    }

    public static List<ArenaActivity__c> removeDuplicates(List<ArenaActivity__c> arenaActivities) {
        Map<String, ArenaActivity__c> arenaMap = new Map<String, ArenaActivity__c>();

        for (ArenaActivity__c aa : arenaActivities) {
            if (arenaMap.containsKey(aa.KafkaId__c)) {
                // remove the first record as the last most likely is newer (not guaranteed)
                // no date updated field to be sure
                arenaMap.remove(aa.KafkaId__c);
            }

            // add the record to map
            // either it wasn't in the map or if it was, it was removed
            arenaMap.put(aa.KafkaId__c, aa);
        }

        return arenaMap.values();
    }

    public static Date stringToDate(String dateString) {
        if (dateString == null)
            return null;
        try {
            Date d = Date.valueOf(dateString.replace('T', ' '));

            if (d.year() < 1700 || d.year() > 4000) {
                return null;
            }
            return d;
        } catch (TypeException e) {
            return null;
        }
    }

    // Extract DateTime from key
    public static DateTime extractMessageTimeStampFromKey(String key) {
        // Verify that key looks like a datetime
        if (key == null || key.length() != 26) {
            return null;
        }
        DateTime dt = SharedIntegrationFunctions.convertNorwegianTimeToGmt(key);
        return dt;
    }
}
