/**
 * Fetches the SurveyXact dataset export one region at a time.
 *
 * A full year is around 17 MB, well past the 12 MB heap limit for a single
 * callout, so the export is split by region.
 *
 * The region filter uses ptype2t, the text variant of ptype2. Unlike ptype2 the
 * values stay the same from year to year. ptype1 is still required because test
 * data exists on other ptype1 values with the same ptype2t values.
 */
public with sharing class TAG_SurveyXactRegionCalloutService {
    public class CalloutException extends Exception {
    }

    private static final String NAMED_CREDENTIAL = 'callout:SurveyXact';

    // The ptype2t values, supplied by SurveyXact. This order decides the order
    // the regions run in. Supplementary samples are separate values.
    public static final List<String> REGIONS = new List<String>{
        '01 Østfold',
        '01 Østfold tilleggsutvalg',
        '02 Akershus',
        '02 Akershus tilleggsutvalg',
        '03 Oslo',
        '04 Innlandet',
        '05 Buskerud',
        '06 Vestfold',
        '07 Telemark',
        '08 Agder',
        '09 Rogaland',
        '10 Vestland',
        '11 Møre og Romsdal',
        '12 Trøndelag',
        '13 Nordland',
        '14 Troms',
        '15 Finnmark'
    };

    public static String getRegionDataset(TAG_SurveyXactDataset_Config__mdt config, String region) {
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
    private static String buildExpression(String ptype1, String region) {
        List<String> clauses = new List<String>();
        if (String.isNotBlank(ptype1)) {
            clauses.add('[background/ptype1]=' + ptype1.trim());
        }
        if (String.isNotBlank(region)) {
            clauses.add('[background/ptype2t]="' + region.trim() + '"');
        }
        return String.join(clauses, ' and ');
    }
}
