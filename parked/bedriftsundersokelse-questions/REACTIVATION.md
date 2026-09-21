# Lagring av svar fra bedriftsundersøkelsen – PARKERT

> **Status: parkert. Skal ikke tas i bruk uten ny avklaring.**
>
> Forskningsseksjonen som eier Bedriftsundersøkelse har konkludert med at svarene fra
> bedriftsundersøkelsen ikke kan lagres i Salesforce. Koden er ferdig utviklet
> og testet, men er flyttet ut av `force-app/` slik at den ikke kan deployes.
> Feltene på `CustomCampaignMember__c` er bevisst **ikke** opprettet.
>
> Dato for beslutning: september 2026.

Denne mappen ligger utenfor `force-app/` og er derfor ikke en del av pakken.
Salesforce ser ikke disse filene, verken ved `sf project deploy` eller ved
bygging av pakkeversjon. Koden er beholdt i sin helhet, inkludert tester, slik
at den kan aktiveres igjen hvis det åpner seg et mulighetsrom.

Resten av integrasjonen går som før:

-   oppretting av kampanjemedlemmer (`bedriftsundersokelseCreateCampaignMembers`)
-   oppdatering av status til `Gjennomført` (`bedriftsundersokelseGetExportDataset`)

Se `Documentation-questions.md` i samme mappe for den opprinnelige, funksjonelle
dokumentasjonen av løsningen.

---

## Innhold i mappen

| Fil                                                        | Ansvar                                                     |
| ---------------------------------------------------------- | ---------------------------------------------------------- |
| `classes/TAG_SurveyXactCodebook.cls`                       | Spørsmåls- og svartekster, generert fra `Kodebok.xlsx`     |
| `classes/TAG_SurveyXactAnswerFormatter.cls`                | Bygger svartekst, JSON og feltverdier fra en respondentrad |
| `classes/TAG_SurveyXactAnswerFormatterTest.cls`            | 15 tester, alle grønne da koden ble parkert                |
| `sync-reactivation/TAG_SurveyXactDatasetSync.cls`          | Svarversjonen av sync-klassen                              |
| `sync-reactivation/TAG_SurveyXactDatasetSyncTest.cls`      | Testklassen med de fem svartestene                         |
| `sync-reactivation/TAG_SurveyXactDatasetSyncQueueable.cls` | Queueable med logging av ukjente svarkoder                 |
| `Documentation-questions.md`                               | Opprinnelig dokumentasjon av løsningen                     |

Filene i `classes/` **flyttes tilbake** ved reaktivering. Filene i
`sync-reactivation/` **erstatter** eksisterende filer i pakken.

`TAG_SurveyXactCodebook` og `TAG_SurveyXactAnswerFormatter` refererer ingen
felter på `CustomCampaignMember__c`. De kompilerer altså uten at feltene finnes.
Det er bare `TAG_SurveyXactDatasetSync` som må endres ved reaktivering.

---

## Felter som må opprettes ved reaktivering

Feltene ligger på `CustomCampaignMember__c`, som eies av
`crm-arbeidsgiver-base`. De må derfor opprettes **der**, ikke i dette repoet.

Alle feltene har prefikset `TAG_BU` fordi `CustomCampaignMember__c` deles med
tre andre kampanjetyper. Prefikset gjør det tydelig i rapporter og feltvelgere
at feltene er tomme for alt annet enn bedriftsundersøkelsen.

https://github.com/navikt/crm-arbeidsgiver-base/pull/2856

### Strukturerte felter

| API-navn                          | Engelsk etikett              | Norsk oversettelse                    | Type           | Detaljer                      |
| --------------------------------- | ---------------------------- | ------------------------------------- | -------------- | ----------------------------- |
| `TAG_BUEmployeesToday__c`         | BU Employees Today           | BU Antall ansatte i dag               | Number         | Presisjon 5, skala 0          |
| `TAG_BUEmployeeOutlookOneYear__c` | BU Employee Outlook One Year | BU Forventet bemanning om 1 år        | Picklist       | Ikke begrenset                |
| `TAG_BUFailedRecruitment__c`      | BU Failed Recruitment        | BU Mislykket rekruttering siste 3 mnd | Picklist       | Ikke begrenset                |
| `TAG_BUFailedRecruitmentCause__c` | BU Failed Recruitment Cause  | BU Årsak til mislykket rekruttering   | Picklist       | Ikke begrenset                |
| `TAG_BUUnfilledPositions__c`      | BU Unfilled Positions        | BU Stillinger uten rett kompetanse    | Long Text Area | 5 000 tegn, 15 synlige linjer |
| `TAG_BUAiUsage__c`                | BU Ai Usage                  | BU Bruk av KI i virksomheten          | Long Text Area | 2 000 tegn, 12 synlige linjer |
| `TAG_BUAiNotUsedReason__c`        | BU Ai Not Used Reason        | BU Grunner til at KI ikke brukes      | Long Text Area | 2 000 tegn, 8 synlige linjer  |

### Tekstfelter

| API-navn               | Engelsk etikett | Norsk oversettelse       | Type           | Detaljer                                                           |
| ---------------------- | --------------- | ------------------------ | -------------- | ------------------------------------------------------------------ |
| `TAG_BUAnswers__c`     | BU Answers      | BU Svar på undersøkelsen | Long Text Area | 131 072 tegn, 10 synlige linjer                                    |
| `TAG_BUJSONAnswers__c` | BU JSON Answers | BU Rådata (JSON)         | Long Text Area | 131 072 tegn, 5 synlige linjer, **kun synlig for administratorer** |

### Plukklisteverdier

`TAG_BUEmployeeOutlookOneYear__c`:

```
Flere enn i dag
Like mange som i dag
Færre enn i dag
```

`TAG_BUFailedRecruitment__c` – merk at verdi 2 er forkortet med vilje. Den
opprinnelige teksten er 127 tegn og er ubrukelig som rapportkolonne. Full
ordlyd lagres uansett i `TAG_BUAnswers__c`:

```
Ja, vi fikk ikke ansatt noen
Ansatt med lavere/annen kompetanse
Nei
```

`TAG_BUFailedRecruitmentCause__c`:

```
Ingen/for få kvalifiserte søkere
Annet
```

Alle plukklistene må være **ikke begrenset** (unrestricted). Hvis SurveyXact
legger til et alternativ, feiler hele batchen med
`INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST`. Ukjente koder logges i stedet som
`Warning` via `LoggerUtility`.

---

## Slik aktiveres løsningen igjen

1. **Opprett feltene** i `crm-arbeidsgiver-base` etter tabellene over, og
   installer ny pakkeversjon.

2. **Flytt klassene tilbake** til
   `force-app/main/bedriftsundersokelseGetExportDataset/classes/`.

3. **Regenerer kodeboken.** `TAG_SurveyXactCodebook` er generert fra
   `Kodebok.xlsx` for 2026. Spørsmålene endrer seg hvert år, og
   variabelnavnene kan bety noe annet i en ny undersøkelse. Be om ny kodebok og
   generer klassen på nytt før den tas i bruk.

4. **Erstatt sync-klassene** med filene fra `sync-reactivation/`. De tre filene
   legges over de eksisterende i
   `force-app/main/bedriftsundersokelseGetExportDataset/classes/`.

5. **Legg tilbake `ignoresMemberWithoutCampaign`** i
   `TAG_SurveyXactDatasetSyncTest`

    ```
    @IsTest
     static void ignoresMemberWithoutCampaign() {
         insert new CustomCampaignMember__c(Key__c = 'NO_CAMPAIGN', Status__c = STATUS_NOT_COMPLETED);

         Test.startTest();
         TAG_SurveyXactDatasetSync.syncFromCsv('respnokk;c_1\nNO_CAMPAIGN;1\n');
         Test.stopTest();

         System.assertEquals(
             STATUS_NOT_COMPLETED,
             [SELECT Status__c FROM CustomCampaignMember__c WHERE Key__c = 'NO_CAMPAIGN'].Status__c,
             'A member without a campaign has no year and is left alone'
         );
     }
    ```

6. **Kjør testene.** `TAG_SurveyXactAnswerFormatterTest` (15 tester) og
   `TAG_SurveyXactDatasetSyncTest` (7 tester) må begge være grønne.

---

## Kodeendringer i `TAG_SurveyXactDatasetSync`

Ved reaktivering skal disse tre filene **erstatte** de tilsvarende filene i
`force-app/main/bedriftsundersokelseGetExportDataset/classes/`:

| Fil i `sync-reactivation/`               | Linjer | Erstatter                         |
| ---------------------------------------- | ------ | --------------------------------- |
| `TAG_SurveyXactDatasetSync.cls`          | 139    | dagens statusversjon på 85 linjer |
| `TAG_SurveyXactDatasetSyncTest.cls`      | 219    | dagens testklasse                 |
| `TAG_SurveyXactDatasetSyncQueueable.cls` | 63     | dagens queueable på 48 linjer     |

Klassene `TAG_SurveyXactCodebook` og `TAG_SurveyXactAnswerFormatter` i
`classes/` flyttes tilbake urørt.

Avsnittene under forklarer **hvorfor** koden ser ut som den gjør. De er
bakgrunn, ikke en oppskrift – bruk filene.

### Radene må beholdes, ikke bare nøklene

Svarene ligger i radene. Statusversjonen reduserer dem til et `Set<String>` av
nøkler og kaster resten. Svarversjonen bygger i stedet en
`Map<String, TAG_SurveyXactDatasetParser.Row>` (`completedRows`) slik at raden
kan hentes igjen når medlemmet skal oppdateres.

### Statusfilteret må fjernes fra spørringen

Statusversjonen har `AND Status__c != :STATUS_COMPLETED`. Det filteret må bort.
Et medlem kan være satt til `Gjennomført` av en kjøring som skjedde før
svarfeltene fantes. Med filteret på ville slike medlemmer aldri fått svar.

Spørringen henter i stedet `TAG_BUAnswers__c` og filtrerer på den i løkken:

> `TAG_BUAnswers__c` er Long Text Area og **kan ikke** brukes i `WHERE`.
> Salesforce feiler med `field 'TAG_BUAnswers__c' can not be filtered in a query call`. Derfor sjekkes `String.isBlank(member.TAG_BUAnswers__c)` inne i
> løkken. Det er dette som gjør kjøringen idempotent: en respondent som endrer
> svaret sitt senere overskriver ikke det som allerede er lagret.

### Svarene skrives via en egen metode

Selve skrivingen ligger i den private metoden `applyAnswers(member, row, result)`, som returnerer `true` når raden hadde svar. Metoden har en
`row == null`-sjekk før den rører `row.values`. **Den sjekken må være der** –
uten den kaster kjøringen null-peker for et medlem hvis nøkkel ikke finnes i
`completedRows`.

`SyncResult` utvides med `answersWritten` og `unknownValues`.
`membersUpdated` betyr etter dette «medlemmer som ble endret», ikke «medlemmer
som fikk ny status».

---

## `TAG_SurveyXactDatasetSyncQueueable`

Ukjente svarkoder logges som `Warning`, ellers oppdages det ikke at SurveyXact
har lagt til et alternativ kodeboken ikke kjenner. Queueablen fanger opp
`result.unknownValues`, fjerner duplikater med et `Set`, og logger dem samlet i
én melding.

---

## Tester

`sync-reactivation/TAG_SurveyXactDatasetSyncTest.cls` inneholder 7
testmetoder, fem flere enn dagens statusversjon:

| Test                                   | Dekker                                      |
| -------------------------------------- | ------------------------------------------- |
| `promotesOnlyEligibleCompletedMembers` | status settes kun på kvalifiserte medlemmer |
| `noCompletedRespondentsDoesNothing`    | tom CSV gir ingen endring                   |
| `writesAnswersForCompletedRespondents` | svartekst skrives                           |
| `writesStructuredFieldsAndRawJson`     | de strukturerte feltene og JSON skrives     |
| `doesNotOverwriteExistingAnswers`      | eksisterende svar bevares                   |
| `completedWithoutAnswersIsNotUpdated`  | `Gjennomført` uten svar gir ingen skriving  |
| `leavesMemberFromEarlierYearUntouched` | årsgrensen holder                           |

---

## Det som ble beholdt i den aktive integrasjonen

**Årsgrense.** Spørringen begrenses til medlemmer på en kampanje som starter i
undersøkelsesåret:

```apex
AND CustomCampaign__r.StartDate__c >= :yearStart
AND CustomCampaign__r.StartDate__c <= :yearEnd
```

Uten denne ville et medlem fra et tidligere år med samme respondentnøkkel også
blitt oppdatert. Testet og bekreftet i scratch org.

**Konsekvens som må være på plass:** et kampanjemedlem uten kampanje, eller på
en kampanje uten `StartDate__c`, blir nå hoppet over. Kontroller at
produksjonsdata har startdato før dette settes i drift.

---

## Personvern – notat til videre arbeid

Vurderingen som ble gjort før parkeringen, til bruk hvis saken tas opp igjen:

-   Selve kodeboken inneholder kun spørsmåls- og svartekster, ingen persondata.
    Skjemaet distribueres til tusenvis av virksomheter og er ikke fortrolig.
-   13 fylkesvariabler er fritekstfelter for kontaktinformasjon (navn, e-post,
    telefon) som respondenten selv fyller ut. Disse er persondata.
-   Kolonnene `email` og `epost` er adressen Nav sendte invitasjonen til, ikke noe
    respondenten har skrevet. `navn2` og `navn3` er **ikke** persondata, men
    fortsettelseslinjer av virksomhetsnavnet fra Enhetsregisteret.
-   SurveyXact sletter svarene etter omtrent ett år. Lagring i Salesforce gjør
    Salesforce til eneste kopi, og sletteplikten flyttes dermed til oss. Dette bør
    avklares med jurist før eventuell aktivering.
