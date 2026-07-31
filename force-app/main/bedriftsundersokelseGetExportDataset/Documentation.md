# SurveyXact Dataset-integrasjon – dokumentasjon

Denne integrasjonen henter respondentstatus fra SurveyXact ("Export dataset")
og oppdaterer `CustomCampaignMember__c.Status__c` til `Gjennomført` for
respondenter som har fullført undersøkelsen.

---

## Arkitektur (kort)

| Komponent                             | Ansvar                                                                      |
| ------------------------------------- | --------------------------------------------------------------------------- |
| `TAG_SurveyXactDatasetCalloutService` | Bygger endepunkt + gjør callout mot SurveyXact                              |
| `TAG_SurveyXactDatasetParser`         | Parser CSV-eksporten (RFC 4180)                                             |
| `TAG_SurveyXactDatasetSync`           | Oppdaterer `CustomCampaignMember__c`                                        |
| `TAG_SurveyXactDatasetSyncQueueable`  | Kjører callout + sync asynkront, logger feil                                |
| `TAG_SurveyXactDatasetScheduler`      | Planlagt kjøring hver time                                                  |
| `TAG_SurveyXactDataset_Config__mdt`   | Custom Metadata: `SurveyId__c`, `LookbackDays__c`, `Ptype1__c`, `Active__c` |

-   **Named Credential:** `SurveyXact` → `https://rest.survey-xact.dk/rest`
-   **Auth:** Basic Authentication via External Credential (ingen secrets i git)
-   **Konfigurasjon:** én record på `TAG_SurveyXactDataset_Config__mdt` følger med
    pakken, se «Konfigurasjon» nedenfor – `Ptype1__c` må oppdateres for hver ny årgang

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

## Konfigurasjon

Innstillingene ligger på Custom Metadata-typen
`TAG_SurveyXactDataset_Config__mdt`. Recorden **Bedriftsundersøkelse 2026**
følger med pakken og deployes automatisk:

| Felt              | Verdi       | Forklaring                                                |
| ----------------- | ----------- | --------------------------------------------------------- |
| `SurveyId__c`     | `519190`    | Survey-ID i SurveyXact                                    |
| `LookbackDays__c` | `1`         | Tilbakeblikk i dager – gir overlapp ved kjøring hver time |
| `Ptype1__c`       | `390264940` | Identifiserer årgangen – **endrer seg fra år til år**     |
| `Active__c`       | `true`      | Kun aktive recorder synkroniseres                         |

Alle årganger av bedriftsundersøkelsen ligger på **samme survey i SurveyXact**,
så `SurveyId__c` er den samme hvert år. Det er `Ptype1__c` som skiller
årgangene, og denne verdien må hentes fra SurveyXact for hver ny årgang.

### Ny årgang

Det er to måter å håndtere en ny årgang på:

1. **Oppdatere eksisterende record** – endre `Ptype1__c` til årets verdi på
   recorden som allerede finnes. Enklest, men historikken om hvilken verdi som
   ble brukt tidligere går tapt.
2. **Opprette ny record (anbefalt)** – lag en ny record, f.eks.
   `Bedriftsundersøkelse 2027`, med samme `SurveyId__c` og `LookbackDays__c`,
   men årets `Ptype1__c`. Sett `Active__c = true` på den nye og
   **`Active__c = false` på fjorårets record**. Da beholdes historikken, og det
   er lett å bytte tilbake om noe er feil.

> **Viktig ved alternativ 2:** integrasjonen kjører én callout per aktiv record.
> Hvis den gamle recorden ikke deaktiveres, hentes data for begge årgangene.

Hvis `Ptype1__c` står tomt, utelates årsfilteret og eksporten inneholder
respondenter fra alle årganger innenfor tilbakeblikket.

Verdiene kan endres i org uten deploy:
**Setup → Custom Metadata Types → SurveyXact Dataset Config → Manage Records**

> Merk: feltene vises kun i Manage Records dersom de er lagt til på page layout.

---

## Statuskoder fra SurveyXact

Om en respondent har gjennomført avgjøres av kolonnen `c_1` i datauttrekket:

| `c_1` | Betydning         | Handling i Salesforce                |
| ----- | ----------------- | ------------------------------------ |
| `1`   | Gjennomført       | `Status__c` settes til `Gjennomført` |
| `2`   | Ikke gjennomført  | Ingen endring                        |
| `3`   | Frafalt / konkurs | Ingen endring                        |

SurveyXact-support anbefalte `c_1` (alternativt `stato_4`) framfor
`response`-kolonnen, som ikke er egnet til dette formålet.

---

## Filter-expression og URL-encoding

`expression`-parameteren bygges i
`TAG_SurveyXactDatasetCalloutService.buildExpression()` og kombinerer
tilbakeblikket med årsfilteret:

```
[respondent/closeTime] > datetime("2026-07-30 00:00:00") and [background/ptype1]=390264940
```

Merk at `ptype1` må refereres som `[background/ptype1]` – ikke `ptype1` eller
`[respondent/ptype1]`, som begge gir HTTP 500.

Uttrykket URL-encodes med `EncodingUtil.urlEncode(...)` i
`buildEndpoint()`. SurveyXact aksepterer standard prosent-encoding.

Eksempel på endepunkt:

```
callout:SurveyXact/surveys/123456/export/dataset?format=EU&lang=en
  &expression=%5Brespondent%2FcloseTime%5D+%3E+datetime(...)
```

---

## Testing i scratch org

### Test 1 — Bekreft callout via ekte metode (liten mengde)

Filteret bruker `LookbackDays__c` (1 dag), så kun nylig lukkede respondenter hentes.

Eksporten har én kolonne per spørsmål, så header-raden alene kan være svært lang.
Derfor parses CSV-en og antall rader telles i stedet for å skrive ut selve teksten.

```apex
TAG_SurveyXactDataset_Config__mdt cfg = [
    SELECT SurveyId__c, LookbackDays__c, Ptype1__c
    FROM TAG_SurveyXactDataset_Config__mdt
    WHERE Active__c = true LIMIT 1
];
String csv = TAG_SurveyXactDatasetCalloutService.getRecentDataset(cfg);
List<TAG_SurveyXactDatasetParser.Row> rows = TAG_SurveyXactDatasetParser.parse(csv);
System.debug(LoggingLevel.INFO, 'CSV-lengde: ' + csv.length());
System.debug(LoggingLevel.INFO, 'Antall rader: ' + rows.size());
```

-   **CSV-lengde > 0 og rader > 0** → callout og parsing er OK.
-   **Rader = 0** → auth virker, men ingen respondenter lukket siste døgn.

### Test 2 — Lag testdata (`CustomCampaignMember__c`)

Lag medlemmer der `Key__c` = ekte `respnokk`-verdier fra eksporten.

```apex
insert new List<CustomCampaignMember__c>{
    new CustomCampaignMember__c(Key__c = 'EKTE_RESPNOKK_1'),
    new CustomCampaignMember__c(Key__c = 'EKTE_RESPNOKK_2', Status__c = 'Ikke gjennomført')
};
```

> Hvis ingen respondenter er lukket siste døgn: sett midlertidig
> `LookbackDays__c` til for eks. `14` på CMDT-recorden
> (**Setup → Custom Metadata Types → SurveyXact Dataset Config → Manage Records**),
> kjør testen, og sett tilbake til `1` etterpå.

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

Medlemmer som matcher en respondent med `c_1 = 1` (innenfor tilbakeblikket)
skal nå være `Gjennomført`. Sjekk også **Application_Log\_\_c** for eventuelle feil.

### Test 4 — Planlagt kjøring (kun når Test 1–3 virker)

Integrasjonen kjøres én gang i timen mellom kl. 07 og 17 i responsperioden.
Cron-uttrykket `0 0 7-17 * * ?` gir 11 kjøringer per dag (07:00, 08:00 … 17:00).

```apex
System.schedule('SurveyXact Dataset Sync', '0 0 7-17 * * ?',
    new TAG_SurveyXactDatasetScheduler());
```

Med `LookbackDays__c = 1` får hver kjøring litt overlapp, slik at ingen
respondenter faller mellom to kjøringer. Oppdateringen er idempotent, så
overlappen fører ikke til feil.

> **Viktig:** jobben må kjøre **alle ukedager, inkludert lørdag og søndag**.
> Med `LookbackDays__c = 1` dekker hver kjøring kun det siste døgnet, så en
> jobb som kun kjørte mandag–fredag ville mistet respondenter som svarte i
> helgen. `0 0 7-17 * * ?` kjører hver dag og dekker dette.

Stopp planlagt jobb ved behov:
**Setup → Scheduled Jobs → Del** ved siden av `SurveyXact Dataset Sync`.
