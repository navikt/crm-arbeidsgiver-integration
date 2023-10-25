public inherited sharing class KafkaArbeidsplassenJobPostingHandler extends KafkaMessageProcessor implements IKafkaMessageConsumer {
    Map<String, ArbeidsplassenJobPosting> keyToJobPosting = new Map<String, ArbeidsplassenJobPosting>();

    public void processMessages(List<KafkaMessage__c> messages) {
        for (KafkaMessage__c msg : messages) {
            try {
                ArbeidsplassenJobPosting job = (ArbeidsplassenJobPosting) parse(ArbeidsplassenJobPosting.class, msg);
                mapJobPosting(job);
                addOrgNumber(job?.employer?.orgnr);
                msg.CRM_Status__c = KafkaMessageService.STATUS_PROCESSED;
            } catch (Exception e) {
                msg.CRM_Status__c = KafkaMessageService.STATUS_ERROR;
                msg.CRM_ErrorMessage__c = e.getMessage() + ' (' + e.getLineNumber() + ')';
                logger.addError();
            }
        }

        convertAndUpsertJobPostings(messages);
        logger.publish();
    }

    private void mapJobPosting(ArbeidsplassenJobPosting jobPosting) {
        String key = jobPosting.key;

        if (!keyToJobPosting.containsKey(key)) {
            keyToJobPosting.put(key, jobPosting);
        } else if (isMostRecent(jobPosting.updated, keyToJobPosting.get(key).updated)) {
            keyToJobPosting.put(key, jobPosting);
        }
    }

    private void convertAndUpsertJobPostings(List<KafkaMessage__c> messages) {
        List<JobPosting__c> jobPostings = new List<JobPosting__c>();
        try {
            jobPostings = getJobPostingSObjects();

            Schema.SObjectField f = JobPosting__c.Fields.KafkaId__c;
            Database.UpsertResult [] cr = Database.upsert(jobPostings , f, false);

        } catch (Exception e) {
            String errorRef = logger.logError(e.getMessage() + '/n' + e.getStackTraceString());
            logger.setMessageErrors(messages, errorRef);
        }
    }

    private List<JobPosting__c> getJobPostingSObjects() {
        Map<String, String> lastSaved = getLastSaved(JobPosting__c.class, keyToJobPosting.keyset());
        Map<String, Account> accountMap = getOrgNumberAccountMap();

        List<JobPosting__c> jobPostings = new List<JobPosting__c>();

        for (ArbeidsplassenJobPosting model : keyToJobPosting.values()) {
            if (isNewOrChanged(model.key, model.hash, lastSaved)) {
                JobPosting__c jobPosting = convertToSObject(model, accountMap);
                jobPostings.add(jobPosting);
            }
        }
        return jobPostings;
    }

    private JobPosting__c convertToSObject(ArbeidsplassenJobPosting model, Map<String, Account> accountMap) {
        JobPosting__c jobPosting = new JobPosting__c(
            EngagementType__c = model.getProperty('engagementtype'),
            SourceURL__c = model.getProperty('sourceurl'),
            Extent__c = model.getProperty('extent'),
            ProfessionCategoryCode__c = model.getCategoryCodes(),
            ProfessionCategory__c = model.getCategoryNames(),
            OrganizationNumber__c = model?.employer?.orgnr,
            LastUpdated__c = dateTimeValue(model.updated),
            Published__c = dateTimeValue(model.published),
            Created__c = dateTimeValue(model.created),
            Expires__c = dateTimeValue(model.expires),
            EmployerReference__c = model.reference,
            WorkplaceCity__c = model.getCities(),
            JobPoster__c = model.businessName,
            Status__c = model.status,
            Medium__c = model.medium,
            Source__c = model.source,
            Title__c = model?.title?.left(254),
            KafkaHash__c = model.hash,
            KafkaId__c = model.key,
            UUID__c = model.uuid
        );

        if (accountMap.containsKey(model?.employer?.orgnr)) {
            jobPosting.Account__c = accountMap.get(model.employer.orgnr).Id;
        }

        return jobPosting;
    }
}
