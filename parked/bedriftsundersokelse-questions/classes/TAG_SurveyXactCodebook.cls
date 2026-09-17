/**
 * Question and answer-option texts for the Bedriftsundersokelsen questionnaire,
 * generated from the SurveyXact codebook (Kodebok.xlsx).
 *
 * Column names are the truncated 8-character names used in the CSV header, not
 * the full variable names from the codebook. Question texts are stored once and
 * referenced by key, because a single question can span many columns.
 *
 * Question 5 is a grid and is rendered by TAG_SurveyXactAnswerFormatter, so its
 * columns are deliberately absent here.
 *
 * Regenerate this class when a new codebook is published. Answers already
 * written keep the wording used at the time they were stored.
 */
public with sharing class TAG_SurveyXactCodebook {
    public enum AnswerKind {
        SINGLE,
        MULTIPLE,
        TEXT
    }

    public class Variable {
        public String column;
        public String question;
        public String option;
        public AnswerKind kind;
        public Map<String, String> valueLabels;

        private Variable(String column, String questionKey, String option, AnswerKind kind, String valueSetKey) {
            this.column = column;
            this.question = QUESTIONS.get(questionKey);
            this.option = option;
            this.kind = kind;
            this.valueLabels = valueSetKey == null ? null : VALUE_SETS.get(valueSetKey);
        }
    }

    private static final Map<String, String> QUESTIONS = new Map<String, String>{
        'Q1' => '1. Hvor mange ansatte er det i virksomheten i dag?',
        'Q2' => '2. Hvor mange ansatte venter dere å ha om ett år? Ta med de samme gruppene som i spørsmål 1. Gi en vurdering ut fra virksomhetens forventninger i dag.',
        'Q3' => '3. Har virksomheten de siste tre månedene forsøkt å rekruttere inn personer uten å få tak i rett/ønsket kompetanse? Vi ønsker svar selv om dere ikke venter en økning i antall ansatte det kommende året. Med forsøkt å rekruttere menes her at virksomheten aktivt har forsøkt å rekruttere ny(e) medarbeider(e) ved å lyse ut stilling, headhunte eller lignende, uten å lykkes.',
        'Q4' => '4. Hva skyldes dette?',
        'Q5' => '6. Bruker virksomheten kunstig intelligens (KI) for å gjennomføre en eller flere av følgende arbeidsoppgaver? Med KI menes generativ KI (som ChatGPT/Copilot), maskinlæring eller KI innebygd i programvare. Flere kryss mulig.',
        'Q6' => '7. Hva er de viktigste grunnene til at virksomheten ikke bruker KI? Flere kryss mulig.',
        'Q7' => 'Er det aktuelt å gi personer med tilretteleggingsbehov og/eller med hull i cv-en en jobbmulighet i din virksomhet?',
        'Q8' => 'Kan din bedrift ta i mot lærlinger?',
        'Q9' => 'På bakgrunn av svarene som er avgitt i denne undersøkelsen, vil du at Nav skal ta kontakt med deg og din bedrift, og informere om Navs tjenester til arbeidsgivere?',
        'Q10' => 'Vennligst oppgi kontaktaktinformasjon slik at Nav kan ta kontakt med deg og din virksomhet, og informere om Navs tjenester til arbeidsgivere',
        'Q11' => 'Ønsker du/din virksomhet å bidra til å inkludere unge under 30 år i arbeidslivet?',
        'Q12' => 'Kontaktinformasjon:',
        'Q13' => 'For å redusere sykefravær i din bedrift, hva tenker du er de største utfordringene? Velg de tre utfordringene du som arbeidsgiver synes er mest utfordrende i oppfølgingen av sykemeldte medarbeidere i din virksomhet:',
        'Q14' => 'Ønsker du flere treffpunkt med Nav i sykefraværsoppfølgingen av arbeidstakere?',
        'Q15' => 'Vennligst oppgi kontaktaktinformasjon slik at Nav kan ta kontakt med deg og din bedrift, og informere om Navs tjenester til arbeidsgivere',
        'Q16' => 'Hvordan vurderes utsiktene for 2026 sammenlignet med 2025 når det gjelder? Kun ett kryss per linje',
        'Q17' => 'Ditt lokale Nav- kontor tilbyr en rekke tjenester til arbeidsgivere. I den forbindelse ønsker vi å vite om dere ønsker å bli kontaktet av Nav i forbindelse med en eller flere av våre tjenester. Er det aktuelt for din bedrift å bli kontaktet av Nav vedrørende: Flere svar er mulig',
        'Q18' => 'Hvordan vurderes utsiktene for 2026 vurdert i forhold til 2025 når det gjelder: - Markedsutsiktene - Sett bare ett kryss i hver linje',
        'Q19' => 'Hvordan vurderes utsiktene for 2026 vurdert i forhold til 2025 når det gjelder: - Driftsresultat (overskudd) - Sett bare ett kryss i hver linje',
        'Q20' => 'Hvordan vurderes utsiktene for 2026 vurdert i forhold til 2025 når det gjelder: - Omsetning - Sett bare ett kryss i hver linje',
        'Q21' => 'Hvordan vurderes utsiktene for 2026 vurdert i forhold til 2025 når det gjelder: - Investeringer - Sett bare ett kryss i hver linje',
        'Q22' => 'Hvordan vurderes utsiktene for 2026 vurdert i forhold til 2025 når det gjelder: - Eksport - Sett bare ett kryss i hver linje',
        'Q23' => 'Er bedriften knyttet opp til oljeindustrien eller har leveranser til denne?',
        'Q24' => 'Hvilken type utdanningsnivå har dere behov for å rekruttere i 2026? Flere kryss er mulig.',
        'Q25' => 'Hvilke av følgende tiltak gjennomfører, eller planlegger virksomheten, å gjennomføre i 2026? Flere kryss er mulig.',
        'Q26' => 'Er det aktuelt å gi personer med tilretteleggingsbehov og/eller med hull i CV-en en jobbmulighet i din virksomhet?',
        'Q27' => 'Hvilke faktorer er viktigst for at dette er aktuelt for din bedrift? (mulig å krysse av flere)',
        'Q28' => 'Hvilke faktorer bidrar mest til at dette ikke er aktuelt for din bedrift? (mulig å krysse av flere)',
        'Q29' => 'Har dere forslag til hva som kan gjøres for å inkludere flere av de som i dag står utenfor arbeidslivet?',
        'Q30' => 'Er det aktuelt for virksomheten å ansette flere lærlinger enn i dag? (gjelder både om din virksomhet har lærlinger eller ikke i dag)',
        'Q31' => 'Hvilke faktorer er mest avgjørende for at virksomheten skal ansette flere lærlinger? Kryss av inntil to alternativer',
        'Q32' => 'Hva er de viktigste årsakene til at virksomheten vurderer det som lite aktuelt å ansette flere lærlinger? Kryss av inntil to alternativer',
        'Q33' => 'Vi bekrefter at opplysninger gitt i denne undersøkelsen kan brukes av Nav til å gi oss konkret informasjon eller bistand.',
        'Q34' => 'Kan det være aktuelt for din bedrift å ansette personer med behov for ekstra oppfølging eller tilrettelegging?'
    };

    private static final Map<String, Map<String, String>> VALUE_SETS = new Map<String, Map<String, String>>{
        'V1' => new Map<String, String>{
            '1' => 'Flere enn i dag',
            '2' => 'Like mange som i dag',
            '3' => 'Færre enn i dag'
        },
        'V2' => new Map<String, String>{
            '1' => 'Ja, vi fikk ikke ansatt noen',
            '2' => 'Vi fikk ikke ansatt noen med de kvalifikasjonene vi søkte etter, men har ansatt noen med lavere eller annen formell kompetanse',
            '3' => 'Nei'
        },
        'V3' => new Map<String, String>{ '1' => 'Ingen/for få kvalifiserte søkere', '2' => 'Annet' },
        'V4' => new Map<String, String>{ '1' => 'Ja', '2' => 'Nei', '3' => 'Vet ikke' },
        'V5' => new Map<String, String>{
            '1' => 'Ja, min bedrift kan ta imot læringer',
            '2' => 'Nei, min bedrift har dessverre ikke mulighet til å ta imot noen på nåværende tidspunkt',
            '3' => 'Vet ikke/usikker'
        },
        'V6' => new Map<String, String>{ '1' => 'Ja', '2' => 'Nei' },
        'V7' => new Map<String, String>{
            '1' => 'Ja. Kan du si noe om hvorfor?',
            '2' => 'Nei. Kan du si noe om hvorfor?'
        },
        'V8' => new Map<String, String>{ '1' => 'Ned', '2' => 'Stabilt', '3' => 'Opp', '4' => 'Ikke aktuelt' },
        'V9' => new Map<String, String>{ '1' => 'Ned', '2' => 'Stabilt', '3' => 'Opp', '99' => 'Ikke aktuelt' },
        'V10' => new Map<String, String>{
            '1' => 'Er i oljeindustrien',
            '2' => 'Leverer i stor grad til oljeindustrien (Over 50%)',
            '3' => 'Leverer i noen grad til oljeindustrien (Under 50%)',
            '4' => 'Ikke aktuelt'
        },
        'V11' => new Map<String, String>{ '1' => 'Ja', '2' => 'Nei', '3' => 'Usikker' },
        'V12' => new Map<String, String>{ '0' => 'Nei', '1' => 'Ja' }
    };

    // Listed in questionnaire order, which is the order answers are rendered in.
    public static final List<Variable> VARIABLES = new List<Variable>{
        new Variable('ans_idag', 'Q1', null, AnswerKind.TEXT, null),
        new Variable('ans_1aar', 'Q2', null, AnswerKind.SINGLE, 'V1'),
        new Variable('problem', 'Q3', null, AnswerKind.SINGLE, 'V2'),
        new Variable('alv_prob', 'Q4', null, AnswerKind.SINGLE, 'V3'),
        new Variable('basis_1', 'Q5', 'Nei, vi bruker ikke KI', AnswerKind.MULTIPLE, null),
        new Variable(
            'basis_2',
            'Q5',
            'Bearbeiding og analyse av tekst (f.eks. søk og oppsummeringer av tekst)',
            AnswerKind.MULTIPLE,
            null
        ),
        new Variable(
            'basis_3',
            'Q5',
            'Rekruttering og HR (f.eks. stillingsannonser og sortering av søknader)',
            AnswerKind.MULTIPLE,
            null
        ),
        new Variable('basis_4', 'Q5', 'Dataanalyse og prognoser (f.eks. risiko og økonomi)', AnswerKind.MULTIPLE, null),
        new Variable(
            'basis_5',
            'Q5',
            'Kundeservice eller intern støtte (f.eks. chatbot og veiledning)',
            AnswerKind.MULTIPLE,
            null
        ),
        new Variable('basis_6', 'Q5', 'Markedsføring og salg (f.eks. innholdsproduksjon)', AnswerKind.MULTIPLE, null),
        new Variable(
            'basis_7',
            'Q5',
            'Bilde-/taleoppgaver (f.eks. kvalitetskontroll og transkripsjon)',
            AnswerKind.MULTIPLE,
            null
        ),
        new Variable('basis_8', 'Q5', 'Andre oppgaver', AnswerKind.MULTIPLE, null),
        new Variable('basis_9', 'Q6', 'Vi ser ikke relevante bruksområder nå', AnswerKind.MULTIPLE, null),
        new Variable('basi_10', 'Q6', 'Kostnader eller usikker lønnsomhet', AnswerKind.MULTIPLE, null),
        new Variable(
            'basi_11',
            'Q6',
            'Ikke prioritert av ledelsen (f.eks. endringsmotstand)',
            AnswerKind.MULTIPLE,
            null
        ),
        new Variable(
            'basi_12',
            'Q6',
            'Personvern, sikkerhet eller juridiske hensyn (f.eks. GDPR)',
            AnswerKind.MULTIPLE,
            null
        ),
        new Variable(
            'basi_13',
            'Q6',
            'Mangler kompetanse eller kapasitet (f.eks. internt eller vanskelig å rekruttere)',
            AnswerKind.MULTIPLE,
            null
        ),
        new Variable('s_1_oest', 'Q7', null, AnswerKind.SINGLE, 'V4'),
        new Variable('s_6_oest', 'Q8', null, AnswerKind.SINGLE, 'V5'),
        new Variable('s_2_oest', 'Q9', null, AnswerKind.SINGLE, 'V6'),
        new Variable('s_3_oest', 'Q10', 'Kontaktperson:', AnswerKind.TEXT, null),
        new Variable('s_4_oest', 'Q10', 'E-post', AnswerKind.TEXT, null),
        new Variable('s_5_oest', 'Q10', 'Telefonnummer', AnswerKind.TEXT, null),
        new Variable('s_1_aker', 'Q7', null, AnswerKind.SINGLE, 'V4'),
        new Variable('s_6_aker', 'Q8', null, AnswerKind.SINGLE, 'V5'),
        new Variable('s_2_aker', 'Q9', null, AnswerKind.SINGLE, 'V6'),
        new Variable('s_3_aker', 'Q10', 'Kontaktperson:', AnswerKind.TEXT, null),
        new Variable('s_4_aker', 'Q10', 'E-post', AnswerKind.TEXT, null),
        new Variable('s_5_aker', 'Q10', 'Telefonnummer', AnswerKind.TEXT, null),
        new Variable('s_1_oslo', 'Q11', null, AnswerKind.SINGLE, 'V6'),
        new Variable('s_2_oslo', 'Q12', 'Navn:', AnswerKind.TEXT, null),
        new Variable('s_3_oslo', 'Q12', 'Virksomhet:', AnswerKind.TEXT, null),
        new Variable('s_4_oslo', 'Q12', 'E-post', AnswerKind.TEXT, null),
        new Variable('s_5_oslo', 'Q12', 'Telefonnummer', AnswerKind.TEXT, null),
        new Variable(
            's_1_i_1',
            'Q13',
            'For lite kjennskap til lovverk, styringsrett, medvirkningsplikt og komplisert regelverk rundt sykefraværsoppfølging',
            AnswerKind.MULTIPLE,
            null
        ),
        new Variable(
            's_1_i_2',
            'Q13',
            'Manglende rolleforståelse og samarbeid mellom arbeidsgiver, sykemeldt, fastlege og Nav',
            AnswerKind.MULTIPLE,
            null
        ),
        new Variable(
            's_1_i_3',
            'Q13',
            'Tidsbruk og/eller manglende HR-ressurser i egen organisasjon',
            AnswerKind.MULTIPLE,
            null
        ),
        new Variable(
            's_1_i_4',
            'Q13',
            'Vanskelig å gjennomføre samtaler og opprettholde god dialog med den sykemeldte (inkl. frykt for å trå feil eller virke for pågående)',
            AnswerKind.MULTIPLE,
            null
        ),
        new Variable(
            's_1_i_5',
            'Q13',
            'Begrensede muligheter for tilrettelegging på arbeidsplassen, inkludert fysiske, organisatoriske og økonomiske begrensninger',
            AnswerKind.MULTIPLE,
            null
        ),
        new Variable(
            's_1_i_6',
            'Q13',
            'Vanskelig å håndtere sykefravær knyttet til stress, konflikter eller psykososiale faktorer',
            AnswerKind.MULTIPLE,
            null
        ),
        new Variable(
            's_1_i_7',
            'Q13',
            'Manglende kompetanse på forebyggende arbeid og arbeidsmiljøproblemer',
            AnswerKind.MULTIPLE,
            null
        ),
        new Variable(
            's_1_i_8',
            'Q13',
            'Vansker med kontinuitet i oppfølgingen ved langvarig sykefravær',
            AnswerKind.MULTIPLE,
            null
        ),
        new Variable(
            's_1_i_9',
            'Q13',
            'Problemer med sykefraværsrefusjon og økonomiske ordninger fra Nav',
            AnswerKind.MULTIPLE,
            null
        ),
        new Variable('s_2_innl', 'Q14', null, AnswerKind.SINGLE, 'V7'),
        new Variable('s_3_innl', 'Q14', 'Ja. Kan du si noe om hvorfor?', AnswerKind.TEXT, null),
        new Variable('s_4_innl', 'Q14', 'Nei. Kan du si noe om hvorfor?', AnswerKind.TEXT, null),
        new Variable('s_1_busk', 'Q7', null, AnswerKind.SINGLE, 'V4'),
        new Variable('s_6_busk', 'Q8', null, AnswerKind.SINGLE, 'V5'),
        new Variable('s_2_busk', 'Q9', null, AnswerKind.SINGLE, 'V6'),
        new Variable('s_3_busk', 'Q15', 'Kontaktperson:', AnswerKind.TEXT, null),
        new Variable('s_4_busk', 'Q15', 'E-post', AnswerKind.TEXT, null),
        new Variable('s_5_busk', 'Q15', 'Telefonnummer', AnswerKind.TEXT, null),
        new Variable('s_1_agde', 'Q16', 'Markedsutsiktene', AnswerKind.SINGLE, 'V8'),
        new Variable('s_2_agde', 'Q16', 'Driftsresultat (overskudd)', AnswerKind.SINGLE, 'V8'),
        new Variable('s_3_agde', 'Q16', 'Omsetning', AnswerKind.SINGLE, 'V8'),
        new Variable('s_4_agde', 'Q16', 'Investeringer', AnswerKind.SINGLE, 'V8'),
        new Variable('s_5_agde', 'Q16', 'Eksport', AnswerKind.SINGLE, 'V8'),
        new Variable('s_6_a_1', 'Q17', 'Rekruttere nye medarbeidere', AnswerKind.MULTIPLE, null),
        new Variable('s_6_a_2', 'Q17', 'Rekruttere nye medarbeidere fra EU/EØS (Eures)', AnswerKind.MULTIPLE, null),
        new Variable('s_6_a_3', 'Q17', 'Permittering/nedbemanning/omstilling', AnswerKind.MULTIPLE, null),
        new Variable(
            's_6_a_4',
            'Q17',
            'Navs digitale selvbetjenings-tjenester til arbeidsgiver',
            AnswerKind.MULTIPLE,
            null
        ),
        new Variable('s_6_a_5', 'Q17', 'Ikke aktuelt', AnswerKind.MULTIPLE, null),
        new Variable('s_7_1_ve', 'Q18', null, AnswerKind.SINGLE, 'V9'),
        new Variable('s_7_2_ve', 'Q19', null, AnswerKind.SINGLE, 'V9'),
        new Variable('s_7_3_ve', 'Q20', null, AnswerKind.SINGLE, 'V9'),
        new Variable('s_7_4_ve', 'Q21', null, AnswerKind.SINGLE, 'V9'),
        new Variable('s_7_5_ve', 'Q22', null, AnswerKind.SINGLE, 'V9'),
        new Variable('s_8_vest', 'Q23', null, AnswerKind.SINGLE, 'V10'),
        new Variable('s_9_v_1', 'Q24', 'Universitet/høyskoleutdanning', AnswerKind.MULTIPLE, null),
        new Variable('s_9_v_2', 'Q24', 'Fagarbeidere', AnswerKind.MULTIPLE, null),
        new Variable('s_9_v_3', 'Q24', 'Ufaglærte', AnswerKind.MULTIPLE, null),
        new Variable('s_9_v_4', 'Q24', 'Ikke aktuelt', AnswerKind.MULTIPLE, null),
        new Variable(
            's_3_v_1',
            'Q25',
            'Styrke innovasjonen i bedriften. (Feks. ny teknologi, nye arbeidsmetoder el.)',
            AnswerKind.MULTIPLE,
            null
        ),
        new Variable(
            's_3_v_2',
            'Q25',
            'Styrke satsingen på kompetanseheving blant de ansatte',
            AnswerKind.MULTIPLE,
            null
        ),
        new Variable('s_3_v_3', 'Q25', 'Organisasjonsmessige endringer', AnswerKind.MULTIPLE, null),
        new Variable('s_3_v_4', 'Q25', 'Permittering av ansatte', AnswerKind.MULTIPLE, null),
        new Variable('s_3_v_5', 'Q25', 'Oppsigelser av ansatte', AnswerKind.MULTIPLE, null),
        new Variable('s_3_v_6', 'Q25', 'Ingen/Annet', AnswerKind.MULTIPLE, null),
        new Variable('s_34_mor', 'Q26', null, AnswerKind.SINGLE, 'V11'),
        new Variable(
            's_2_m_1',
            'Q27',
            'Har god erfaring med å ansette personer med tilretteleggingsbehov og/eller hull i CV',
            AnswerKind.MULTIPLE,
            null
        ),
        new Variable(
            's_2_m_2',
            'Q27',
            'Bedriften har kapasitet til å gi kompetanseheving for å mestre arbeidsoppgavene',
            AnswerKind.MULTIPLE,
            null
        ),
        new Variable(
            's_2_m_3',
            'Q27',
            'Opplever dette som en del av bedriftens samfunnsoppdrag',
            AnswerKind.MULTIPLE,
            null
        ),
        new Variable('s_2_m_4', 'Q27', 'Økonomisk støtte fra Nav', AnswerKind.MULTIPLE, null),
        new Variable('s_2_m_5', 'Q27', 'Oppfølging fra Nav', AnswerKind.MULTIPLE, null),
        new Variable(
            's_3_m_1',
            'Q28',
            'Har dårlig erfaring med ansette personer med tilretteleggingsbehov og/eller hull i CV',
            AnswerKind.MULTIPLE,
            null
        ),
        new Variable(
            's_3_m_2',
            'Q28',
            'Kjenner ikke til Nav sine virkemidler for å bidra til jobbmulighet for de med tilretteleggingsbehov og/eller hull i CV',
            AnswerKind.MULTIPLE,
            null
        ),
        new Variable(
            's_3_m_3',
            'Q28',
            'Manglende ressurser i bedriften til å håndtere opplæring av personer med tilretteleggingsbehov og/eller hul i CV',
            AnswerKind.MULTIPLE,
            null
        ),
        new Variable('s_3_m_4', 'Q28', 'Manglende økonomisk støtte fra Nav', AnswerKind.MULTIPLE, null),
        new Variable('s_3_m_5', 'Q28', 'Manglende oppfølging fra Nav', AnswerKind.MULTIPLE, null),
        new Variable('s_4_more', 'Q29', null, AnswerKind.TEXT, null),
        new Variable('s_10_mor', 'Q30', null, AnswerKind.SINGLE, 'V6'),
        new Variable(
            's_11__1',
            'Q31',
            'Behov for flere ansatte med yrkesfaglig kompetanse (fagbrev)',
            AnswerKind.MULTIPLE,
            null
        ),
        new Variable('s_11__2', 'Q31', 'Økonomisk støtte for å ansette lærlinger', AnswerKind.MULTIPLE, null),
        new Variable(
            's_11__3',
            'Q31',
            'Tilgang på god veiledning og støtte til oppfølging av lærlinger',
            AnswerKind.MULTIPLE,
            null
        ),
        new Variable('s_11__4', 'Q31', 'Krav om lærlinger ved offentlige anbud', AnswerKind.MULTIPLE, null),
        new Variable(
            's_11__5',
            'Q31',
            'Mulighet for samarbeid med andre virksomheter om opplæring og oppfølging av lærlingene',
            AnswerKind.MULTIPLE,
            null
        ),
        new Variable('s_11__6', 'Q31', 'Annet', AnswerKind.MULTIPLE, null),
        new Variable('s_12_mor', 'Q31', 'Annet', AnswerKind.TEXT, null),
        new Variable(
            's_13__1',
            'Q32',
            'Ikke behov for ansatte med yrkesfaglig kompetanse (fagbrev)',
            AnswerKind.MULTIPLE,
            null
        ),
        new Variable('s_13__2', 'Q32', 'Ikke behov for flere lærlinger', AnswerKind.MULTIPLE, null),
        new Variable('s_13__3', 'Q32', 'Kjenner ikke til lærlingordningen', AnswerKind.MULTIPLE, null),
        new Variable('s_13__4', 'Q32', 'Dårlig erfaringer med lærlinger', AnswerKind.MULTIPLE, null),
        new Variable('s_13__5', 'Q32', 'Ikke nok ressurser til å følge opp lærlinger', AnswerKind.MULTIPLE, null),
        new Variable('s_13__6', 'Q32', 'Annet', AnswerKind.MULTIPLE, null),
        new Variable('s_14_mor', 'Q32', 'Annet', AnswerKind.TEXT, null),
        new Variable('s_9_more', 'Q33', null, AnswerKind.SINGLE, 'V12'),
        new Variable('s_1_nord', 'Q34', null, AnswerKind.SINGLE, 'V4'),
        new Variable('s_1_trom', 'Q34', null, AnswerKind.SINGLE, 'V4'),
        new Variable('s_1_finn', 'Q34', null, AnswerKind.SINGLE, 'V4')
    };
}
