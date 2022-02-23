public without sharing class KafkaPermitteringHandler implements IKafkaMessageConsumer {
    public void processMessages(List<KafkaMessage__c> messages) {
        List<KafkaPermitteringHandler_Model> permitteringer = KafkaPermitteringHandler_Helper.convertKafkaToPermittering(
            messages
        );
        List<String> organisationNumbers = KafkaPermitteringHandler_Helper.getOrgNumbersFromPermittering(
            permitteringer
        );
        Map<String, Account> accountMap = SharedFunctions.fetchAccounts(organisationNumbers);

        // creates a list of each user / contact
        List<SharedFunctions_ContactModel> wrapperList = KafkaPermitteringHandler_Helper.convertPermitteringToContactWrapper(
            permitteringer
        );

        /*
        * 22.02 ble det tatt en beslutning om å fjerne tilgang til permitteringsvarsler i Salesforce.
        * Siden oppretelse av nye kontaktpersoner med kilde "permittering" kan tyde på mottakelse av nye permitteringsvarsler
        * valgte vi å fjerne opprettelse av kontakter i forbindelse med permitteringsvarsel.
        *
        * Dette kan aktiveres på nytt senere of testene bør oppdateres.
        *
        Map<String, Contact> contactMap = SharedFunctions.fetchOrCreateContact(wrapperList, accountMap);
        */

        Map<String, Contact> contactMap = new Map<String, Contact>();

        // create SObject version of layoff
        List<TemporaryLayoff__c> layoffs = KafkaPermitteringHandler_Helper.convertPermitteringToLayoff(
            permitteringer,
            accountMap,
            contactMap
        );

        layoffs = KafkaPermitteringHandler_Helper.removeExistingTempLayoffs(layoffs);
        layoffs = KafkaPermitteringHandler_Helper.removeDuplicateTempLayoffsInList(layoffs);

        insert layoffs;
    }
}
