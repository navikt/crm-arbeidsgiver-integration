/**
 * Starter den årlige importen av kampanjemedlemmer. Kjøres én gang - maks to -
 * i året, når respondentene er klare i SurveyXact.
 *
 * Planlegges fra Execute Anonymous, f.eks. 1. februar kl. 02:
 *   System.schedule('SurveyXact Member Import',
 *       '0 0 2 1 2 ?', new TAG_SurveyXactMemberImportScheduler());
 *
 * Husk å slette den planlagte jobben etterpå - den skal ikke gå kontinuerlig.
 */
public with sharing class TAG_SurveyXactMemberImportScheduler implements Schedulable {
    public void execute(SchedulableContext context) {
        System.enqueueJob(new TAG_SurveyXactMemberImportQueueable());
    }
}
