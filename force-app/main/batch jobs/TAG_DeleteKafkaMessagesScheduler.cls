public class TAG_DeleteKafkaMessagesScheduler implements Schedulable {
    public void execute(SchedulableContext SC) {
        TAG_DeleteKafkaMessagesBatchJob batch = new TAG_DeleteKafkaMessagesBatchJob();
        Database.executeBatch(batch, 10000);
    }
}