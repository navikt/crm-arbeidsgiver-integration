/**
 * @description Handler class to process inbound Kafka messages and create Job Posting records.
 * Contains functions to parse data from messages, create records and upsert them.
 */
public inherited sharing class KafkaArbeidsplassenJobPostingHandler extends KafkaMessageProcessor implements IKafkaMessageConsumer {
    Map<String, ArbeidsplassenJobPosting> keyToJobPosting = new Map<String, ArbeidsplassenJobPosting>();
    private static final Integer AGE_THRESHOLD_MINUTES = 15; //
    public static Boolean enableTimeDeviationLogging = false;
    /**
     * @description Implementation of processMessages-method from IKafkaMessageConsumer
     * @param messages List of kafka message records
     */
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
        if (enableTimeDeviationLogging) {
            logTimeDeviations(keyToJobPosting);
        }
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
            Database.UpsertResult[] cr = Database.upsert(jobPostings, f, false);
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
            UUID__c = model.uuid,
            NavIdent__c = model?.administration?.navIdent,
            NavEmployeeName__c = model?.administration?.reportee
        );

        if (accountMap.containsKey(model?.employer?.orgnr)) {
            jobPosting.Account__c = accountMap.get(model.employer.orgnr).Id;
        }

        if (model.getProperty('rekrutteringshjelp') == 'true') {
            jobPosting.RecruitmentAssistance__c = true;
            jobPosting.RecruitmentPhone__c = model.getProperty('rekrutteringshjelpTelefonnummer');
        }

        if (
            model.getProperty('employerdescription') != null &&
            model.getProperty('employerdescription').contains('Etterregistrering')
        ) {
            jobPosting.TAG_EmploymentPlacement__c = true;
        }

        jobPosting.JanzzName__c = model.getJanzzName();
        jobPosting.JanzzCode__c = model.getJanzzCode();
        jobPosting.WorkLanguage__c = truncate(convertJsonArrayToSortedString(model.getProperty('workLanguage')));
        jobPosting.JobTitle__c = truncate(model.getProperty('jobtitle'));
        jobPosting.Keywords__c = truncate(formatKeywords(model.getProperty('keywords')));

        return jobPosting;
    }

    /**
     * @description Helper method to convert a JSON array string to a comma-separated string.
     * @param propertyJson JSON array string to convert
     * @return Comma-separated string, or null if the input is null or empty.
     */
    @TestVisible
    private static String convertJsonArrayToSortedString(String propertyJson) {
        if (propertyJson != null) {
            try {
                List<String> propertyList = (List<String>) JSON.deserialize(propertyJson, List<String>.class);
                if (!propertyList.isEmpty()) {
                    propertyList.sort();
                    return String.join(propertyList, ', ');
                } else {
                    return null;
                }
            } catch (Exception e) {
                return null;
            }
        }
        return null;
    }

    /**
     * @description Helper method to truncate a string to 255 characters, or returns null if the string is null.
     * @param str String to truncate
     * @return Truncated string, or null if the string is null or blank.
     */
    @TestVisible
    private static String truncate(String str) {
        if (String.isBlank(str)) {
            return null;
        }
        return str.abbreviate(255);
    }

    /**
     * @description Formats a string of keywords by replacing semicolons with commas, removing instances of "null"(sometimes occurs as a keyword), and adding whitespace after commas.
     * This method replace semicolons with commas and adds whitespaces after commas. It also removes instances of "null" from the string, and returns null if the string is empty or only contains null.
     * @param str String of keywords to format
     * @return Formatted string with null removed, or null if the string is empty or only contains null
     */
    @TestVisible
    private static String formatKeywords(String str) {
        if (String.isBlank(str)) {
            return null;
        }
        str = str.replace(';', ',');
        List<String> keywords = str.split(',');
        List<String> formattedKeywords = new List<String>();
        for (String keyword : keywords) {
            if (!String.isBlank(keyword) && !keyword?.trim().equalsIgnoreCase('null')) {
                formattedKeywords.add(keyword.trim());
            }
        }
        return formattedKeywords.isEmpty() ? null : String.join(formattedKeywords, ', ');
    }

    @TestVisible
    private void logTimeDeviations(Map<String, ArbeidsplassenJobPosting> keyToJobPosting) {
        DateTime batchProcessingTime = DateTime.now();
        ReportingDataBuilder reportingDataBuilder = new ReportingDataBuilder();
        for (ArbeidsplassenJobPosting jobPosting : keyToJobPosting.values()) {
            Integer messageAge = jobPosting.getMessageAge(batchProcessingTime);
            if (messageAge > AGE_THRESHOLD_MINUTES) {
                reportingDataBuilder.logTimeDeviation('teampam.stilling-ekstern-1', jobPosting.key, messageAge);
            }
        }
        reportingDataBuilder.saveReportingDataEntries();
    }
}
