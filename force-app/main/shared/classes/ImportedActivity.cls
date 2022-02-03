public inherited sharing abstract class ImportedActivity {
    public Map<String, ArenaActivity__c> keyToExistingActivity;
    public Set<String> orgNumbers;

    public ImportedActivity() {
        this.keyToExistingActivity = new Map<String, ArenaActivity__c>();
        this.orgNumbers = new Set<String>();
    }

    public void addOrgNumber(String orgNumber) {
        if (orgNumber != null) {
            orgNumbers.add(orgNumber);
        }
    }

    public Boolean isMostRecent(String newLastChanged, String oldLastChanged) {
        return dateTimeValue(newLastChanged) > dateTimeValue(oldLastChanged);
    }

    public Boolean isNewOrChanged(String kafkaId, String kafkaHash) {
        if (!keyToExistingActivity.containsKey(kafkaId)) {
            return true;
        }
        return keyToExistingActivity.get(kafkaId).KafkaHash__c != kafkaHash;
    }

    public DateTime dateTimeValue(String timeDate) {
        String formattedDateTime = timeDate.replaceAll('T', ' ');

        return DateTime.valueOf(formattedDateTime);
    }

    public Map<String, ArenaActivity__c> getExistingActivities(Set<String> kafkaIds) {
        for (ArenaActivity__c aa : [
            SELECT KafkaHash__c, KafkaId__c
            FROM ArenaActivity__c
            WHERE KafkaId__c IN :kafkaIds
        ]) {
            keyToExistingActivity.put(aa.KafkaId__c, aa);
        }
        return keyToExistingActivity;
    }

    public Map<String, Account> getOrgNumberAccountMap(Set<String> orgNumbers) {
        List<Account> accounts = [
            SELECT Id, Name, INT_OrganizationNumber__c, INT_MunicipalityNumber__c
            FROM Account
            WHERE INT_OrganizationNumber__c IN :orgNumbers AND IsPersonAccount = FALSE
        ];

        Map<String, Account> accountMap = new Map<String, Account>();

        for (Account acc : accounts) {
            accountMap.put(acc.INT_OrganizationNumber__c, acc);
        }
        return accountMap;
    }
}
