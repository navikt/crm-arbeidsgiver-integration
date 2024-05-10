public class TAG_DeleteKafkaMessagesScheduler extends KafkaMessageProcessor implements Schedulable {
    public void execute(SchedulableContext SC) {
        //Turn off Queueable that deleted old recrds from the topics (22.04.2024)
        //AsyncOptions options = new AsyncOptions();
        //options.MaximumQueueableStackDepth = 600;
        //System.enqueueJob(new TAG_DeleteKafkaMessagesQueuable(), options);

        try {
            TAG_DeleteKafkaMessagesBatchJob batch = new TAG_DeleteKafkaMessagesBatchJob();
            Database.executeBatch(batch, 2000);
        } catch (Exception e) {
            logger.addError();
        }
        logger.publish();
    }
}
