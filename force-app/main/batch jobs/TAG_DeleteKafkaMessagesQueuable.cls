public without sharing class TAG_DeleteKafkaMessagesQueuable implements Queueable {
    public static void execute(QueueableContext context) {
        List<KafkaMessage__c> messagesToDelete = [
            SELECT Id
            FROM KafkaMessage__c
            WHERE
                CreatedDate < N_DAYS_AGO:750
                AND CreatedDate > N_DAYS_AGO:801
                AND CRM_Status__c = 'Processed'
                AND CRM_Topic__c = 'arbeidsgiver.sykefravarsstatistikk-v1'
                AND IsDeleted = FALSE
            LIMIT 10000
        ];

        try {
            delete messagesToDelete;
        } catch (Exception e) {
            System.debug('Error during Queueable record deletion: ' + e.getMessage());
        }

        if (
            !messagesToDelete.isEmpty() &&
            AsyncInfo.hasMaxStackDepth() &&
            AsyncInfo.getCurrentQueueableStackDepth() < AsyncInfo.getMaximumQueueableStackDepth()
        ) {
            System.enqueueJob(new TAG_DeleteKafkaMessagesQueuable());
        }
    }
}
