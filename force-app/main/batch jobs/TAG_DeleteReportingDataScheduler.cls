/**
 * Scheduler for daglig sletting av gamle tidsmålinger (ReportingData__c).
 *
 * Starter TAG_DeleteReportingDataBatchJob én gang i døgnet for å holde
 * datamengden i takt med produksjonstempoet til tidsmålingene.
 *
 * Aktiver med følgende Anonymous Apex (kjøres én gang per org):
 *
 * System.schedule(
 *     'Delete old ReportingData daily',
 *     '0 0 2 * * ?',  // Daglig kl. 02:00
 *     new TAG_DeleteReportingDataScheduler()
 * );
 */
public class TAG_DeleteReportingDataScheduler implements Schedulable {
    public void execute(SchedulableContext SC) {
        try {
            TAG_DeleteReportingDataBatchJob batch = new TAG_DeleteReportingDataBatchJob();
            Database.executeBatch(batch, 2000);
        } catch (Exception e) {
            System.debug('Error scheduling ReportingData deletion batch: ' + e.getMessage());
        }
    }
}
