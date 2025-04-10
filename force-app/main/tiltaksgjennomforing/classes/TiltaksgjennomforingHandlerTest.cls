@isTest
public with sharing class TiltaksgjennomforingHandlerTest {
    @TestSetup
    static void makeData() {
        Account account1 = new Account(Name = 'Test Employer 1', INT_OrganizationNumber__c = '973113631');
        insert account1;
        Account account2 = new Account(Name = 'Test Employer 2', INT_OrganizationNumber__c = '973113632');
        insert account2;

        NavUnit__c unit1 = new NavUnit__c(Name = 'NAV Unit 1', INT_UnitNumber__c = '0219');
        insert unit1;
        NavUnit__c unit2 = new NavUnit__c(Name = 'NAV Unit 2', INT_UnitNumber__c = '0239');
        insert unit2;

        List<User> users = TestDataFactory.getUsers(2, 'Standard User', false, false);
        users[0].CRM_NAV_Ident__c = 'Z992800';
        users[1].CRM_NAV_Ident__c = 'Z992801';
        insert users;

        String topic = 'arbeidsgiver.tiltak-avtale-hendelse';
        List<KafkaMessage__c> testMessages = new List<KafkaMessage__c>();

        //Record status GJENNOMFØRES and type MIDLERTIDIG_LONNSTILSKUDD
        testMessages.add(
            new KafkaMessage__c(
                CRM_Topic__c = topic,
                CRM_Key__c = 'c9d8fe1e-c4d2-499e-bd16-af3a88b1e734',
                CRM_Value__c = EncodingUtil.base64Encode(
                    Blob.valueOf(
                        '{"hendelseType":"STILLINGSBESKRIVELSE_ENDRET","avtaleStatus":"GJENNOMFØRES","deltakerFnr":"02129623805","mentorFnr":null,"bedriftNr":"973113631","veilederNavIdent":"Z992800","tiltakstype":"MIDLERTIDIG_LONNSTILSKUDD","opprettetTidspunkt":"2022-05-23T10:27:13.626211","avtaleId":"c9d8fe1e-c4d2-499e-bd16-af3a88b1e734","avtaleNr":397,"sistEndret":"2022-10-26T09:54:34.265048609Z","annullertTidspunkt":null,"annullertGrunn":null,"slettemerket":false,"opprettetAvArbeidsgiver":false,"enhetGeografisk":"0805","enhetsnavnGeografisk":"NAV Porsgrunn","enhetOppfolging":"0219","enhetsnavnOppfolging":"NAV Bærum","godkjentForEtterregistrering":true,"kvalifiseringsgruppe":"BFORM","formidlingsgruppe":"ARBS","tilskuddPeriode":[],"feilregistrert":false,"versjon":5,"deltakerFornavn":"Overfølsom","deltakerEtternavn":"Klovn","deltakerTlf":"12345676","bedriftNavn":"GAMLE FREDRIKSTAD OG RAMNES REGNSKA P","arbeidsgiverFornavn":"Dolly","arbeidsgiverEtternavn":"Duck","arbeidsgiverTlf":"12345678","veilederFornavn":"Onkel","veilederEtternavn":"Donald","veilederTlf":"12345678","oppfolging":"rtretyrteyrtey","tilrettelegging":"fdghdfghdfghfdgh","startDato":"2022-01-01","sluttDato":"2023-01-01","stillingprosent":100,"journalpostId":null,"arbeidsoppgaver":"trrtyrtrtytreyccxzc","stillingstittel":"Bussrengjører","stillingStyrk08":9122,"stillingKonseptId":168963,"antallDagerPerUke":5,"refusjonKontaktperson":null,"mentorFornavn":"Test","mentorEtternavn":"Testersen","mentorOppgaver":null,"mentorAntallTimer":null,"mentorTimelonn":null,"mentorTlf":null,"arbeidsgiverKontonummer":"91311592950","lonnstilskuddProsent":40,"manedslonn":20000,"feriepengesats":0.143,"arbeidsgiveravgift":0.106,"harFamilietilknytning":false,"familietilknytningForklaring":null,"feriepengerBelop":2860,"otpSats":0.1,"otpBelop":2286,"arbeidsgiveravgiftBelop":2665,"sumLonnsutgifter":27811,"sumLonnstilskudd":11124,"manedslonn100pst":27811,"sumLønnstilskuddRedusert":8343,"datoForRedusertProsent":"2022-07-01","stillingstype":"FAST","maal":[],"inkluderingstilskuddsutgift":[],"inkluderingstilskuddBegrunnelse":null,"inkluderingstilskuddTotalBeløp":0,"godkjentAvDeltaker":"2022-05-23T10:31:49.922613","godkjentTaushetserklæringAvMentor":null,"godkjentAvArbeidsgiver":"2022-05-23T10:31:18.693921","godkjentAvVeileder":"2022-05-23T10:31:49.922613","godkjentAvBeslutter":null,"avtaleInngått":"2022-05-23T10:31:49.922613","ikrafttredelsestidspunkt":"2022-10-26T11:54:34.265009244","godkjentAvNavIdent":"Z992800","godkjentAvBeslutterNavIdent":null,"enhetKostnadssted":null,"enhetsnavnKostnadssted":null,"godkjentPaVegneGrunn":{"ikkeBankId":true,"reservert":false,"digitalKompetanse":false,"arenaMigreringDeltaker":true},"godkjentPaVegneAv":true,"godkjentPaVegneAvArbeidsgiverGrunn":{"klarerIkkeGiFaTilgang":false,"vetIkkeHvemSomKanGiTilgang":false,"farIkkeTilgangPersonvern":false,"arenaMigreringArbeidsgiver":true},"godkjentPaVegneAvArbeidsgiver":false,"innholdType":"ENDRE_STILLING","utførtAv":"Z992800"}'
                    )
                )
            )
        );

         //Record status GJENNOMFØRES and type MIDLERTIDIG_LONNSTILSKUDD and multiple null values
         testMessages.add(
            new KafkaMessage__c(
                CRM_Topic__c = topic,
                CRM_Key__c = 'c9d8fe1e-c4d2-499e-bd16-af3a88b1e735',
                CRM_Value__c = EncodingUtil.base64Encode(
                    Blob.valueOf(
                        '{"hendelseType":"STILLINGSBESKRIVELSE_ENDRET","avtaleStatus":"GJENNOMFØRES","deltakerFnr":"02129623805","mentorFnr":null,"bedriftNr":null,"veilederNavIdent":null,"tiltakstype":"MIDLERTIDIG_LONNSTILSKUDD","opprettetTidspunkt":"2022-05-23T10:27:13.626211","avtaleId":"c9d8fe1e-c4d2-499e-bd16-af3a88b1e735","avtaleNr":null,"sistEndret":"2022-10-26T09:54:34.265048609Z","annullertTidspunkt":null,"annullertGrunn":null,"slettemerket":false,"opprettetAvArbeidsgiver":false,"enhetGeografisk":"0805","enhetsnavnGeografisk":"NAV Porsgrunn","enhetOppfolging":null,"enhetsnavnOppfolging":null,"godkjentForEtterregistrering":true,"kvalifiseringsgruppe":"BFORM","formidlingsgruppe":"ARBS","tilskuddPeriode":[],"feilregistrert":false,"versjon":5,"deltakerFornavn":"Overfølsom","deltakerEtternavn":"Klovn","deltakerTlf":"12345676","bedriftNavn":"GAMLE FREDRIKSTAD OG RAMNES REGNSKA P","arbeidsgiverFornavn":null,"arbeidsgiverEtternavn":null,"arbeidsgiverTlf":null,"veilederFornavn":"Onkel","veilederEtternavn":"Donald","veilederTlf":"12345678","oppfolging":"rtretyrteyrtey","tilrettelegging":"fdghdfghdfghfdgh","startDato":null,"sluttDato":null,"stillingprosent":100,"journalpostId":null,"arbeidsoppgaver":"trrtyrtrtytreyccxzc","stillingstittel":"Bussrengjører","stillingStyrk08":9122,"stillingKonseptId":168963,"antallDagerPerUke":5,"refusjonKontaktperson":null,"mentorFornavn":null,"mentorEtternavn":null,"mentorOppgaver":null,"mentorAntallTimer":null,"mentorTimelonn":null,"mentorTlf":null,"arbeidsgiverKontonummer":"91311592950","lonnstilskuddProsent":40,"manedslonn":20000,"feriepengesats":0.143,"arbeidsgiveravgift":0.106,"harFamilietilknytning":false,"familietilknytningForklaring":null,"feriepengerBelop":2860,"otpSats":0.1,"otpBelop":2286,"arbeidsgiveravgiftBelop":2665,"sumLonnsutgifter":27811,"sumLonnstilskudd":11124,"manedslonn100pst":27811,"sumLønnstilskuddRedusert":8343,"datoForRedusertProsent":"2022-07-01","stillingstype":"FAST","maal":[],"inkluderingstilskuddsutgift":[],"inkluderingstilskuddBegrunnelse":null,"inkluderingstilskuddTotalBeløp":0,"godkjentAvDeltaker":"2022-05-23T10:31:49.922613","godkjentTaushetserklæringAvMentor":null,"godkjentAvArbeidsgiver":"2022-05-23T10:31:18.693921","godkjentAvVeileder":"2022-05-23T10:31:49.922613","godkjentAvBeslutter":null,"avtaleInngått":"2022-05-23T10:31:49.922613","ikrafttredelsestidspunkt":"2022-10-26T11:54:34.265009244","godkjentAvNavIdent":"Z992800","godkjentAvBeslutterNavIdent":null,"enhetKostnadssted":null,"enhetsnavnKostnadssted":null,"godkjentPaVegneGrunn":{"ikkeBankId":true,"reservert":false,"digitalKompetanse":false,"arenaMigreringDeltaker":true},"godkjentPaVegneAv":true,"godkjentPaVegneAvArbeidsgiverGrunn":{"klarerIkkeGiFaTilgang":false,"vetIkkeHvemSomKanGiTilgang":false,"farIkkeTilgangPersonvern":false,"arenaMigreringArbeidsgiver":true},"godkjentPaVegneAvArbeidsgiver":false,"innholdType":"ENDRE_STILLING","utførtAv":"Z992800"}'
                    )
                )
            )
        );

        //Json string with invalid values, like feilregistrert does not have boolean value
        testMessages.add(
            new KafkaMessage__c(
                CRM_Topic__c = topic,
                CRM_Key__c = 'c9d8fe1e-c4d2-499e-bd16-af3a88b1e736',
                CRM_Value__c = EncodingUtil.base64Encode(
                    Blob.valueOf(
                        '{"hendelseType":"STILLINGSBESKRIVELSE_ENDRET","deltakerFnr":"02129623805","mentorFnr":null,"veilederNavIdent":"Z992800576577","tiltakstype":"MIDLERTIDIG_LONNSTILSKUDD","opprettetTidspunkt":"2022-05-23T10:27:13.626211","avtaleId":"c9d8fe1e-c4d2-499e-bd16-af3a88b1e736","avtaleNr":399,"sistEndret":"2022-10-26T09:54:34.265048609Z","annullertTidspunkt":null,"annullertGrunn":null,"slettemerket":false,"opprettetAvArbeidsgiver":false,"enhetGeografisk":"0805","enhetsnavnGeografisk":"NAV Porsgrunn","enhetOppfolging":"0219","enhetsnavnOppfolging":"NAV Bærum","godkjentForEtterregistrering":true,"kvalifiseringsgruppe":"BFORM","formidlingsgruppe":"ARBS","tilskuddPeriode":[],"feilregistrert":"falses","versjon":5,"deltakerFornavn":"Overfølsom","deltakerEtternavn":"Klovn","deltakerTlf":"12345676","bedriftNavn":"GAMLE FREDRIKSTAD OG RAMNES REGNSKA P","arbeidsgiverFornavn":"Dolly","arbeidsgiverEtternavn":"Duck","arbeidsgiverTlf":"12345678","veilederFornavn":"Onkel","veilederEtternavn":"Donald","veilederTlf":"12345678","oppfolging":"rtretyrteyrtey","tilrettelegging":"fdghdfghdfghfdgh","startDato":"2022-01-01","sluttDato":"2023-01-01","stillingprosent":100,"journalpostId":null,"arbeidsoppgaver":"trrtyrtrtytreyccxzc","stillingstittel":"Bussrengjører","stillingStyrk08":9122,"stillingKonseptId":168963,"antallDagerPerUke":5,"refusjonKontaktperson":null,"mentorFornavn":"Test","mentorEtternavn":"Testersen","mentorOppgaver":null,"mentorAntallTimer":null,"mentorTimelonn":null,"mentorTlf":null,"arbeidsgiverKontonummer":"91311592950","lonnstilskuddProsent":40,"manedslonn":20000,"feriepengesats":0.143,"arbeidsgiveravgift":0.106,"harFamilietilknytning":false,"familietilknytningForklaring":null,"feriepengerBelop":2860,"otpSats":0.1,"otpBelop":2286,"arbeidsgiveravgiftBelop":2665,"sumLonnsutgifter":27811,"sumLonnstilskudd":11124,"manedslonn100pst":27811,"sumLønnstilskuddRedusert":8343,"datoForRedusertProsent":"2022-07-01","stillingstype":"FAST","maal":[],"inkluderingstilskuddsutgift":[],"inkluderingstilskuddBegrunnelse":null,"inkluderingstilskuddTotalBeløp":0,"godkjentAvDeltaker":"2022-05-23T10:31:49.922613","godkjentTaushetserklæringAvMentor":null,"godkjentAvArbeidsgiver":"2022-05-23T10:31:18.693921","godkjentAvVeileder":"2022-05-23T10:31:49.922613","godkjentAvBeslutter":null,"avtaleInngått":"2022-05-23T10:31:49.922613","ikrafttredelsestidspunkt":"2022-10-26T11:54:34.265009244","godkjentAvNavIdent":"Z992800","godkjentAvBeslutterNavIdent":null,"enhetKostnadssted":null,"enhetsnavnKostnadssted":null,"godkjentPaVegneGrunn":{"ikkeBankId":true,"reservert":false,"digitalKompetanse":false,"arenaMigreringDeltaker":true},"godkjentPaVegneAv":true,"godkjentPaVegneAvArbeidsgiverGrunn":{"klarerIkkeGiFaTilgang":false,"vetIkkeHvemSomKanGiTilgang":false,"farIkkeTilgangPersonvern":false,"arenaMigreringArbeidsgiver":true},"godkjentPaVegneAvArbeidsgiver":false,"innholdType":"ENDRE_STILLING","utførtAv":"Z992800"}'
                    )
                )
            )
        );

        // Mass generate records for bulk testing
        for (Integer i = 0; i < 20; i++) {
            String key = 'TEST-c4d2' + i;
            testMessages.add(
                new KafkaMessage__c(
                    CRM_Topic__c = topic,
                    CRM_Key__c = key,
                    CRM_Value__c = EncodingUtil.base64Encode(
                        Blob.valueOf(
                            '{"avtaleId":"' +
                            key +
                            '","hendelseType":"STILLINGSBESKRIVELSE_ENDRET","avtaleStatus":"GJENNOMFØRES","deltakerFnr":"02129623805","mentorFnr":null,"bedriftNr":"973113631","veilederNavIdent":"Z992800","tiltakstype":"MENTOR","opprettetTidspunkt":"2022-05-23T10:27:13.626211","avtaleNr":397,"sistEndret":"2022-10-26T09:54:36.265048609Z","annullertTidspunkt":null,"annullertGrunn":null,"slettemerket":false,"opprettetAvArbeidsgiver":false,"enhetGeografisk":"0805","enhetsnavnGeografisk":"NAV Porsgrunn","enhetOppfolging":"0219","enhetsnavnOppfolging":"NAV Bærum","godkjentForEtterregistrering":true,"kvalifiseringsgruppe":"BFORM","formidlingsgruppe":"ARBS","tilskuddPeriode":[],"feilregistrert":false,"versjon":5,"deltakerFornavn":"Overfølsom","deltakerEtternavn":"Klovn","deltakerTlf":"12345676","bedriftNavn":"GAMLE FREDRIKSTAD OG RAMNES REGNSKA P","arbeidsgiverFornavn":"Dolly","arbeidsgiverEtternavn":"Duck","arbeidsgiverTlf":"12345678","veilederFornavn":"Onkel","veilederEtternavn":"Donald","veilederTlf":"12345678","oppfolging":"rtretyrteyrtey","tilrettelegging":"fdghdfghdfghfdgh","startDato":"2022-01-01","sluttDato":"2023-01-01","stillingprosent":100,"journalpostId":null,"arbeidsoppgaver":"trrtyrtrtytreyccxzc","stillingstittel":"Bussrengjører","stillingStyrk08":9122,"stillingKonseptId":168963,"antallDagerPerUke":5,"refusjonKontaktperson":null,"mentorFornavn":null,"mentorEtternavn":null,"mentorOppgaver":null,"mentorAntallTimer":null,"mentorTimelonn":null,"mentorTlf":null,"arbeidsgiverKontonummer":"91311592950","lonnstilskuddProsent":40,"manedslonn":20000,"feriepengesats":0.143,"arbeidsgiveravgift":0.106,"harFamilietilknytning":false,"familietilknytningForklaring":null,"feriepengerBelop":2860,"otpSats":0.1,"otpBelop":2286,"arbeidsgiveravgiftBelop":2665,"sumLonnsutgifter":27811,"sumLonnstilskudd":11124,"manedslonn100pst":27811,"sumLønnstilskuddRedusert":8343,"datoForRedusertProsent":"2022-07-01","stillingstype":"FAST","maal":[],"inkluderingstilskuddsutgift":[],"inkluderingstilskuddBegrunnelse":null,"inkluderingstilskuddTotalBeløp":0,"godkjentAvDeltaker":"2022-05-23T10:31:49.922613","godkjentTaushetserklæringAvMentor":null,"godkjentAvArbeidsgiver":"2022-05-23T10:31:18.693921","godkjentAvVeileder":"2022-05-23T10:31:49.922613","godkjentAvBeslutter":null,"avtaleInngått":"2022-05-23T10:31:49.922613","ikrafttredelsestidspunkt":"2022-10-26T11:54:34.265009244","godkjentAvNavIdent":"Z992800","godkjentAvBeslutterNavIdent":null,"enhetKostnadssted":null,"enhetsnavnKostnadssted":null,"godkjentPaVegneGrunn":{"ikkeBankId":true,"reservert":false,"digitalKompetanse":false,"arenaMigreringDeltaker":true},"godkjentPaVegneAv":true,"godkjentPaVegneAvArbeidsgiverGrunn":{"klarerIkkeGiFaTilgang":false,"vetIkkeHvemSomKanGiTilgang":false,"farIkkeTilgangPersonvern":false,"arenaMigreringArbeidsgiver":true},"godkjentPaVegneAvArbeidsgiver":false,"innholdType":"ENDRE_STILLING","utførtAv":"Z992800"}'
                        )
                    )
                )
            );
        }

        insert testMessages;
    }

    @isTest
    static void testProcessSingleMessagePositive() {
        List<KafkaMessage__c> message = [
            SELECT CRM_Topic__c, CRM_Value__c, CRM_Key__c
            FROM KafkaMessage__c
            WHERE CRM_Key__c = 'c9d8fe1e-c4d2-499e-bd16-af3a88b1e734'
        ];

        System.assert(message.size() == 1);

        Test.startTest();
        TiltaksgjennomforingHandler handler = new TiltaksgjennomforingHandler();
        handler.processMessages(message);
        Test.stopTest();

        List<Workfare__c> agreements = [
            SELECT
                Id,
                Account__c,
                ActionType__c,
                AgreementId__c,
                ContentType__c,
                EmployerContactName__c,
                EmployerContactPhone__c,
                EndDate__c,
                InternalContact__c,
                KafkaHash__c,
                KafkaId__c,
                Link__c,
                MentorName__c,
                Name,
                NavUnit__c,
                OwnerId,
                StartDate__c,
                Status__c,
                Type__c
            FROM Workfare__c
        ];

        List<NavUnit__c> units = [SELECT Id, INT_UnitNumber__c FROM NavUnit__c WHERE INT_UnitNumber__c = '0219'];
        List<Account> accounts = [SELECT Id FROM Account WHERE INT_OrganizationNumber__c = '973113631'];
        List<User> users = [SELECT Id FROM User WHERE CRM_NAV_Ident__c = 'Z992800'];

        System.assertEquals(1, agreements.size());
        System.assertEquals(accounts[0].id, agreements[0].Account__c);
        System.assertEquals('STILLINGSBESKRIVELSE_ENDRET', agreements[0].ActionType__c);
        System.assertEquals('c9d8fe1e-c4d2-499e-bd16-af3a88b1e734', agreements[0].AgreementId__c);
        System.assertEquals('ENDRE_STILLING', agreements[0].ContentType__c);
        System.assertEquals('Dolly Duck', agreements[0].EmployerContactName__c);
        System.assertEquals('12345678', agreements[0].EmployerContactPhone__c);
        System.assertEquals('2023-01-01', String.valueOf(agreements[0].EndDate__c));
        System.assertEquals(users[0].id, agreements[0].InternalContact__c);
        System.assertEquals(message[0].CRM_Value__c, agreements[0].KafkaHash__c);
        System.assertEquals(message[0].CRM_Key__c, agreements[0].KafkaId__c);
        System.assertEquals('https://arbeidsgiver.nav.no/tiltaksgjennomforing/avtale/c9d8fe1e-c4d2-499e-bd16-af3a88b1e734?bedrift=973113631', agreements[0].Link__c);
        System.assertEquals('Test Testersen', agreements[0].MentorName__c);
        System.assertEquals('397', agreements[0].Name);
        System.assertEquals(units[0].id, agreements[0].NavUnit__c);
        System.assertEquals('2022-01-01', String.valueOf(agreements[0].StartDate__c));
        System.assertEquals('GJENNOMFØRES', agreements[0].Status__c);
        System.assertEquals('MIDLERTIDIG_LONNSTILSKUDD', agreements[0].Type__c);
    }

    @isTest
    static void testUpdateSingleMessagePositive() {
        String topic = 'arbeidsgiver.tiltak-avtale-hendelse';
        List<KafkaMessage__c> testMessages = new List<KafkaMessage__c>();
        //Record status AVSLUTTET and type MENTOR
        testMessages.add(
            new KafkaMessage__c(
                CRM_Topic__c = topic,
                CRM_Key__c = 'c9d8fe1e-c4d2-499e-bd16-af3a88b1e734',
                CRM_Value__c = EncodingUtil.base64Encode(
                    Blob.valueOf(
                        '{"hendelseType":"STILLINGSBESKRIVELSE_ENDRET","avtaleStatus":"AVSLUTTET","deltakerFnr":"02129623805","mentorFnr":null,"bedriftNr":"973113632","veilederNavIdent":"Z992801","tiltakstype":"MENTOR","opprettetTidspunkt":"2022-05-23T10:27:13.626211","avtaleId":"c9d8fe1e-c4d2-499e-bd16-af3a88b1e734","avtaleNr":397,"sistEndret":"2022-10-26T09:54:36.265048609Z","annullertTidspunkt":null,"annullertGrunn":null,"slettemerket":false,"opprettetAvArbeidsgiver":false,"enhetGeografisk":"0805","enhetsnavnGeografisk":"NAV Porsgrunn","enhetOppfolging":"0239","enhetsnavnOppfolging":"NAV Bærum","godkjentForEtterregistrering":true,"kvalifiseringsgruppe":"BFORM","formidlingsgruppe":"ARBS","tilskuddPeriode":[],"feilregistrert":false,"versjon":5,"deltakerFornavn":"Overfølsom","deltakerEtternavn":"Klovn","deltakerTlf":"12345676","bedriftNavn":"GAMLE FREDRIKSTAD OG RAMNES REGNSKA P","arbeidsgiverFornavn":"Dolly","arbeidsgiverEtternavn":"Duck","arbeidsgiverTlf":"12345678","veilederFornavn":"Onkel","veilederEtternavn":"Donald","veilederTlf":"12345678","oppfolging":"rtretyrteyrtey","tilrettelegging":"fdghdfghdfghfdgh","startDato":"2022-01-01","sluttDato":"2023-01-01","stillingprosent":100,"journalpostId":null,"arbeidsoppgaver":"trrtyrtrtytreyccxzc","stillingstittel":"Bussrengjører","stillingStyrk08":9122,"stillingKonseptId":168963,"antallDagerPerUke":5,"refusjonKontaktperson":null,"mentorFornavn":null,"mentorEtternavn":null,"mentorOppgaver":null,"mentorAntallTimer":null,"mentorTimelonn":null,"mentorTlf":null,"arbeidsgiverKontonummer":"91311592950","lonnstilskuddProsent":40,"manedslonn":20000,"feriepengesats":0.143,"arbeidsgiveravgift":0.106,"harFamilietilknytning":false,"familietilknytningForklaring":null,"feriepengerBelop":2860,"otpSats":0.1,"otpBelop":2286,"arbeidsgiveravgiftBelop":2665,"sumLonnsutgifter":27811,"sumLonnstilskudd":11124,"manedslonn100pst":27811,"sumLønnstilskuddRedusert":8343,"datoForRedusertProsent":"2022-07-01","stillingstype":"FAST","maal":[],"inkluderingstilskuddsutgift":[],"inkluderingstilskuddBegrunnelse":null,"inkluderingstilskuddTotalBeløp":0,"godkjentAvDeltaker":"2022-05-23T10:31:49.922613","godkjentTaushetserklæringAvMentor":null,"godkjentAvArbeidsgiver":"2022-05-23T10:31:18.693921","godkjentAvVeileder":"2022-05-23T10:31:49.922613","godkjentAvBeslutter":null,"avtaleInngått":"2022-05-23T10:31:49.922613","ikrafttredelsestidspunkt":"2022-10-26T11:54:34.265009244","godkjentAvNavIdent":"Z992800","godkjentAvBeslutterNavIdent":null,"enhetKostnadssted":null,"enhetsnavnKostnadssted":null,"godkjentPaVegneGrunn":{"ikkeBankId":true,"reservert":false,"digitalKompetanse":false,"arenaMigreringDeltaker":true},"godkjentPaVegneAv":true,"godkjentPaVegneAvArbeidsgiverGrunn":{"klarerIkkeGiFaTilgang":false,"vetIkkeHvemSomKanGiTilgang":false,"farIkkeTilgangPersonvern":false,"arenaMigreringArbeidsgiver":true},"godkjentPaVegneAvArbeidsgiver":false,"innholdType":"ENDRE_STILLING","utførtAv":"Z992800"}'
                    )
                )
            )
        );
        insert testMessages;

        List<KafkaMessage__c> message = [
            SELECT CRM_Topic__c, CRM_Value__c, CRM_Key__c
            FROM KafkaMessage__c
            WHERE CRM_Key__c = 'c9d8fe1e-c4d2-499e-bd16-af3a88b1e734'
        ];

        System.assert(message.size() == 2);

        Test.startTest();
        TiltaksgjennomforingHandler handler = new TiltaksgjennomforingHandler();
        handler.processMessages(message);
        Test.stopTest();

        List<Workfare__c> agreements = [
            SELECT
                Id,
                Account__c,
                ActionType__c,
                AgreementId__c,
                ContentType__c,
                EmployerContactName__c,
                EmployerContactPhone__c,
                EndDate__c,
                InternalContact__c,
                KafkaHash__c,
                KafkaId__c,
                Link__c,
                MentorName__c,
                Name,
                NavUnit__c,
                OwnerId,
                StartDate__c,
                Status__c,
                Type__c
            FROM Workfare__c
        ];

        List<NavUnit__c> units = [SELECT Id, INT_UnitNumber__c FROM NavUnit__c WHERE INT_UnitNumber__c = '0239'];
        List<Account> accounts = [SELECT Id FROM Account WHERE INT_OrganizationNumber__c = '973113632'];
        List<User> users = [SELECT Id FROM User WHERE CRM_NAV_Ident__c = 'Z992801'];

        System.assertEquals(1, agreements.size());
        System.assertEquals(accounts[0].id, agreements[0].Account__c);
        System.assertEquals('STILLINGSBESKRIVELSE_ENDRET', agreements[0].ActionType__c);
        System.assertEquals('c9d8fe1e-c4d2-499e-bd16-af3a88b1e734', agreements[0].AgreementId__c);
        System.assertEquals('ENDRE_STILLING', agreements[0].ContentType__c);
        System.assertEquals('Dolly Duck', agreements[0].EmployerContactName__c);
        System.assertEquals('12345678', agreements[0].EmployerContactPhone__c);
        System.assertEquals('2023-01-01', String.valueOf(agreements[0].EndDate__c));
        System.assertEquals(users[0].id, agreements[0].InternalContact__c);
        //System.assertEquals(message[0].CRM_Value__c, agreements[0].KafkaHash__c);
        System.assertEquals(message[0].CRM_Key__c, agreements[0].KafkaId__c);
        System.assertEquals('https://arbeidsgiver.nav.no/tiltaksgjennomforing/avtale/c9d8fe1e-c4d2-499e-bd16-af3a88b1e734?bedrift=973113632', agreements[0].Link__c);
        System.assertEquals(null, agreements[0].MentorName__c);
        System.assertEquals('397', agreements[0].Name);
        System.assertEquals(units[0].id, agreements[0].NavUnit__c);
        System.assertEquals('2022-01-01', String.valueOf(agreements[0].StartDate__c));
        System.assertEquals('AVSLUTTET', agreements[0].Status__c);
        System.assertEquals('MENTOR', agreements[0].Type__c);
    }

    @isTest
    static void testProcessMultipleMessagesPositive() {
        List<KafkaMessage__c> message = [
            SELECT CRM_Topic__c, CRM_Value__c, CRM_Key__c
            FROM KafkaMessage__c
            WHERE CRM_Key__c LIKE 'TEST%'
        ];

        System.assert(message.size() == 20);

        Test.startTest();
        TiltaksgjennomforingHandler handler = new TiltaksgjennomforingHandler();
        handler.processMessages(message);
        Test.stopTest();

        List<Workfare__c> agreements = [SELECT Id FROM Workfare__c];

        System.assertEquals(20, agreements.size());
    }

    @isTest
    static void testProcessSingleMessageNullValuesPositive() {
        List<KafkaMessage__c> message = [
            SELECT CRM_Topic__c, CRM_Value__c, CRM_Key__c
            FROM KafkaMessage__c
            WHERE CRM_Key__c = 'c9d8fe1e-c4d2-499e-bd16-af3a88b1e735'
        ];

        System.assert(message.size() == 1);

        Test.startTest();
        TiltaksgjennomforingHandler handler = new TiltaksgjennomforingHandler();
        handler.processMessages(message);
        Test.stopTest();

        List<Workfare__c> agreements = [
            SELECT
                Id,
                Account__c,
                ActionType__c,
                AgreementId__c,
                ContentType__c,
                EmployerContactName__c,
                EmployerContactPhone__c,
                EndDate__c,
                InternalContact__c,
                KafkaHash__c,
                KafkaId__c,
                Link__c,
                MentorName__c,
                Name,
                NavUnit__c,
                OwnerId,
                StartDate__c,
                Status__c,
                Type__c
            FROM Workfare__c
        ];

        System.assertEquals(1, agreements.size());
        System.assertEquals(null, agreements[0].Account__c);
        System.assertEquals('STILLINGSBESKRIVELSE_ENDRET', agreements[0].ActionType__c);
        System.assertEquals('c9d8fe1e-c4d2-499e-bd16-af3a88b1e735', agreements[0].AgreementId__c);
        System.assertEquals('ENDRE_STILLING', agreements[0].ContentType__c);
        System.assertEquals(null, agreements[0].EmployerContactName__c);
        System.assertEquals(null, agreements[0].EmployerContactPhone__c);
        System.assertEquals(null, String.valueOf(agreements[0].EndDate__c));
        System.assertEquals(null, agreements[0].InternalContact__c);
        System.assertEquals(message[0].CRM_Value__c, agreements[0].KafkaHash__c);
        System.assertEquals(message[0].CRM_Key__c, agreements[0].KafkaId__c);
        System.assertEquals('https://arbeidsgiver.nav.no/tiltaksgjennomforing/avtale/c9d8fe1e-c4d2-499e-bd16-af3a88b1e735', agreements[0].Link__c);
        System.assertEquals(null, agreements[0].MentorName__c);
        System.assertEquals('Avtalenummer ikke opprettet enda', agreements[0].Name);
        System.assertEquals(null, agreements[0].NavUnit__c);
        System.assertEquals(null, String.valueOf(agreements[0].StartDate__c));
        System.assertEquals('GJENNOMFØRES', agreements[0].Status__c);
        System.assertEquals('MIDLERTIDIG_LONNSTILSKUDD', agreements[0].Type__c);
    }

    @isTest
    static void testProcessSingleMessageWithCorruptedJsonStringNegative() {
        List<KafkaMessage__c> message = [
            SELECT CRM_Topic__c, CRM_Value__c, CRM_Key__c, CRM_Status__c
            FROM KafkaMessage__c
            WHERE CRM_Key__c = 'c9d8fe1e-c4d2-499e-bd16-af3a88b1e736'
        ];

        System.assert(message.size() == 1);

        Test.startTest();
        TiltaksgjennomforingHandler handler = new TiltaksgjennomforingHandler();
        handler.processMessages(message);
        Test.stopTest();

        List<Workfare__c> agreements = [
            SELECT
                Id
            FROM Workfare__c
        ];

        System.assertEquals('Error', message[0].CRM_Status__c, 'Expecting CRM_Status__c = Error as json-string has errors');
        System.assertEquals(0, agreements.size(), 'Expecting agreements-list to be empty');
    }
}