@IsTest
private class TAG_SurveyXactRespondentParserTest {
    private static final String SAMPLE_XML =
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
        '<respondents>' +
        '  <respondent>' +
        '    <id>42</id>' +
        '    <externalkey>ABCDEFGH1234</externalkey>' +
        '    <collectstatus>no answers</collectstatus>' +
        '  </respondent>' +
        '  <respondent>' +
        '    <id>43</id>' +
        '    <externalkey>ABCDEFGH2345</externalkey>' +
        '    <collectstatus>some answers</collectstatus>' +
        '  </respondent>' +
        '</respondents>';

    @IsTest
    static void parsesAllRespondents() {
        Test.startTest();
        List<TAG_SurveyXactRespondentParser.Respondent> respondents = TAG_SurveyXactRespondentParser.parse(SAMPLE_XML);
        Test.stopTest();

        System.assertEquals(2, respondents.size(), 'Both respondents should be parsed');
        System.assertEquals('ABCDEFGH1234', respondents[0].externalKey, 'First external key');
        System.assertEquals('no answers', respondents[0].collectStatus, 'First collect status');
        System.assertEquals('ABCDEFGH2345', respondents[1].externalKey, 'Second external key');
    }

    @IsTest
    static void hasAnsweredReflectsCollectStatus() {
        List<TAG_SurveyXactRespondentParser.Respondent> respondents = TAG_SurveyXactRespondentParser.parse(SAMPLE_XML);

        System.assertEquals(false, respondents[0].hasAnswered(), '"no answers" means not answered');
        System.assertEquals(true, respondents[1].hasAnswered(), 'Any other value means answered');
    }

    @IsTest
    static void skipsRespondentsWithoutExternalKey() {
        String xml =
            '<respondents>' +
            '  <respondent>' +
            '    <id>1</id>' +
            '    <collectstatus>no answers</collectstatus>' +
            '  </respondent>' +
            '</respondents>';

        List<TAG_SurveyXactRespondentParser.Respondent> respondents = TAG_SurveyXactRespondentParser.parse(xml);

        System.assertEquals(0, respondents.size(), 'Respondents without an external key are skipped');
    }

    @IsTest
    static void handlesBlankInput() {
        System.assertEquals(0, TAG_SurveyXactRespondentParser.parse(null).size(), 'Null input yields empty list');
        System.assertEquals(0, TAG_SurveyXactRespondentParser.parse('').size(), 'Empty input yields empty list');
    }
}
