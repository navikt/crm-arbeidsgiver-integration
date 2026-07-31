/**
 * Calls the SurveyXact "Export dataset" endpoint and returns the CSV body.
 *
 * The host and Basic authentication are provided by the 'SurveyXact' Named
 * Credential. Example endpoint produced:
 *   callout:SurveyXact/surveys/123456/export/dataset?format=EU&lang=en
 *     &expression=%5Brespondent%2FcloseTime%5D+%3E+datetime(...)
 */
public with sharing class TAG_SurveyXactDatasetCalloutService {
    public class CalloutException extends Exception {
    }

    private static final String NAMED_CREDENTIAL = 'callout:SurveyXact';
    private static final Integer DEFAULT_LOOKBACK_DAYS = 1;

    // Fetches the dataset CSV for respondents whose closeTime is within the
    // configured look-back window, using the given survey configuration.
    public static String getRecentDataset(TAG_SurveyXactDataset_Config__mdt config) {
        Integer lookbackDays = config != null &&
            config.LookbackDays__c != null
            ? Integer.valueOf(config.LookbackDays__c)
            : DEFAULT_LOOKBACK_DAYS;
        String surveyId = config != null ? config.SurveyId__c : null;
        String ptype1 = config != null ? config.Ptype1__c : null;

        if (String.isBlank(surveyId)) {
            throw new CalloutException('SurveyXact survey id is not configured.');
        }

        return getDataset(surveyId, buildExpression(lookbackDays, ptype1));
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

    // Combines the closeTime window with the ptype1 background variable, which
    // limits the export to one survey year. The ptype1 clause is only added when
    // configured, so an empty value simply means "no year filter".
    @TestVisible
    private static String buildExpression(Integer lookbackDays, String ptype1) {
        String expression = buildCloseTimeExpression(lookbackDays);
        if (String.isNotBlank(ptype1)) {
            expression += ' and [background/ptype1]=' + ptype1.trim();
        }
        return expression;
    }

    // Builds the SurveyXact filter expression for respondents closed within the window.
    // The cutoff is set to midnight (00:00:00) of the day 'lookbackDays' ago, so
    // respondents that closed early on the oldest day of the window are still included.
    @TestVisible
    private static String buildCloseTimeExpression(Integer lookbackDays) {
        Integer days = lookbackDays != null && lookbackDays > 0 ? lookbackDays : DEFAULT_LOOKBACK_DAYS;
        Date cutoffDate = Date.today().addDays(-days);
        String cutoff =
            cutoffDate.year() +
            '-' +
            padTwo(cutoffDate.month()) +
            '-' +
            padTwo(cutoffDate.day()) +
            ' 00:00:00';
        return '[respondent/closeTime] > datetime("' + cutoff + '")';
    }

    private static String padTwo(Integer value) {
        return String.valueOf(value).leftPad(2, '0');
    }
}
