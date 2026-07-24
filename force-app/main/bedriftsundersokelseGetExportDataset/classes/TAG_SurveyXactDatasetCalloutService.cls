/**
 * Calls the SurveyXact "Export dataset" endpoint and returns the CSV body.
 *
 * The host and Basic authentication are provided by the 'SurveyXact' Named
 * Credential. Example endpoint produced:
 *   callout:SurveyXact/surveys/123456/export/dataset?format=EU&lang=en
 *     &expression=%5Brespondent%2FcloseTime%5D%20%3E%20datetime(...)
 */
public with sharing class TAG_SurveyXactDatasetCalloutService {
    public class CalloutException extends Exception {
    }

    private static final String NAMED_CREDENTIAL = 'callout:SurveyXact';
    private static final Integer DEFAULT_LOOKBACK_DAYS = 3;

    // Fetches the dataset CSV for respondents whose closeTime is within the
    // configured look-back window, using the given survey configuration.
    public static String getRecentDataset(TAG_SurveyXactDataset_Config__mdt config) {
        Integer lookbackDays = config != null &&
            config.LookbackDays__c != null
            ? Integer.valueOf(config.LookbackDays__c)
            : DEFAULT_LOOKBACK_DAYS;
        String surveyId = config != null ? config.SurveyId__c : null;

        if (String.isBlank(surveyId)) {
            throw new CalloutException('SurveyXact survey id is not configured.');
        }

        return getDataset(surveyId, buildCloseTimeExpression(lookbackDays));
    }

    // Performs the dataset export callout for the given survey and filter expression.
    public static String getDataset(String surveyId, String expression) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(buildEndpoint(surveyId, expression));
        req.setMethod('GET');
        req.setTimeout(120000);

        HttpResponse res = new Http().send(req);
        if (res.getStatusCode() != 200) {
            throw new CalloutException(
                'SurveyXact dataset export failed: HTTP ' +
                res.getStatusCode() +
                ' ' +
                res.getStatus()
            );
        }
        return res.getBody();
    }

    @TestVisible
    private static String buildEndpoint(String surveyId, String expression) {
        String endpoint = NAMED_CREDENTIAL + '/surveys/' + surveyId + '/export/dataset?format=EU&lang=en';
        if (String.isNotBlank(expression)) {
            endpoint += '&expression=' + EncodingUtil.urlEncode(expression, 'UTF-8');
        }
        return endpoint;
    }

    // Builds the SurveyXact filter expression for respondents closed within the window.
    @TestVisible
    private static String buildCloseTimeExpression(Integer lookbackDays) {
        Integer days = lookbackDays != null && lookbackDays > 0 ? lookbackDays : DEFAULT_LOOKBACK_DAYS;
        String cutoff = Datetime.now().addDays(-days).format('yyyy-MM-dd HH:mm:ss');
        return '[respondent/closeTime] > datetime("' + cutoff + '")';
    }
}
