/**
 * Turns one respondent row from the dataset export into the field values stored
 * on CustomCampaignMember__c.
 *
 * The export has one column per possible answer, so a grid question such as
 * question 5 spans 30 columns and a checkbox question one column per option.
 * This class collapses that back into the questions the respondent actually
 * saw, using the texts in TAG_SurveyXactCodebook. Column names are the
 * truncated 8-character names from the CSV header.
 *
 * Both base and fylke-specific questions are rendered. Questions the respondent
 * skipped are left out entirely.
 */
public with sharing class TAG_SurveyXactAnswerFormatter {
    private static final String COL_EMPLOYEES_TODAY = 'ans_idag';
    private static final String COL_EMPLOYEES_ONE_YEAR = 'ans_1aar';
    private static final String COL_RECRUITMENT_PROBLEM = 'problem';
    private static final String COL_PROBLEM_CAUSE = 'alv_prob';

    private static final Integer GRID_ROWS = 10;
    private static final String CHECKED = '1';

    // Field lengths on CustomCampaignMember__c. Rendered text stays well below
    // these, but free-text answers have no length limit in SurveyXact, so values
    // are truncated rather than risking the whole batch failing.
    private static final Integer MAX_ANSWERS = 131072;
    private static final Integer MAX_JSON = 131072;
    private static final Integer MAX_UNFILLED_POSITIONS = 5000;
    private static final Integer MAX_AI = 2000;

    // TAG_BUEmployeesToday__c is Number(5,0) and the source is a free-text box.
    private static final Integer MAX_EMPLOYEES = 99999;
    private static final Pattern WHOLE_NUMBER = Pattern.compile('^[0-9]{1,5}$');

    private static final String Q5 = '5. Innen hvilke yrker har dere forsøkt å rekruttere inn personer uten å få tak i rett/ønsket kompetanse, hvilken utdanningsbakgrunn var mest relevant for stillingen(e), og hvor mange stillinger dreier det seg om?';
    private static final String Q_AI_USAGE = '6. Bruker virksomheten kunstig intelligens (KI) for å gjennomføre en eller flere av følgende arbeidsoppgaver?';
    private static final String Q_AI_REASON = '7. Hva er de viktigste grunnene til at virksomheten ikke bruker KI?';

    // Fylke-specific questions have no number in the questionnaire, so they are
    // gathered under their own heading and numbered from 1.
    private static final String FYLKE_HEADING = '--- TILLEGGSSPØRSMÅL FRA FYLKET ---';
    private static final String FYLKE_QUESTION_PREFIX = 'Tilleggsspørsmål ';

    private static final List<String> AI_USAGE_COLUMNS = new List<String>{
        'basis_1',
        'basis_2',
        'basis_3',
        'basis_4',
        'basis_5',
        'basis_6',
        'basis_7',
        'basis_8'
    };

    private static final List<String> AI_REASON_COLUMNS = new List<String>{
        'basis_9',
        'basi_10',
        'basi_11',
        'basi_12',
        'basi_13'
    };

    private static final Map<String, String> EMPLOYEES_ONE_YEAR_PICKLIST = new Map<String, String>{
        '1' => 'Flere enn i dag',
        '2' => 'Like mange som i dag',
        '3' => 'Færre enn i dag'
    };

    // Shortened so the value reads well as a report or list view column. The
    // full wording is kept in TAG_BUAnswers__c.
    private static final Map<String, String> RECRUITMENT_PROBLEM_PICKLIST = new Map<String, String>{
        '1' => 'Ja, vi fikk ikke ansatt noen',
        '2' => 'Ansatt med lavere/annen kompetanse',
        '3' => 'Nei'
    };

    private static final Map<String, String> PROBLEM_CAUSE_PICKLIST = new Map<String, String>{
        '1' => 'Ingen/for få kvalifiserte søkere',
        '2' => 'Annet'
    };

    private static Map<String, String> optionsByColumn;

    // The values written to one member record.
    public class Answers {
        public String answers;
        public String rawJson;
        public Decimal employeesToday;
        public String employeeOutlookOneYear;
        public String failedRecruitment;
        public String failedRecruitmentCause;
        public String unfilledPositions;
        public String aiUsage;
        public String aiNotUsedReason;

        public Boolean isEmpty() {
            return String.isBlank(answers);
        }
    }

    public static Answers build(Map<String, String> values) {
        return build(values, null);
    }

    // Codes missing from the codebook are added to unknownValues so the caller
    // can log them. Such answers are skipped rather than stored.
    public static Answers build(Map<String, String> values, List<String> unknownValues) {
        Answers result = new Answers();
        if (values == null || values.isEmpty()) {
            return result;
        }

        result.answers = truncate(renderAll(values, unknownValues), MAX_ANSWERS);
        result.rawJson = truncate(toJson(values), MAX_JSON);
        result.employeesToday = parseEmployees(valueOf(values, COL_EMPLOYEES_TODAY));
        result.employeeOutlookOneYear = picklist(
            values,
            COL_EMPLOYEES_ONE_YEAR,
            EMPLOYEES_ONE_YEAR_PICKLIST,
            unknownValues
        );
        result.failedRecruitment = picklist(
            values,
            COL_RECRUITMENT_PROBLEM,
            RECRUITMENT_PROBLEM_PICKLIST,
            unknownValues
        );
        result.failedRecruitmentCause = picklist(values, COL_PROBLEM_CAUSE, PROBLEM_CAUSE_PICKLIST, unknownValues);
        result.unfilledPositions = truncate(recruitmentGrid(values), MAX_UNFILLED_POSITIONS);
        result.aiUsage = truncate(checkboxes(values, Q_AI_USAGE, AI_USAGE_COLUMNS), MAX_AI);
        result.aiNotUsedReason = truncate(checkboxes(values, Q_AI_REASON, AI_REASON_COLUMNS), MAX_AI);
        return result;
    }

    // Renders every answered question in questionnaire order, with the fylke
    // questions in a section of their own. Returns null when the respondent
    // answered nothing.
    private static String renderAll(Map<String, String> values, List<String> unknownValues) {
        List<String> baseBlocks = new List<String>();
        List<String> fylkeBlocks = new List<String>();

        List<String> blocks = baseBlocks;
        String currentQuestion = null;
        List<String> currentLines = new List<String>();
        Boolean gridAdded = false;

        for (TAG_SurveyXactCodebook.Variable variable : TAG_SurveyXactCodebook.VARIABLES) {
            // Fylke columns follow the base questions in the codebook, so the
            // first one also marks where question 5 belongs.
            if (!gridAdded && variable.column.startsWith('s_')) {
                flush(blocks, currentQuestion, currentLines);
                currentQuestion = null;
                currentLines = new List<String>();
                addGrid(blocks, values);
                gridAdded = true;
                blocks = fylkeBlocks;
            }

            String line = renderVariable(variable, values, unknownValues);
            if (line == null) {
                continue;
            }

            if (variable.question != currentQuestion) {
                flush(blocks, currentQuestion, currentLines);
                currentQuestion = variable.question;
                currentLines = new List<String>();
            }
            currentLines.add(line);
        }
        flush(blocks, currentQuestion, currentLines);

        if (!gridAdded) {
            addGrid(baseBlocks, values);
        }

        List<String> all = new List<String>(baseBlocks);
        if (!fylkeBlocks.isEmpty()) {
            all.add(FYLKE_HEADING);
            for (Integer i = 0; i < fylkeBlocks.size(); i++) {
                all.add(FYLKE_QUESTION_PREFIX + (i + 1) + '\n' + fylkeBlocks[i]);
            }
        }

        return all.isEmpty() ? null : String.join(all, '\n\n');
    }

    private static String renderVariable(
        TAG_SurveyXactCodebook.Variable variable,
        Map<String, String> values,
        List<String> unknownValues
    ) {
        String raw = valueOf(values, variable.column);
        if (String.isBlank(raw)) {
            return null;
        }

        if (variable.kind == TAG_SurveyXactCodebook.AnswerKind.MULTIPLE) {
            return CHECKED.equals(raw) ? '- ' + variable.option : null;
        }

        if (variable.kind == TAG_SurveyXactCodebook.AnswerKind.SINGLE) {
            String label = variable.valueLabels == null ? null : variable.valueLabels.get(raw);
            if (String.isBlank(label)) {
                addUnknown(unknownValues, variable.column, raw);
                return null;
            }
            return prefixed(variable.option, label);
        }

        return prefixed(variable.option, raw);
    }

    private static String prefixed(String option, String answer) {
        return String.isBlank(option) ? answer : option + ' ' + answer;
    }

    private static void flush(List<String> blocks, String question, List<String> lines) {
        if (String.isNotBlank(question) && !lines.isEmpty()) {
            blocks.add(question + '\n' + String.join(lines, '\n'));
        }
    }

    private static void addGrid(List<String> blocks, Map<String, String> values) {
        String grid = recruitmentGrid(values);
        if (String.isNotBlank(grid)) {
            blocks.add(Q5 + '\n' + grid);
        }
    }

    // Question 5 is a grid of 10 rows with occupation, education and a count.
    // Columns are named s_2_{row}a, s_2_{row}b and s_2_{row}.
    private static String recruitmentGrid(Map<String, String> values) {
        List<String> rows = new List<String>();
        for (Integer i = 1; i <= GRID_ROWS; i++) {
            String occupation = valueOf(values, 's_2_' + i + 'a');
            String education = valueOf(values, 's_2_' + i + 'b');
            String positions = valueOf(values, 's_2_' + i);

            if (String.isBlank(occupation) && String.isBlank(education) && String.isBlank(positions)) {
                continue;
            }

            List<String> lines = new List<String>();
            if (String.isNotBlank(occupation)) {
                lines.add('Yrke: ' + occupation);
            }
            if (String.isNotBlank(education)) {
                lines.add('Utdanning: ' + education);
            }
            if (String.isNotBlank(positions)) {
                lines.add('Antall stillinger: ' + positions);
            }
            rows.add(String.join(lines, '\n'));
        }
        return rows.isEmpty() ? null : String.join(rows, '\n\n');
    }

    private static String checkboxes(Map<String, String> values, String question, List<String> columns) {
        List<String> selected = new List<String>();
        for (String column : columns) {
            if (CHECKED.equals(valueOf(values, column))) {
                String option = optionLabel(column);
                if (String.isNotBlank(option)) {
                    selected.add('- ' + option);
                }
            }
        }
        return selected.isEmpty() ? null : question + '\n' + String.join(selected, '\n');
    }

    private static String optionLabel(String column) {
        if (optionsByColumn == null) {
            optionsByColumn = new Map<String, String>();
            for (TAG_SurveyXactCodebook.Variable variable : TAG_SurveyXactCodebook.VARIABLES) {
                optionsByColumn.put(variable.column, variable.option);
            }
        }
        return optionsByColumn.get(column);
    }

    private static String picklist(
        Map<String, String> values,
        String column,
        Map<String, String> labels,
        List<String> unknownValues
    ) {
        String raw = valueOf(values, column);
        if (String.isBlank(raw)) {
            return null;
        }
        String label = labels.get(raw);
        if (String.isBlank(label)) {
            addUnknown(unknownValues, column, raw);
            return null;
        }
        return label;
    }

    // The source is a free-text box, so anything that is not a plain whole
    // number is left out. The typed answer is still kept in TAG_BUAnswers__c.
    private static Decimal parseEmployees(String raw) {
        if (String.isBlank(raw)) {
            return null;
        }
        String digits = raw.trim().replaceAll('\\s', '');
        if (!WHOLE_NUMBER.matcher(digits).matches()) {
            return null;
        }
        Decimal parsed = Decimal.valueOf(digits);
        return parsed > MAX_EMPLOYEES ? null : parsed;
    }

    // Every non-empty column, so a response can be re-read if the fields we map
    // to change later. Keys are sorted to keep the output stable.
    private static String toJson(Map<String, String> values) {
        List<String> columns = new List<String>();
        for (String column : values.keySet()) {
            if (String.isNotBlank(column) && String.isNotBlank(values.get(column))) {
                columns.add(column);
            }
        }
        if (columns.isEmpty()) {
            return null;
        }
        columns.sort();

        JSONGenerator generator = JSON.createGenerator(false);
        generator.writeStartObject();
        for (String column : columns) {
            generator.writeStringField(column, values.get(column).trim());
        }
        generator.writeEndObject();
        return generator.getAsString();
    }

    private static void addUnknown(List<String> unknownValues, String column, String raw) {
        if (unknownValues != null) {
            unknownValues.add(column + '=' + raw);
        }
    }

    private static String truncate(String value, Integer maxLength) {
        if (String.isBlank(value)) {
            return null;
        }
        return value.length() <= maxLength ? value : value.abbreviate(maxLength);
    }

    private static String valueOf(Map<String, String> values, String column) {
        String raw = values.get(column);
        return raw == null ? null : raw.trim();
    }
}
