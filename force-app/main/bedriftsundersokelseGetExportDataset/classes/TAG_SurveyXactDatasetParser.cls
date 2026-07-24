/**
 * Parses a SurveyXact "Export dataset" CSV export.
 *
 * The dataset contains one column per survey variable. We only need the
 * respondent key ('respnokk') and the response status ('response'), which are
 * located by header name. The remaining columns are kept per row so any survey
 * variable stays accessible to callers.
 *
 * Handles quoted fields that contain the delimiter, line breaks or escaped
 * ("") quotes. The dataset is requested with shortVariableNames=true, so the
 * 8-character column names ('respnokk', 'response') are stable.
 */
public with sharing class TAG_SurveyXactDatasetParser {
    // format=EU uses a semicolon list separator.
    public static final String DEFAULT_DELIMITER = ';';
    public static final String KEY_COLUMN = 'respnokk';
    public static final String RESPONSE_COLUMN = 'response';

    public class Row {
        public String externalKey;
        public String responseStatus;
        public Map<String, String> values;

        public Row(String externalKey, String responseStatus, Map<String, String> values) {
            this.externalKey = externalKey;
            this.responseStatus = responseStatus;
            this.values = values;
        }
    }

    public static List<Row> parse(String csvBody) {
        return parse(csvBody, DEFAULT_DELIMITER);
    }

    public static List<Row> parse(String csvBody, String delimiter) {
        List<Row> result = new List<Row>();
        List<List<String>> table = tokenize(csvBody, delimiter);
        if (table.isEmpty()) {
            return result;
        }

        List<String> headers = table[0];
        Integer keyIdx = indexOfHeader(headers, KEY_COLUMN);
        Integer respIdx = indexOfHeader(headers, RESPONSE_COLUMN);

        for (Integer r = 1; r < table.size(); r++) {
            List<String> cols = table[r];
            if (isEmptyRow(cols)) {
                continue;
            }

            Map<String, String> values = new Map<String, String>();
            for (Integer c = 0; c < headers.size() && c < cols.size(); c++) {
                values.put(headers[c], cols[c]);
            }

            String key = valueAt(cols, keyIdx);
            String resp = valueAt(cols, respIdx);
            result.add(new Row(key, resp, values));
        }
        return result;
    }

    // Returns the distinct 'response' values across the parsed rows.
    public static Set<String> distinctResponseValues(List<Row> rows) {
        Set<String> values = new Set<String>();
        for (Row row : rows) {
            values.add(row.responseStatus);
        }
        return values;
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

    // Splits CSV content into rows of fields, honouring RFC 4180 style quoting
    // with a configurable delimiter.
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
