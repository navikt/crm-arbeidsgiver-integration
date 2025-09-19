// Class used together with handler classes to log age in Kafka messages.
public with sharing class ReportingDataBuilder {
    private List<ReportingData__c> reportingDataEntries;
    private LoggerUtility logger;
    private static final String CRM_CATEGORY = 'TAG Admin';
    private static final String RECORD_NAME = 'Tidsmåling';
    public ReportingDataBuilder() {
        this.reportingDataEntries = new List<ReportingData__c>();
        this.logger = new LoggerUtility();
    }

    /**
     * @description Logs the time deviation for a Kafka message.
     * @param topic - The Kafka topic name. Logged to referenceInfo
     * @param key - The key of the Kafka message.
     * @param timeInMinutes - The time taken to process the message in minutes.
     */
    public void logTimeDeviation(String topic, String key, Integer timeInMinutes) {
        ReportingData__c reportingData = createReportingDataRecord();
        reportingData.TAG_Category__c = topic;
        reportingData.TAG_Key__c = key;
        reportingData.CRM_Category__c = CRM_CATEGORY;
        reportingData.TAG_Measurement__c = timeInMinutes;
        this.reportingDataEntries.add(reportingData);
    }

    public void saveReportingDataEntries() {
        if (!this.reportingDataEntries.isEmpty()) {
            try {
                insert this.reportingDataEntries;
                this.reportingDataEntries.clear();
            } catch (DmlException e) {
                this.logger.logMessage(
                    LoggerUtility.LogLevel.Info,
                    '',
                    '',
                    'Failed to insert ReportingData__c records: ' + e.getMessage(),
                    e.getStackTraceString(),
                    null,
                    CRM_ApplicationDomain.Domain.POAB
                );
                this.logger.publish();
            }
        }
    }

    /**
     * @description Creates a new ReportingData__c record with default values.
     * @return ReportingData__c - A new instance with common fields populated.
     */
    private ReportingData__c createReportingDataRecord() {
        return new ReportingData__c(Name = RECORD_NAME);
    }

    /**
     * @description Returns the number of reporting entries currently in the buffer.
     * @return Integer - The number of entries waiting to be saved.
     */
    public Integer getEntryCount() {
        return this.reportingDataEntries.size();
    }
}
