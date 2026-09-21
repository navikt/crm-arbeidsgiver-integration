@IsTest
private class TAG_SurveyXactAnswerFormatterTest {
    private static Map<String, String> baseValues() {
        return new Map<String, String>{
            'ans_idag' => '37',
            'ans_1aar' => '2',
            'problem' => '3',
            'basis_2' => '1',
            'basis_8' => '1'
        };
    }

    @IsTest
    static void formatsSingleChoiceAnswersWithLabels() {
        TAG_SurveyXactAnswerFormatter.Answers answers = TAG_SurveyXactAnswerFormatter.build(baseValues());

        System.assert(
            answers.answers.contains('1. Hvor mange ansatte er det i virksomheten i dag?\n37'),
            'Numeric answer is kept as is'
        );
        System.assert(answers.answers.contains('Like mange som i dag'), 'Code 2 is translated for question 2');
        System.assert(answers.answers.contains('3. Har virksomheten'), 'Question 3 is included');
        System.assert(answers.answers.contains('\nNei'), 'Code 3 is translated for question 3');
    }

    @IsTest
    static void fillsStructuredFields() {
        Map<String, String> values = baseValues();
        values.put('problem', '2');
        values.put('alv_prob', '1');

        TAG_SurveyXactAnswerFormatter.Answers answers = TAG_SurveyXactAnswerFormatter.build(values);

        System.assertEquals(37, answers.employeesToday, 'Employee count is parsed');
        System.assertEquals('Like mange som i dag', answers.employeeOutlookOneYear, 'Outlook picklist is mapped');
        System.assertEquals(
            'Ansatt med lavere/annen kompetanse',
            answers.failedRecruitment,
            'Long option is stored shortened'
        );
        System.assertEquals('Ingen/for få kvalifiserte søkere', answers.failedRecruitmentCause, 'Cause is mapped');
        System.assert(answers.aiUsage.contains('- Andre oppgaver'), 'Selected AI option is stored');
        System.assertEquals(null, answers.aiNotUsedReason, 'Unanswered checkbox question stays null');
    }

    @IsTest
    static void keepsFullWordingInAnswersWhenPicklistIsShortened() {
        Map<String, String> values = baseValues();
        values.put('problem', '2');

        TAG_SurveyXactAnswerFormatter.Answers answers = TAG_SurveyXactAnswerFormatter.build(values);

        System.assert(
            answers.answers.contains('men har ansatt noen med lavere eller annen formell kompetanse'),
            'Answer text keeps the wording the respondent saw'
        );
    }

    @IsTest
    static void formatsCheckboxesInQuestionnaireOrder() {
        TAG_SurveyXactAnswerFormatter.Answers answers = TAG_SurveyXactAnswerFormatter.build(baseValues());

        Integer textAnalysis = answers.answers.indexOf('- Bearbeiding og analyse av tekst');
        Integer otherTasks = answers.answers.indexOf('- Andre oppgaver');

        System.assert(textAnalysis > 0, 'Selected option is listed');
        System.assert(otherTasks > textAnalysis, 'Options keep the questionnaire order');
        System.assert(!answers.answers.contains('Markedsføring og salg'), 'Unselected options are left out');
    }

    @IsTest
    static void skipsQuestionsWithoutAnswer() {
        TAG_SurveyXactAnswerFormatter.Answers answers = TAG_SurveyXactAnswerFormatter.build(baseValues());

        System.assert(!answers.answers.contains('4. Hva skyldes dette?'), 'Unanswered question is omitted');
        System.assert(
            !answers.answers.contains('7. Hva er de viktigste grunnene'),
            'Question without selections is omitted'
        );
    }

    @IsTest
    static void formatsRecruitmentGrid() {
        Map<String, String> values = baseValues();
        values.put('problem', '1');
        values.put('alv_prob', '1');
        values.put('s_2_1a', 'Sykepleier');
        values.put('s_2_1b', 'Bachelor i sykepleie');
        values.put('s_2_1', '4');
        values.put('s_2_2a', 'Helsefagarbeider');
        values.put('s_2_2b', 'Videregående');
        values.put('s_2_2', '6');

        TAG_SurveyXactAnswerFormatter.Answers answers = TAG_SurveyXactAnswerFormatter.build(values);

        System.assert(answers.answers.contains('Yrke: Sykepleier'), 'First grid row is included');
        System.assert(answers.answers.contains('Antall stillinger: 4'), 'Count is included');
        System.assert(
            answers.answers.indexOf('Yrke: Sykepleier') < answers.answers.indexOf('Yrke: Helsefagarbeider'),
            'Grid rows keep their order'
        );
        System.assert(answers.unfilledPositions.contains('Yrke: Helsefagarbeider'), 'Grid is also stored on its own');
    }

    @IsTest
    static void includesPartiallyFilledGridRow() {
        TAG_SurveyXactAnswerFormatter.Answers answers = TAG_SurveyXactAnswerFormatter.build(
            new Map<String, String>{ 's_2_1a' => 'Snekker' }
        );

        System.assert(answers.answers.contains('Yrke: Snekker'), 'Row with only an occupation is kept');
        System.assert(!answers.answers.contains('Utdanning:'), 'Blank columns are left out');
    }

    @IsTest
    static void formatsFylkeQuestions() {
        Map<String, String> values = baseValues();
        values.put('s_1_oest', '1');
        values.put('s_2_oest', '1');

        TAG_SurveyXactAnswerFormatter.Answers answers = TAG_SurveyXactAnswerFormatter.build(values);

        System.assert(
            answers.answers.contains('Er det aktuelt å gi personer med tilretteleggingsbehov'),
            'Fylke question text is included'
        );
        System.assert(answers.answers.contains('vil du at Nav skal ta kontakt'), 'Second fylke question is included');
        System.assert(
            answers.answers.indexOf('1. Hvor mange ansatte') < answers.answers.indexOf('Er det aktuelt å gi personer'),
            'Base questions come before fylke questions'
        );
    }

    @IsTest
    static void groupsContactInformationUnderOneQuestion() {
        TAG_SurveyXactAnswerFormatter.Answers answers = TAG_SurveyXactAnswerFormatter.build(
            new Map<String, String>{ 's_3_oest' => 'Kari Nordmann', 's_5_oest' => '99887766' }
        );

        System.assert(answers.answers.contains('Kontaktperson: Kari Nordmann'), 'Sub-label prefixes the answer');
        System.assert(answers.answers.contains('Telefonnummer 99887766'), 'Second sub-answer is listed');
        System.assertEquals(
            1,
            answers.answers.countMatches('Vennligst oppgi kontaktaktinformasjon'),
            'Shared question text is written once'
        );
    }

    @IsTest
    static void numbersFylkeQuestionsUnderOwnHeading() {
        Map<String, String> values = baseValues();
        values.put('s_1_oest', '1');
        values.put('s_6_oest', '1');
        values.put('s_2_oest', '1');

        TAG_SurveyXactAnswerFormatter.Answers answers = TAG_SurveyXactAnswerFormatter.build(values);

        System.assert(
            answers.answers.contains('--- TILLEGGSSPØRSMÅL FRA FYLKET ---'),
            'Fylke questions get their own heading'
        );
        System.assert(
            answers.answers.contains('Tilleggsspørsmål 1\nEr det aktuelt'),
            'First fylke question is numbered'
        );
        System.assert(answers.answers.contains('Tilleggsspørsmål 2\nKan din bedrift'), 'Numbering continues');
        System.assert(answers.answers.contains('Tilleggsspørsmål 3\nPå bakgrunn'), 'Third fylke question is numbered');
        System.assert(
            answers.answers.indexOf('--- TILLEGGSSPØRSMÅL FRA FYLKET ---') >
            answers.answers.indexOf('1. Hvor mange ansatte'),
            'Heading comes after the base questions'
        );
    }

    @IsTest
    static void omitsFylkeHeadingWhenOnlyBaseQuestionsAnswered() {
        TAG_SurveyXactAnswerFormatter.Answers answers = TAG_SurveyXactAnswerFormatter.build(baseValues());

        System.assert(
            !answers.answers.contains('TILLEGGSSPØRSMÅL'),
            'No heading when the respondent had no fylke questions'
        );
    }

    @IsTest
    static void buildsJsonOfNonEmptyColumns() {
        TAG_SurveyXactAnswerFormatter.Answers answers = TAG_SurveyXactAnswerFormatter.build(
            new Map<String, String>{ 'ans_idag' => '12', 'orgnr' => '912976904', 'problem' => '', 'basis_2' => '1' }
        );

        Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(answers.rawJson);

        System.assertEquals(3, parsed.size(), 'Empty columns are left out');
        System.assertEquals('912976904', parsed.get('orgnr'), 'Registry columns are kept');
        System.assert(!parsed.containsKey('problem'), 'Blank answer is not stored');
    }

    @IsTest
    static void returnsEmptyWhenNoAnswers() {
        System.assert(TAG_SurveyXactAnswerFormatter.build(null).isEmpty(), 'Null input gives no answers');
        System.assert(
            TAG_SurveyXactAnswerFormatter.build(new Map<String, String>()).isEmpty(),
            'Empty input gives no answers'
        );

        TAG_SurveyXactAnswerFormatter.Answers answers = TAG_SurveyXactAnswerFormatter.build(
            new Map<String, String>{ 'bedrnr' => '123456789', 'ans_idag' => '' }
        );
        System.assert(answers.isEmpty(), 'Only background data counts as no answers');
        System.assertNotEquals(null, answers.rawJson, 'Background data is still kept as raw JSON');
    }

    @IsTest
    static void reportsUnknownAnswerCode() {
        List<String> unknownValues = new List<String>();

        TAG_SurveyXactAnswerFormatter.Answers answers = TAG_SurveyXactAnswerFormatter.build(
            new Map<String, String>{ 'ans_1aar' => '9', 'ans_idag' => '5' },
            unknownValues
        );

        System.assert(!answers.answers.contains('2. Hvor mange ansatte venter dere'), 'Unmapped code is skipped');
        System.assertEquals(null, answers.employeeOutlookOneYear, 'Unmapped code is not written to the picklist');
        System.assert(answers.answers.contains('\n5'), 'Other answers are still included');
        System.assert(unknownValues.contains('ans_1aar=9'), 'Unknown code is reported to the caller');
    }

    @IsTest
    static void ignoresEmployeeCountThatIsNotAWholeNumber() {
        System.assertEquals(
            null,
            TAG_SurveyXactAnswerFormatter.build(new Map<String, String>{ 'ans_idag' => 'ca 15' }).employeesToday,
            'Free text is not written to the number field'
        );
        System.assertEquals(
            null,
            TAG_SurveyXactAnswerFormatter.build(new Map<String, String>{ 'ans_idag' => '120000' }).employeesToday,
            'Value above the field length is left out'
        );

        TAG_SurveyXactAnswerFormatter.Answers answers = TAG_SurveyXactAnswerFormatter.build(
            new Map<String, String>{ 'ans_idag' => 'ca 15' }
        );
        System.assert(answers.answers.contains('ca 15'), 'The typed answer is still kept as text');
    }
}
