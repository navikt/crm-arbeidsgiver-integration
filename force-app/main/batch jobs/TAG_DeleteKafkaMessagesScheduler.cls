public class TAG_DeleteKafkaMessagesScheduler implements Schedulable {
    public void execute(SchedulableContext SC) {
        AsyncOptions options = new AsyncOptions();
        options.MaximumQueueableStackDepth = 1000;
        System.enqueueJob(new TAG_DeleteKafkaMessagesQueuable(), options);

        TAG_DeleteKafkaMessagesBatchJob batch = new TAG_DeleteKafkaMessagesBatchJob();
        Database.executeBatch(batch, 2000);
    }
}
