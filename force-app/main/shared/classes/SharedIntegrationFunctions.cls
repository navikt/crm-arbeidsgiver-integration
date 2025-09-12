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
}
