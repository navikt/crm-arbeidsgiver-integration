# SurveyXact – opprettelse av kampanjemedlemmer

Denne integrasjonen henter alle respondenter for årets bedriftsundersøkelse fra
SurveyXact og oppretter `CustomCampaignMember__c` for de virksomhetene som finnes
i Salesforce. Den kjøres **én gang i året**, etter at utvalget er klart i
SurveyXact.

Dette er en annen integrasjon enn `bedriftsundersokelseGetExportDataset`, som
kjører hver time og **oppdaterer status** på medlemmer som allerede finnes.
Denne mappen **oppretter** medlemmene. De to deler Named Credential og
Custom Metadata, men er ellers uavhengige.

---

## Arkitektur (kort)

| Komponent                             | Ansvar                                                   |
| ------------------------------------- | -------------------------------------------------------- |
| `TAG_SurveyXactRegionCalloutService`  | Bygger endepunkt + gjør callout, én region om gangen     |
| `TAG_SurveyXactMemberImportParser`    | Parser CSV-en, plukker ut `respnokk` og `bedrnr`         |
| `TAG_SurveyXactMemberImportService`   | Matcher mot Account/kampanje og oppretter medlemmer      |
| `TAG_SurveyXactMemberImportQueueable` | Kjører callout + import asynkront per region, logger     |
| `TAG_SurveyXactMemberImportScheduler` | Planlagt kjøring én gang i året                          |
| `TAG_SurveyXactDataset_Config__mdt`   | Custom Metadata: `SurveyId__c`, `Ptype1__c`, `Active__c` |

-   **Named Credential:** `SurveyXact` → `https://rest.survey-xact.dk/rest`
-   **Auth:** Basic Authentication via External Credential (ingen secrets i git)
-   **Konfigurasjon:** samme record som statusoppdateringen bruker

---

## Oppsett i org

Hvis `bedriftsundersokelseGetExportDataset` allerede er satt opp i orgen, er
**Steg 1–4 gjort fra før** – hopp rett til «Slik matches respondentene».
Stegene gjentas her slik at denne integrasjonen kan testes alene.

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

Integrasjonen bruker samme Custom Metadata-record som statusoppdateringen,
`TAG_SurveyXactDataset_Config__mdt`:

| Felt              | Verdi       | Brukes her                                 |
| ----------------- | ----------- | ------------------------------------------ |
| `SurveyId__c`     | `519190`    | Ja – survey-ID i SurveyXact                |
| `Ptype1__c`       | `390264940` | Ja – identifiserer årgangen                |
| `Active__c`       | `true`      | Ja – recorden må være aktiv                |
| `LookbackDays__c` | `1`         | Nei – kun relevant for statusoppdateringen |

`Ptype1__c` **må oppdateres før hver årlige kjøring**. Alle årganger ligger på
samme survey i SurveyXact, så uten dette filteret hentes respondenter fra alle
år. Se «Ny årgang» i dokumentasjonen for `bedriftsundersokelseGetExportDataset`.

Kampanjeåret settes ikke i metadata – det utledes fra `Date.today().year()`,
eller kan overstyres i konstruktøren ved behov.

---

## Slik matches respondentene

For hver rad i uttrekket:

1. `bedrnr` matches mot `Account.INT_OrganizationNumber__c`
2. Kontoens `TAG_NavUnit__c` gir NAV-enheten
3. Kampanjen finnes via `CustomCampaign__c.NAV_Unit__c` blant kampanjer som
   heter `BU {år} ...` – disse opprettes av `TAG_EmployerSurveyCampaignsBatch`
   i `crm-arbeidsgiver-base`, og **må finnes før importen kjøres**
4. `respnokk` lagres i `Key__c`, som er koblingen statusoppdateringen bruker senere

Medlemmet opprettes med:

| Felt                | Verdi                          |
| ------------------- | ------------------------------ |
| `Account__c`        | Matchet virksomhet             |
| `CustomCampaign__c` | Årets kampanje for NAV-enheten |
| `NAV_Unit__c`       | Kontoens NAV-enhet             |
| `Key__c`            | `respnokk` fra SurveyXact      |
| `Campaign_type__c`  | `Bedriftsundersøkelse`         |
| `Status__c`         | `Ikke gjennomført`             |

Alle statuser settes til `Ikke gjennomført`. Statusoppdateringen setter
`Gjennomført` etter hvert som svarene kommer inn.

### Respondenter som hoppes over

Ingenting avbryter importen – hver rad som ikke kan matches logges for seg og
telles opp i resultatet:

| Teller              | Årsak                                          |
| ------------------- | ---------------------------------------------- |
| `skippedInvalidRow` | Raden mangler `respnokk` eller `bedrnr`        |
| `skippedNoAccount`  | Ingen virksomhet med det organisasjonsnummeret |
| `skippedNoNavUnit`  | Virksomheten mangler NAV-enhet                 |
| `skippedNoCampaign` | Ingen `BU {år}`-kampanje for NAV-enheten       |
| `skippedExisting`   | Medlemmet finnes allerede (`Key__c` er i bruk) |

Importen er idempotent: kjøres den to ganger, havner alt i `skippedExisting`
andre gang, og ingen duplikater opprettes.

---

## Hvorfor uttrekket deles opp

Hele årgangen er ca. **17 MB fordelt på rundt 18 000 respondenter**. Apex tåler
maksimalt 12 MB heap i asynkron kontekst, så uttrekket kan ikke hentes i én
callout.

Løsningen er å hente **én region om gangen** (1–15). Køen kjører seg selv videre
til neste region etter hver kjøring, slik at hver transaksjon får sin egen
heap-, SOQL- og DML-kvote.

> **Status:** regionfilteret er **ikke bekreftet** av SurveyXact ennå.
> `[Fylkebg/region]=1` gir HTTP 200, men uten datarader. Riktig syntaks for
> single-choice-variabler er etterspurt hos support. Selve importlogikken er
> testet mot ekte data med et `closeTime`-filter og fungerer.

---

## Filter-expression og URL-encoding

`expression`-parameteren bygges i
`TAG_SurveyXactRegionCalloutService.buildExpression()`:

```
[background/ptype1]=390264940 and [Fylkebg/region]=1
```

Til forskjell fra statusoppdateringen brukes **ikke** `closeTime` her – importen
trenger alle respondenter i utvalget, også de som ikke har svart.

Prefiksene er hentet fra XML-eksporten av undersøkelsen, som er fasit for hvilken
variabel som ligger hvor:

| Variabel    | Referanse                | Type     |
| ----------- | ------------------------ | -------- |
| `closeTime` | `[respondent/closeTime]` | dateTime |
| `ptype1`    | `[background/ptype1]`    | double   |
| `region`    | `[Fylkebg/region]`       | single   |
| `bedrnr`    | `null/bedrnr`            | text     |
| `respnokk`  | `calculated/respnokk`    | text     |

Uttrykket URL-encodes med `EncodingUtil.urlEncode(...)` i `buildEndpoint()`.

> **Fallgruve:** SurveyXact svarer HTTP 200 selv om et filter ikke virker – det
> returnerer bare header-raden uten data. To `and`-koblede betingelser på
> **samme** variabel gir også 200, men bare den første brukes. Sjekk derfor alltid
> at antall rader faktisk endrer seg, ikke bare at kallet gikk gjennom.

---

## Testing i scratch org

Testene under er skrevet for **Developer Console → Debug → Open Execute
Anonymous Window**. Huk av **Open Log**, og velg **Debug Only** i loggvinduet.

### Test 1 — Bekreft at callouten virker

```apex
TAG_SurveyXactDataset_Config__mdt cfg = [
    SELECT SurveyId__c, Ptype1__c
    FROM TAG_SurveyXactDataset_Config__mdt
    WHERE Active__c = true LIMIT 1
];
String csv = TAG_SurveyXactRegionCalloutService.getDataset(
    cfg.SurveyId__c,
    '[respondent/closeTime] > datetime("2026-03-07 00:00:00")'
);
List<TAG_SurveyXactMemberImportParser.Respondent> rows =
    TAG_SurveyXactMemberImportParser.parse(csv);
System.debug(LoggingLevel.INFO, 'Antall respondenter: ' + rows.size());
for (TAG_SurveyXactMemberImportParser.Respondent r : rows) {
    System.debug(LoggingLevel.INFO, r.externalKey + ' -> ' + r.organizationNumber);
}
```

-   **Rader > 0** → auth, callout og parsing er OK.
-   **Rader = 0** → sjekk survey-ID og filter før du går videre.

> `closeTime`-filteret brukes her fordi det gir få rader. Ikke bruk et bredt
> filter i Execute Anonymous – synkron kontekst har kun 6 MB heap.

### Test 2 — Lag testdata

Importen trenger virksomheter, NAV-enheter og kampanjer som matcher uttrekket.
Bytt ut organisasjonsnumrene med verdier fra din egen Test 1.

```apex
NavUnit__c unit = new NavUnit__c(Name = 'NAV Testenhet', INT_UnitNumber__c = '1234');
insert unit;

insert new CustomCampaign__c(
    Name = 'BU ' + Date.today().year() + ' ' + unit.Name,
    NAV_Unit__c = unit.Id,
    Type__c = 'Bedriftsundersøkelse'
);

Account acc = new Account(Name = 'Testvirksomhet AS', INT_OrganizationNumber__c = '974478048');
insert acc;

// Settes i egen update: NavUnitAccountRoutingService kan overstyre feltet ved insert
update new Account(Id = acc.Id, TAG_NavUnit__c = unit.Id);
```

### Test 3 — Kjør importen mot ekte data

```apex
String csv = TAG_SurveyXactRegionCalloutService.getDataset(
    [SELECT SurveyId__c FROM TAG_SurveyXactDataset_Config__mdt
     WHERE Active__c = true LIMIT 1].SurveyId__c,
    '[respondent/closeTime] > datetime("2026-03-07 00:00:00")'
);

List<String> skipReasons = new List<String>();
TAG_SurveyXactMemberImportService.ImportResult result =
    TAG_SurveyXactMemberImportService.importFromCsv(
        csv, Date.today().year(), false, skipReasons
    );

System.debug(LoggingLevel.INFO, 'Resultat: ' + result);
for (String reason : skipReasons) {
    System.debug(LoggingLevel.INFO, 'Hoppet over: ' + reason);
}
```

Sjekk resultatet:

```apex
System.debug(LoggingLevel.INFO, [
    SELECT Key__c, Account__r.Name, CustomCampaign__r.Name, Status__c
    FROM CustomCampaignMember__c
    WHERE Campaign_type__c = 'Bedriftsundersøkelse'
]);
```

Kjør Test 3 en gang til uten å endre noe. Alt skal nå havne i `skippedExisting`
med `created=0` – det bekrefter at gjentatte kjøringer ikke lager duplikater.

Rydd opp mellom forsøk:

```apex
delete [SELECT Id FROM CustomCampaignMember__c
        WHERE Campaign_type__c = 'Bedriftsundersøkelse'];
```

### Test 4 — Hele kjeden (krever bekreftet regionfilter)

```apex
System.enqueueJob(new TAG_SurveyXactMemberImportQueueable());
```

Jobben går gjennom region 1–15, én transaksjon per region. Følg med i
**Setup → Apex Jobs** mens den kjører, og sjekk **Application_Log\_\_c** etterpå.
En region som feiler stopper ikke resten.

### Test 5 — Planlagt kjøring

```apex
System.schedule('SurveyXact Member Import', '0 0 2 1 2 ?',
    new TAG_SurveyXactMemberImportScheduler());
```

Cron-uttrykket over kjører 1. februar kl. 02:00. Jobben skal kjøre **én gang per
årgang**, så slett den planlagte jobben når importen er ferdig:
**Setup → Scheduled Jobs → Del**.

Alternativt kan importen startes manuelt med Test 4 når utvalget er klart – det
er færre bevegelige deler enn en planlagt jobb som står ubrukt mesteparten av året.

---

## Rekkefølge ved ny årgang

1. Oppdater `Ptype1__c` på Custom Metadata-recorden til årets verdi
2. Kjør `TAG_EmployerSurveyCampaignsBatch` (`crm-arbeidsgiver-base`) slik at
   `BU {år}`-kampanjene finnes
3. Start importen – Test 4 eller planlagt jobb
4. Kontroller `Application_Log__c` for hoppede respondenter
5. Statusoppdateringen (`bedriftsundersokelseGetExportDataset`) kan nå kjøre
   hver time gjennom responsperioden
