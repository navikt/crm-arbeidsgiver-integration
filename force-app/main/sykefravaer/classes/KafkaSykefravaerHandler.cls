public inherited sharing class KafkaSykefravaerHandler extends KafkaMessageProcessor implements IKafkaMessageConsumer {
    public void processMessages(List<KafkaMessage__c> messages) {
        List<KafkaSykefravaerHandler_Model> sykefravaer = KafkaSykefravaerHandler_Helper.convertKafkaToSykefravaer(
            messages
        );

        try {
            List<String> organisationNumbers = KafkaSykefravaerHandler_Helper.getOrgNumbersFromSykefravaer(sykefravaer);
            Map<String, Account> accountMap = KafkaSykefravaerHandler_Helper.fetchAccounts(organisationNumbers);
            List<Absence__c> absence = KafkaSykefravaerHandler_Helper.convertSykefravaerToAbsence(sykefravaer, accountMap);
            
            upsert absence CRM_Key__c;
        } catch (Exception e) {
            String errorRef = logError(e.getMessage() + '/n' + e.getStackTraceString());
            setMessageErrors(messages, errorRef);
        }
    }
}
