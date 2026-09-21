/**
 * Creates test data for the Bedriftsundersøkelse layout in a scratch org.
 *
 * 5 NAV units, 10 accounts, 5 campaigns (4 Bedriftsundersøkelse + 1 other type)
 * and 10 campaign members per campaign.
 *
 * Members get a mix of statuses so Dynamic Forms visibility rules can be tested
 * against Campaign_type__c and Status__c. The first members of the first
 * Bedriftsundersokelse campaign get the respondent keys from the SurveyXact
 * sample export, so the sync can be run against the sample CSV afterwards.
 *
 * Re-runnable: existing records with the TEST_MARKER prefix are deleted first.
 *
 *   sf apex run --file scripts/apex/createBuTestData.apex
 */

final String TEST_MARKER = 'BUTEST';
final Integer CAMPAIGN_YEAR = Date.today().year();
final Integer MEMBERS_PER_CAMPAIGN = 10;
final String CAMPAIGN_TYPE_BU = 'Bedriftsundersøkelse';
final String CAMPAIGN_TYPE_OTHER = 'Sommerjobbkampanje';
final String STATUS_COMPLETED = 'Gjennomført';
final String STATUS_NOT_COMPLETED = 'Ikke gjennomført';

// Keys from the SurveyXact sample export. Assigned to the first members of the
// first Bedriftsundersokelse campaign so TAG_SurveyXactDatasetSync can be run
// against the sample CSV afterwards. Each key is used once, otherwise one
// respondent's answers would be written to several members.
List<String> sampleKeys = new List<String>{
    'YDA14CFYEASS', // gjennomfort - far svar
    'AGAPAV8Z7SSF', // gjennomfort - far svar
    '9ZA64GHDGTS9', // ikke gjennomfort - skal ikke rores
    'RDD24YHD7AUE' // ikke gjennomfort - skal ikke rores
};

// ---------------------------------------------------------------- cleanup

// The sample keys do not carry the marker, so they are deleted by key as well.
delete [
    SELECT Id
    FROM CustomCampaignMember__c
    WHERE Key__c LIKE :(TEST_MARKER + '%') OR Key__c IN :sampleKeys
];
delete [SELECT Id FROM CustomCampaign__c WHERE Name LIKE :('%' + TEST_MARKER + '%')];
delete [SELECT Id FROM Account WHERE Name LIKE :(TEST_MARKER + '%')];
delete [SELECT Id FROM NavUnit__c WHERE Name LIKE :(TEST_MARKER + '%')];

// ---------------------------------------------------------------- nav units

List<String> unitNames = new List<String>{ 'Drammen', 'Kongsberg', 'Bærum', 'Asker', 'Ringerike' };

List<NavUnit__c> units = new List<NavUnit__c>();
for (Integer i = 0; i < unitNames.size(); i++) {
    units.add(new NavUnit__c(Name = TEST_MARKER + ' NAV ' + unitNames[i], INT_UnitNumber__c = '90' + (10 + i)));
}
insert units;

// ---------------------------------------------------------------- accounts

List<String> companyNames = new List<String>{
    'Nordvik Bygg AS',
    'Fjordtech Solutions AS',
    'Bakeriet på Hjørnet AS',
    'Vestre Transport AS',
    'Helsehuset Omsorg AS',
    'Granli Elektro AS',
    'Sørlie Regnskap AS',
    'Kystens Mat AS',
    'Lundeberg Mekaniske AS',
    'Aurora Digital AS'
};

List<Account> accounts = new List<Account>();
for (Integer i = 0; i < companyNames.size(); i++) {
    accounts.add(
        new Account(
            Name = TEST_MARKER + ' ' + companyNames[i],
            INT_OrganizationNumber__c = String.valueOf(999000000 + i)
        )
    );
}
insert accounts;

// Set in a separate update: routing logic can overwrite the field on insert.
List<Account> accountUpdates = new List<Account>();
for (Integer i = 0; i < accounts.size(); i++) {
    accountUpdates.add(new Account(Id = accounts[i].Id, TAG_NavUnit__c = units[Math.mod(i, units.size())].Id));
}
update accountUpdates;

// ---------------------------------------------------------------- campaigns

List<CustomCampaign__c> campaigns = new List<CustomCampaign__c>();
for (Integer i = 0; i < units.size(); i++) {
    Boolean isLast = i == units.size() - 1;
    String campaignType = isLast ? CAMPAIGN_TYPE_OTHER : CAMPAIGN_TYPE_BU;
    String prefix = isLast ? 'Sommerjobb ' : 'BU ';

    campaigns.add(
        new CustomCampaign__c(
            Name = prefix + CAMPAIGN_YEAR + ' ' + TEST_MARKER + ' NAV ' + unitNames[i],
            NAV_Unit__c = units[i].Id,
            Type__c = campaignType,
            Status__c = 'Åpen',
            StartDate__c = Date.today(),
            EndDate__c = Date.today().addDays(45)
        )
    );
}
insert campaigns;

// ---------------------------------------------------------------- members

List<CustomCampaignMember__c> members = new List<CustomCampaignMember__c>();
Integer keyCounter = 0;

for (Integer c = 0; c < campaigns.size(); c++) {
    CustomCampaign__c campaign = campaigns[c];
    Boolean isBu = CAMPAIGN_TYPE_BU.equals(campaign.Type__c);

    for (Integer m = 0; m < MEMBERS_PER_CAMPAIGN; m++) {
        keyCounter++;
        // 6 of 10 completed, so both sides of the visibility rule are covered.
        Boolean completed = m < 6;
        Boolean usesSampleKey = isBu && c == 0 && m < sampleKeys.size();

        CustomCampaignMember__c member = new CustomCampaignMember__c(
            Account__c = accounts[Math.mod(m, accounts.size())].Id,
            CustomCampaign__c = campaign.Id,
            NAV_Unit__c = campaign.NAV_Unit__c,
            Campaign_type__c = campaign.Type__c,
            Key__c = usesSampleKey ? sampleKeys[m] : TEST_MARKER + String.valueOf(100000 + keyCounter),
            // Sample respondents start at Ny so the sync can be seen promoting them.
            Status__c = usesSampleKey ? 'Ny' : (completed ? STATUS_COMPLETED : STATUS_NOT_COMPLETED)
        );

        members.add(member);
    }
}
insert members;

// ---------------------------------------------------------------- summary

System.debug(LoggingLevel.ERROR, '--- Testdata opprettet ---');
System.debug(LoggingLevel.ERROR, 'NAV-enheter:      ' + units.size());
System.debug(LoggingLevel.ERROR, 'Kontoer:          ' + accounts.size());
System.debug(LoggingLevel.ERROR, 'Kampanjer:        ' + campaigns.size());
System.debug(LoggingLevel.ERROR, 'Kampanjemedlemmer:' + members.size());
System.debug(LoggingLevel.ERROR, 'Respondentnokler:  ' + sampleKeys);

for (CustomCampaign__c campaign : [
    SELECT Name, Type__c, (SELECT Id FROM Custom_Campaign_Members__r)
    FROM CustomCampaign__c
    WHERE Name LIKE :('%' + TEST_MARKER + '%')
    ORDER BY Name
]) {
    System.debug(
        LoggingLevel.ERROR,
        campaign.Name + ' [' + campaign.Type__c + '] - ' + campaign.Custom_Campaign_Members__r.size() + ' medlemmer'
    );
}
