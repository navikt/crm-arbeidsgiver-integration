# Lagring av svar fra bedriftsundersøkelsen

> **PARKERT.** Denne løsningen er ikke i drift. Se `REACTIVATION.md` i samme
> mappe for bakgrunn og for hva som må til for å aktivere den. Dokumentet under
> beskriver løsningen slik den ble bygget og testet.

Denne delen lagrer respondentens svar på bedriftsundersøkelsen som lesbar tekst
i `CustomCampaignMember__c.TAG_BUAnswers__c`, med de viktigste svarene i tillegg
i egne felter det kan rapporteres på.

Svarene skrives av den samme timesjobben som setter status til `Gjennomført`.
Det er ikke en egen integrasjon: ingen ekstra callout, ingen ekstra planlagt
jobb. Uttrekket inneholder allerede alle kolonnene – tidligere ble bare
`respnokk` og `c_1` brukt, resten ble kastet.

Se `Documentation.md` i samme mappe for oppsett av Named Credential,
konfigurasjon og planlagt kjøring. Alt det gjelder også her.

---

## Arkitektur (kort)

| Komponent                       | Ansvar                                                 |
| ------------------------------- | ------------------------------------------------------ |
| `TAG_SurveyXactDatasetParser`   | Gir alle kolonnene per rad i `Row.values` (uendret)    |
| `TAG_SurveyXactCodebook`        | Spørsmåls- og svartekster, generert fra `Kodebok.xlsx` |
| `TAG_SurveyXactAnswerFormatter` | Bygger svartekst, JSON og feltverdier fra én rad       |
| `TAG_SurveyXactDatasetSync`     | Skriver verdiene til `TAG_BU`-feltene                  |

Feltene ligger på `CustomCampaignMember__c`, som eies av
`crm-arbeidsgiver-base`. De må derfor opprettes der, ikke i dette repoet.

Alle feltene har prefikset `TAG_BU` fordi objektet deles med tre andre
kampanjetyper. `REACTIVATION.md` har etiketter og norske oversettelser.

| API-navn                          | Type           | Detaljer                                       |
| --------------------------------- | -------------- | ---------------------------------------------- |
| `TAG_BUAnswers__c`                | Long Text Area | 131 072 tegn – hele svaret som lesbar tekst    |
| `TAG_BUJSONAnswers__c`            | Long Text Area | 131 072 tegn – rådata, kun for administratorer |
| `TAG_BUEmployeesToday__c`         | Number(5,0)    | spørsmål 1                                     |
| `TAG_BUEmployeeOutlookOneYear__c` | Picklist       | spørsmål 2, ikke begrenset                     |
| `TAG_BUFailedRecruitment__c`      | Picklist       | spørsmål 3, ikke begrenset                     |
| `TAG_BUFailedRecruitmentCause__c` | Picklist       | spørsmål 4, ikke begrenset                     |
| `TAG_BUUnfilledPositions__c`      | Long Text Area | 5 000 tegn, spørsmål 5                         |
| `TAG_BUAiUsage__c`                | Long Text Area | 2 000 tegn, spørsmål 6                         |
| `TAG_BUAiNotUsedReason__c`        | Long Text Area | 2 000 tegn, spørsmål 7                         |

Plukklistene må være **ikke begrenset**. Hvis SurveyXact legger til et
alternativ, feiler ellers hele batchen med
`INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST`. Ukjente koder logges i stedet som
`Warning`.

---

## Når skrives svarene

Svarene skrives når **begge** disse er oppfylt:

1. `c_1` i uttrekket er `1` (gjennomført)
2. `TAG_BUAnswers__c` er tom på medlemmet
3. Medlemmet ligger på en kampanje som starter i undersøkelsesåret

Det betyr at svarene lagres én gang, første gang respondenten registreres som
ferdig. Endrer respondenten svaret sitt i SurveyXact senere, blir det som
allerede står i Salesforce ikke overskrevet.

Grunnen til at vilkåret er «feltet er tomt» og ikke «status endres til
gjennomført», er at det gjør det mulig å etterfylle. Tømmer man feltet på et
medlem, fylles det ved neste kjøring. Hadde vi hengt skrivingen på
statusendringen, måtte man nullstilt statusen for å få svarene på nytt.

Respondenter som ikke har svart får ingen tekst – feltet forblir tomt.

---

## Hva som lagres

Hele spørreskjemaet: basisspørsmål 1–7 og fylkets tilleggsspørsmål.

Fylkesspørsmålene kommer til slutt, under overskriften
`--- TILLEGGSSPØRSMÅL FRA FYLKET ---`, og nummereres `Tilleggsspørsmål 1`,
`Tilleggsspørsmål 2` og så videre. De skilles ut fordi de varierer mellom
fylkene og ikke kan sammenlignes på tvers.

> **Personopplysninger:** noen fylker bruker tilleggsspørsmålene til å be om
> navn, e-post og telefonnummer til en kontaktperson. Den teksten havner da i
> `TAG_BUAnswers__c`. Dette må vurderes på nytt før løsningen aktiveres, se
> avsnittet om personvern i `REACTIVATION.md`.

Spørsmål respondenten ikke har besvart tas ikke med. Har man svart «Nei» på
spørsmål 3, hoppes spørsmål 4 og 5 over i skjemaet, og da står de heller ikke i
teksten.

Eksempel:

```
1. Hvor mange ansatte er det i virksomheten i dag?
37

2. Hvor mange ansatte venter dere å ha om ett år?
Like mange som i dag

3. Har virksomheten de siste tre månedene forsøkt å rekruttere inn personer uten å få tak i rett/ønsket kompetanse?
Nei

6. Bruker virksomheten kunstig intelligens (KI) for å gjennomføre en eller flere av følgende arbeidsoppgaver?
- Bearbeiding og analyse av tekst (f.eks. søk og oppsummeringer av tekst)
- Andre oppgaver

--- TILLEGGSSPØRSMÅL FRA FYLKET ---

Tilleggsspørsmål 1
Er det aktuelt for virksomheten å ta inn lærlinger?
Ja
```

Et typisk svar er 400–1 500 tegn. Verste tilfelle, Møre og Romsdal med flest
tilleggsspørsmål og alt fylt ut, ligger rundt 16 600 tegn. Feltet rommer
131 072, så det er god margin.

I tillegg lagres hele raden som JSON i `TAG_BUJSONAnswers__c`. Det feltet er
råkopien fra SurveyXact og er ment for feilsøking, ikke for lesing. Det er
verdiløst uten kodeboken for samme årgang, siden det er kolonnenavn og tallkoder
som lagres, ikke tekst.

---

## Hvorfor tekstfelt og ikke ett felt per spørsmål

Uttrekket har 296 kolonner, men skjemaet har bare 7 basisspørsmål. Kolonnene
multipliseres opp på tre måter:

| Type       | Hvordan det gir kolonner                 | Eksempel                      |
| ---------- | ---------------------------------------- | ----------------------------- |
| Enkeltvalg | Én kolonne med tallkode                  | `ans_1aar` = `2`              |
| Avkryssing | Én kolonne per alternativ, verdi `0`/`1` | `basis_1` … `basis_8`         |
| Rutenett   | Rad × kolonne                            | `s_2_1a` … `s_2_10` (30 stk.) |

I tillegg ligger alle fylkers tilleggsspørsmål som egne kolonner på hver eneste
rad – 92 kolonner der de fleste alltid er tomme, siden en respondent bare ser
sitt eget fylkes spørsmål. Resten er bakgrunnsdata om virksomheten, som vi
allerede har i Salesforce.

Fylkene velger nye tilleggsspørsmål hvert år, og variabelnavnene følger ikke
noe mønster som kan utledes (`s_34_moreogromsdal`, `s_9_vestland_1`,
`s_2_moreogromsdal_1`). Et oppsett med ett felt per spørsmål måtte vært endret
hver årgang. Et tekstfelt tåler at skjemaet endrer seg.

Løsningen er derfor todelt: alt havner i `TAG_BUAnswers__c` som lesbar tekst,
mens de sju basisspørsmålene i tillegg skrives til egne felter det kan
rapporteres på. Basisspørsmålene ligger stabilt fra år til år og tåler egne
felter. Tilleggsspørsmålene fra fylkene gjør det ikke, og finnes bare i teksten.

Det betyr at tilleggsspørsmålene kan leses, men ikke telles. Det er akseptert –
behovet er at NAV-ansatte skal kunne se hva virksomheten har svart.

---

## Kolonnenavn i uttrekket

Kodeboken bruker fulle variabelnavn, men CSV-headeren bruker forkortede navn på
maks 8 tegn. Det er de forkortede navnene som ligger i Apex.

| Spørsmål | Kolonner i CSV        | Kodebok                   |
| -------- | --------------------- | ------------------------- |
| 1        | `ans_idag`            | `ans_idag`                |
| 2        | `ans_1aar`            | `ans_1aar`                |
| 3        | `problem`             | `problem`                 |
| 4        | `alv_prob`            | `alv_problem`             |
| 5        | `s_2_1a` … `s_2_10`   | `s_2_1a` … `s_2_10`       |
| 6        | `basis_1` … `basis_8` | `basis_6_1` … `basis_6_8` |
| 7        | `basis_9` … `basi_13` | `basis_7_1` … `basis_7_5` |

> **Fallgruve:** `basis_6` er **alternativ 6 i spørsmål 6**, ikke spørsmål 6.
> Spørsmål 7 begynner på `basis_9`. Nummereringen kan ikke utledes fra navnet,
> så både spørsmål og alternativ er listet eksplisitt i
> `TAG_SurveyXactAnswerFormatter`.

Spørsmålstekster og verdikoder ligger i `TAG_SurveyXactCodebook`, generert fra
`Kodebok.xlsx`. Endres skjemaet, må klassen genereres på nytt fra årets kodebok.

---

## Testing

### Test 1 — Formatering uten callout

Sjekker at kolonner blir til lesbar tekst. Ingen callout, ingen data i orgen.

```apex
Map<String, String> values = new Map<String, String>{
    'ans_idag' => '37',
    'ans_1aar' => '2',
    'problem' => '1',
    'alv_prob' => '1',
    's_2_1a' => 'Sykepleier',
    's_2_1b' => 'Bachelor i sykepleie',
    's_2_1' => '4',
    'basis_2' => '1',
    'basis_8' => '1'
};
System.debug(LoggingLevel.INFO, '\n' + TAG_SurveyXactAnswerFormatter.build(values).answers);
```

### Test 2 — Mot ekte data

Kjør den vanlige timesjobben og se på et medlem som nettopp ble Gjennomført:

```apex
System.enqueueJob(new TAG_SurveyXactDatasetSyncQueueable());
```

```apex
System.debug(LoggingLevel.INFO, [
    SELECT Key__c, Status__c, TAG_BUAnswers__c, TAG_BUEmployeesToday__c
    FROM CustomCampaignMember__c
    WHERE Status__c = 'Gjennomført'
    LIMIT 5
]);
```

> `TAG_BUAnswers__c` er Long Text Area og **kan ikke** brukes i `WHERE`.
> `WHERE TAG_BUAnswers__c != NULL` feiler med `field ... can not be filtered in a query call`. Filtrer på `Status__c` i stedet.

### Test 3 — Etterfylling

Tøm feltet på ett medlem og kjør jobben på nytt. Teksten skal komme tilbake,
mens medlemmer som allerede har tekst er urørt.

```apex
update new CustomCampaignMember__c(Id = '<id>', TAG_BUAnswers__c = null);
```

---

## Ny årgang

Kodeboken må hentes inn på nytt hver årgang. Fylkene velger nye
tilleggsspørsmål, og variabelnavnene kan bety noe annet enn året før.
`TAG_SurveyXactCodebook` genereres derfor på nytt fra årets `Kodebok.xlsx`.

Be om ny kodebok fra SurveyXact og kontroller:

1. At kolonnenavnene i tabellen over fortsatt stemmer
2. At svaralternativene i spørsmål 6 og 7 er de samme, og i samme rekkefølge
3. At spørsmål 5 fortsatt har ti rader
