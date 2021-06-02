@RestResource(urlMapping='/ContactForm/*')
global with sharing class KontaktSkjemaHandler {
    @HttpPost
    global static String doPost() {
        KontaktSkjemaModel rw = KontaktSkjemaModel.deserializeData(RestContext.request);

        Id contactId = KontaktSkjemaHelper.fetchOrCreateContact(rw);
        Id accountId = KontaktSkjemaHelper.getAccount(rw.organisationNumber);

        CustomOpportunity__c co = KontaktSkjemaHelper.createOpportunity(accountId, contactId, rw);
        KontaktSkjemaHelper.sendEmailReceipt(rw, co);

        return [SELECT Name FROM CustomOpportunity__c WHERE Id = :co.Id LIMIT 1].Name;
    }
}
