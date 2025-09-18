public with sharing class SharedIntegrationFunctions {
    public static Map<String, User> fetchUsersByTitle(Set<String> userTitles) {
        List<User> users = [SELECT Id, Title FROM User WHERE Title IN :userTitles];
        Map<String, User> userMap = new Map<String, User>();
        for (User u : users) {
            userMap.put(u.Title, u);
        }

        return userMap;
    }

    /**
     * Converts a Norwegian datetime string to GMT.
     */
    public static DateTime convertNorwegianTimeToGmt(String datetimeString) {
        if (datetimeString == null || String.isBlank(datetimeString.trim())) {
            return null;
        }
        String formattedDateTime = datetimeString.replaceAll('T', ' ');
        try {
            DateTime tempDateTime = DateTime.valueOfGmt(formattedDateTime);
            TimeZone norwegianTz = TimeZone.getTimeZone('Europe/Oslo');
            if (norwegianTz == null) {
                return null;
            }
            Integer offsetMilliseconds = norwegianTz.getOffset(tempDateTime);
            DateTime gmtDateTime = tempDateTime.addSeconds(-offsetMilliseconds / 1000);
            if (gmtDateTime.year() < 1700 || gmtDateTime.year() > 4000) {
                return null;
            }
            return gmtDateTime;
        } catch (TypeException e) {
            return null;
        }
    }

    /**
     * @description Uses JSON parser to deserialize DateTimes in ISO format "yyyy-MM-dd'T'HH:mm:ss.SSSZ".
     * @param datetimeString The datetime string to parse. For instance 2020-01-04T23:30:05.711Z or 2020-01-05T00:30:05.711Z-02:00
     * @return DateTime object or null if the year is out of range.
     */
    public static DateTime parseISODateTime(String datetimeString) {
        Datetime result = (DateTime) JSON.deserialize('"' + datetimeString + '"', DateTime.class);
        if (result.year() < 1700 || result.year() > 4000) {
            return null;
        }
        return result;
    }

    /**
     * @description Calculates difference in minutes between two timestamps.
     * If either timestamp is null, or if the difference is negative, null is returned.
     * @param past The earlier timestamp.
     * @param present The later timestamp.
     * @return Integer difference in minutes, or null if inputs are invalid.
     */
    public static Integer calculateMinutesBetween(DateTime past, DateTime present) {
        if (past == null || present == null || past > present) {
            return null;
        }
        if (past == present) {
            return 0;
        }
        Long diffInMillis = present.getTime() - past.getTime();

        try {
            Long diffInMinutes = diffInMillis / 60000;
            return diffInMinutes.intValue();
        } catch (System.MathException e) {
            System.debug(LoggingLevel.ERROR, 'Math calculation error in calculateMinutesBetween: ' + e.getMessage());
            return null;
        }
    }
}
