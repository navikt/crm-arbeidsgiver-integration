/**
 * Batch-jobb for å slette gamle tidsmålinger fra ReportingData__c.
 *
 * Bakgrunn:
 * Tidsmålinger produseres kontinuerlig og må slettes i samme tempo for å unngå
 * at objektet vokser ukontrollert. Retention-reglene er:
 *
 * - IA-sak og samarbeidsplan (pia.*): beholdes i 6 måneder.
 *   Disse er viktigst å måle ettersom brukere har rapportert tregheter.
 *
 * - Øvrige topics (arbeidsplassen, dialogmøte, arena, tiltak): beholdes i 30 dager.
 *
 * Kjøres daglig via TAG_DeleteReportingDataScheduler.
 */
public class TAG_DeleteReportingDataBatchJob implements Database.Batchable<sObject> {
    // Henter alle ReportingData__c-records med Name = 'Tidsmåling' som er eldre enn
    // gjeldende retention-grense for hvert topic.
    private static final String QUERY =
        'SELECT Id FROM ReportingData__c' +
        ' WHERE Name = \'Tidsmåling\'' +
        ' AND (' +
        // Øvrige tidsmålinger: 30 dagers retention
        '   (CreatedDate < LAST_N_DAYS:30' +
        '    AND TAG_Category__c IN (' +
        '       \'teampam.stilling-ekstern-1\',' +
        '       \'teamsykefravr.isdialogmote-dialogmote-statusendring\',' +
        '       \'teamarenanais.aapen-arena-arbeidsgiveraktivitetendret-v1\',' +
        '       \'arbeidsgiver.tiltak-avtale-hendelse\'' +
        '    )' +
        '   )' +
        '   OR' +
        // IA-sak og samarbeidsplan: 6 måneders retention (brukere har rapportert tregheter)
        '   (CreatedDate < LAST_N_MONTHS:6' +
        '    AND TAG_Category__c IN (' +
        '       \'pia.ia-sak-v1\',' +
        '       \'pia.samarbeidsplan-v1\'' +
        '    )' +
        '   )' +
        ')';

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(QUERY);
    }

    public void execute(Database.BatchableContext BC, List<ReportingData__c> records) {
        try {
            delete records;
        } catch (Exception e) {
            System.debug('Error during ReportingData deletion: ' + e.getMessage());
        }
    }

    public void finish(Database.BatchableContext BC) {
    }
}
