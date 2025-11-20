public class TAG_DeleteKafkaMessagesBatchJob extends KafkaMessageProcessor implements Database.Batchable<sObject> {
    private static final String KAFKA_MESSAGE_QUERY =
        'SELECT Id FROM KafkaMessage__c WHERE LastModifiedDate < N_DAYS_AGO:7 AND LastModifiedDate > N_DAYS_AGO:15 AND IsDeleted = false AND (CRM_Status__c = \'Processed\' OR CRM_Status__c = \'Pending\') AND' +
        ' (CRM_Topic__c = \'teampam.stilling-ekstern-1\' OR' +
        ' CRM_Topic__c = \'teamarenanais.aapen-arena-arbeidsgiveraktivitetendret-v1\' OR' +
        ' CRM_Topic__c = \'arbeidsgiver.tiltak-avtale-hendelse\' OR' +
        ' CRM_Topic__c = \'public-ereg-cache-org-json\' OR' +
        ' CRM_Topic__c = \'pia.fullfort-behovsvurdering-v1\' OR' +
        ' CRM_Topic__c = \'pia.ia-sak-v1\' OR' +
        ' CRM_Topic__c = \'pia.samarbeidsplan-v1\' OR' +
        ' CRM_Topic__c = \'team-dialog.employer-activity\' OR' +
        ' CRM_Topic__c = \'pia.sykefravarsstatistikk-bransje-v1\' OR' +
        ' CRM_Topic__c = \'pia.sykefravarsstatistikk-land-v1\' OR' +
        ' CRM_Topic__c = \'pia.sykefravarsstatistikk-virksomhet-v1\' OR' +
        ' CRM_Topic__c = \'pia.sykefravarsstatistikk-naring-v1\' OR' +
        ' CRM_Topic__c = \'pia.sykefravarsstatistikk-naringskode-v1\' OR' +
        ' CRM_Topic__c = \'pia.sykefravarsstatistikk-metadata-virksomhet-v1\' OR' +
        ' CRM_Topic__c = \'pia.sykefravarsstatistikk-sektor-v1\' OR' +
        ' CRM_Topic__c = \'public-ereg-cache-org-tombstones\' OR' +
        ' CRM_Topic__c = \'teamsykefravr.isdialogmote-dialogmote-statusendring\')';

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(KAFKA_MESSAGE_QUERY);
    }

    public void execute(Database.BatchableContext BC, List<KafkaMessage__c> records) {
        try {
            delete records;
            //Database.emptyRecycleBin(records);
        } catch (Exception e) {
            System.debug('Error during record deletion: ' + e.getMessage());
            logger.addError();
        }
        logger.publish();
    }

    public void finish(Database.BatchableContext BC) {
        return;
    }
}

/*
Emptied obsolete topics:
pia.sykefravarsstatistikk-v1
team-innhold.arbeidsgiver-kontaktskjema
permittering-og-nedbemanning.aapen-permittering-arbeidsgiver
team-dialog.crm-kafka-activity-events
team-dialog.crm-kafka-activity-oppgaver
gg-arbeidsgiver-aktivitet-v1-p
privat-arbeidsgiver-aktivitet-crm
pia.ia-sak-leveranse-v1
*/

