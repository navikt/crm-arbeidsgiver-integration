public inherited sharing abstract class KafkaMessageProcessor {
    public static AG_KafkaLogger logger = AG_KafkaLogger.get();
    public Set<String> orgNumbers;
    public Set<String> navIdents;
    public Set<String> navUnits;

    public KafkaMessageProcessor() {
        this.orgNumbers = new Set<String>();
        this.navIdents = new Set<String>();
        this.navUnits = new Set<String>();
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

    public KafkaMessageProcessor addNavIdent(String navIdent) {
        if (navIdent != null) {
            navIdents.add(navIdent);
        }
        return this;
    }

    public KafkaMessageProcessor addNavUnit(String navUnit) {
        if (navUnit != null) {
            navUnits.add(navUnit);
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
        DateTime dtime = DateTime.valueOf(formattedDateTime);

        if (dtime.year() < 1700 || dtime.year() > 4000) {
            return null;
        }

        return dtime;
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

    public Map<String, User> getNavIdentMap() {
        Map<String, User> navIdentMap = new Map<String, User>();
        List<User> users = [
            SELECT Id, firstName, lastName, CRM_NAV_Ident__c
            FROM User
            WHERE CRM_NAV_Ident__c IN :navIdents
        ];

        for (User u : users) {
            navIdentMap.put(u.CRM_NAV_Ident__c, u);
        }
        return navIdentMap;
    }

    public Map<String, NAVUnit__c> getNavUnitsMap() {
        Map<String, NAVUnit__c> navUnitMap = new Map<String, NAVUnit__c>();
        List<NAVUnit__c> navUnits = [
            SELECT Id, Name, CRM_QueueId__c, INT_UnitNumber__c
            FROM NAVUnit__c
            WHERE INT_UnitNumber__c IN :navUnits AND IsDeleted = FALSE
        ];

        for (NAVUnit__c n : navUnits) {
            navUnitMap.put(n.INT_UnitNumber__c, n);
        }
        return navUnitMap;
    }
}
