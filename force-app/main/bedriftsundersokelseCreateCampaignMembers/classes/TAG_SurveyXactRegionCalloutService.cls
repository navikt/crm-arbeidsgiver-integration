/**
 * Henter datauttrekket fra SurveyXact for én region om gangen.
 *
 * Hele årgangen er ca. 17 MB, som er for mye for én callout (grensen er 12 MB).
 * Uttrekket deles derfor per region.
 *
 * TODO: regionfilteret er ikke bekreftet av SurveyXact. '[Fylkebg/region]=1'
 * gir HTTP 200, men uten datarader. Venter på riktig syntaks for
 * single-choice-variabler.
 */
public with sharing class TAG_SurveyXactRegionCalloutService {
    public class CalloutException extends Exception {
    }

    private static final String NAMED_CREDENTIAL = 'callout:SurveyXact';

    // Region 1-15, Østfold til Finnmark.
    public static final Integer FIRST_REGION = 1;
    public static final Integer LAST_REGION = 15;

    public static String getRegionDataset(TAG_SurveyXactDataset_Config__mdt config, Integer region) {
        String surveyId = config != null ? config.SurveyId__c : null;
        String ptype1 = config != null ? config.Ptype1__c : null;

        if (String.isBlank(surveyId)) {
            throw new CalloutException('SurveyXact survey id is not configured.');
        }

        return getDataset(surveyId, buildExpression(ptype1, region));
    }

    public static String getDataset(String surveyId, String expression) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(buildEndpoint(surveyId, expression));
        req.setMethod('GET');
        req.setTimeout(120000);

        HttpResponse res = new Http().send(req);
        if (res.getStatusCode() != 200) {
            throw new CalloutException(
                'SurveyXact region export failed: HTTP ' +
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

    @TestVisible
    private static String buildExpression(String ptype1, Integer region) {
        List<String> clauses = new List<String>();
        if (String.isNotBlank(ptype1)) {
            clauses.add('[background/ptype1]=' + ptype1.trim());
        }
        if (region != null) {
            clauses.add('[Fylkebg/region]=' + region);
        }
        return String.join(clauses, ' and ');
    }
}
