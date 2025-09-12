@isTest
public class AG_KafkaLoggerTest {
    @isTest
    static void logError() {
        AG_KafkaLogger logger = AG_KafkaLogger.get();
        String reference = logger.logError('Test error message');

        System.assert(String.isNotBlank(reference));
    }

    @isTest
    static void addError() {
        AG_KafkaLogger logger = AG_KafkaLogger.get();

        System.assertEquals(0, logger.getErrorCount(), 'No errors');

        logger.addError();

        System.assertEquals(1, logger.getErrorCount(), '1 error');
    }

    @isTest
    static void publish() {
        AG_KafkaLogger logger = AG_KafkaLogger.get();

        logger.addError();

        System.assertEquals(1, logger.getErrorCount(), '1 error');

        logger.publish();

        System.assertEquals(0, logger.getErrorCount(), 'Errors published and count reset');
    }

    @isTest
    static void setMessageError() {
        AG_KafkaLogger logger = AG_KafkaLogger.get();
        KafkaMessage__c msg = new KafkaMessage__c(CRM_Status__c = KafkaMessageService.STATUS_PENDING);
        List<KafkaMessage__c> messages = new List<KafkaMessage__c>{ msg };
        String errorMessage = 'Test error message';

        logger.setMessageErrors(messages, errorMessage);

        System.assert(String.isNotBlank(messages[0].CRM_ErrorMessage__c));
        System.assertEquals(KafkaMessageService.STATUS_ERROR, messages[0].CRM_Status__c);
    }

    @isTest
    static void testLogTimeDeviation() {
        AG_KafkaLogger logger = AG_KafkaLogger.get();
        String reference = logger.logTimeDeviation('Test topic', 'Test key', 12345);

        System.assert(String.isNotBlank(reference));
    }
}
