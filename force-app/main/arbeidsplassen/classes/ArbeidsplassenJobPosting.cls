public with sharing class ArbeidsplassenJobPosting {
    public List<Property> properties { get; set; }
    public List<Location> locations { get; set; }
    public List<Contact> contacts { get; set; }
    public List<StyrkCategory> categories { get; set; }
    public Company employer { get; set; }

    public String businessName { get; set; }
    public String published { get; set; }
    public String reference { get; set; }
    public String expires { get; set; }
    public String created { get; set; }
    public String updated { get; set; }
    public String status { get; set; }
    public String medium { get; set; }
    public String source { get; set; }
    public String title { get; set; }
    public String uuid { get; set; }

    public String jsonPayload { get; set; }
    public String hash { get; set; }
    public String key { get; set; }

    public class Location {
        public String municipal_code { get; set; }
        public String county_code { get; set; }
        public String postalCode { get; set; }
        public String municipal { get; set; }
        public String longitude { get; set; }
        public String latitude { get; set; }
        public String country { get; set; }
        public String address { get; set; }
        public String county { get; set; }
        public String city { get; set; }
    }

    public class Property {
        public String value { get; set; }
        public String key { get; set; }
    }

    public class StyrkCategory {
        public String styrkCode { get; set; }
        public String name { get; set; }
    }

    public class Contact {
        public String email { get; set; }
        public String phone { get; set; }
        public String title { get; set; }
        public String role { get; set; }
        public String name { get; set; }
    }

    public class Company {
        public String parentOrgnr { get; set; }
        public String publicName { get; set; }
        public String orgform { get; set; }
        public String orgnr { get; set; }
        public String name { get; set; }
    }

    public static ArbeidsplassenJobPosting parse(String json, String key, String hash) {
        ArbeidsplassenJobPosting model = (ArbeidsplassenJobPosting) System.JSON.deserialize(
            json,
            ArbeidsplassenJobPosting.class
        );
        model.jsonPayload = json;
        model.hash = hash;
        model.key = key;

        return model;
    }
}
