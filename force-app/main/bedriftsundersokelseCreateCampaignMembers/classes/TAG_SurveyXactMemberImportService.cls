/**
 * Creates CustomCampaignMember__c records from a SurveyXact dataset export.
 *
 * 'bedrnr' is matched against Account.INT_OrganizationNumber__c. The campaign is
 * found through the account's NAV unit, among the 'BU {year} ...' campaigns
 * created by TAG_EmployerSurveyCampaignsBatch in crm-arbeidsgiver-base.
 *
 * Respondents that cannot be matched are skipped and logged individually.
 * Existing members are left alone unless updateExisting is set.
 */
public with sharing class TAG_SurveyXactMemberImportService {
    @TestVisible
    private static final String CAMPAIGN_TYPE = 'Bedriftsundersøkelse';

    @TestVisible
    private static final String STATUS_NOT_COMPLETED = 'Ikke gjennomført';

    private static final String CAMPAIGN_NAME_PREFIX = 'BU ';

    public class ImportResult {
        public Integer respondentsParsed = 0;
        public Integer membersCreated = 0;
        public Integer skippedExisting = 0;
        public Integer skippedNoAccount = 0;
        public Integer skippedNoNavUnit = 0;
        public Integer skippedNoCampaign = 0;
        public Integer skippedInvalidRow = 0;

        public Integer totalSkipped() {
            return skippedExisting + skippedNoAccount + skippedNoNavUnit + skippedNoCampaign + skippedInvalidRow;
        }

        public override String toString() {
            return 'parsed=' +
                respondentsParsed +
                ', created=' +
                membersCreated +
                ', existing=' +
                skippedExisting +
                ', noAccount=' +
                skippedNoAccount +
                ', noNavUnit=' +
                skippedNoNavUnit +
                ', noCampaign=' +
                skippedNoCampaign +
                ', invalidRow=' +
                skippedInvalidRow;
        }
    }

    // Parses the CSV and creates the members that do not already exist.
    // Skipped respondents are added to 'skipReasons' with their respondent key.
    public static ImportResult importFromCsv(
        String csvBody,
        Integer campaignYear,
        Boolean updateExisting,
        List<String> skipReasons
    ) {
        ImportResult result = new ImportResult();

        List<TAG_SurveyXactMemberImportParser.Respondent> respondents = TAG_SurveyXactMemberImportParser.parse(csvBody);
        result.respondentsParsed = respondents.size();
        if (respondents.isEmpty()) {
            return result;
        }

        Set<String> orgNumbers = new Set<String>();
        Set<String> keys = new Set<String>();
        for (TAG_SurveyXactMemberImportParser.Respondent r : respondents) {
            if (String.isNotBlank(r.organizationNumber)) {
                orgNumbers.add(r.organizationNumber.trim());
            }
            if (String.isNotBlank(r.externalKey)) {
                keys.add(r.externalKey.trim());
            }
        }

        Map<String, Account> accountByOrgNumber = fetchAccounts(orgNumbers);
        Map<Id, Id> campaignByNavUnit = fetchCampaigns(accountByOrgNumber.values(), campaignYear);
        Set<String> existingKeys = fetchExistingKeys(keys);

        List<CustomCampaignMember__c> toInsert = new List<CustomCampaignMember__c>();

        for (TAG_SurveyXactMemberImportParser.Respondent r : respondents) {
            String key = String.isNotBlank(r.externalKey) ? r.externalKey.trim() : null;
            String orgNumber = String.isNotBlank(r.organizationNumber) ? r.organizationNumber.trim() : null;

            if (String.isBlank(key) || String.isBlank(orgNumber)) {
                result.skippedInvalidRow++;
                skipReasons.add('Row is missing respnokk or bedrnr (respnokk=' + key + ', bedrnr=' + orgNumber + ')');
                continue;
            }

            if (existingKeys.contains(key) && !updateExisting) {
                result.skippedExisting++;
                skipReasons.add(key + ': campaign member already exists');
                continue;
            }

            Account account = accountByOrgNumber.get(orgNumber);
            if (account == null) {
                result.skippedNoAccount++;
                skipReasons.add(key + ': no account with organisation number ' + orgNumber);
                continue;
            }

            if (account.TAG_NavUnit__c == null) {
                result.skippedNoNavUnit++;
                skipReasons.add(key + ': account ' + account.Id + ' has no NAV unit');
                continue;
            }

            Id campaignId = campaignByNavUnit.get(account.TAG_NavUnit__c);
            if (campaignId == null) {
                result.skippedNoCampaign++;
                skipReasons.add(
                    key +
                    ': no ' +
                    CAMPAIGN_NAME_PREFIX +
                    campaignYear +
                    ' campaign for NAV unit ' +
                    account.TAG_NavUnit__c
                );
                continue;
            }

            toInsert.add(
                new CustomCampaignMember__c(
                    Account__c = account.Id,
                    CustomCampaign__c = campaignId,
                    Key__c = key,
                    Campaign_type__c = CAMPAIGN_TYPE,
                    Status__c = STATUS_NOT_COMPLETED,
                    NAV_Unit__c = account.TAG_NavUnit__c
                )
            );
        }

        if (!toInsert.isEmpty()) {
            insert toInsert;
            result.membersCreated = toInsert.size();
        }

        return result;
    }

    private static Map<String, Account> fetchAccounts(Set<String> orgNumbers) {
        Map<String, Account> accountByOrgNumber = new Map<String, Account>();
        if (orgNumbers.isEmpty()) {
            return accountByOrgNumber;
        }

        for (Account account : [
            SELECT Id, INT_OrganizationNumber__c, TAG_NavUnit__c
            FROM Account
            WHERE INT_OrganizationNumber__c IN :orgNumbers AND IsPersonAccount = FALSE
        ]) {
            accountByOrgNumber.put(account.INT_OrganizationNumber__c, account);
        }
        return accountByOrgNumber;
    }

    // Maps NAV unit to this year's campaign. The campaigns are named
    // 'BU {year} {unit}' and have a lookup to the NAV unit, so the lookup is used
    // for matching - not the name.
    private static Map<Id, Id> fetchCampaigns(List<Account> accounts, Integer campaignYear) {
        Map<Id, Id> campaignByNavUnit = new Map<Id, Id>();

        Set<Id> navUnitIds = new Set<Id>();
        for (Account account : accounts) {
            if (account.TAG_NavUnit__c != null) {
                navUnitIds.add(account.TAG_NavUnit__c);
            }
        }
        if (navUnitIds.isEmpty()) {
            return campaignByNavUnit;
        }

        String namePrefix = CAMPAIGN_NAME_PREFIX + campaignYear + '%';
        for (CustomCampaign__c campaign : [
            SELECT Id, NAV_Unit__c
            FROM CustomCampaign__c
            WHERE NAV_Unit__c IN :navUnitIds AND Name LIKE :namePrefix
        ]) {
            if (!campaignByNavUnit.containsKey(campaign.NAV_Unit__c)) {
                campaignByNavUnit.put(campaign.NAV_Unit__c, campaign.Id);
            }
        }
        return campaignByNavUnit;
    }

    private static Set<String> fetchExistingKeys(Set<String> keys) {
        Set<String> existing = new Set<String>();
        if (keys.isEmpty()) {
            return existing;
        }

        for (CustomCampaignMember__c member : [SELECT Key__c FROM CustomCampaignMember__c WHERE Key__c IN :keys]) {
            existing.add(member.Key__c);
        }
        return existing;
    }
}
