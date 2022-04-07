public inherited sharing abstract class KafkaMessageProcessor {
    private static final LoggerUtility logger = new LoggerUtility();
    public Set<String> orgNumbers;

    public KafkaMessageProcessor() {
        orgNumbers = new Set<String>();
    }

    public IKafkaMessageParser parse(Type className, KafkaMessage__c message) {
        String decodedValue = KafkaMessageUtils.base64ULSafeDecode(message.CRM_Value__c).toString();
        IKafkaMessageParser instance = (IKafkaMessageParser) className.newInstance();

        return instance.parse(decodedValue, message.CRM_Key__c, message.CRM_Value__c);
    }

    public KafkaMessageProcessor addOrgNumber(String orgNumber) {
        if (orgNumber != null) {
            orgNumbers.add(orgNumber);
        }
        return this;
    }

    public Boolean isNewOrChanged(String kafkaId, String kafkaHash, Map<String, String> keyToHash) {
        if (!keyToHash.containsKey(kafkaId)) {
            return true;
        }
        return keyToHash.get(kafkaId) != kafkaHash;
    }

    public Boolean isMostRecent(String newLastChanged, String oldLastChanged) {
        return dateTimeValue(newLastChanged) > dateTimeValue(oldLastChanged);
    }

    public DateTime dateTimeValue(String timeDate) {
        String formattedDateTime = timeDate.replaceAll('T', ' ');

        return DateTime.valueOf(formattedDateTime);
    }

    public Map<String, String> getLastSaved(Type className, Set<String> kafkaIds) {
        String query = 'SELECT KafkaHash__c, KafkaId__c FROM ' + className.getName() + ' WHERE KafkaId__c IN: kafkaIds';
        Map<String, String> keyToExistingHash = new Map<String, String>();

        for (SObject obj : Database.query(query)) {
            if (obj.get('KafkaHash__c') != null) {
                keyToExistingHash.put(obj.get('KafkaId__c').toString(), obj.get('KafkaHash__c').toString());
            }
        }

        return keyToExistingHash;
    }

    public Map<String, Account> getOrgNumberAccountMap() {
        Map<String, Account> accountMap = new Map<String, Account>();
        List<Account> accounts = [
            SELECT Id, Name, INT_OrganizationNumber__c, INT_MunicipalityNumber__c
            FROM Account
            WHERE INT_OrganizationNumber__c IN :orgNumbers AND IsPersonAccount = FALSE
        ];

        for (Account a : accounts) {
            accountMap.put(a.INT_OrganizationNumber__c, a);
        }
        return accountMap;
    }

    public String logError(String message) {
        LoggerUtility.LogLevel logLevel = LoggerUtility.LogLevel.Error;
        String errorRef = '';

        logger.logMessage(logLevel, errorRef, null, message, null, null);
        errorRef = logger.peek().UUID__c;
        logger.publish();

        return errorRef;
    }

    public List<KafkaMessage__c> setMessageErrors(List<KafkaMessage__c> messages, String errorRef) {
        for (KafkaMessage__c m : messages) {
            m.CRM_Status__c = KafkaMessageService.STATUS_ERROR;
            m.CRM_ErrorMessage__c = 'Message Processing error. See log with ref: ' + errorRef;
        }
        return messages;
    }
}
