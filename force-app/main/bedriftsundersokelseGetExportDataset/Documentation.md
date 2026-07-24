# SurveyXact Dataset-integrasjon – dokumentasjon

Denne integrasjonen henter respondentstatus fra SurveyXact ("Export dataset")
og oppdaterer `CustomCampaignMember__c.Status__c` til `Gjennomført` for
respondenter som har fullført undersøkelsen.

---

## Arkitektur (kort)

| Komponent                             | Ansvar                                                         |
| ------------------------------------- | -------------------------------------------------------------- |
| `TAG_SurveyXactDatasetCalloutService` | Bygger endepunkt + gjør callout mot SurveyXact                 |
| `TAG_SurveyXactDatasetParser`         | Parser CSV-eksporten (RFC 4180)                                |
| `TAG_SurveyXactDatasetSync`           | Oppdaterer `CustomCampaignMember__c`                           |
| `TAG_SurveyXactDatasetSyncQueueable`  | Kjører callout + sync asynkront, logger feil                   |
| `TAG_SurveyXactDatasetScheduler`      | Planlagt daglig kjøring                                        |
| `TAG_SurveyXactDataset_Config__mdt`   | Custom Metadata: `SurveyId__c`, `LookbackDays__c`, `Active__c` |

-   **Named Credential:** `SurveyXact` → `https://rest.survey-xact.dk/rest`
-   **Auth:** Basic Authentication via External Credential (ingen secrets i git)

---

## Oppsett i org

### Steg 1 — Opprett External Credential (Basic Authentication)

**Setup → Named Credentials → External Credentials-fanen → New**

1. **Label:** `SurveyXact`
2. **Name:** `SurveyXact`
3. **Authentication Protocol:** **Basic Authentication**
4. **Save**

> **Viktig lærdom:** Custom-protokoll med formel-header fungerte ikke – headeren
> `Authorization` ble stille droppet (loggen viste
> `Authorization=Method: Not set - Credential: Not set`), og SurveyXact svarte
> med en generisk **HTTP 500** i stedet for 401. **Basic Authentication**-protokollen
> løste dette, fordi Salesforce da bygger `Authorization: Basic ...`-headeren
> automatisk.

### Steg 2 — Legg til Principal med brukernavn/passord

På detaljsiden til External Credential:

1. **Principals → New**
2. **Parameter Name:** `SurveyXactPrincipal`
3. **Sequence Number:** `1`
4. **Identity Type:** **Named Principal**
5. **Username:** SurveyXact API-brukernavn
6. **Password:** SurveyXact API-passord
7. **Save**

### Steg 3 — Opprett Named Credential

**Setup → Named Credentials → Named Credentials-fanen → New**

1. **Label:** `SurveyXact`
2. **Name:** `SurveyXact` (må være nøyaktig dette – Apex bruker `callout:SurveyXact`)
3. **URL:** `https://rest.survey-xact.dk/rest`
4. **External Credential:** `SurveyXact`
5. Huk av **Generate Authorization Header** ✅
6. La **Allow Formulas in HTTP Header** stå uhuket
7. **Save**

### Steg 4 — Gi brukeren tilgang til credential

Callouten kjører som den innloggede brukeren.

**Setup → Permission Sets → New**

1. **Label:** `SurveyXact Callout` → **Save**
2. **External Credential Principal Access → Edit** → legg til
   **SurveyXact - SurveyXactPrincipal** → **Save**
3. **Manage Assignments → Add Assignment** → velg brukeren → **Assign**

---

## URL-encoding

`expression`-parameteren URL-encodes med `EncodingUtil.urlEncode(...)` i
`TAG_SurveyXactDatasetCalloutService.buildEndpoint()`. SurveyXact aksepterer
standard prosent-encoding.

Eksempel på endepunkt:

```
callout:SurveyXact/surveys/519190/export/dataset?format=EU&lang=en
  &expression=%5Brespondent%2FcloseTime%5D+%3E+datetime(...)
```

---

## Testing i scratch org

### Test 1 — Bekreft callout via ekte metode (liten mengde)

Filteret bruker `LookbackDays__c` (3 dager), så kun nylig lukkede respondenter hentes.

Eksporten har én kolonne per spørsmål, så header-raden alene kan være svært lang.
Derfor parses CSV-en og antall rader telles i stedet for å skrive ut selve teksten.

```apex
TAG_SurveyXactDataset_Config__mdt cfg = [
    SELECT SurveyId__c, LookbackDays__c
    FROM TAG_SurveyXactDataset_Config__mdt
    WHERE Active__c = true LIMIT 1
];
String csv = TAG_SurveyXactDatasetCalloutService.getRecentDataset(cfg);
List<TAG_SurveyXactDatasetParser.Row> rows = TAG_SurveyXactDatasetParser.parse(csv);
System.debug(LoggingLevel.INFO, 'CSV-lengde: ' + csv.length());
System.debug(LoggingLevel.INFO, 'Antall rader: ' + rows.size());
```

-   **CSV-lengde > 0 og rader > 0** → callout og parsing er OK.
-   **Rader = 0** → auth virker, men ingen respondenter lukket siste 3 dager.

### Test 2 — Lag testdata (`CustomCampaignMember__c`)

Lag medlemmer der `Key__c` = ekte `respnokk`-verdier fra eksporten.

```apex
insert new List<CustomCampaignMember__c>{
    new CustomCampaignMember__c(Key__c = 'EKTE_RESPNOKK_1'),
    new CustomCampaignMember__c(Key__c = 'EKTE_RESPNOKK_2', Status__c = 'Ikke gjennomført')
};
```

> Hvis ingen respondenter er lukket siste 3 dager: sett midlertidig
> `LookbackDays__c` til for eks. `14` på CMDT-recorden
> (**Setup → Custom Metadata Types → SurveyXact Dataset Config → Manage Records**),
> kjør testen, og sett tilbake til `3` etterpå.

### Test 3 — Kjør hele synkroniseringen ende-til-ende

```apex
System.enqueueJob(new TAG_SurveyXactDatasetSyncQueueable());
```

Sjekk resultatet:

```apex
System.debug(LoggingLevel.INFO, [
    SELECT Key__c, Status__c
    FROM CustomCampaignMember__c
    ORDER BY Key__c
]);
```

Medlemmer som matcher en respondent med `response = 1` (innenfor tilbakeblikket)
skal nå være `Gjennomført`. Sjekk også **Application_Log\_\_c** for eventuelle feil.

### Test 4 — Planlagt kjøring (kun når Test 1–3 virker)

```apex
System.schedule('SurveyXact Dataset Sync', '0 0 22 * * ?',
    new TAG_SurveyXactDatasetScheduler());
```

Stopp planlagt jobb ved behov:
**Setup → Scheduled Jobs → Del** ved siden av `SurveyXact Dataset Sync`.
