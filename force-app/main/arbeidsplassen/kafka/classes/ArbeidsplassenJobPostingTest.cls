@IsTest
public with sharing class ArbeidsplassenJobPostingTest {
    public static final String JSON =
        '{\n' +
        '  "uuid": "8e019569-0a0b-4f34-8d43-4498b9f0b32b",\n' +
        '  "title": "Medarbeider søkes",\n' +
        '  "status": "ACTIVE",\n' +
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
        '    },\n' +
        '    {\n' +
        '      "address": "Hedalsvegen 1165",\n' +
        '      "city": "OSLO",\n' +
        '      "country": "NORGE",\n' +
        '      "county": "OSLO",\n' +
        '      "county_code": "34",\n' +
        '      "latitude": "60.54515075683594",\n' +
        '      "longitude": "9.809159278869629",\n' +
        '      "municipal": "OSLO",\n' +
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
        '      "key": "sourceurl",\n' +
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

    public static final String JSON_WITH_NULLS =
        '{\n' +
        '  "uuid": "8e019569-0a0b-4f34-8d43-4498b9f0b32b",\n' +
        '  "title": "Medarbeider søkes",\n' +
        '  "status": "INACTIVE",\n' +
        '  "published": "2022-02-18T07:07:07.064711",\n' +
        '  "expires": "2022-03-31T00:00:00",\n' +
        '  "created": "2022-02-18T07:17:50.477069",\n' +
        '  "updated": "2021-02-18T07:19:21.575794",\n' +
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

    public static final String JSON_NEW_FORMAT =
        '{\n' +
        '   "uuid":"79867b56-ab2c-47b7-b85c-95ada4aeb348",\n' +
        '   "adnr":"R996802",\n' +
        '   "title":"Ny stilling",\n' +
        '   "status":"INACTIVE",\n' +
        '   "privacy":"INTERNAL_NOT_SHOWN",\n' +
        '   "administration": {\n' +
        '       "status":"DONE",\n' +
        '       "remarks":[],\n' +
        '       "comments":"",\n' +
        '       "reportee":"Stig Garberg-Johnsen",\n' +
        '       "navIdent":"G111709"},\n' +
        '   "published":"2025-11-10T12:54:11.466407",\n' +
        '   "expires":"2025-12-10T12:54:11.466468",\n' +
        '   "created":"2025-11-10T12:54:11.466407",\n' +
        '   "updated":"2025-11-10T12:54:11.466407",\n' +
        '   "employer":null,\n' +
        '   "categories":[],\n' +
        '   "source":"DIR",\n' +
        '   "medium":"DIR",\n' +
        '   "reference":"79867b56-ab2c-47b7-b85c-95ada4aeb348",\n' +
        '   "publishedByAdmin":null,\n' +
        '   "businessName":null,\n' +
        '   "locations":[],\n' +
        '   "properties":[],\n' +
        '   "contacts":[],\n' +
        '   "classifications":[]\n' +
        '}';

    @IsTest
    static void parse_newFormat() {
        ArbeidsplassenJobPosting model = ArbeidsplassenJobPosting.parse(JSON_NEW_FORMAT, 'testkey', 'testhash');

        System.assertEquals('79867b56-ab2c-47b7-b85c-95ada4aeb348', model.uuid);
        System.assertEquals('Ny stilling', model.title);
        System.assertEquals('INACTIVE', model.status);
        System.assertEquals('2025-11-10T12:54:11.466407', model.published);
        System.assertEquals('2025-12-10T12:54:11.466468', model.expires);
        System.assertEquals('2025-11-10T12:54:11.466407', model.created);
        System.assertEquals('2025-11-10T12:54:11.466407', model.updated);
        System.assertEquals('DIR', model.source);
        System.assertEquals('DIR', model.medium);
        System.assertEquals('79867b56-ab2c-47b7-b85c-95ada4aeb348', model.reference);
        System.assertEquals(null, model.businessName);
        System.assertEquals(0, model.locations.size());
        System.assertEquals(0, model.properties.size());
        //  System.assert(model.categories == null);
        System.assertEquals(0, model.contacts.size());
        //  System.assertEquals(null, model.employer.name);
        //  System.assertEquals(null, model.employer.publicName);
        //  System.assertEquals(null, model.employer.orgnr);
        //  System.assertEquals(null, model.employer.parentOrgnr);
        //  System.assertEquals(null, model.employer.orgform);
    }

    public static final String JSON_RECRUITMENT_HELP =
        '{\n' +
        '  "uuid": "21c2a9e4-d013-4bf5-b30e-225d8695088d",\n' +
        '  "adnr": "1059662",\n' +
        '  "title": "Trenger en helt",\n' +
        '  "status": "ACTIVE",\n' +
        '  "privacy": "SHOW_ALL",\n' +
        '  "administration": {\n' +
        '    "status": "DONE",\n' +
        '    "remarks": [],\n' +
        '    "comments": "Auto approved - 2025-10-28T13:11:30.355133675\\n",\n' +
        '    "reportee": "AUTO",\n' +
        '    "navIdent": ""\n' +
        '  },\n' +
        '  "published": "2025-10-28T13:10:53",\n' +
        '  "expires": "2025-11-18T00:00:00",\n' +
        '  "created": "2025-10-28T13:11:30.528326",\n' +
        '  "updated": "2025-10-28T13:11:39.663852",\n' +
        '  "employer": {\n' +
        '    "name": "ORDKNAPP BLOMSTRETE TIGER AS",\n' +
        '    "publicName": "ORDKNAPP BLOMSTRETE TIGER AS",\n' +
        '    "orgnr": "312113341",\n' +
        '    "parentOrgnr": "311185268",\n' +
        '    "orgform": "BEDR"\n' +
        '  },\n' +
        '  "categories": [],\n' +
        '  "source": "Stillingsregistrering",\n' +
        '  "medium": "Stillingsregistrering",\n' +
        '  "reference": "21c2a9e4-d013-4bf5-b30e-225d8695088d",\n' +
        '  "publishedByAdmin": "2025-10-28T13:11:30.355187",\n' +
        '  "businessName": "Ordknapp Blomstrete Tiger As",\n' +
        '  "locations": [\n' +
        '    {\n' +
        '      "address": "Kong Oscarsgate 8B",\n' +
        '      "postalCode": "3112",\n' +
        '      "county": "VESTFOLD",\n' +
        '      "municipal": "TØNSBERG",\n' +
        '      "city": "TØNSBERG",\n' +
        '      "country": "NORGE",\n' +
        '      "latitude": null,\n' +
        '      "longitude": null,\n' +
        '      "municipal_code": "3905",\n' +
        '      "county_code": "39"\n' +
        '    }\n' +
        '  ],\n' +
        '  "properties": [\n' +
        '    {\n' +
        '      "key": "extent",\n' +
        '      "value": "Heltid"\n' +
        '    },\n' +
        '    {\n' +
        '      "key": "rekrutteringshjelp",\n' +
        '      "value": "true"\n' +
        '    },\n' +
        '    {\n' +
        '      "key": "rekrutteringshjelpTelefonnummer",\n' +
        '      "value": "12312312"\n' +
        '    },\n' +
        '    {\n' +
        '      "key": "workday",\n' +
        '      "value": "[\\"Ukedager\\"]"\n' +
        '    },\n' +
        '    {\n' +
        '      "key": "positioncount",\n' +
        '      "value": "1"\n' +
        '    },\n' +
        '    {\n' +
        '      "key": "engagementtype",\n' +
        '      "value": "Vikariat"\n' +
        '    },\n' +
        '    {\n' +
        '      "key": "starttime",\n' +
        '      "value": "Etter avtale"\n' +
        '    },\n' +
        '    {\n' +
        '      "key": "employerdescription",\n' +
        '      "value": "<p>Etterregistrering, Vi selger tigre, blomstre og knapper.</p>\\n"\n' +
        '    },\n' +
        '    {\n' +
        '      "key": "remote",\n' +
        '      "value": "Hybridkontor"\n' +
        '    },\n' +
        '    {\n' +
        '      "key": "classification_styrk08_code",\n' +
        '      "value": "8154"\n' +
        '    },\n' +
        '    {\n' +
        '      "key": "applicationemail",\n' +
        '      "value": "test@testnav.navtest"\n' +
        '    },\n' +
        '    {\n' +
        '      "key": "sector",\n' +
        '      "value": "Privat"\n' +
        '    },\n' +
        '    {\n' +
        '      "key": "workhours",\n' +
        '      "value": "[\\"Dagtid\\"]"\n' +
        '    },\n' +
        '    {\n' +
        '      "key": "applicationdue",\n' +
        '      "value": "Snarest"\n' +
        '    },\n' +
        '    {\n' +
        '      "key": "jobtitle",\n' +
        '      "value": "Bandasjearbeider"\n' +
        '    },\n' +
        '    {\n' +
        '      "key": "classification_styrk08_score",\n' +
        '      "value": "1.0"\n' +
        '    },\n' +
        '    {\n' +
        '      "key": "jobarrangement",\n' +
        '      "value": "Turnus"\n' +
        '    },\n' +
        '    {\n' +
        '      "key": "adtext",\n' +
        '      "value": "<p>Kor e alle helter hen?<br />\\nStå opp igjen<br />\\nZorro kom tilbake<br />\\nKem ska redde verden no?<br />\\nPrøysen og barnatro<br />\\nE nostalgi på video</p>\\n"\n' +
        '    },\n' +
        '    {\n' +
        '      "key": "workLanguage",\n' +
        '      "value": "[\\"Norsk\\"]"\n' +
        '    },\n' +
        '    {\n' +
        '      "key": "adtextFormat",\n' +
        '      "value": "ikkeStrukturert"\n' +
        '    },\n' +
        '    {\n' +
        '      "key": "ontologyJobtitle",\n' +
        '      "value": "{\\"konseptId\\":254881,\\"label\\":\\"Bandasjearbeider\\",\\"styrk08\\":\\"8154\\"}"\n' +
        '    },\n' +
        '    {\n' +
        '      "key": "classification_input_source",\n' +
        '      "value": "ontologyJobtitle"\n' +
        '    }\n' +
        '  ],\n' +
        '  "contacts": [],\n' +
        '  "classifications": [\n' +
        '    {\n' +
        '      "categoryType": "JANZZ",\n' +
        '      "code": "254881",\n' +
        '      "name": "Bandasjearbeider",\n' +
        '      "score": 1.0,\n' +
        '      "janzzParentId": "254881"\n' +
        '    },\n' +
        '    {\n' +
        '      "categoryType": "ESCO",\n' +
        '      "code": "http://data.europa.eu/esco/isco/C8154",\n' +
        '      "name": "Bandasjearbeider",\n' +
        '      "score": 1.0,\n' +
        '      "janzzParentId": "254881"\n' +
        '    },\n' +
        '    {\n' +
        '      "categoryType": "STYRK08",\n' +
        '      "code": "8154",\n' +
        '      "name": "Operatører innen tekstilbearbeiding",\n' +
        '      "score": 1.0,\n' +
        '      "janzzParentId": "254881"\n' +
        '    }\n' +
        '  ]\n' +
        '}';

    public static final String JSON_RECRUITMENT_HELP_FALSE =
        '{\n' +
        '  "uuid": "21c2a9e4-d013-4bf5-b30e-225d8695088d",\n' +
        '  "adnr": "1059662",\n' +
        '  "title": "Trenger en helt",\n' +
        '  "status": "ACTIVE",\n' +
        '  "privacy": "SHOW_ALL",\n' +
        '  "administration": {\n' +
        '    "status": "DONE",\n' +
        '    "remarks": [],\n' +
        '    "comments": "Auto approved - 2025-10-28T13:11:30.355133675\\n",\n' +
        '    "reportee": "AUTO",\n' +
        '    "navIdent": ""\n' +
        '  },\n' +
        '  "published": "2025-10-28T13:10:53",\n' +
        '  "expires": "2025-11-18T00:00:00",\n' +
        '  "created": "2025-10-28T13:11:30.528326",\n' +
        '  "updated": "2025-10-28T13:11:39.663852",\n' +
        '  "employer": {\n' +
        '    "name": "ORDKNAPP BLOMSTRETE TIGER AS",\n' +
        '    "publicName": "ORDKNAPP BLOMSTRETE TIGER AS",\n' +
        '    "orgnr": "312113341",\n' +
        '    "parentOrgnr": "311185268",\n' +
        '    "orgform": "BEDR"\n' +
        '  },\n' +
        '  "categories": [],\n' +
        '  "source": "Stillingsregistrering",\n' +
        '  "medium": "Stillingsregistrering",\n' +
        '  "reference": "21c2a9e4-d013-4bf5-b30e-225d8695088d",\n' +
        '  "publishedByAdmin": "2025-10-28T13:11:30.355187",\n' +
        '  "businessName": "Ordknapp Blomstrete Tiger As",\n' +
        '  "locations": [\n' +
        '    {\n' +
        '      "address": "Kong Oscarsgate 8B",\n' +
        '      "postalCode": "3112",\n' +
        '      "county": "VESTFOLD",\n' +
        '      "municipal": "TØNSBERG",\n' +
        '      "city": "TØNSBERG",\n' +
        '      "country": "NORGE",\n' +
        '      "latitude": null,\n' +
        '      "longitude": null,\n' +
        '      "municipal_code": "3905",\n' +
        '      "county_code": "39"\n' +
        '    }\n' +
        '  ],\n' +
        '  "properties": [\n' +
        '    {\n' +
        '      "key": "extent",\n' +
        '      "value": "Heltid"\n' +
        '    },\n' +
        '    {\n' +
        '      "key": "rekrutteringshjelp",\n' +
        '      "value": "false"\n' +
        '    },\n' +
        '    {\n' +
        '      "key": "workday",\n' +
        '      "value": "[\\"Ukedager\\"]"\n' +
        '    },\n' +
        '    {\n' +
        '      "key": "positioncount",\n' +
        '      "value": "1"\n' +
        '    },\n' +
        '    {\n' +
        '      "key": "engagementtype",\n' +
        '      "value": "Vikariat"\n' +
        '    },\n' +
        '    {\n' +
        '      "key": "starttime",\n' +
        '      "value": "Etter avtale"\n' +
        '    },\n' +
        '    {\n' +
        '      "key": "employerdescription",\n' +
        '      "value": "<p>Vi selger tigre, blomstre og knapper.</p>\\n"\n' +
        '    },\n' +
        '    {\n' +
        '      "key": "remote",\n' +
        '      "value": "Hybridkontor"\n' +
        '    },\n' +
        '    {\n' +
        '      "key": "classification_styrk08_code",\n' +
        '      "value": "8154"\n' +
        '    },\n' +
        '    {\n' +
        '      "key": "applicationemail",\n' +
        '      "value": "test@testnav.navtest"\n' +
        '    },\n' +
        '    {\n' +
        '      "key": "sector",\n' +
        '      "value": "Privat"\n' +
        '    },\n' +
        '    {\n' +
        '      "key": "workhours",\n' +
        '      "value": "[\\"Dagtid\\"]"\n' +
        '    },\n' +
        '    {\n' +
        '      "key": "applicationdue",\n' +
        '      "value": "Snarest"\n' +
        '    },\n' +
        '    {\n' +
        '      "key": "jobtitle",\n' +
        '      "value": "Bandasjearbeider"\n' +
        '    },\n' +
        '    {\n' +
        '      "key": "classification_styrk08_score",\n' +
        '      "value": "1.0"\n' +
        '    },\n' +
        '    {\n' +
        '      "key": "jobarrangement",\n' +
        '      "value": "Turnus"\n' +
        '    },\n' +
        '    {\n' +
        '      "key": "adtext",\n' +
        '      "value": "<p>Kor e alle helter hen?<br />\\nStå opp igjen<br />\\nZorro kom tilbake<br />\\nKem ska redde verden no?<br />\\nPrøysen og barnatro<br />\\nE nostalgi på video</p>\\n"\n' +
        '    },\n' +
        '    {\n' +
        '      "key": "workLanguage",\n' +
        '      "value": "[\\"Norsk\\"]"\n' +
        '    },\n' +
        '    {\n' +
        '      "key": "adtextFormat",\n' +
        '      "value": "ikkeStrukturert"\n' +
        '    },\n' +
        '    {\n' +
        '      "key": "ontologyJobtitle",\n' +
        '      "value": "{\\"konseptId\\":254881,\\"label\\":\\"Bandasjearbeider\\",\\"styrk08\\":\\"8154\\"}"\n' +
        '    },\n' +
        '    {\n' +
        '      "key": "classification_input_source",\n' +
        '      "value": "ontologyJobtitle"\n' +
        '    }\n' +
        '  ],\n' +
        '  "contacts": [],\n' +
        '  "classifications": [\n' +
        '    {\n' +
        '      "categoryType": "JANZZ",\n' +
        '      "code": "254881",\n' +
        '      "name": "Bandasjearbeider",\n' +
        '      "score": 1.0,\n' +
        '      "janzzParentId": "254881"\n' +
        '    },\n' +
        '    {\n' +
        '      "categoryType": "ESCO",\n' +
        '      "code": "http://data.europa.eu/esco/isco/C8154",\n' +
        '      "name": "Bandasjearbeider",\n' +
        '      "score": 1.0,\n' +
        '      "janzzParentId": "254881"\n' +
        '    },\n' +
        '    {\n' +
        '      "categoryType": "STYRK08",\n' +
        '      "code": "8154",\n' +
        '      "name": "Operatører innen tekstilbearbeiding",\n' +
        '      "score": 1.0,\n' +
        '      "janzzParentId": "254881"\n' +
        '    }\n' +
        '  ]\n' +
        '}';

    @IsTest
    static void parse_successNoNulls() {
        ArbeidsplassenJobPosting model = ArbeidsplassenJobPosting.parse(JSON, 'testkey', 'testhash');

        System.assertEquals('8e019569-0a0b-4f34-8d43-4498b9f0b32b', model.uuid);
        System.assertEquals('Medarbeider søkes', model.title);
        System.assertEquals('ACTIVE', model.status);
        System.assertEquals('2022-02-18T07:07:07.064711', model.published);
        System.assertEquals('2022-03-31T00:00:00', model.expires);
        System.assertEquals('2022-02-18T07:17:50.477069', model.created);
        System.assertEquals('2022-02-18T07:19:21.575794', model.updated);
        System.assertEquals('FINN', model.source);
        System.assertEquals('FINN', model.medium);
        System.assertEquals('248749509', model.reference);
        System.assertEquals('Hedda Hytter AS', model.businessName);
        System.assertEquals(2, model.locations.size());
        System.assertEquals('Hedalsvegen 1165', model.locations[0].address);
        System.assertEquals('HEDALEN', model.locations[0].city);
        System.assertEquals('NORGE', model.locations[0].country);
        System.assertEquals('INNLANDET', model.locations[0].county);
        System.assertEquals('34', model.locations[0].county_code);
        System.assertEquals('60.54515075683594', model.locations[0].latitude);
        System.assertEquals('9.809159278869629', model.locations[0].longitude);
        System.assertEquals('SØR-AURDA', model.locations[0].municipal);
        System.assertEquals('3449', model.locations[0].municipal_code);
        System.assertEquals('3528', model.locations[0].postalCode);
        System.assertEquals(4, model.properties.size());
        System.assertEquals(1, model.categories.size());
        System.assertEquals(1, model.contacts.size());
        System.assertEquals('kari@nav.no', model.contacts[0].email);
        System.assertEquals('Kari Nordmann', model.contacts[0].name);
        System.assertEquals('41161711', model.contacts[0].phone);
        System.assertEquals('Daglig leder', model.contacts[0].role);
        System.assertEquals('Daglig leder', model.contacts[0].title);
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
        System.assertEquals('Medarbeider søkes', model.title);
        System.assertEquals('INACTIVE', model.status);
        System.assertEquals('2022-02-18T07:07:07.064711', model.published);
        System.assertEquals('2022-03-31T00:00:00', model.expires);
        System.assertEquals('2022-02-18T07:17:50.477069', model.created);
        System.assertEquals('2021-02-18T07:19:21.575794', model.updated);
        System.assertEquals('FINN', model.source);
        System.assertEquals('FINN', model.medium);
        System.assertEquals('248749509', model.reference);
        System.assertEquals('Hedda Hytter AS', model.businessName);
        System.assertEquals(1, model.locations.size());
        System.assertEquals(4, model.properties.size());
        System.assert(model.categories == null);
        System.assertEquals(1, model.contacts.size());
        System.assertEquals('Hedda Hytter AS', model.employer.name);
        System.assertEquals('Hedda Hytter AS', model.employer.publicName);
        System.assertEquals(null, model.employer.orgnr);
        System.assertEquals(null, model.employer.parentOrgnr);
        System.assertEquals('AS', model.employer.orgform);
    }

    @IsTest
    static void parse_successRecruitment() {
        ArbeidsplassenJobPosting model = ArbeidsplassenJobPosting.parse(JSON_RECRUITMENT_HELP, 'testkey', 'testhash');

        System.assertEquals('21c2a9e4-d013-4bf5-b30e-225d8695088d', model.uuid);
        System.assertEquals('Trenger en helt', model.title);
        System.assertEquals('ACTIVE', model.status);
        System.assertEquals('2025-10-28T13:10:53', model.published);
        System.assertEquals('2025-11-18T00:00:00', model.expires);
        System.assertEquals('2025-10-28T13:11:30.528326', model.created);
        System.assertEquals('2025-10-28T13:11:39.663852', model.updated);
        System.assertEquals('Stillingsregistrering', model.source);
        System.assertEquals('Stillingsregistrering', model.medium);
        System.assertEquals('21c2a9e4-d013-4bf5-b30e-225d8695088d', model.reference);
        System.assertEquals('Ordknapp Blomstrete Tiger As', model.businessName);
        System.assertEquals(1, model.locations.size());
        System.assertEquals('Kong Oscarsgate 8B', model.locations[0].address);
        System.assertEquals('TØNSBERG', model.locations[0].city);
        System.assertEquals('NORGE', model.locations[0].country);
        System.assertEquals('VESTFOLD', model.locations[0].county);
        System.assertEquals('39', model.locations[0].county_code);
        System.assertEquals(null, model.locations[0].latitude);
        System.assertEquals(null, model.locations[0].longitude);
        System.assertEquals('TØNSBERG', model.locations[0].municipal);
        System.assertEquals('3905', model.locations[0].municipal_code);
        System.assertEquals('3112', model.locations[0].postalCode);
        System.assertEquals(22, model.properties.size());
        System.assertEquals(0, model.categories.size());
        System.assertEquals(0, model.contacts.size());
        System.assertEquals('ORDKNAPP BLOMSTRETE TIGER AS', model.employer.name);
        System.assertEquals('ORDKNAPP BLOMSTRETE TIGER AS', model.employer.publicName);
        System.assertEquals('312113341', model.employer.orgnr);
        System.assertEquals('311185268', model.employer.parentOrgnr);
        System.assertEquals('BEDR', model.employer.orgform);
    }

    @IsTest
    static void parse_successRecruitmentFalse() {
        ArbeidsplassenJobPosting model = ArbeidsplassenJobPosting.parse(
            JSON_RECRUITMENT_HELP_FALSE,
            'testkey',
            'testhash'
        );

        System.assertEquals('21c2a9e4-d013-4bf5-b30e-225d8695088d', model.uuid);
        System.assertEquals('Trenger en helt', model.title);
        System.assertEquals('ACTIVE', model.status);
        System.assertEquals('2025-10-28T13:10:53', model.published);
        System.assertEquals('2025-11-18T00:00:00', model.expires);
        System.assertEquals('2025-10-28T13:11:30.528326', model.created);
        System.assertEquals('2025-10-28T13:11:39.663852', model.updated);
        System.assertEquals('Stillingsregistrering', model.source);
        System.assertEquals('Stillingsregistrering', model.medium);
        System.assertEquals('21c2a9e4-d013-4bf5-b30e-225d8695088d', model.reference);
        System.assertEquals('Ordknapp Blomstrete Tiger As', model.businessName);
        System.assertEquals(1, model.locations.size());
        System.assertEquals('Kong Oscarsgate 8B', model.locations[0].address);
        System.assertEquals('TØNSBERG', model.locations[0].city);
        System.assertEquals('NORGE', model.locations[0].country);
        System.assertEquals('VESTFOLD', model.locations[0].county);
        System.assertEquals('39', model.locations[0].county_code);
        System.assertEquals(null, model.locations[0].latitude);
        System.assertEquals(null, model.locations[0].longitude);
        System.assertEquals('TØNSBERG', model.locations[0].municipal);
        System.assertEquals('3905', model.locations[0].municipal_code);
        System.assertEquals('3112', model.locations[0].postalCode);
        System.assertEquals(21, model.properties.size());
        System.assertEquals(0, model.categories.size());
        System.assertEquals(0, model.contacts.size());
        System.assertEquals('ORDKNAPP BLOMSTRETE TIGER AS', model.employer.name);
        System.assertEquals('ORDKNAPP BLOMSTRETE TIGER AS', model.employer.publicName);
        System.assertEquals('312113341', model.employer.orgnr);
        System.assertEquals('311185268', model.employer.parentOrgnr);
        System.assertEquals('BEDR', model.employer.orgform);
    }

    @IsTest
    static void getProperty_success() {
        ArbeidsplassenJobPosting model = ArbeidsplassenJobPosting.parse(JSON, 'testkey', 'testhash');

        String value = model.getProperty('extent');

        System.assertEquals('Heltid', value);
    }

    @IsTest
    static void getPropertyRecruitment_success() {
        ArbeidsplassenJobPosting model = ArbeidsplassenJobPosting.parse(JSON_RECRUITMENT_HELP, 'testkey', 'testhash');

        String value = model.getProperty('rekrutteringshjelp');
        String valuetlf = model.getProperty('rekrutteringshjelpTelefonnummer');
        Boolean valueEmpDes = model.getProperty('employerdescription').contains('Etterregistrering');

        System.assertEquals('true', value);
        System.assertEquals('12312312', valuetlf);
        System.assertEquals(true, valueEmpDes);
    }

    @IsTest
    static void getPropertyRecruitmentFalse_success() {
        ArbeidsplassenJobPosting model = ArbeidsplassenJobPosting.parse(
            JSON_RECRUITMENT_HELP_FALSE,
            'testkey',
            'testhash'
        );

        String value = model.getProperty('rekrutteringshjelp');

        System.assertEquals('false', value);
    }

    @IsTest
    static void getProperty_notFound() {
        ArbeidsplassenJobPosting model = ArbeidsplassenJobPosting.parse(JSON, 'testkey', 'testhash');

        String value = model.getProperty('propnotfound');

        System.assertEquals(null, value);
    }

    @IsTest
    static void getProperty_notProperties() {
        ArbeidsplassenJobPosting model = ArbeidsplassenJobPosting.parse('{}', 'testkey', 'testhash');

        String value = model.getProperty('propnotfound');

        System.assertEquals(null, value);
    }

    @IsTest
    static void getCities_noNulls() {
        ArbeidsplassenJobPosting model = ArbeidsplassenJobPosting.parse(JSON, 'testkey', 'testhash');

        String value = model.getCities();

        System.assertEquals('HEDALEN, OSLO', value);
    }

    @IsTest
    static void getCities_allNulls() {
        ArbeidsplassenJobPosting model = ArbeidsplassenJobPosting.parse('{}', 'testkey', 'testhash');

        String value = model.getCities();

        System.assert(String.isBlank(value));
    }

    @IsTest
    static void getCategoryCodes_noNulls() {
        ArbeidsplassenJobPosting model = ArbeidsplassenJobPosting.parse(JSON, 'testkey', 'testhash');

        String value = model.getCategoryCodes();

        System.assertEquals('STYRK08', value);
    }

    @IsTest
    static void getCategoryCodes_nulls() {
        ArbeidsplassenJobPosting model = ArbeidsplassenJobPosting.parse(JSON_WITH_NULLS, 'testkey', 'testhash');

        String value = model.getCategoryCodes();

        System.assert(String.isBlank(value));
    }

    @IsTest
    static void getCategoryNames_noNulls() {
        ArbeidsplassenJobPosting model = ArbeidsplassenJobPosting.parse(JSON, 'testkey', 'testhash');

        String value = model.getCategoryNames();

        System.assertEquals('Fylkesjordskiftesjef', value);
    }

    @IsTest
    static void getCategoryNames_nulls() {
        ArbeidsplassenJobPosting model = ArbeidsplassenJobPosting.parse(JSON_WITH_NULLS, 'testkey', 'testhash');

        String value = model.getCategoryNames();

        System.assert(String.isBlank(value));
    }

    @isTest
    static void should_calculate_message_age_correctly() {
        String updatedTimeNOR = '2024-01-15T14:30:00.123456'; // 14:30 Norway time.  Norway is UTC+1 in winter, so 14:30 Norway time = 13:30 GMT
        DateTime processedTimeGmt = DateTime.newInstanceGmt(2024, 1, 15, 13, 50, 0); // 13:50 GMT, 20 minutes after the above time
        ArbeidsplassenJobPosting jobPosting = new ArbeidsplassenJobPosting();
        jobPosting.updated = updatedTimeNOR;
        Integer age = jobPosting.getMessageAge(processedTimeGmt);
        Assert.areEqual(20, age, 'Message age should be 20 minutes');
    }

    @isTest
    static void should_handle_invalid_date_formats() {
        DateTime processedTimeGmt = DateTime.newInstanceGmt(2024, 1, 15, 13, 50, 0);
        ArbeidsplassenJobPosting nullValue = new ArbeidsplassenJobPosting();
        nullValue.updated = null;
        ArbeidsplassenJobPosting invalidValue = new ArbeidsplassenJobPosting();
        invalidValue.updated = 'not-a-valid-timestamp';
        ArbeidsplassenJobPosting futureDate = new ArbeidsplassenJobPosting();
        futureDate.updated = '2024-12-31T23:59:59.999999';

        Assert.areEqual(null, nullValue.getMessageAge(processedTimeGmt), 'Should return null for null timestamp');
        Assert.areEqual(null, invalidValue.getMessageAge(processedTimeGmt), 'Should return null for invalid timestamp');
        Assert.areEqual(null, futureDate.getMessageAge(processedTimeGmt), 'Should return null for future timestamp');
    }
}
