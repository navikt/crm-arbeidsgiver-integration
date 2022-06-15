public class JobPostingDeletion_Scheduler implements Schedulable {
    public void execute(SchedulableContext SC) {
        JobPostingDeletion_Batch batch = new JobPostingDeletion_Batch();
        Database.executeBatch(batch, 2000);
    }
}
