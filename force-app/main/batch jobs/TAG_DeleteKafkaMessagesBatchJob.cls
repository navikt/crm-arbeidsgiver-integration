public class TAG_DeleteKafkaMessagesBatchJob implements Database.Batchable<sObject> {
    private static final String KAFKA_MESSAGE_QUERY = 'SELECT Id FROM KafkaMessage__c WHERE (CRM_Status__c = \'Processed\') AND'
        + ' (CRM_Topic__c = \'team-innhold.arbeidsgiver-kontaktskjema\' OR'
        + ' CRM_Topic__c = \'teampam.stilling-ekstern-1\' OR'
        + ' CRM_Topic__c = \'teamarenanais.aapen-arena-arbeidsgiveraktivitetendret-v1\' OR'
        + ' CRM_Topic__c = \'arbeidsgiver.tiltak-avtale-hendelse\' OR'
        + ' CRM_Topic__c = \'public-ereg-cache-org-json\' OR'
        + ' CRM_Topic__c = \'pia.ia-sak-v1\' OR'
        + ' CRM_Topic__c = \'pia.ia-sak-leveranse-v1\' OR'
        + ' CRM_Topic__c = \'teamsykefravr.isdialogmote-dialogmote-statusendring\' OR'
        + ' CRM_Topic__c = \'permittering-og-nedbemanning.aapen-permittering-arbeidsgiver\' OR'
        + ' CRM_Topic__c = \'arbeidsgiver.sykefravarsstatistikk-bransje-v1\' OR'
        + ' CRM_Topic__c = \'arbeidsgiver.sykefravarsstatistikk-land-v1\' OR'
        + ' CRM_Topic__c = \'arbeidsgiver.sykefravarsstatistikk-virksomhet-v1\' OR'
        + ' CRM_Topic__c = \'arbeidsgiver.sykefravarsstatistikk-naring-v1\' OR'
        + ' CRM_Topic__c = \'arbeidsgiver.sykefravarsstatistikk-naringskode-v1\' OR'
        + ' CRM_Topic__c = \'arbeidsgiver.sykefravarsstatistikk-metadata-virksomhet-v1\' OR'
        + ' CRM_Topic__c = \'arbeidsgiver.sykefravarsstatistikk-sektor-v1\' OR'
        + ' CRM_Topic__c = \'public-ereg-cache-org-tombstones\' OR'
        + ' CRM_Topic__c = \'arbeidsgiver.sykefravarsstatistikk-v1\')';

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(KAFKA_MESSAGE_QUERY);
    }

    public void execute(Database.BatchableContext BC, List<KafkaMessage__c> records) {
            try {
                delete records;
            } catch (Exception e) {
                System.debug('Error during record deletion: ' + e.getMessage());
            }
        }

    public void finish(Database.BatchableContext BC) {
        return;
    }
}