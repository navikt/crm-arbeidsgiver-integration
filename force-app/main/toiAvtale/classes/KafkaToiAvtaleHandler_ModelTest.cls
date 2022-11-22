@IsTest
public with sharing class KafkaToiAvtaleHandler_ModelTest {
    public static String JSON =
    '{' +
    '   \"hendelseType\":\"STILLINGSBESKRIVELSE_ENDRET\",' +
    '   \"avtaleStatus\":\"GJENNOMFØRES\",' +
    '   \"deltakerFnr\":\"02129623805\",' +
    '   \"mentorFnr\":null,' +
    '   \"bedriftNr\":\"910825526\",' +
    '   \"veilederNavIdent\":\"Z992800\",' +
    '   \"tiltakstype\":\"MIDLERTIDIG_LONNSTILSKUDD\",' +
    '   \"opprettetTidspunkt\":\"2022-05-23T10:27:13.626211\",' +
    '   \"id\":\"c9d8fe1e-c4d2-499e-bd16-af3a88b1e734\",' +
    '   \"avtaleNr\":397,' +
    '   \"sistEndret\":\"2022-10-26T09:54:34.265048609Z\",' +
    '   \"annullertTidspunkt\":null,' +
    '   \"annullertGrunn\":null,' +
    '   \"slettemerket\":false,' +
    '   \"opprettetAvArbeidsgiver\":false,' +
    '   \"enhetGeografisk\":\"0805\",' +
    '   \"enhetsnavnGeografisk\":\"NAV Porsgrunn\",' +
    '   \"enhetOppfolging\":\"0219\",' +
    '   \"enhetsnavnOppfolging\":\"NAV Bærum\",' +
    '   \"godkjentForEtterregistrering\":true,' +
    '   \"kvalifiseringsgruppe\":\"BFORM\",' +
    '   \"formidlingsgruppe\":\"ARBS\",' +
    '   \"tilskuddPeriode\":[],' +
    '   \"feilregistrert\":false,' +
    '   \"versjon\":5,' +
    '   \"deltakerFornavn\":\"Overfølsom\",' +
    '   \"deltakerEtternavn\":\"Klovn\",' +
    '   \"deltakerTlf\":\"12345676\",' +
    '   \"bedriftNavn\":\"GAMLE FREDRIKSTAD OG RAMNES REGNSKA P\",' +
    '   \"arbeidsgiverFornavn\":\"Dolly\",' +
    '   \"arbeidsgiverEtternavn\":\"Duck\",' +
    '   \"arbeidsgiverTlf\":\"12345678\",' +
    '   \"veilederFornavn\":\"Onkel\",' +
    '   \"veilederEtternavn\":\"Donald\",' +
    '   \"veilederTlf\":\"12345678\",' +
    '   \"oppfolging\":\"rtretyrteyrtey\",' +
    '   \"tilrettelegging\":\"fdghdfghdfghfdgh\",' +
    '   \"startDato\":\"2022-01-01\",' +
    '   \"sluttDato\":\"2023-01-01\",' +
    '   \"stillingprosent\":100,' +
    '   \"journalpostId\":null,' +
    '   \"arbeidsoppgaver\":\"trrtyrtrtytreyccxzc\",' +
    '   \"stillingstittel\":\"Bussrengjører\",' +
    '   \"stillingStyrk08\":9122,' +
    '   \"stillingKonseptId\":168963,' +
    '   \"antallDagerPerUke\":5,' +
    '   \"refusjonKontaktperson\":null,' +
    '   \"mentorFornavn\":null,' +
    '   \"mentorEtternavn\":null,' +
    '   \"mentorOppgaver\":null,' +
    '   \"mentorAntallTimer\":null,' +
    '   \"mentorTimelonn\":null,' +
    '   \"mentorTlf\":null,' +
    '   \"arbeidsgiverKontonummer\":\"91311592950\",' +
    '   \"lonnstilskuddProsent\":40,' +
    '   \"manedslonn\":20000,' +
    '   \"feriepengesats\":0.143,' +
    '   \"arbeidsgiveravgift\":0.106,' +
    '   \"harFamilietilknytning\":false,' +
    '   \"familietilknytningForklaring\":null,' +
    '   \"feriepengerBelop\":2860,' +
    '   \"otpSats\":0.1,' +
    '   \"otpBelop\":2286,' +
    '   \"arbeidsgiveravgiftBelop\":2665,' +
    '   \"sumLonnsutgifter\":27811,' +
    '   \"sumLonnstilskudd\":11124,' +
    '   \"manedslonn100pst\":27811,' +
    '   \"sumLønnstilskuddRedusert\":8343,' +
    '   \"datoForRedusertProsent\":\"2022-07-01\",' +
    '   \"stillingstype\":\"FAST\",' +
    '   \"maal\":[],' +
    '   \"inkluderingstilskuddsutgift\":[],' +
    '   \"inkluderingstilskuddBegrunnelse\":null,' +
    '   \"inkluderingstilskuddTotalBeløp\":0,' +
    '   \"godkjentAvDeltaker\":\"2022-05-23T10:31:49.922613\",' +
    '   \"godkjentTaushetserklæringAvMentor\":null,' +
    '   \"godkjentAvArbeidsgiver\":\"2022-05-23T10:31:18.693921\",' +
    '   \"godkjentAvVeileder\":\"2022-05-23T10:31:49.922613\",' +
    '   \"godkjentAvBeslutter\":null,' +
    '   \"avtaleInngått\":\"2022-05-23T10:31:49.922613\",' +
    '   \"ikrafttredelsestidspunkt\":\"2022-10-26T11:54:34.265009244\",' +
    '   \"godkjentAvNavIdent\":\"Z992800\",' +
    '   \"godkjentAvBeslutterNavIdent\":null,' +
    '   \"enhetKostnadssted\":null,' +
    '   \"enhetsnavnKostnadssted\":null,' +
    '   \"godkjentPaVegneGrunn\":{\"ikkeBankId\":true,\"reservert\":false,\"digitalKompetanse\":false},' +
    '   \"godkjentPaVegneAv\":true,' +
    '   \"godkjentPaVegneAvArbeidsgiverGrunn\":null,' +
    '   \"godkjentPaVegneAvArbeidsgiver\":false,' +
    '   \"innholdType\":\"ENDRE_STILLING\",' +
    '   \"utførtAv\":\"Z992800\"' +
    '}';

    @isTest
    static void parse() {
        KafkaToiAvtaleHandler_Model model = KafkaToiAvtaleHandler_Model.parse(JSON, null, null);

        System.assertEquals('GJENNOMFØRES', model.avtaleStatus);
        System.assertEquals('MIDLERTIDIG_LONNSTILSKUDD', model.tiltakstype);
        System.assertEquals('02129623805', model.deltakerFnr);
        System.assertEquals(null, model.mentorFnr);
        System.assertEquals('910825526', model.bedriftNr);
        System.assertEquals('Z992800', model.veilederNavIdent);
        System.assertEquals('2022-05-23T10:27:13.626211', model.opprettetTidspunkt);
        System.assertEquals('c9d8fe1e-c4d2-499e-bd16-af3a88b1e734', model.id);
        System.assertEquals('397', model.avtaleNr);
        System.assertEquals('2022-10-26T09:54:34.265048609Z', model.sistEndret);
        System.assertEquals(null, model.annullertTidspunkt);
        System.assertEquals(null, model.annullertGrunn);
        System.assertEquals(false, model.slettemerket);
        System.assertEquals(false, model.opprettetAvArbeidsgiver);
        System.assertEquals('0805', model.enhetGeografisk);
        System.assertEquals('NAV Porsgrunn', model.enhetsnavnGeografisk);
        System.assertEquals('0219', model.enhetOppfolging);
        System.assertEquals('NAV Bærum', model.enhetsnavnOppfolging);
        System.assertEquals(true, model.godkjentForEtterregistrering);
        System.assertEquals('BFORM', model.kvalifiseringsgruppe);
        System.assertEquals('ARBS', model.formidlingsgruppe);
        System.assertEquals(0, model.tilskuddPeriode.size());
        System.assertEquals(false, model.feilregistrert);
        System.assertEquals(5, model.versjon);
        System.assertEquals('Overfølsom', model.deltakerFornavn);
        System.assertEquals('Klovn', model.deltakerEtternavn);
        System.assertEquals('GAMLE FREDRIKSTAD OG RAMNES REGNSKA P', model.bedriftNavn);
        System.assertEquals('Dolly', model.arbeidsgiverFornavn);
        System.assertEquals('Duck', model.arbeidsgiverEtternavn);
        System.assertEquals('12345678', model.arbeidsgiverTlf);
        System.assertEquals('Onkel', model.veilederFornavn);
        System.assertEquals('Donald', model.veilederEtternavn);
        System.assertEquals('rtretyrteyrtey', model.oppfolging);
        System.assertEquals('fdghdfghdfghfdgh', model.tilrettelegging);
        System.assertEquals('2022-01-01', model.startDato);
        System.assertEquals('2023-01-01', model.sluttDato);
        System.assertEquals(100, model.stillingprosent);
        System.assertEquals(null, model.journalpostId);
        System.assertEquals('trrtyrtrtytreyccxzc', model.arbeidsoppgaver);
        System.assertEquals('Bussrengjører', model.stillingstittel);
        System.assertEquals(9122, model.stillingStyrk08);
        System.assertEquals(168963, model.stillingKonseptId);
        System.assertEquals(5, model.antallDagerPerUke);
        System.assertEquals(null, model.refusjonKontaktperson);
        System.assertEquals(null, model.mentorFornavn);
        System.assertEquals(null, model.mentorEtternavn);
        System.assertEquals(null, model.mentorOppgaver);
        System.assertEquals(null, model.mentorAntallTimer);
        System.assertEquals(null, model.mentorTimelonn);
        System.assertEquals(null, model.mentorTlf);
        System.assertEquals('91311592950', model.arbeidsgiverKontonummer);
        System.assertEquals(40, model.lonnstilskuddProsent);
        System.assertEquals(20000, model.manedslonn);
        System.assertEquals(0.143, model.feriepengesats);
        System.assertEquals(0.106, model.arbeidsgiveravgift);
        System.assertEquals(false, model.harFamilietilknytning);
        System.assertEquals(null, model.familietilknytningForklaring);
        System.assertEquals(2860, model.feriepengerBelop);
        System.assertEquals(0.1, model.otpSats);
        System.assertEquals(2286, model.otpBelop);
        System.assertEquals(2665, model.arbeidsgiveravgiftBelop);
        System.assertEquals(27811, model.sumLonnsutgifter);
        System.assertEquals(11124, model.sumLonnstilskudd);
        System.assertEquals(27811, model.manedslonn100pst);
        System.assertEquals('2022-07-01', model.datoForRedusertProsent);
        System.assertEquals('FAST', model.stillingstype);
        System.assertEquals(0, model.maal.size());
        System.assertEquals(0, model.inkluderingstilskuddsutgift.size());
        System.assertEquals(null, model.inkluderingstilskuddBegrunnelse);
        System.assertEquals('2022-05-23T10:31:49.922613', model.godkjentAvDeltaker);
        System.assertEquals('2022-05-23T10:31:18.693921', model.godkjentAvArbeidsgiver);
        System.assertEquals('2022-05-23T10:31:49.922613', model.godkjentAvVeileder);
        System.assertEquals(null, model.godkjentAvBeslutter);
        System.assertEquals('2022-10-26T11:54:34.265009244', model.ikrafttredelsestidspunkt);
        System.assertEquals('Z992800', model.godkjentAvNavIdent);
        System.assertEquals(null, model.godkjentAvBeslutterNavIdent);
        System.assertEquals(null, model.enhetKostnadssted);
        System.assertEquals(null, model.enhetsnavnKostnadssted);
        System.assertEquals(true, model.godkjentPaVegneGrunn.ikkeBankId);
        System.assertEquals(false, model.godkjentPaVegneGrunn.reservert);
        System.assertEquals(false, model.godkjentPaVegneGrunn.digitalKompetanse);
        System.assertEquals(true, model.godkjentPaVegneAv);
        System.assertEquals(null, model.godkjentPaVegneAvArbeidsgiverGrunn);
        System.assertEquals(false, model.godkjentPaVegneAvArbeidsgiver);
        System.assertEquals('ENDRE_STILLING', model.innholdType);
        System.assertEquals(null, model.key);
        System.assertEquals('Z992800', model.utfortAv);
    }

}
