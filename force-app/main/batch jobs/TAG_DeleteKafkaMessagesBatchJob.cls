public class TAG_DeleteKafkaMessagesBatchJob extends KafkaMessageProcessor implements Database.Batchable<sObject> {
    private static final String KAFKA_MESSAGE_QUERY =
        'SELECT Id FROM KafkaMessage__c WHERE IsDeleted = false AND CRM_Status__c = \'Pending\' AND' +
        ' (CRM_Topic__c = \'arbeidsgiver.sykefravarsstatistikk-bransje-v1\' OR' +
        ' CRM_Topic__c = \'arbeidsgiver.sykefravarsstatistikk-land-v1\' OR' +
        ' CRM_Topic__c = \'arbeidsgiver.sykefravarsstatistikk-virksomhet-v1\' OR' +
        ' CRM_Topic__c = \'arbeidsgiver.sykefravarsstatistikk-naring-v1\' OR' +
        ' CRM_Topic__c = \'arbeidsgiver.sykefravarsstatistikk-naringskode-v1\' OR' +
        ' CRM_Topic__c = \'arbeidsgiver.sykefravarsstatistikk-metadata-virksomhet-v1\' OR' +
        ' CRM_Topic__c = \'arbeidsgiver.sykefravarsstatistikk-sektor-v1\')';

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
*/

