@IsTest
public with sharing class KafkaMessageProcessorTest {
    @isTest
    static void addOrgNumber() {
        KafkaMessageProcessorExtension processor = new KafkaMessageProcessorExtension();

        processor.addOrgNumber('123456789');
        processor.addOrgNumber('113456789');

        System.assertEquals(2, processor.orgNumbers.size(), 'Org Numbers added');
    }

    @isTest
    static void addNavIdent() {
        KafkaMessageProcessorExtension processor = new KafkaMessageProcessorExtension();

        processor.addNavIdent('C112233');
        processor.addNavIdent('B112233');

        System.assertEquals(2, processor.navIdents.size(), 'Nav Idents added');
    }

    @isTest
    static void addNavUnit() {
        KafkaMessageProcessorExtension processor = new KafkaMessageProcessorExtension();

        processor.addNavUnit('0303');
        processor.addNavUnit('0202');

        System.assertEquals(2, processor.navUnits.size(), 'Nav Units added');
    }

    @isTest
    static void addOrgNumber_null() {
        KafkaMessageProcessorExtension processor = new KafkaMessageProcessorExtension();

        processor.addOrgNumber(null);

        System.assertEquals(0, processor.orgNumbers.size(), 'Org Numbers added');
    }

    @isTest
    static void addNavIdent_null() {
        KafkaMessageProcessorExtension processor = new KafkaMessageProcessorExtension();

        processor.addNavIdent(null);

        System.assertEquals(0, processor.navIdents.size(), 'Nav Idents added');
    }

    @isTest
    static void addNavUnit_null() {
        KafkaMessageProcessorExtension processor = new KafkaMessageProcessorExtension();

        processor.addNavUnit(null);

        System.assertEquals(0, processor.navUnits.size(), 'Nav Units added');
    }

    @isTest
    static void isMostRecent_mostRecent() {
        String newTime = '1970-01-19T18:46:53.748Z';
        String oldTime = '1970-01-19T18:46:52.748Z';

        Boolean mostRecent = new KafkaMessageProcessorExtension().isMostRecent(newTime, oldTime);

        System.assertEquals(true, mostRecent, 'New time is most recent');
    }

    @isTest
    static void isMostRecent_notMostRecent() {
        String newTime = '1970-01-19T18:46:52.748Z';
        String oldTime = '1970-01-19T18:46:53.748Z';

        Boolean mostRecent = new KafkaMessageProcessorExtension().isMostRecent(newTime, oldTime);

        System.assertEquals(false, mostRecent, 'Old time most recent');
    }

    @isTest
    static void isMostRecent_invalidFormat() {
        String newTime = '18:46:52.748Z 1970-01-19';
        String oldTime = '1970-01-19T18:46:53.748Z';
        Exception caughtExcepiton;
        try {
            Boolean mostRecent = new KafkaMessageProcessorExtension().isMostRecent(newTime, oldTime);
        } catch (Exception e) {
            caughtExcepiton = e;
        }

        System.assertEquals(TypeException.class.getName(), caughtExcepiton.getTypeName(), 'Correct exception thrown');
    }

    @isTest
    static void dateTimeValue() {
        DateTime dt = DateTime.newInstance(1970, 1, 19, 18, 46, 52);
        String timeDate = '1970-01-19T18:46:52.748Z';
        Datetime dateTimeValue = new KafkaMessageProcessorExtension().dateTimeValue(timeDate);

        System.assertEquals(dt, dateTimeValue, 'Successfull datetime conversion');
    }

    @isTest
    static void dateTimeValue_Ancient() {
        String timeDate = '1600-01-19T18:46:52.748Z';
        Datetime dateTimeValue = new KafkaMessageProcessorExtension().dateTimeValue(timeDate);

        System.assertEquals(null, dateTimeValue, 'Successfull datetime conversion');
    }

    @isTest
    static void dateTimeValue_Futuristic() {
        String timeDate = '4500-01-19T18:46:52.748Z';
        Datetime dateTimeValue = new KafkaMessageProcessorExtension().dateTimeValue(timeDate);

        System.assertEquals(null, dateTimeValue, 'Successfull datetime conversion');
    }

    @isTest
    static void dateTimeValue_invalidFormat() {
        Exception caughtExcepiton;
        try {
            String timeDate = '18:46:52.748Z 1970-01-19';
            Datetime dateTimeValue = new KafkaMessageProcessorExtension().dateTimeValue(timeDate);
        } catch (Exception e) {
            caughtExcepiton = e;
        }

        System.assertEquals(TypeException.class.getName(), caughtExcepiton.getTypeName(), 'Correct exception thrown');
    }

    @isTest
    static void isNewOrChanged_noChanges() {
        String json = '{"status": "NY"}';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(json));
        String key = 'a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e';

        Map<String, String> keyToHash = new Map<String, String>{ key => encodedValue };

        Boolean isNewOrChanged = new KafkaMessageProcessorExtension().isNewOrChanged(key, encodedValue, keyToHash);

        System.assertEquals(false, isNewOrChanged, 'Hash did not change');
    }

    @isTest
    static void isNewOrChanged_hasChanges() {
        String json1 = '{"status": "NY"}';
        String json2 = '{"status": "AVSLUTTET"}';
        String encodedValue1 = EncodingUtil.base64Encode(Blob.valueOf(json1));
        String encodedValue2 = EncodingUtil.base64Encode(Blob.valueOf(json2));
        String key = 'a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e';

        Map<String, String> keyToHash = new Map<String, String>{ key => encodedValue1 };

        Boolean isNewOrChanged = new KafkaMessageProcessorExtension().isNewOrChanged(key, encodedValue2, keyToHash);

        System.assertEquals(true, isNewOrChanged, 'Hash changed');
    }

    @isTest
    static void isNewOrChanged_newActivity() {
        String json = '{"status": "NY"}';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(json));
        String key = 'a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e';

        Map<String, String> keyToHash = new Map<String, String>();

        Boolean isNewOrChanged = new KafkaMessageProcessorExtension().isNewOrChanged(key, encodedValue, keyToHash);

        System.assertEquals(true, isNewOrChanged, 'Is new. Not included in existing map.');
    }

    @isTest
    static void lastSaved_success() {
        String key = 'a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e';
        String json = '{"status": "NY"}';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(json));

        JobPosting__c activity = new JobPosting__c(KafkaId__c = key, KafkaHash__c = encodedValue);
        insert activity;

        Map<String, String> lastSavedMessages = new KafkaMessageProcessorExtension()
            .getLastSaved(JobPosting__c.class, new Set<String>{ key });

        System.assertEquals(1, lastSavedMessages.size(), 'Account added to map');
        System.assertEquals(true, lastSavedMessages.containsKey(key));
        System.assertEquals(encodedValue, lastSavedMessages.get(key));
    }

    @isTest
    static void getOrgNumberAccountMap() {
        Account acc = new Account(Name = 'Test Employer 1', INT_OrganizationNumber__c = '973113631');
        insert acc;

        Map<String, Account> accountMap = new KafkaMessageProcessorExtension()
            .addOrgNumber('973113631')
            .getOrgNumberAccountMap();

        System.assertEquals(1, accountMap.size(), 'Account added to map');
        System.assertEquals(true, accountMap.containsKey(acc.INT_OrganizationNumber__c));
        System.assertEquals(acc.Id, accountMap.get(acc.INT_OrganizationNumber__c).Id);
    }

    @isTest
    static void getNavIdentMap() {
        List<User> us = TestDataFactory.getUsers(1, 'Standard User', false, false);
        us[0].CRM_NAV_Ident__c = 'C112233';
        insert us;

        Map<String, User> navIdentMap = new KafkaMessageProcessorExtension().addNavIdent('C112233').getNavIdentMap();

        System.assertEquals(1, navIdentMap.size(), 'User added to map');
        System.assertEquals(true, navIdentMap.containsKey(us[0].CRM_NAV_Ident__c));
        System.assertEquals(us[0].Id, navIdentMap.get(us[0].CRM_NAV_Ident__c).Id);
    }

    @isTest
    static void getNavUnitsMap() {
        NavUnit__c unit = new NavUnit__c(Name = 'NAV Test', INT_UnitNumber__c = '0303');
        insert unit;

        Map<String, NavUnit__c> navUnitMap = new KafkaMessageProcessorExtension().addNavUnit('0303').getNavUnitsMap();

        System.assertEquals(1, navUnitMap.size(), 'Nav unit added to map');
        System.assertEquals(true, navUnitMap.containsKey(unit.INT_UnitNumber__c));
        System.assertEquals(unit.Id, navUnitMap.get(unit.INT_UnitNumber__c).Id);
    }

    @isTest
    static void logError() {
        KafkaMessageProcessorExtension processor = new KafkaMessageProcessorExtension();
        String reference = processor.getLogger().logError('Test error message');

        System.assert(String.isNotBlank(reference));
    }

    @isTest
    static void setMessageError() {
        KafkaMessageProcessorExtension processor = new KafkaMessageProcessorExtension();
        KafkaMessage__c msg = new KafkaMessage__c(CRM_Status__c = KafkaMessageService.STATUS_PENDING);
        List<KafkaMessage__c> messages = new List<KafkaMessage__c>{ msg };
        String errorMessage = 'Test error message';

        processor.getLogger().setMessageErrors(messages, errorMessage);

        System.assert(String.isNotBlank(messages[0].CRM_ErrorMessage__c));
        System.assertEquals(KafkaMessageService.STATUS_ERROR, messages[0].CRM_Status__c);
    }

    @IsTest
    static void parse_success() {
        String json = '{}';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(json));

        KafkaMessage__c msg = new KafkaMessage__c();
        msg.CRM_Key__c = 'a240d1ad-ac38-4c2e-b0e7-e204c7e5bc1e';
        msg.CRM_Value__c = encodedValue;

        KafkaMessageProcessorExtension processor = new KafkaMessageProcessorExtension();

        MessageParser parser = (MessageParser) processor.parse(MessageParser.class, msg);

        System.assertEquals(msg.CRM_Value__c, parser.hash);
        System.assertEquals(msg.CRM_Key__c, parser.key);
        System.assertEquals(json, parser.jsonPayload);
    }

    public class MessageParser implements IKafkaMessageParser {
        public String jsonPayload { get; set; }
        public String hash { get; set; }
        public String key { get; set; }

        public MessageParser parse(String json, String key, String hash) {
            MessageParser model = (MessageParser) System.JSON.deserialize(json, MessageParser.class);
            model.jsonPayload = json;
            model.hash = hash;
            model.key = key;

            return model;
        }
    }

    public class KafkaMessageProcessorExtension extends KafkaMessageProcessor {
        public AG_KafkaLogger getLogger() {
            return logger;
        }
    }
}
