/**
 * Parser datauttrekket fra SurveyXact og plukker ut de to kolonnene importen
 * trenger: respondentnøkkel og organisasjonsnummer.
 *
 * Uttrekket har rundt 295 kolonner. Å beholde alle ville brukt ca. ti ganger
 * mer heap enn nødvendig, så resten forkastes.
 */
public with sharing class TAG_SurveyXactMemberImportParser {
    public static final String DEFAULT_DELIMITER = ';';
    public static final String KEY_COLUMN = 'respnokk';
    public static final String ORG_NUMBER_COLUMN = 'bedrnr';

    public class Respondent {
        public String externalKey;
        public String organizationNumber;

        public Respondent(String externalKey, String organizationNumber) {
            this.externalKey = externalKey;
            this.organizationNumber = organizationNumber;
        }
    }

    public static List<Respondent> parse(String csvBody) {
        return parse(csvBody, DEFAULT_DELIMITER);
    }

    public static List<Respondent> parse(String csvBody, String delimiter) {
        List<Respondent> result = new List<Respondent>();
        List<List<String>> table = tokenize(csvBody, delimiter);
        if (table.isEmpty()) {
            return result;
        }

        List<String> headers = table[0];
        Integer keyIdx = indexOfHeader(headers, KEY_COLUMN);
        Integer orgIdx = indexOfHeader(headers, ORG_NUMBER_COLUMN);

        for (Integer r = 1; r < table.size(); r++) {
            List<String> cols = table[r];
            if (isEmptyRow(cols)) {
                continue;
            }
            result.add(new Respondent(valueAt(cols, keyIdx), valueAt(cols, orgIdx)));
        }
        return result;
    }

    private static String valueAt(List<String> cols, Integer index) {
        return index >= 0 && index < cols.size() ? cols[index] : null;
    }

    private static Integer indexOfHeader(List<String> headers, String name) {
        for (Integer i = 0; i < headers.size(); i++) {
            if (headers[i] != null && headers[i].trim().equalsIgnoreCase(name)) {
                return i;
            }
        }
        return -1;
    }

    private static Boolean isEmptyRow(List<String> cols) {
        if (cols == null || cols.isEmpty()) {
            return true;
        }
        for (String c : cols) {
            if (String.isNotBlank(c)) {
                return false;
            }
        }
        return true;
    }

    // Splitter CSV-innholdet i rader og felter. Følger RFC 4180-quoting.
    private static List<List<String>> tokenize(String content, String delimiter) {
        List<List<String>> rows = new List<List<String>>();
        if (String.isBlank(content)) {
            return rows;
        }

        String delim = String.isBlank(delimiter) ? DEFAULT_DELIMITER : delimiter;
        Integer delimChar = delim.charAt(0);
        Integer quoteChar = '"'.charAt(0);
        Integer carriageReturn = 13;
        Integer lineFeed = 10;

        List<String> currentRow = new List<String>();
        List<Integer> field = new List<Integer>();
        Boolean inQuotes = false;
        Integer len = content.length();

        for (Integer i = 0; i < len; i++) {
            Integer ch = content.charAt(i);

            if (inQuotes) {
                if (ch == quoteChar) {
                    if (i + 1 < len && content.charAt(i + 1) == quoteChar) {
                        field.add(quoteChar);
                        i++;
                    } else {
                        inQuotes = false;
                    }
                } else {
                    field.add(ch);
                }
            } else if (ch == quoteChar) {
                inQuotes = true;
            } else if (ch == delimChar) {
                currentRow.add(fieldToString(field));
                field = new List<Integer>();
            } else if (ch == lineFeed) {
                currentRow.add(fieldToString(field));
                field = new List<Integer>();
                rows.add(currentRow);
                currentRow = new List<String>();
            } else if (ch != carriageReturn) {
                field.add(ch);
            }
        }

        currentRow.add(fieldToString(field));
        rows.add(currentRow);
        return rows;
    }

    private static String fieldToString(List<Integer> chars) {
        return chars.isEmpty() ? '' : String.fromCharArray(chars);
    }
}
