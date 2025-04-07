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

        String jsonMidlertidigLonnstilskudd = '{"hendelseType":"STILLINGSBESKRIVELSE_ENDRET","avtaleStatus":"GJENNOMFØRES","deltakerFnr":"02129623805","mentorFnr":null,"bedriftNr":"910825526","veilederNavIdent":"Z992800","tiltakstype":"MIDLERTIDIG_LONNSTILSKUDD","opprettetTidspunkt":"2022-05-23T10:27:13.626211","avtaleId":"c9d8fe1e-c4d2-499e-bd16-af3a88b1e734","avtaleNr":397,"sistEndret":"2022-10-26T09:54:34.265048609Z","annullertTidspunkt":null,"annullertGrunn":null,"slettemerket":false,"opprettetAvArbeidsgiver":false,"enhetGeografisk":"0805","enhetsnavnGeografisk":"NAV Porsgrunn","enhetOppfolging":"0219","enhetsnavnOppfolging":"NAV Bærum","godkjentForEtterregistrering":true,"kvalifiseringsgruppe":"BFORM","formidlingsgruppe":"ARBS","tilskuddPeriode":[],"feilregistrert":false,"versjon":5,"deltakerFornavn":"Overfølsom","deltakerEtternavn":"Klovn","deltakerTlf":"12345676","bedriftNavn":"GAMLE FREDRIKSTAD OG RAMNES REGNSKA P","arbeidsgiverFornavn":"Dolly","arbeidsgiverEtternavn":"Duck","arbeidsgiverTlf":"12345678","veilederFornavn":"Onkel","veilederEtternavn":"Donald","veilederTlf":"12345678","oppfolging":"rtretyrteyrtey","tilrettelegging":"fdghdfghdfghfdgh","startDato":"2022-01-01","sluttDato":"2023-01-01","stillingprosent":100,"journalpostId":null,"arbeidsoppgaver":"trrtyrtrtytreyccxzc","stillingstittel":"Bussrengjører","stillingStyrk08":9122,"stillingKonseptId":168963,"antallDagerPerUke":5,"refusjonKontaktperson":null,"mentorFornavn":null,"mentorEtternavn":null,"mentorOppgaver":null,"mentorAntallTimer":null,"mentorTimelonn":null,"mentorTlf":null,"arbeidsgiverKontonummer":"91311592950","lonnstilskuddProsent":40,"manedslonn":20000,"feriepengesats":0.143,"arbeidsgiveravgift":0.106,"harFamilietilknytning":false,"familietilknytningForklaring":null,"feriepengerBelop":2860,"otpSats":0.1,"otpBelop":2286,"arbeidsgiveravgiftBelop":2665,"sumLonnsutgifter":27811,"sumLonnstilskudd":11124,"manedslonn100pst":27811,"sumLønnstilskuddRedusert":8343,"datoForRedusertProsent":"2022-07-01","stillingstype":"FAST","maal":[],"inkluderingstilskuddsutgift":[],"inkluderingstilskuddBegrunnelse":null,"inkluderingstilskuddTotalBeløp":0,"godkjentAvDeltaker":"2022-05-23T10:31:49.922613","godkjentTaushetserklæringAvMentor":null,"godkjentAvArbeidsgiver":"2022-05-23T10:31:18.693921","godkjentAvVeileder":"2022-05-23T10:31:49.922613","godkjentAvBeslutter":null,"avtaleInngått":"2022-05-23T10:31:49.922613","ikrafttredelsestidspunkt":"2022-10-26T11:54:34.265009244","godkjentAvNavIdent":"Z992800","godkjentAvBeslutterNavIdent":null,"enhetKostnadssted":null,"enhetsnavnKostnadssted":null,"godkjentPaVegneGrunn":{"ikkeBankId":true,"reservert":false,"digitalKompetanse":false,"arenaMigreringDeltaker":true},"godkjentPaVegneAv":true,"godkjentPaVegneAvArbeidsgiverGrunn":{"klarerIkkeGiFaTilgang":false,"vetIkkeHvemSomKanGiTilgang":false,"farIkkeTilgangPersonvern":false,"arenaMigreringArbeidsgiver":true},"godkjentPaVegneAvArbeidsgiver":false,"innholdType":"ENDRE_STILLING","utførtAv":"Z992800"}';
        String jsonMidlertidigLonnstilskuddNewStatus = '{"hendelseType":"STILLINGSBESKRIVELSE_ENDRET","avtaleStatus":"AVSLUTTET","deltakerFnr":"02129623805","mentorFnr":null,"bedriftNr":"910825526","veilederNavIdent":"Z992800","tiltakstype":"MIDLERTIDIG_LONNSTILSKUDD","opprettetTidspunkt":"2022-05-23T10:27:13.626211","avtaleId":"c9d8fe1e-c4d2-499e-bd16-af3a88b1e734","avtaleNr":397,"sistEndret":"2022-10-26T09:56:34.265048609Z","annullertTidspunkt":null,"annullertGrunn":null,"slettemerket":false,"opprettetAvArbeidsgiver":false,"enhetGeografisk":"0805","enhetsnavnGeografisk":"NAV Porsgrunn","enhetOppfolging":"0219","enhetsnavnOppfolging":"NAV Bærum","godkjentForEtterregistrering":true,"kvalifiseringsgruppe":"BFORM","formidlingsgruppe":"ARBS","tilskuddPeriode":[],"feilregistrert":false,"versjon":5,"deltakerFornavn":"Overfølsom","deltakerEtternavn":"Klovn","deltakerTlf":"12345676","bedriftNavn":"GAMLE FREDRIKSTAD OG RAMNES REGNSKA P","arbeidsgiverFornavn":"Dolly","arbeidsgiverEtternavn":"Duck","arbeidsgiverTlf":"12345678","veilederFornavn":"Onkel","veilederEtternavn":"Donald","veilederTlf":"12345678","oppfolging":"rtretyrteyrtey","tilrettelegging":"fdghdfghdfghfdgh","startDato":"2022-01-01","sluttDato":"2023-01-01","stillingprosent":100,"journalpostId":null,"arbeidsoppgaver":"trrtyrtrtytreyccxzc","stillingstittel":"Bussrengjører","stillingStyrk08":9122,"stillingKonseptId":168963,"antallDagerPerUke":5,"refusjonKontaktperson":null,"mentorFornavn":null,"mentorEtternavn":null,"mentorOppgaver":null,"mentorAntallTimer":null,"mentorTimelonn":null,"mentorTlf":null,"arbeidsgiverKontonummer":"91311592950","lonnstilskuddProsent":40,"manedslonn":20000,"feriepengesats":0.143,"arbeidsgiveravgift":0.106,"harFamilietilknytning":false,"familietilknytningForklaring":null,"feriepengerBelop":2860,"otpSats":0.1,"otpBelop":2286,"arbeidsgiveravgiftBelop":2665,"sumLonnsutgifter":27811,"sumLonnstilskudd":11124,"manedslonn100pst":27811,"sumLønnstilskuddRedusert":8343,"datoForRedusertProsent":"2022-07-01","stillingstype":"FAST","maal":[],"inkluderingstilskuddsutgift":[],"inkluderingstilskuddBegrunnelse":null,"inkluderingstilskuddTotalBeløp":0,"godkjentAvDeltaker":"2022-05-23T10:31:49.922613","godkjentTaushetserklæringAvMentor":null,"godkjentAvArbeidsgiver":"2022-05-23T10:31:18.693921","godkjentAvVeileder":"2022-05-23T10:31:49.922613","godkjentAvBeslutter":null,"avtaleInngått":"2022-05-23T10:31:49.922613","ikrafttredelsestidspunkt":"2022-10-26T11:54:34.265009244","godkjentAvNavIdent":"Z992800","godkjentAvBeslutterNavIdent":null,"enhetKostnadssted":null,"enhetsnavnKostnadssted":null,"godkjentPaVegneGrunn":{"ikkeBankId":true,"reservert":false,"digitalKompetanse":false,"arenaMigreringDeltaker":true},"godkjentPaVegneAv":true,"godkjentPaVegneAvArbeidsgiverGrunn":{"klarerIkkeGiFaTilgang":false,"vetIkkeHvemSomKanGiTilgang":false,"farIkkeTilgangPersonvern":false,"arenaMigreringArbeidsgiver":true},"godkjentPaVegneAvArbeidsgiver":false,"innholdType":"ENDRE_STILLING","utførtAv":"Z992800"}';
        String jsonStatusViBistar2 = '{"saksnummer": "a240d1adtuasydt2", "orgnr": "973113632", "eierAvSak": "C156987", "endretAvHendelseId": "sdfhoisdyfio49856", "status": "VI_BISTÅR", "opprettetTidspunkt": "2022-02-18T07:07:07.064711", "endretTidspunkt": "2022-02-18T07:19:21.575794"}';
        String jsonStatusSlettet2 = '{"saksnummer": "a240d1adtuasydt2", "orgnr": "973113632", "eierAvSak": "C156987", "endretAvHendelseId": "sdfhoisdyfio49856", "status": "SLETTET", "opprettetTidspunkt": "2022-02-18T07:07:07.064711", "endretTidspunkt": "2022-02-19T07:19:21.575794"}';
        String jsonStatusViBistar3 = '{"saksnummer": "a240d1adtuasydt3", "orgnr": "973113632", "eierAvSak": "C156987", "endretAvHendelseId": "sdfhoisdyfio49856", "status": "VI_BISTÅR", "opprettetTidspunkt": "2022-02-18T07:07:07.064711", "endretTidspunkt": "2022-02-20T07:19:21.575794"}';
        String jsonStatusSlettet3 = '{"saksnummer": "a240d1adtuasydt3", "orgnr": "973113632", "eierAvSak": "C156987", "endretAvHendelseId": "sdfhoisdyfio49856", "status": "SLETTET", "opprettetTidspunkt": "2022-02-18T07:07:07.064711", "endretTidspunkt": "2022-02-21T07:19:21.575794"}';

        String encodedMidlertidigLonnstilskudd = EncodingUtil.base64Encode(Blob.valueOf(jsonMidlertidigLonnstilskudd));
        String encodedJsonStatusVurderes1 = EncodingUtil.base64Encode(Blob.valueOf(jsonStatusVurderes1));
        String encodedJsonStatusViBistar1 = EncodingUtil.base64Encode(Blob.valueOf(jsonStatusViBistar1));
        String encodedJsonStatusViBistar2 = EncodingUtil.base64Encode(Blob.valueOf(jsonStatusViBistar2));
        String encodedJsonStatusSlettet2 = EncodingUtil.base64Encode(Blob.valueOf(jsonStatusSlettet2));
        String encodedJsonStatusViBistar3 = EncodingUtil.base64Encode(Blob.valueOf(jsonStatusViBistar3));
        String encodedJsonStatusSlettet3 = EncodingUtil.base64Encode(Blob.valueOf(jsonStatusSlettet3));

        List<KafkaMessage__c> messages = new List<KafkaMessage__c>();

        KafkaMessage__c messageMidlertidigLonnstilskudd = new KafkaMessage__c();
        messageMidlertidigLonnstilskudd.CRM_Topic__c = 'arbeidsgiver.tiltak-avtale-hendelse';
        messageMidlertidigLonnstilskudd.CRM_Key__c = 'c9d8fe1e-c4d2-499e-bd16-af3a88b1e734';
        messageMidlertidigLonnstilskudd.CRM_Value__c = encodedMidlertidigLonnstilskudd;

        KafkaMessage__c messageJsonStatusVurderes1 = new KafkaMessage__c();
        messageJsonStatusVurderes1.CRM_Topic__c = 'pia.ia-sak-v1';
        messageJsonStatusVurderes1.CRM_Key__c = 'a240d1adtuasydt1';
        messageJsonStatusVurderes1.CRM_Value__c = encodedJsonStatusVurderes1;

        KafkaMessage__c messageJsonStatusViBistar1 = new KafkaMessage__c();
        messageJsonStatusViBistar1.CRM_Topic__c = 'pia.ia-sak-v1';
        messageJsonStatusViBistar1.CRM_Key__c = 'a240d1adtuasydt1';
        messageJsonStatusViBistar1.CRM_Value__c = encodedJsonStatusViBistar1;

        KafkaMessage__c messageJsonStatusViBistar2 = new KafkaMessage__c();
        messageJsonStatusViBistar2.CRM_Topic__c = 'pia.ia-sak-v1';
        messageJsonStatusViBistar2.CRM_Key__c = 'a240d1adtuasydt2';
        messageJsonStatusViBistar2.CRM_Value__c = encodedJsonStatusViBistar2;

        KafkaMessage__c messageJsonStatusSlettet2 = new KafkaMessage__c();
        messageJsonStatusSlettet2.CRM_Topic__c = 'pia.ia-sak-v1';
        messageJsonStatusSlettet2.CRM_Key__c = 'a240d1adtuasydt2';
        messageJsonStatusSlettet2.CRM_Value__c = encodedJsonStatusSlettet2;

        KafkaMessage__c messageJsonStatusViBistar3 = new KafkaMessage__c();
        messageJsonStatusViBistar3.CRM_Topic__c = 'pia.ia-sak-v1';
        messageJsonStatusViBistar3.CRM_Key__c = 'a240d1adtuasydt3';
        messageJsonStatusViBistar3.CRM_Value__c = encodedJsonStatusViBistar3;

        KafkaMessage__c messageJsonStatusSlettet3 = new KafkaMessage__c();
        messageJsonStatusSlettet3.CRM_Topic__c = 'pia.ia-sak-v1';
        messageJsonStatusSlettet3.CRM_Key__c = 'a240d1adtuasydt3';
        messageJsonStatusSlettet3.CRM_Value__c = encodedJsonStatusSlettet3;

        messages.add(messageMidlertidigLonnstilskudd);
        messages.add(messageJsonStatusVurderes1);
        messages.add(messageJsonStatusViBistar1);
        messages.add(messageJsonStatusViBistar2);
        messages.add(messageJsonStatusSlettet2);
        messages.add(messageJsonStatusViBistar3);
        messages.add(messageJsonStatusSlettet3);

        insert messages;
    }

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
                Link,
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
        List<Account> accounts = [SELECT Id FROM Account WHERE INT_OrganizationNumber__c = '910825526'];
        List<Account> users = [SELECT Id FROM User WHERE CRM_NAV_Ident__c = 'Z992800'];

        System.assertEquals(1, agreements.size());
        System.assertEquals(accounts[0].id, agreements[0].Account__c);
        System.assertEquals(accounts[0].id, agreements[0].ActionType__c);
        System.assertEquals(accounts[0].id, agreements[0].AgreementId__c);
        System.assertEquals(accounts[0].id, agreements[0].ContentType__c);
        System.assertEquals('Dolly Duck', agreements[0].EmployerContactName__c);
        System.assertEquals('12345678', agreements[0].EmployerContactPhone__c);
        System.assertEquals('2023-01-01', String.valueOf(agreements[0].EndDate__c));
        System.assertEquals(users[0].id, agreements[0].InternalContact__c);
        System.assertEquals(message[0].CRM_Value__c, agreements[0].KafkaHash__c);
        System.assertEquals(message[0].CRM_Key__c, agreements[0].KafkaId__c);
        System.assertEquals('https://arbeidsgiver.nav.no/tiltaksgjennomforing/avtale/c9d8fe1e-c4d2-499e-bd16-af3a88b1e734?bedrift=910825526', agreements[0].Link__c);
        System.assertEquals(null, agreements[0].MentorName__c);
        System.assertEquals('397', agreements[0].Name);
        System.assertEquals(users[0].id, agreements[0].NavUnit__c);
        System.assertEquals('2022-01-01', String.valueOf(agreements[0].StartDate__c));
        System.assertEquals('GJENNOMFØRES', agreements[0].Status__c);
        System.assertEquals('GJENNOMFØRES', agreements[0].Type__c);
    }
}