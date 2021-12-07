@isTest
public with sharing class ImportedActivity_TEST {
    @isTest
    static void addOrgNumber() {
        ActivityExtension activity = new ActivityExtension();

        activity.addOrgNumber('123456789');
        activity.addOrgNumber('113456789');

        System.assertEquals(2, activity.orgNumbers.size(), 'Org Numbers added');
    }

    @isTest
    static void addOrgNumber_null() {
        ActivityExtension activity = new ActivityExtension();

        activity.addOrgNumber(null);

        System.assertEquals(0, activity.orgNumbers.size(), 'Org Numbers added');
    }

    @isTest
    static void isMostRecent_mostRecent() {
        String newTime = '1970-01-19T18:46:53.748Z';
        String oldTime = '1970-01-19T18:46:52.748Z';

        Boolean mostRecent = new ActivityExtension().isMostRecent(newTime, oldTime);

        System.assertEquals(true, mostRecent, 'New time is most recent');
    }

    @isTest
    static void isMostRecent_notMostRecent() {
        String newTime = '1970-01-19T18:46:52.748Z';
        String oldTime = '1970-01-19T18:46:53.748Z';

        Boolean mostRecent = new ActivityExtension().isMostRecent(newTime, oldTime);

        System.assertEquals(false, mostRecent, 'Old time most recent');
    }

    @isTest
    static void dateTimeValue() {
        DateTime dt = DateTime.newInstance(1970, 1, 19, 18, 46, 52);

        String timeDate = '1970-01-19T18:46:52.748Z';
        Datetime dateTimeValue = new ActivityExtension().dateTimeValue(timeDate);

        System.assertEquals(dt, dateTimeValue, 'Successfull datetime conversion');
    }

    @isTest
    static void dateTimeValue_Ancient() {
        DateTime dt = DateTime.newInstance(1600, 1, 19, 18, 46, 52);

        String timeDate = '1600-01-19T18:46:52.748Z';
        Datetime dateTimeValue = new ActivityExtension().dateTimeValue(timeDate);

        System.assertEquals(dt, dateTimeValue, 'Successfull datetime conversion');
    }

    @isTest
    static void dateTimeValue_Futuristic() {
        DateTime dt = DateTime.newInstance(4500, 1, 19, 18, 46, 52);

        String timeDate = '4500-01-19T18:46:52.748Z';
        Datetime dateTimeValue = new ActivityExtension().dateTimeValue(timeDate);

        System.assertEquals(dt, dateTimeValue, 'Successfull datetime conversion');
    }

    @isTest
    static void isNewOrChanged_noChanges() {
        String json = '{"status": "NY"}';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(json));
        String key = 'a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e';
        ArenaActivity__c aa = new ArenaActivity__c(KafkaId__c = key, KafkaHash__c = encodedValue);

        ActivityExtension activity = new ActivityExtension();
        activity.keyToExistingActivity.put(key, aa);

        Boolean isNewOrChanged = activity.isNewOrChanged(key, encodedValue);

        System.assertEquals(false, isNewOrChanged, 'Hash did not change');
    }

    @isTest
    static void isNewOrChanged_hasChanges() {
        String json1 = '{"status": "NY"}';
        String json2 = '{"status": "AVSLUTTET"}';
        String encodedValue1 = EncodingUtil.base64Encode(Blob.valueOf(json1));
        String encodedValue2 = EncodingUtil.base64Encode(Blob.valueOf(json2));
        String key = 'a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e';

        ArenaActivity__c aa = new ArenaActivity__c(KafkaId__c = key, KafkaHash__c = encodedValue1);

        ActivityExtension activity = new ActivityExtension();
        activity.keyToExistingActivity.put(key, aa);

        Boolean isNewOrChanged = activity.isNewOrChanged(key, encodedValue2);

        System.assertEquals(true, isNewOrChanged, 'Hash changed');
    }

    @isTest
    static void isNewOrChanged_newActivity() {
        String json = '{"status": "NY"}';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(json));
        String key = 'a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e';

        Boolean isNewOrChanged = new ActivityExtension().isNewOrChanged(key, encodedValue);

        System.assertEquals(true, isNewOrChanged, 'Is new. Not included in existing map.');
    }

    @isTest
    static void getOrgNumberAccountMap() {
        Account acc = new Account(Name = 'Test Employer 1', INT_OrganizationNumber__c = '973113631');
        insert acc;

        ActivityExtension activity = new ActivityExtension();
        Map<String, Account> accountMap = activity.getOrgNumberAccountMap(new Set<String>{ '973113631' });

        System.assertEquals(1, accountMap.size(), 'Account added to map');
        System.assertEquals(true, accountMap.containsKey('973113631'));
        System.assertEquals('Test Employer 1', accountMap.get('973113631').Name);
    }

    @isTest
    static void getExistingActivities() {
        String key = 'a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e';
        String json = '{"status": "NY"}';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(json));

        ArenaActivity__c activity = new ArenaActivity__c(KafkaId__c = key, KafkaHash__c = encodedValue);
        insert activity;

        Map<String, ArenaActivity__c> existingActivityMap = new ActivityExtension()
            .getExistingActivities(new Set<String>{ key });

        System.assertEquals(1, existingActivityMap.size(), 'Account added to map');
        System.assertEquals(true, existingActivityMap.containsKey(key));
        System.assertEquals(encodedValue, existingActivityMap.get(key).KafkaHash__c);
    }

    public class ActivityExtension extends ImportedActivity {
    }
}
