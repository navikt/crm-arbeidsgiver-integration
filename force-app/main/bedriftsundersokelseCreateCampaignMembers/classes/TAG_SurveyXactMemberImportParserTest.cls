@IsTest
private class TAG_SurveyXactMemberImportParserTest {
    @IsTest
    static void parsesKeyAndOrganizationNumber() {
        String csv =
            'survey;respnokk;bedrnr;offnavn\n' +
            '123456;ABCDEFGH1234;973871714;Acme\n' +
            '123456;ABCDEFGH2345;928366561;Beta\n';

        List<TAG_SurveyXactMemberImportParser.Respondent> rows = TAG_SurveyXactMemberImportParser.parse(csv);

        System.assertEquals(2, rows.size(), 'Two data rows expected');
        System.assertEquals('ABCDEFGH1234', rows[0].externalKey, 'First key');
        System.assertEquals('973871714', rows[0].organizationNumber, 'First organisation number');
        System.assertEquals('ABCDEFGH2345', rows[1].externalKey, 'Second key');
        System.assertEquals('928366561', rows[1].organizationNumber, 'Second organisation number');
    }

    @IsTest
    static void findsColumnsByNameNotPosition() {
        String csv = 'bedrnr;offnavn;respnokk\n' + '973871714;Acme;ABCDEFGH1234\n';

        List<TAG_SurveyXactMemberImportParser.Respondent> rows = TAG_SurveyXactMemberImportParser.parse(csv);

        System.assertEquals('ABCDEFGH1234', rows[0].externalKey, 'Key found regardless of position');
        System.assertEquals(
            '973871714',
            rows[0].organizationNumber,
            'Organisation number found regardless of position'
        );
    }

    @IsTest
    static void handlesQuotedDelimiterNewlineAndEscapedQuotes() {
        String csv =
            'respnokk;offnavn;bedrnr\n' +
            'ABCDEFGH1234;"Acme; Inc";973871714\n' +
            'ABCDEFGH2345;"Line1\nLine2";928366561\n' +
            'ABCDEFGH3456;"He said ""hi""";921804849\n';

        List<TAG_SurveyXactMemberImportParser.Respondent> rows = TAG_SurveyXactMemberImportParser.parse(csv);

        System.assertEquals(3, rows.size(), 'Three data rows expected');
        System.assertEquals('973871714', rows[0].organizationNumber, 'Embedded delimiter does not shift columns');
        System.assertEquals('928366561', rows[1].organizationNumber, 'Embedded newline does not shift columns');
        System.assertEquals('ABCDEFGH3456', rows[2].externalKey, 'Key after quoted rows');
    }

    @IsTest
    static void missingColumnsYieldNullValues() {
        String csv = 'survey;offnavn\n' + '123456;Acme\n';

        List<TAG_SurveyXactMemberImportParser.Respondent> rows = TAG_SurveyXactMemberImportParser.parse(csv);

        System.assertEquals(1, rows.size(), 'Row still parsed');
        System.assertEquals(null, rows[0].externalKey, 'Key is null when column is absent');
        System.assertEquals(null, rows[0].organizationNumber, 'Organisation number is null when column is absent');
    }

    @IsTest
    static void skipsTrailingEmptyRow() {
        String csv = 'respnokk;bedrnr\n' + 'ABCDEFGH1234;973871714\n' + '\n';

        List<TAG_SurveyXactMemberImportParser.Respondent> rows = TAG_SurveyXactMemberImportParser.parse(csv);

        System.assertEquals(1, rows.size(), 'Trailing empty line is ignored');
    }

    @IsTest
    static void handlesBlankInput() {
        System.assertEquals(0, TAG_SurveyXactMemberImportParser.parse(null).size(), 'Null yields empty');
        System.assertEquals(0, TAG_SurveyXactMemberImportParser.parse('').size(), 'Empty yields empty');
    }
}
