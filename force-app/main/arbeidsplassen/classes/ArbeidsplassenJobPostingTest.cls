@IsTest
public with sharing class ArbeidsplassenJobPostingTest {
    private static final String JSON =
        '{\n' +
        '  "uuid": "8e019569-0a0b-4f34-8d43-4498b9f0b32b",\n' +
        '  "title": "Hedda Hytter søker tømrer/tømrerlag for oppføring av hytter på Østlandet.",\n' +
        '  "status": "INACTIVE",\n' +
        '  "published": "2022-02-18T07:07:07.064711",\n' +
        '  "expires": "2022-03-31T00:00:00",\n' +
        '  "created": "2022-02-18T07:17:50.477069",\n' +
        '  "updated": "2022-02-18T07:19:21.575794",\n' +
        '  "source": "FINN",\n' +
        '  "medium": "FINN",\n' +
        '  "reference": "248749509",\n' +
        '  "businessName": "Hedda Hytter AS",\n' +
        '  "locations": [\n' +
        '    {\n' +
        '      "address": "Hedalsvegen 1165",\n' +
        '      "city": "HEDALEN",\n' +
        '      "country": "NORGE",\n' +
        '      "county": "INNLANDET",\n' +
        '      "county_code": "34",\n' +
        '      "latitude": "60.54515075683594",\n' +
        '      "longitude": "9.809159278869629",\n' +
        '      "municipal": "SØR-AURDA",\n' +
        '      "municipal_code": "3449",\n' +
        '      "postalCode": "3528"\n' +
        '\n' +
        '\n' +
        '    }\n' +
        '  ],\n' +
        '  "properties": [\n' +
        '    {\n' +
        '      "key": "extent",\n' +
        '      "value": "Heltid"\n' +
        '    },\n' +
        '    {\n' +
        '      "key": "positioncount",\n' +
        '      "value": "6"\n' +
        '    },\n' +
        '    {\n' +
        '      "key": "engagementtype" ,\n' +
        '      "value": "Fast"\n' +
        '    },\n' +
        '    {\n' +
        '      "key": "sourceur",\n' +
        '      "value": "https://www.finn.no/248749509"\n' +
        '    }\n' +
        '  ],\n' +
        '  "categories": [\n' +
        '   {\n' +
        '      "styrkCode": "STYRK08",\n' +
        '      "name": "Fylkesjordskiftesjef"\n' +
        '    }\n' +
        '  ],\n' +
        '  "contacts": [\n' +
        '    {\n' +
        '      "name": "Kari Nordmann",\n' +
        '      "email": "kari@nav.no",\n' +
        '      "phone": "41161711",\n' +
        '      "role": "Daglig leder",\n' +
        '      "title": "Daglig leder"\n' +
        '    }\n' +
        '  ],\n' +
        '  "employer": {\n' +
        '    "name": "Hedda Hytter AS",\n' +
        '    "publicName": "Hedda Hytter AS",\n' +
        '    "orgnr": "123456789",\n' +
        '    "parentOrgnr": "123456799",\n' +
        '    "orgform": "AS"\n' +
        '  }\n' +
        '  \n' +
        '\n' +
        '}';

    private static final String JSON_WITH_NULLS =
        '{\n' +
        '  "uuid": "8e019569-0a0b-4f34-8d43-4498b9f0b32b",\n' +
        '  "title": "Hedda Hytter søker tømrer/tømrerlag for oppføring av hytter på Østlandet.",\n' +
        '  "status": "INACTIVE",\n' +
        '  "published": "2022-02-18T07:07:07.064711",\n' +
        '  "expires": "2022-03-31T00:00:00",\n' +
        '  "created": "2022-02-18T07:17:50.477069",\n' +
        '  "updated": "2022-02-18T07:19:21.575794",\n' +
        '  "source": "FINN",\n' +
        '  "medium": "FINN",\n' +
        '  "reference": "248749509",\n' +
        '  "businessName": "Hedda Hytter AS",\n' +
        '  "locations": [\n' +
        '    {\n' +
        '      "address": null,\n' +
        '      "city": null,\n' +
        '      "country": "NORGE",\n' +
        '      "county": null,\n' +
        '      "county_code": null,\n' +
        '      "latitude": null,\n' +
        '      "longitude": null,\n' +
        '      "municipal": null,\n' +
        '      "municipal_code": null,\n' +
        '      "postalCode": null\n' +
        '\n' +
        '\n' +
        '    }\n' +
        '  ],\n' +
        '  "properties": [\n' +
        '    {\n' +
        '      "key": "extent",\n' +
        '      "value": "Heltid"\n' +
        '    },\n' +
        '    {\n' +
        '      "key": "positioncount",\n' +
        '      "value": "6"\n' +
        '    },\n' +
        '    {\n' +
        '      "key": "engagementtype" ,\n' +
        '      "value": "Fast"\n' +
        '    },\n' +
        '    {\n' +
        '      "key": "sourceur",\n' +
        '      "value": "https://www.finn.no/248749509"\n' +
        '    }\n' +
        '  ],\n' +
        '  "categories": [\n' +
        '   {\n' +
        '      "styrkCode": "STYRK08",\n' +
        '      "name": "Fylkesjordskiftesjef"\n' +
        '    }\n' +
        '  ],\n' +
        '  "contacts": [\n' +
        '    {\n' +
        '      "name": "Kari Nordmann",\n' +
        '      "email": "kari@nav.no",\n' +
        '      "phone": "41161711",\n' +
        '      "role": "Daglig leder",\n' +
        '      "title": "Daglig leder"\n' +
        '    }\n' +
        '  ],\n' +
        '  "employer": {\n' +
        '    "name": "Hedda Hytter AS",\n' +
        '    "publicName": "Hedda Hytter AS",\n' +
        '    "orgnr": null,\n' +
        '    "parentOrgnr": null,\n' +
        '    "orgform": "AS"\n' +
        '  }\n' +
        '  \n' +
        '\n' +
        '}';

    @IsTest
    static void parse_successNoNulls() {
        ArbeidsplassenJobPosting model = ArbeidsplassenJobPosting.parse(JSON, 'testkey', 'testhash');

        System.assertEquals('8e019569-0a0b-4f34-8d43-4498b9f0b32b', model.uuid);
        System.assertEquals('Hedda Hytter søker tømrer/tømrerlag for oppføring av hytter på Østlandet.', model.title);
        System.assertEquals('INACTIVE', model.status);
        System.assertEquals('2022-02-18T07:07:07.064711', model.published);
        System.assertEquals('2022-03-31T00:00:00', model.expires);
        System.assertEquals('2022-02-18T07:17:50.477069', model.created);
        System.assertEquals('2022-02-18T07:19:21.575794', model.updated);
        System.assertEquals('FINN', model.source);
        System.assertEquals('FINN', model.medium);
        System.assertEquals('248749509', model.reference);
        System.assertEquals('Hedda Hytter AS', model.businessName);
        System.assertEquals(1, model.locations.size());
        System.assertEquals(4, model.properties.size());
        System.assertEquals(1, model.categories.size());
        System.assertEquals(1, model.contacts.size());
        System.assertEquals('Hedda Hytter AS', model.employer.name);
        System.assertEquals('Hedda Hytter AS', model.employer.publicName);
        System.assertEquals('123456789', model.employer.orgnr);
        System.assertEquals('123456799', model.employer.parentOrgnr);
        System.assertEquals('AS', model.employer.orgform);
    }

    @IsTest
    static void parse_successNulls() {
        ArbeidsplassenJobPosting model = ArbeidsplassenJobPosting.parse(JSON_WITH_NULLS, 'testkey', 'testhash');

        System.assertEquals('8e019569-0a0b-4f34-8d43-4498b9f0b32b', model.uuid);
        System.assertEquals('Hedda Hytter søker tømrer/tømrerlag for oppføring av hytter på Østlandet.', model.title);
        System.assertEquals('INACTIVE', model.status);
        System.assertEquals('2022-02-18T07:07:07.064711', model.published);
        System.assertEquals('2022-03-31T00:00:00', model.expires);
        System.assertEquals('2022-02-18T07:17:50.477069', model.created);
        System.assertEquals('2022-02-18T07:19:21.575794', model.updated);
        System.assertEquals('FINN', model.source);
        System.assertEquals('FINN', model.medium);
        System.assertEquals('248749509', model.reference);
        System.assertEquals('Hedda Hytter AS', model.businessName);
        System.assertEquals(1, model.locations.size());
        System.assertEquals(4, model.properties.size());
        System.assertEquals(1, model.categories.size());
        System.assertEquals(1, model.contacts.size());
        System.assertEquals('Hedda Hytter AS', model.employer.name);
        System.assertEquals('Hedda Hytter AS', model.employer.publicName);
        System.assertEquals(null, model.employer.orgnr);
        System.assertEquals(null, model.employer.parentOrgnr);
        System.assertEquals('AS', model.employer.orgform);
    }
}
