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

        // will create non-existing contacts and fetch those already existing + map existing contacts to new accounts if represnting another unit
        Map<String, Contact> contactMap = SharedFunctions.fetchOrCreateContact(wrapperList, accountMap);

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
