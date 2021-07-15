public inherited sharing class KafkaSykefravaerHandler implements IKafkaMessageConsumer {
    public void processMessages(List<KafkaMessage__c> messages) {
        List<KafkaSykefravaerHandler_Model> sykefravaer = KafkaSykefravaerHandler_Helper.convertKafkaToSykefravaer(
            messages
        );
        List<String> organisationNumbers = KafkaSykefravaerHandler_Helper.getOrgNumbersFromSykefravaer(
            sykefravaer
        );
        Map<String, Account> accountMap = SharedFunctions.fetchAccounts(organisationNumbers);

        List<Absence__c> absence = KafkaSykefravaerHandler_Helper.convertSykefravaerToAbsence (
            sykefravaer,
            accountMap
        );

        upsert absence CRM_Key__c;
    }
}