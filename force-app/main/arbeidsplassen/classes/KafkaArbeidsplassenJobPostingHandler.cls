public with sharing class KafkaArbeidsplassenJobPostingHandler extends KafkaMessageProcessor implements IKafkaMessageConsumer {
    Map<String, ArbeidsplassenJobPosting> keyToJobPosting = new Map<String, ArbeidsplassenJobPosting>();

    public void processMessages(List<KafkaMessage__c> messages) {
        List<JobPosting__c> jobPostings = new List<JobPosting__c>();

        for (KafkaMessage__c msg : messages) {
            try {
                ArbeidsplassenJobPosting job = (ArbeidsplassenJobPosting) parse(ArbeidsplassenJobPosting.class, msg);
                mapJobPosting(job);
                addOrgNumber(job.employer.orgnr);
                msg.CRM_Status__c = KafkaMessageService.STATUS_PROCESSED;
            } catch (Exception e) {
                msg.CRM_Status__c = KafkaMessageService.STATUS_ERROR;
                msg.CRM_ErrorMessage__c = e.getMessage() + ' (' + e.getLineNumber() + ')';
            }
        }

        getLastSaved(JobPosting__c.class, keyToJobPosting.keySet());
        jobPostings = toSObject();

        //upsert jobPostings JobPosting__c.KafkaId__c;
    }

    private void mapJobPosting(ArbeidsplassenJobPosting jobPosting) {
        String key = jobPosting.key;

        if (!keyToJobPosting.containsKey(key)) {
            keyToJobPosting.put(key, jobPosting);
        } else if (isMostRecent(jobPosting.updated, keyToJobPosting.get(key).updated)) {
            keyToJobPosting.put(key, jobPosting);
        }
    }

    private List<JobPosting__c> toSOBject() {
        Map<String, Id> accountMap = getOrgNumberAccountIdMap();
        Map<String, String> lastSaved = getLastSaved(JobPosting__c.class, keyToJobPosting.keyset());
        List<JobPosting__c> jobPostings = new List<JobPosting__c>();

        for (ArbeidsplassenJobPosting model : keyToJobPosting.values()) {
            if (!isNewOrChanged(model.key, model.hash, lastSaved)) {
                continue;
            }

            JobPosting__c jobPosting = new JobPosting__c();

            if (accountMap.containsKey(model.employer.orgnr)) {
                jobPosting.Account__c = accountMap.get(model.employer.orgnr);
            }

            jobPostings.add(jobPosting);
        }
        return jobPostings;
    }
}