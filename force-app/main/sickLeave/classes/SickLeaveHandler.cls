public inherited sharing class SickLeaveHandler extends KafkaMessageProcessor implements IKafkaMessageConsumer {
   
    //tanken er å lage en handlerklasse for alle topicene, men kun en model klasse, siden de er like. Så har vi en helper-class, 
    //der vi samler gjenbrukbare kodesnutter. 
    public void processMessages(List<KafkaMessage__c> messages) {
         List<SickLeave> sickLeave = SickLeaveHelper.convertKafkaToSickleave(
            messages
        );
        
        try {
            List<String> organisationNumbers = SickLeaveHelper.getOrgNumbersFromSickLeave(sickLeave);
            Map<String, Account> accountMap = SickLeaveHelper.fetchAccounts(organisationNumbers);

            List<Absence__c> absence = SickLeaveHelper.convertSickLeaveToAbsence(
                sickLeave,
                accountMap
            );
            upsert absence CRM_Key__c;
        } catch (Exception e) {
            String errorRef = logger.logError(e.getMessage() + '/n' + e.getStackTraceString());
            logger.setMessageErrors(messages, errorRef);
        } 
    }
}
