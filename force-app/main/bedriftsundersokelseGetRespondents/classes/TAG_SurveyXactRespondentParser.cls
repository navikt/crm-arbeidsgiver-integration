/**
 * Parses the XML response from the SurveyXact respondents endpoint
 * (GET /surveys/{surveyId}/respondents) into a list of respondent records
 * holding the external key and collect status.
 * !! If GET Respondents will not be used (to favour GET Export Dataset), this class can be removed.
 */
public with sharing class TAG_SurveyXactRespondentParser {
    // Collect status indicating a respondent has not answered. Any other value means answered.
    public static final String COLLECT_STATUS_NO_ANSWERS = 'no answers';

    public class Respondent {
        public String externalKey;
        public String collectStatus;

        public Respondent(String externalKey, String collectStatus) {
            this.externalKey = externalKey;
            this.collectStatus = collectStatus;
        }

        // A respondent has answered when the collect status is anything other than 'no answers'.
        public Boolean hasAnswered() {
            return this.collectStatus != null && this.collectStatus.trim().toLowerCase() != COLLECT_STATUS_NO_ANSWERS;
        }
    }

    // Parses the respondents XML. Respondents without an external key are skipped.
    public static List<Respondent> parse(String xmlBody) {
        List<Respondent> result = new List<Respondent>();
        if (String.isBlank(xmlBody)) {
            return result;
        }

        Dom.Document doc = new Dom.Document();
        doc.load(xmlBody);

        Dom.XmlNode root = doc.getRootElement();
        if (root == null) {
            return result;
        }

        for (Dom.XmlNode respondentNode : root.getChildElements()) {
            if (respondentNode.getName() != 'respondent') {
                continue;
            }

            String externalKey;
            String collectStatus;

            for (Dom.XmlNode field : respondentNode.getChildElements()) {
                String name = field.getName();
                if (name == 'externalkey') {
                    externalKey = field.getText();
                } else if (name == 'collectstatus') {
                    collectStatus = field.getText();
                }
            }

            if (String.isNotBlank(externalKey)) {
                result.add(new Respondent(externalKey.trim(), collectStatus));
            }
        }

        return result;
    }
}
