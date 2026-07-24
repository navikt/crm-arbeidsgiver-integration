@IsTest
private class TAG_SurveyXactDatasetParserTest {
    @IsTest
    static void parsesKeyAndResponseColumns() {
        String csv = 'survey;respnokk;response;offnavn\n' + '123;ABCDEFGH1234;4;Acme\n' + '123;ABCDEFGH2345;1;Beta\n';

        List<TAG_SurveyXactDatasetParser.Row> rows = TAG_SurveyXactDatasetParser.parse(csv);

        System.assertEquals(2, rows.size(), 'Two data rows expected');
        System.assertEquals('ABCDEFGH1234', rows[0].externalKey, 'First key');
        System.assertEquals('4', rows[0].responseStatus, 'First response');
        System.assertEquals('ABCDEFGH2345', rows[1].externalKey, 'Second key');
        System.assertEquals('1', rows[1].responseStatus, 'Second response');
    }

    @IsTest
    static void keepsAllColumnsPerRow() {
        String csv = 'survey;respnokk;response;offnavn\n' + '123;ABCDEFGH1234;4;Acme\n';

        List<TAG_SurveyXactDatasetParser.Row> rows = TAG_SurveyXactDatasetParser.parse(csv);

        System.assertEquals('123', rows[0].values.get('survey'), 'survey column kept');
        System.assertEquals('Acme', rows[0].values.get('offnavn'), 'offnavn column kept');
    }

    @IsTest
    static void handlesQuotedDelimiterNewlineAndEscapedQuotes() {
        String csv =
            'respnokk;response;offnavn\n' +
            'ABCDEFGH1234;4;"Acme; Inc"\n' +
            'ABCDEFGH2345;3;"Line1\nLine2"\n' +
            'ABCDEFGH3456;1;"He said ""hi"""\n';

        List<TAG_SurveyXactDatasetParser.Row> rows = TAG_SurveyXactDatasetParser.parse(csv);

        System.assertEquals(3, rows.size(), 'Three data rows expected');
        System.assertEquals('Acme; Inc', rows[0].values.get('offnavn'), 'Embedded delimiter preserved');
        System.assertEquals('Line1\nLine2', rows[1].values.get('offnavn'), 'Embedded newline preserved');
        System.assertEquals('He said "hi"', rows[2].values.get('offnavn'), 'Escaped quotes unescaped');
        System.assertEquals('ABCDEFGH3456', rows[2].externalKey, 'Key after quoted rows');
    }

    @IsTest
    static void skipsTrailingEmptyRow() {
        String csv = 'respnokk;response\n' + 'ABCDEFGH1234;4\n' + '\n';

        List<TAG_SurveyXactDatasetParser.Row> rows = TAG_SurveyXactDatasetParser.parse(csv);

        System.assertEquals(1, rows.size(), 'Trailing empty line is ignored');
    }

    @IsTest
    static void distinctResponseValuesReturnsUniqueCodes() {
        String csv = 'respnokk;response\n' + 'A;4\n' + 'B;1\n' + 'C;4\n';

        List<TAG_SurveyXactDatasetParser.Row> rows = TAG_SurveyXactDatasetParser.parse(csv);
        Set<String> codes = TAG_SurveyXactDatasetParser.distinctResponseValues(rows);

        System.assertEquals(2, codes.size(), 'Two distinct response codes');
        System.assert(codes.contains('4'), 'Contains 4');
        System.assert(codes.contains('1'), 'Contains 1');
    }

    @IsTest
    static void handlesBlankInput() {
        System.assertEquals(0, TAG_SurveyXactDatasetParser.parse(null).size(), 'Null yields empty');
        System.assertEquals(0, TAG_SurveyXactDatasetParser.parse('').size(), 'Empty yields empty');
    }
}
