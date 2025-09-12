public with sharing class AG_KafkaLogger {
    private static AG_KafkaLogger current;
    private LoggerUtility logger;
    private Integer errorCount;

    private AG_KafkaLogger() {
        this.logger = new LoggerUtility();
        this.errorCount = 0;
    }

    public static AG_KafkaLogger get() {
        if (current == null) {
            current = new AG_KafkaLogger();
        }
        return current;
    }

    public Integer getErrorCount() {
        return this.errorCount;
    }

    public void addError() {
        this.errorCount = this.errorCount + 1;
    }

    public void publish() {
        if (errorCount >= 1) {
            logError('Message processing failed with ' + errorCount + 'errors');
            this.errorCount = 0;
        }
        logger.publish();
    }

    public String logError(String message) {
        LoggerUtility.LogLevel logLevel = LoggerUtility.LogLevel.Error;
        String errorRef = '';

        logger.logMessage(logLevel, errorRef, null, message, null, null, CRM_ApplicationDomain.Domain.POAB);
        errorRef = logger.peek().UUID__c;

        return errorRef;
    }

    public String logError(String referenceInfo, String message, String stacktrace) {
        LoggerUtility.LogLevel logLevel = LoggerUtility.LogLevel.Error;
        String errorRef = '';
        logger.logMessage(
            logLevel,
            errorRef,
            referenceInfo,
            message,
            stacktrace,
            null,
            CRM_ApplicationDomain.Domain.POAB
        );
        errorRef = logger.peek().UUID__c;

        return errorRef;
    }

    public List<KafkaMessage__c> setMessageErrors(List<KafkaMessage__c> messages, String errorRef) {
        for (KafkaMessage__c m : messages) {
            m.CRM_Status__c = KafkaMessageService.STATUS_ERROR;
            m.CRM_ErrorMessage__c = 'Message processing error. See log with ref: ' + errorRef;
        }
        return messages;
    }

    /**
     * @description Logs the time deviation for a specific Kafka message.
     * @param topic - The Kafka topic name. Logged to referenceInfo
     * @param key - The key of the Kafka message.
     * @param timeInMinutes - The time taken to process the message in minutes.
     */
    public String logTimeDeviation(String topic, String key, Integer timeInMinutes) {
        LoggerUtility.LogLevel logLevel = LoggerUtility.LogLevel.Info;
        Integer ageInMinutes = Math.round(timeInMinutes);
        String message = ''; // Not used yet.
        String payload = key + ' | Age: ' + ageInMinutes + ' minutes';
        String logRef = '';
        // referenceId, referenceInfo, logMessage, payLoad, timeTaken, domain
        logger.logMessage(logLevel, '', topic, message, payload, null, CRM_ApplicationDomain.Domain.POAB);

        logRef = logger.peek().UUID__c;

        return logRef;
    }
}
