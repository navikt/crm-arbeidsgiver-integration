@isTest
public with sharing class KafkaToiAvtaleHandlerTest {
    /* Cannot Test for NAV Kontor Profile User because NAV Kontor profile is not in the package*/
    @isTest
    static void processMessage() {
        Account acc = new Account(Name = 'Test Employer 1', INT_OrganizationNumber__c = '910825526');
        insert acc;

        List<Account> accounts = [SELECT Id FROM Account];

        System.assertEquals(1, accounts.size(), 'Acc Inserted');

        List<User> users = TestDataFactory.getUsers(1, 'Standard User', false, false);
        users[0].CRM_NAV_Ident__c = 'Z992800';
        insert users;

        System.assertEquals(1, users.size(), 'User Inserted');

        Group g = new Group(Name = 'Test queue', DeveloperName = 'queue_219', Type = 'Queue');
        insert g;

        List<Group> groups = [SELECT Id FROM Group WHERE Name = 'Test queue'];

        System.assertEquals(1, groups.size(), 'Group Inserted');

        System.runAs(new User(Id = UserInfo.getUserId())) {
            QueueSobject qs = new QueueSobject(QueueId = g.Id, SobjectType = 'Contract__c');
            insert qs;
        }

        NavUnit__c unit = new NavUnit__c(Name = 'NAV Test', INT_UnitNumber__c = '0219', CRM_QueueId__c = g.Id);
        insert unit;

        List<NavUnit__c> units = [SELECT Id, INT_UnitNumber__c FROM NavUnit__c WHERE Name = 'NAV Test'];

        System.assertEquals(1, units.size(), 'Unit Inserted');
        System.assertEquals('0219', units[0].INT_UnitNumber__c, 'Unit nr Inserted');

        String json = '{"hendelseType":"STILLINGSBESKRIVELSE_ENDRET","avtaleStatus":"GJENNOMFØRES","deltakerFnr":"02129623805","mentorFnr":null,"bedriftNr":"910825526","veilederNavIdent":"Z992800","tiltakstype":"MIDLERTIDIG_LONNSTILSKUDD","opprettetTidspunkt":"2022-05-23T10:27:13.626211","avtaleId":"c9d8fe1e-c4d2-499e-bd16-af3a88b1e734","avtaleNr":397,"sistEndret":"2022-10-26T09:54:34.265048609Z","annullertTidspunkt":null,"annullertGrunn":null,"slettemerket":false,"opprettetAvArbeidsgiver":false,"enhetGeografisk":"0805","enhetsnavnGeografisk":"NAV Porsgrunn","enhetOppfolging":"0219","enhetsnavnOppfolging":"NAV Bærum","godkjentForEtterregistrering":true,"kvalifiseringsgruppe":"BFORM","formidlingsgruppe":"ARBS","tilskuddPeriode":[],"feilregistrert":false,"versjon":5,"deltakerFornavn":"Overfølsom","deltakerEtternavn":"Klovn","deltakerTlf":"12345676","bedriftNavn":"GAMLE FREDRIKSTAD OG RAMNES REGNSKA P","arbeidsgiverFornavn":"Dolly","arbeidsgiverEtternavn":"Duck","arbeidsgiverTlf":"12345678","veilederFornavn":"Onkel","veilederEtternavn":"Donald","veilederTlf":"12345678","oppfolging":"rtretyrteyrtey","tilrettelegging":"fdghdfghdfghfdgh","startDato":"2022-01-01","sluttDato":"2023-01-01","stillingprosent":100,"journalpostId":null,"arbeidsoppgaver":"trrtyrtrtytreyccxzc","stillingstittel":"Bussrengjører","stillingStyrk08":9122,"stillingKonseptId":168963,"antallDagerPerUke":5,"refusjonKontaktperson":null,"mentorFornavn":null,"mentorEtternavn":null,"mentorOppgaver":null,"mentorAntallTimer":null,"mentorTimelonn":null,"mentorTlf":null,"arbeidsgiverKontonummer":"91311592950","lonnstilskuddProsent":40,"manedslonn":20000,"feriepengesats":0.143,"arbeidsgiveravgift":0.106,"harFamilietilknytning":false,"familietilknytningForklaring":null,"feriepengerBelop":2860,"otpSats":0.1,"otpBelop":2286,"arbeidsgiveravgiftBelop":2665,"sumLonnsutgifter":27811,"sumLonnstilskudd":11124,"manedslonn100pst":27811,"sumLønnstilskuddRedusert":8343,"datoForRedusertProsent":"2022-07-01","stillingstype":"FAST","maal":[],"inkluderingstilskuddsutgift":[],"inkluderingstilskuddBegrunnelse":null,"inkluderingstilskuddTotalBeløp":0,"godkjentAvDeltaker":"2022-05-23T10:31:49.922613","godkjentTaushetserklæringAvMentor":null,"godkjentAvArbeidsgiver":"2022-05-23T10:31:18.693921","godkjentAvVeileder":"2022-05-23T10:31:49.922613","godkjentAvBeslutter":null,"avtaleInngått":"2022-05-23T10:31:49.922613","ikrafttredelsestidspunkt":"2022-10-26T11:54:34.265009244","godkjentAvNavIdent":"Z992800","godkjentAvBeslutterNavIdent":null,"enhetKostnadssted":null,"enhetsnavnKostnadssted":null,"godkjentPaVegneGrunn":{"ikkeBankId":true,"reservert":false,"digitalKompetanse":false,"arenaMigreringDeltaker":true},"godkjentPaVegneAv":true,"godkjentPaVegneAvArbeidsgiverGrunn":{"klarerIkkeGiFaTilgang":false,"vetIkkeHvemSomKanGiTilgang":false,"farIkkeTilgangPersonvern":false,"arenaMigreringArbeidsgiver":true},"godkjentPaVegneAvArbeidsgiver":false,"innholdType":"ENDRE_STILLING","utførtAv":"Z992800"}';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(json));

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'arbeidsgiver.tiltak-avtale-hendelse';
        msg1.CRM_Key__c = 'c9d8fe1e-c4d2-499e-bd16-af3a88b1e734';
        msg1.CRM_Value__c = encodedValue;

        Test.StartTest();
        KafkaToiAvtaleHandler handler = new KafkaToiAvtaleHandler();
        handler.processMessages(new List<KafkaMessage__c>{ msg1 });
        Test.StopTest();

        List<Contract__c> avtaler = [
            SELECT
                Id,
                RecordTypeId,
                TAG_StartDate__c,
                TAG_ContractId__c,
                TAG_ActionType__c,
                TAG_ContentType__c,
                TAG_EndDate__c,
                ExternalId__c,
                TAG_EmployerContactPhone__c,
                TAG_Status__c,
                TAG_MeasureParticipant__c,
                TAG_EmployerContact__c,
                TAG_Mentor__c,
                TAG_ExternalURL__c,
                TAG_Category__c,
                TAG_InternalContact__c,
                OwnerId,
                TAG_Account__c,
                TAG_NAVUnit__c,
                KafkaId__c
            FROM Contract__c
        ];

        List<ArenaActivity__c> aktiviteter = [
            SELECT
                Id,
                DateFrom__c,
                DateTo__c,
                DateTimeRegistered__c,
                DateTimeFrom__c,
                Aktivitetsgruppekode__c,
                TAG_Source__c,
                AktivitetStatuskode__c,
                AktivitetsKode__c,
                KafkaId__c,
                NAVIdent__c,
                Account__c,
                NAV_Kontor__c,
                CaseWorker__c
            FROM ArenaActivity__c
        ];

        System.assertEquals(1, avtaler.size());
        System.assertEquals(acc.id, avtaler[0].TAG_Account__c);
        System.assertEquals(msg1.CRM_Key__c, avtaler[0].KafkaId__c);
        System.assertEquals('2022-01-01', String.valueOf(avtaler[0].TAG_StartDate__c));
        System.assertEquals('2023-01-01', String.valueOf(avtaler[0].TAG_EndDate__c));
        System.assertEquals('397', avtaler[0].ExternalId__c);
        System.assertEquals('GJENNOMFØRES', avtaler[0].TAG_Status__c);
        System.assertEquals('Overfølsom Klovn', avtaler[0].TAG_MeasureParticipant__c);
        System.assertEquals('Dolly Duck', avtaler[0].TAG_EmployerContact__c);
        System.assertEquals('12345678', avtaler[0].TAG_EmployerContactPhone__c);
        System.assertEquals(null, avtaler[0].TAG_Mentor__c);
        System.assertEquals(
            'https://arbeidsgiver.nav.no/tiltaksgjennomforing/avtale/c9d8fe1e-c4d2-499e-bd16-af3a88b1e734?bedrift=910825526',
            avtaler[0].TAG_ExternalURL__c
        );
        System.assertEquals('MIDLERTIDIG_LONNSTILSKUDD', avtaler[0].TAG_Category__c);
        System.assertEquals(users[0].Id, avtaler[0].TAG_InternalContact__c);
        System.assertEquals(unit.Id, avtaler[0].TAG_NAVUnit__c);
        System.assertEquals('STILLINGSBESKRIVELSE_ENDRET', avtaler[0].TAG_ActionType__c);
        System.assertEquals('ENDRE_STILLING', avtaler[0].TAG_ContentType__c);
        System.assertEquals('c9d8fe1e-c4d2-499e-bd16-af3a88b1e734', avtaler[0].TAG_ContractId__c);
        System.assertEquals(1, aktiviteter.size());
        System.assertEquals('GJENNOMFØRES', aktiviteter[0].AktivitetStatuskode__c);
        System.assertEquals('2022-01-01', String.valueOf(aktiviteter[0].DateFrom__c));
        System.assertEquals('2023-01-01', String.valueOf(aktiviteter[0].DateTo__c));
        System.assertEquals('TLTAK', aktiviteter[0].Aktivitetsgruppekode__c);
        System.assertEquals('Z992800', aktiviteter[0].NAVIdent__c);
        System.assertEquals(users[0].Id, aktiviteter[0].CaseWorker__c);
        System.assertEquals(acc.id, aktiviteter[0].Account__c);
        System.assertEquals(unit.Id, aktiviteter[0].NAV_Kontor__c);
        System.assertEquals('Tiltaksløsning', aktiviteter[0].TAG_Source__c);
    }

    @isTest
    static void missingUserMatch() {
        Account acc = new Account(Name = 'Test Employer 1', INT_OrganizationNumber__c = '910825526');
        insert acc;

        List<Account> accounts = [SELECT Id FROM Account];

        System.assertEquals(1, accounts.size(), 'Acc Inserted');

        List<User> users = TestDataFactory.getUsers(1, 'Standard User', false, false);
        users[0].CRM_NAV_Ident__c = 'Z000000';
        insert users;

        System.assertEquals(1, users.size(), 'User Inserted');

        Group g = new Group(Name = 'Test queue', DeveloperName = 'queue_219', Type = 'Queue');
        insert g;

        List<Group> groups = [SELECT Id FROM Group WHERE Name = 'Test queue'];

        System.assertEquals(1, groups.size(), 'Group Inserted');

        System.runAs(new User(Id = UserInfo.getUserId())) {
            QueueSobject qs = new QueueSobject(QueueId = g.Id, SobjectType = 'Contract__c');
            insert qs;
        }

        NavUnit__c unit = new NavUnit__c(Name = 'NAV Test', INT_UnitNumber__c = '0219', CRM_QueueId__c = g.Id);
        insert unit;

        List<NavUnit__c> units = [SELECT Id, INT_UnitNumber__c FROM NavUnit__c WHERE Name = 'NAV Test'];

        System.assertEquals(1, units.size(), 'Unit Inserted');
        System.assertEquals('0219', units[0].INT_UnitNumber__c, 'Unit nr Inserted');

        String json = '{"hendelseType":"STILLINGSBESKRIVELSE_ENDRET","avtaleStatus":"GJENNOMFØRES","deltakerFnr":"02129623805","mentorFnr":null,"bedriftNr":"910825526","veilederNavIdent":"Z992800","tiltakstype":"MIDLERTIDIG_LONNSTILSKUDD","opprettetTidspunkt":"2022-05-23T10:27:13.626211","avtaleId":"c9d8fe1e-c4d2-499e-bd16-af3a88b1e734","avtaleNr":397,"sistEndret":"2022-10-26T09:54:34.265048609Z","annullertTidspunkt":null,"annullertGrunn":null,"slettemerket":false,"opprettetAvArbeidsgiver":false,"enhetGeografisk":"0805","enhetsnavnGeografisk":"NAV Porsgrunn","enhetOppfolging":"0219","enhetsnavnOppfolging":"NAV Bærum","godkjentForEtterregistrering":true,"kvalifiseringsgruppe":"BFORM","formidlingsgruppe":"ARBS","tilskuddPeriode":[],"feilregistrert":false,"versjon":5,"deltakerFornavn":"Overfølsom","deltakerEtternavn":"Klovn","deltakerTlf":"12345676","bedriftNavn":"GAMLE FREDRIKSTAD OG RAMNES REGNSKA P","arbeidsgiverFornavn":"Dolly","arbeidsgiverEtternavn":"Duck","arbeidsgiverTlf":"12345678","veilederFornavn":"Onkel","veilederEtternavn":"Donald","veilederTlf":"12345678","oppfolging":"rtretyrteyrtey","tilrettelegging":"fdghdfghdfghfdgh","startDato":"2022-01-01","sluttDato":"2023-01-01","stillingprosent":100,"journalpostId":null,"arbeidsoppgaver":"trrtyrtrtytreyccxzc","stillingstittel":"Bussrengjører","stillingStyrk08":9122,"stillingKonseptId":168963,"antallDagerPerUke":5,"refusjonKontaktperson":null,"mentorFornavn":null,"mentorEtternavn":null,"mentorOppgaver":null,"mentorAntallTimer":null,"mentorTimelonn":null,"mentorTlf":null,"arbeidsgiverKontonummer":"91311592950","lonnstilskuddProsent":40,"manedslonn":20000,"feriepengesats":0.143,"arbeidsgiveravgift":0.106,"harFamilietilknytning":false,"familietilknytningForklaring":null,"feriepengerBelop":2860,"otpSats":0.1,"otpBelop":2286,"arbeidsgiveravgiftBelop":2665,"sumLonnsutgifter":27811,"sumLonnstilskudd":11124,"manedslonn100pst":27811,"sumLønnstilskuddRedusert":8343,"datoForRedusertProsent":"2022-07-01","stillingstype":"FAST","maal":[],"inkluderingstilskuddsutgift":[],"inkluderingstilskuddBegrunnelse":null,"inkluderingstilskuddTotalBeløp":0,"godkjentAvDeltaker":"2022-05-23T10:31:49.922613","godkjentTaushetserklæringAvMentor":null,"godkjentAvArbeidsgiver":"2022-05-23T10:31:18.693921","godkjentAvVeileder":"2022-05-23T10:31:49.922613","godkjentAvBeslutter":null,"avtaleInngått":"2022-05-23T10:31:49.922613","ikrafttredelsestidspunkt":"2022-10-26T11:54:34.265009244","godkjentAvNavIdent":"Z992800","godkjentAvBeslutterNavIdent":null,"enhetKostnadssted":null,"enhetsnavnKostnadssted":null,"godkjentPaVegneGrunn":{"ikkeBankId":true,"reservert":false,"digitalKompetanse":false},"godkjentPaVegneAv":true,"godkjentPaVegneAvArbeidsgiverGrunn":null,"godkjentPaVegneAvArbeidsgiver":false,"innholdType":"ENDRE_STILLING","utførtAv":"Z992800"}';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(json));

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'arbeidsgiver.tiltak-avtale-hendelse';
        msg1.CRM_Key__c = 'c9d8fe1e-c4d2-499e-bd16-af3a88b1e734';
        msg1.CRM_Value__c = encodedValue;

        Test.StartTest();
        KafkaToiAvtaleHandler handler = new KafkaToiAvtaleHandler();
        handler.processMessages(new List<KafkaMessage__c>{ msg1 });
        Test.StopTest();

        List<Contract__c> avtaler = [
            SELECT
                Id,
                RecordTypeId,
                TAG_StartDate__c,
                TAG_EndDate__c,
                ExternalId__c,
                TAG_Status__c,
                TAG_MeasureParticipant__c,
                TAG_EmployerContact__c,
                TAG_Mentor__c,
                TAG_ExternalURL__c,
                TAG_Category__c,
                TAG_InternalContact__c,
                OwnerId,
                TAG_Account__c,
                TAG_NAVUnit__c,
                KafkaId__c
            FROM Contract__c
        ];

        System.assertEquals(1, avtaler.size());
        System.assertEquals(acc.id, avtaler[0].TAG_Account__c);
        System.assertEquals(msg1.CRM_Key__c, avtaler[0].KafkaId__c);
        System.assertEquals('2022-01-01', String.valueOf(avtaler[0].TAG_StartDate__c));
        System.assertEquals('2023-01-01', String.valueOf(avtaler[0].TAG_EndDate__c));
        System.assertEquals('397', avtaler[0].ExternalId__c);
        System.assertEquals('GJENNOMFØRES', avtaler[0].TAG_Status__c);
        System.assertEquals('Overfølsom Klovn', avtaler[0].TAG_MeasureParticipant__c);
        System.assertEquals('Dolly Duck', avtaler[0].TAG_EmployerContact__c);
        System.assertEquals(null, avtaler[0].TAG_Mentor__c);
        System.assertEquals(
            'https://arbeidsgiver.nav.no/tiltaksgjennomforing/avtale/c9d8fe1e-c4d2-499e-bd16-af3a88b1e734?bedrift=910825526',
            avtaler[0].TAG_ExternalURL__c
        );
        System.assertEquals('MIDLERTIDIG_LONNSTILSKUDD', avtaler[0].TAG_Category__c);
        System.assert(String.isBlank(avtaler[0].TAG_InternalContact__c));
        System.assertEquals(unit.Id, avtaler[0].TAG_NAVUnit__c);
    }

    @isTest
    static void processMessageWithMoreNulls() {
        Account acc = new Account(Name = 'Test Employer 1', INT_OrganizationNumber__c = '910825526');
        insert acc;

        List<Account> accounts = [SELECT Id FROM Account];

        System.assertEquals(1, accounts.size(), 'Acc Inserted');

        List<User> users = TestDataFactory.getUsers(1, 'Standard User', false, false);
        users[0].CRM_NAV_Ident__c = 'Z992800';
        insert users;

        System.assertEquals(1, users.size(), 'User Inserted');

        Group g = new Group(Name = 'Test queue', DeveloperName = 'queue_219', Type = 'Queue');
        insert g;

        List<Group> groups = [SELECT Id FROM Group WHERE Name = 'Test queue'];

        System.assertEquals(1, groups.size(), 'Group Inserted');

        System.runAs(new User(Id = UserInfo.getUserId())) {
            QueueSobject qs = new QueueSobject(QueueId = g.Id, SobjectType = 'Contract__c');
            insert qs;
        }

        NavUnit__c unit = new NavUnit__c(Name = 'NAV Test', INT_UnitNumber__c = '0219', CRM_QueueId__c = g.Id);
        insert unit;

        List<NavUnit__c> units = [SELECT Id, INT_UnitNumber__c FROM NavUnit__c WHERE Name = 'NAV Test'];

        System.assertEquals(1, units.size(), 'Unit Inserted');
        System.assertEquals('0219', units[0].INT_UnitNumber__c, 'Unit nr Inserted');

        String json = '{"hendelseType":"STILLINGSBESKRIVELSE_ENDRET","avtaleStatus":"GJENNOMFØRES","deltakerFnr":"02129623805","mentorFnr":null,"bedriftNr":"910825526","veilederNavIdent":null,"tiltakstype":"MIDLERTIDIG_LONNSTILSKUDD","opprettetTidspunkt":"2022-05-23T10:27:13.626211","avtaleId":"c9d8fe1e-c4d2-499e-bd16-af3a88b1e734","avtaleNr":397,"sistEndret":"2022-10-26T09:54:34.265048609Z","annullertTidspunkt":null,"annullertGrunn":null,"slettemerket":false,"opprettetAvArbeidsgiver":false,"enhetGeografisk":"0805","enhetsnavnGeografisk":"NAV Porsgrunn","enhetOppfolging":"0219","enhetsnavnOppfolging":"NAV Bærum","godkjentForEtterregistrering":true,"kvalifiseringsgruppe":"BFORM","formidlingsgruppe":"ARBS","tilskuddPeriode":[],"feilregistrert":false,"versjon":5,"deltakerFornavn":"Overfølsom","deltakerEtternavn":"Klovn","deltakerTlf":"12345676","bedriftNavn":"GAMLE FREDRIKSTAD OG RAMNES REGNSKA P","arbeidsgiverFornavn":"Dolly","arbeidsgiverEtternavn":"Duck","arbeidsgiverTlf":"12345678","veilederFornavn":"Onkel","veilederEtternavn":"Donald","veilederTlf":"12345678","oppfolging":"rtretyrteyrtey","tilrettelegging":"fdghdfghdfghfdgh","startDato":"2022-01-01","sluttDato":null,"stillingprosent":100,"journalpostId":null,"arbeidsoppgaver":"trrtyrtrtytreyccxzc","stillingstittel":"Bussrengjører","stillingStyrk08":9122,"stillingKonseptId":168963,"antallDagerPerUke":5,"refusjonKontaktperson":null,"mentorFornavn":null,"mentorEtternavn":null,"mentorOppgaver":null,"mentorAntallTimer":null,"mentorTimelonn":null,"mentorTlf":null,"arbeidsgiverKontonummer":"91311592950","lonnstilskuddProsent":40,"manedslonn":20000,"feriepengesats":0.143,"arbeidsgiveravgift":0.106,"harFamilietilknytning":false,"familietilknytningForklaring":null,"feriepengerBelop":2860,"otpSats":0.1,"otpBelop":2286,"arbeidsgiveravgiftBelop":2665,"sumLonnsutgifter":27811,"sumLonnstilskudd":11124,"manedslonn100pst":27811,"sumLønnstilskuddRedusert":8343,"datoForRedusertProsent":"2022-07-01","stillingstype":"FAST","maal":[],"inkluderingstilskuddsutgift":[],"inkluderingstilskuddBegrunnelse":null,"inkluderingstilskuddTotalBeløp":0,"godkjentAvDeltaker":"2022-05-23T10:31:49.922613","godkjentTaushetserklæringAvMentor":null,"godkjentAvArbeidsgiver":"2022-05-23T10:31:18.693921","godkjentAvVeileder":"2022-05-23T10:31:49.922613","godkjentAvBeslutter":null,"avtaleInngått":"2022-05-23T10:31:49.922613","ikrafttredelsestidspunkt":"2022-10-26T11:54:34.265009244","godkjentAvNavIdent":"Z992800","godkjentAvBeslutterNavIdent":null,"enhetKostnadssted":null,"enhetsnavnKostnadssted":null,"godkjentPaVegneGrunn":null,"godkjentPaVegneAv":true,"godkjentPaVegneAvArbeidsgiverGrunn":null,"godkjentPaVegneAvArbeidsgiver":false,"innholdType":"ENDRE_STILLING","utførtAv":"Z992800"}';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(json));

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'arbeidsgiver.tiltak-avtale-hendelse';
        msg1.CRM_Key__c = 'c9d8fe1e-c4d2-499e-bd16-af3a88b1e734';
        msg1.CRM_Value__c = encodedValue;

        Test.StartTest();
        KafkaToiAvtaleHandler handler = new KafkaToiAvtaleHandler();
        handler.processMessages(new List<KafkaMessage__c>{ msg1 });
        Test.StopTest();

        List<Contract__c> avtaler = [
            SELECT
                Id,
                RecordTypeId,
                TAG_StartDate__c,
                TAG_EndDate__c,
                ExternalId__c,
                TAG_Status__c,
                TAG_MeasureParticipant__c,
                TAG_EmployerContact__c,
                TAG_Mentor__c,
                TAG_ExternalURL__c,
                TAG_Category__c,
                TAG_InternalContact__c,
                OwnerId,
                TAG_Account__c,
                TAG_NAVUnit__c,
                KafkaId__c
            FROM Contract__c
        ];

        System.assertEquals(1, avtaler.size());
        System.assertEquals(acc.id, avtaler[0].TAG_Account__c);
        System.assertEquals(msg1.CRM_Key__c, avtaler[0].KafkaId__c);
        System.assertEquals('2022-01-01', String.valueOf(avtaler[0].TAG_StartDate__c));
        //System.assertEquals(null, String.valueOf(avtaler[0].TAG_EndDate__c));
        System.assertEquals('397', avtaler[0].ExternalId__c);
        System.assertEquals('GJENNOMFØRES', avtaler[0].TAG_Status__c);
        System.assertEquals('Overfølsom Klovn', avtaler[0].TAG_MeasureParticipant__c);
        System.assertEquals('Dolly Duck', avtaler[0].TAG_EmployerContact__c);
        System.assertEquals(null, avtaler[0].TAG_Mentor__c);
        System.assertEquals(
            'https://arbeidsgiver.nav.no/tiltaksgjennomforing/avtale/c9d8fe1e-c4d2-499e-bd16-af3a88b1e734?bedrift=910825526',
            avtaler[0].TAG_ExternalURL__c
        );
        System.assertEquals('MIDLERTIDIG_LONNSTILSKUDD', avtaler[0].TAG_Category__c);
        System.assert(String.isBlank(avtaler[0].TAG_InternalContact__c));
        System.assertEquals(unit.Id, avtaler[0].TAG_NAVUnit__c);
    }

    @isTest
    static void deltakerFornavnNull() {
        Account acc = new Account(Name = 'Test Employer 1', INT_OrganizationNumber__c = '910825526');
        insert acc;

        List<Account> accounts = [SELECT Id FROM Account];

        System.assertEquals(1, accounts.size(), 'Acc Inserted');

        List<User> users = TestDataFactory.getUsers(2, 'Standard User', false, false);
        users[0].CRM_NAV_Ident__c = 'Z000000';
        users[1].FirstName = 'Systembruker';
        users[1].LastName = 'Asynkron Prosessering';
        insert users;

        System.assertEquals(2, users.size(), 'User Inserted');

        String json = '{"hendelseType":"STILLINGSBESKRIVELSE_ENDRET","avtaleStatus":"GJENNOMFØRES","deltakerFnr":"02129623805","mentorFnr":null,"bedriftNr":"910825526","veilederNavIdent":null,"tiltakstype":"MIDLERTIDIG_LONNSTILSKUDD","opprettetTidspunkt":"2022-05-23T10:27:13.626211","avtaleId":"c9d8fe1e-c4d2-499e-bd16-af3a88b1e734","avtaleNr":397,"sistEndret":"2022-10-26T09:54:34.265048609Z","annullertTidspunkt":null,"annullertGrunn":null,"slettemerket":false,"opprettetAvArbeidsgiver":false,"enhetGeografisk":"0805","enhetsnavnGeografisk":"NAV Porsgrunn","enhetOppfolging":"0219","enhetsnavnOppfolging":"NAV Bærum","godkjentForEtterregistrering":true,"kvalifiseringsgruppe":"BFORM","formidlingsgruppe":"ARBS","tilskuddPeriode":[],"feilregistrert":false,"versjon":5,"deltakerFornavn":null,"deltakerEtternavn":"Klovn","deltakerTlf":"12345676","bedriftNavn":"GAMLE FREDRIKSTAD OG RAMNES REGNSKA P","arbeidsgiverFornavn":"Dolly","arbeidsgiverEtternavn":"Duck","arbeidsgiverTlf":"12345678","veilederFornavn":"Onkel","veilederEtternavn":"Donald","veilederTlf":"12345678","oppfolging":"rtretyrteyrtey","tilrettelegging":"fdghdfghdfghfdgh","startDato":"2022-01-01","sluttDato":null,"stillingprosent":100,"journalpostId":null,"arbeidsoppgaver":"trrtyrtrtytreyccxzc","stillingstittel":"Bussrengjører","stillingStyrk08":9122,"stillingKonseptId":168963,"antallDagerPerUke":5,"refusjonKontaktperson":null,"mentorFornavn":null,"mentorEtternavn":null,"mentorOppgaver":null,"mentorAntallTimer":null,"mentorTimelonn":null,"mentorTlf":null,"arbeidsgiverKontonummer":"91311592950","lonnstilskuddProsent":40,"manedslonn":20000,"feriepengesats":0.143,"arbeidsgiveravgift":0.106,"harFamilietilknytning":false,"familietilknytningForklaring":null,"feriepengerBelop":2860,"otpSats":0.1,"otpBelop":2286,"arbeidsgiveravgiftBelop":2665,"sumLonnsutgifter":27811,"sumLonnstilskudd":11124,"manedslonn100pst":27811,"sumLønnstilskuddRedusert":8343,"datoForRedusertProsent":"2022-07-01","stillingstype":"FAST","maal":[],"inkluderingstilskuddsutgift":[],"inkluderingstilskuddBegrunnelse":null,"inkluderingstilskuddTotalBeløp":0,"godkjentAvDeltaker":"2022-05-23T10:31:49.922613","godkjentTaushetserklæringAvMentor":null,"godkjentAvArbeidsgiver":"2022-05-23T10:31:18.693921","godkjentAvVeileder":"2022-05-23T10:31:49.922613","godkjentAvBeslutter":null,"avtaleInngått":"2022-05-23T10:31:49.922613","ikrafttredelsestidspunkt":"2022-10-26T11:54:34.265009244","godkjentAvNavIdent":"Z992800","godkjentAvBeslutterNavIdent":null,"enhetKostnadssted":null,"enhetsnavnKostnadssted":null,"godkjentPaVegneGrunn":{"ikkeBankId":true,"reservert":false,"digitalKompetanse":false},"godkjentPaVegneAv":true,"godkjentPaVegneAvArbeidsgiverGrunn":null,"godkjentPaVegneAvArbeidsgiver":false,"innholdType":"ENDRE_STILLING","utførtAv":"Z992800"}';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(json));

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'arbeidsgiver.tiltak-avtale-hendelse';
        msg1.CRM_Key__c = 'c9d8fe1e-c4d2-499e-bd16-af3a88b1e734';
        msg1.CRM_Value__c = encodedValue;

        Test.StartTest();
        KafkaToiAvtaleHandler handler = new KafkaToiAvtaleHandler();
        handler.processMessages(new List<KafkaMessage__c>{ msg1 });
        Test.StopTest();

        List<Contract__c> avtaler = [
            SELECT
                Id,
                RecordTypeId,
                TAG_StartDate__c,
                TAG_EndDate__c,
                ExternalId__c,
                TAG_Status__c,
                TAG_MeasureParticipant__c,
                TAG_EmployerContact__c,
                TAG_Mentor__c,
                TAG_ExternalURL__c,
                TAG_Category__c,
                TAG_InternalContact__c,
                OwnerId,
                TAG_Account__c,
                TAG_NAVUnit__c,
                KafkaId__c
            FROM Contract__c
        ];

        System.assertEquals(1, avtaler.size());
        System.assertEquals(null, avtaler[0].TAG_MeasureParticipant__c, 'Should be null');
    }

    @isTest
    static void testMissingOrgNr() {
        Account acc = new Account(Name = 'Test Employer 1', INT_OrganizationNumber__c = '910825526');
        insert acc;

        List<Account> accounts = [SELECT Id FROM Account];

        System.assertEquals(1, accounts.size(), 'Acc Inserted');

        List<User> users = TestDataFactory.getUsers(2, 'Standard User', false, false);
        users[0].CRM_NAV_Ident__c = 'Z992800';
        users[1].FirstName = 'Systembruker';
        users[1].LastName = 'Asynkron Prosessering';

        insert users;

        System.assertEquals(2, users.size(), 'User Inserted');

        Group g = new Group(Name = 'Test queue', DeveloperName = 'queue_219', Type = 'Queue');
        insert g;

        List<Group> groups = [SELECT Id FROM Group WHERE Name = 'Test queue'];

        System.assertEquals(1, groups.size(), 'Group Inserted');

        NavUnit__c unit = new NavUnit__c(Name = 'NAV Test', INT_UnitNumber__c = '0219', CRM_QueueId__c = g.Id);
        insert unit;

        List<NavUnit__c> units = [SELECT Id, INT_UnitNumber__c FROM NavUnit__c WHERE Name = 'NAV Test'];

        System.assertEquals(1, units.size(), 'Unit Inserted');
        System.assertEquals('0219', units[0].INT_UnitNumber__c, 'Unit nr Inserted');

        String json = '{"hendelseType":"AVTALE_FORLENGET","avtaleStatus":"GJENNOMFØRES","deltakerFnr":"07860198775","mentorFnr":null,"bedriftNr":null,"veilederNavIdent":"Z992785","tiltakstype":"VARIG_LONNSTILSKUDD","opprettetTidspunkt":"2023-01-23T15:08:53.014813","avtaleId":"d0abcf43-f240-442f-913b-8865521c40b3","avtaleNr":548,"sistEndret":"2023-01-30T10:39:22.029935206Z","annullertTidspunkt":null,"annullertGrunn":null,"slettemerket":false,"opprettetAvArbeidsgiver":false,"enhetGeografisk":"1860","enhetsnavnGeografisk":"NAV Lofoten","enhetOppfolging":"1860","enhetsnavnOppfolging":"NAV Lofoten","godkjentForEtterregistrering":false,"kvalifiseringsgruppe":"VARIG","formidlingsgruppe":"IARBS","tilskuddPeriode":[],"feilregistrert":false,"versjon":3,"deltakerFornavn":"Konge","deltakerEtternavn":"Syndebukk","deltakerTlf":"12121212","bedriftNavn":"MAURA OG KOLBU REGNSKAP","arbeidsgiverFornavn":"For","arbeidsgiverEtternavn":"Navn","arbeidsgiverTlf":"12121212","veilederFornavn":"Kontakt","veilederEtternavn":"Person","veilederTlf":"12121212","oppfolging":"Water spider things","tilrettelegging":"Water spider things","startDato":"2023-01-16","sluttDato":"2025-04-01","stillingprosent":100,"journalpostId":null,"arbeidsoppgaver":"Spindler i vannet","stillingstittel":"Water Spider","stillingStyrk08":4322,"stillingKonseptId":259822,"antallDagerPerUke":5,"refusjonKontaktperson":null,"mentorFornavn":null,"mentorEtternavn":null,"mentorOppgaver":null,"mentorAntallTimer":null,"mentorTimelonn":null,"mentorTlf":null,"arbeidsgiverKontonummer":"91311592950","lonnstilskuddProsent":60,"manedslonn":4000,"feriepengesats":0.143,"arbeidsgiveravgift":0.106,"harFamilietilknytning":false,"familietilknytningForklaring":null,"feriepengerBelop":5720,"otpSats":0.07,"otpBelop":3200,"arbeidsgiveravgiftBelop":5186,"sumLonnsutgifter":54106,"sumLonnstilskudd":32464,"manedslonn100pst":54106,"sumLønnstilskuddRedusert":null,"datoForRedusertProsent":null,"stillingstype":"FAST","maal":[],"inkluderingstilskuddsutgift":[],"inkluderingstilskuddBegrunnelse":null,"inkluderingstilskuddTotalBeløp":0,"godkjentAvDeltaker":"2023-01-23T15:12:07.444992","godkjentTaushetserklæringAvMentor":null,"godkjentAvArbeidsgiver":"2023-01-23T15:12:07.444992","godkjentAvVeileder":"2023-01-23T15:12:07.444992","godkjentAvBeslutter":null,"avtaleInngått":"2023-01-23T15:12:07.444992","ikrafttredelsestidspunkt":"2023-01-30T11:39:22.029904056","godkjentAvNavIdent":"Z992785","godkjentAvBeslutterNavIdent":null,"enhetKostnadssted":null,"enhetsnavnKostnadssted":null,"godkjentPaVegneGrunn":{"ikkeBankId":false,"reservert":false,"digitalKompetanse":false,"arenaMigreringDeltaker":true},"godkjentPaVegneAv":true,"godkjentPaVegneAvArbeidsgiverGrunn":{"klarerIkkeGiFaTilgang":false,"vetIkkeHvemSomKanGiTilgang":false,"farIkkeTilgangPersonvern":false,"arenaMigreringArbeidsgiver":true},"godkjentPaVegneAvArbeidsgiver":true,"innholdType":"FORLENGE","utførtAv":"Z992785","utførtAvRolle":"VEILEDER"}';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(json));

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'arbeidsgiver.tiltak-avtale-hendelse';
        msg1.CRM_Key__c = 'd0abcf43-f240-442f-913b-8865521c40b3';
        msg1.CRM_Value__c = encodedValue;

        Test.StartTest();
        KafkaToiAvtaleHandler handler = new KafkaToiAvtaleHandler();
        handler.processMessages(new List<KafkaMessage__c>{ msg1 });
        Test.StopTest();

        List<Contract__c> avtaler = [
            SELECT
                Id,
                RecordTypeId,
                TAG_StartDate__c,
                TAG_EndDate__c,
                ExternalId__c,
                TAG_EmployerContactPhone__c,
                TAG_Status__c,
                TAG_MeasureParticipant__c,
                TAG_EmployerContact__c,
                TAG_Mentor__c,
                TAG_ExternalURL__c,
                TAG_Category__c,
                TAG_InternalContact__c,
                OwnerId,
                TAG_Account__c,
                TAG_NAVUnit__c,
                KafkaId__c
            FROM Contract__c
        ];

        List<ArenaActivity__c> aktiviteter = [
            SELECT
                Id,
                DateFrom__c,
                DateTo__c,
                DateTimeRegistered__c,
                DateTimeFrom__c,
                Aktivitetsgruppekode__c,
                TAG_Source__c,
                AktivitetStatuskode__c,
                AktivitetsKode__c,
                KafkaId__c,
                NAVIdent__c,
                Account__c,
                NAV_Kontor__c,
                CaseWorker__c
            FROM ArenaActivity__c
        ];

        System.assertEquals(1, avtaler.size());
        System.assertEquals(null, avtaler[0].TAG_Account__c);
        System.assertEquals(msg1.CRM_Key__c, avtaler[0].KafkaId__c);
        System.assertEquals('548', avtaler[0].ExternalId__c);
        System.assertEquals('GJENNOMFØRES', avtaler[0].TAG_Status__c);
        System.assertEquals(
            'https://arbeidsgiver.nav.no/tiltaksgjennomforing/avtale/d0abcf43-f240-442f-913b-8865521c40b3',
            avtaler[0].TAG_ExternalURL__c
        );
        System.assertEquals('VARIG_LONNSTILSKUDD', avtaler[0].TAG_Category__c);
        System.assertEquals(1, aktiviteter.size());
        System.assertEquals('GJENNOMFØRES', aktiviteter[0].AktivitetStatuskode__c);
    }

    @isTest
    static void multipleMessageSameKey() {
        Account acc = new Account(Name = 'Test Employer 1', INT_OrganizationNumber__c = '910825526');
        insert acc;

        List<Account> accounts = [SELECT Id FROM Account];

        System.assertEquals(1, accounts.size(), 'Acc Inserted');

        List<User> users = TestDataFactory.getUsers(1, 'Standard User', false, false);
        users[0].CRM_NAV_Ident__c = 'Z992800';
        users[0].FirstName = 'Systembruker';
        users[0].LastName = 'Asynkron Prosessering';
        insert users;

        System.assertEquals(1, users.size(), 'User Inserted');

        Group g = new Group(Name = 'Test queue', DeveloperName = 'queue_219', Type = 'Queue');
        insert g;

        List<Group> groups = [SELECT Id FROM Group WHERE Name = 'Test queue'];

        System.assertEquals(1, groups.size(), 'Group Inserted');

        NavUnit__c unit = new NavUnit__c(Name = 'NAV Test', INT_UnitNumber__c = '0219', CRM_QueueId__c = g.Id);
        insert unit;

        List<NavUnit__c> units = [SELECT Id, INT_UnitNumber__c FROM NavUnit__c WHERE Name = 'NAV Test'];

        System.assertEquals(1, units.size(), 'Unit Inserted');
        System.assertEquals('0219', units[0].INT_UnitNumber__c, 'Unit nr Inserted');

        String json1 = '{"hendelseType":"AVTALE_FORLENGET","avtaleStatus":"KLAR_FOR_OPPSTART","deltakerFnr":"07860198775","mentorFnr":null,"bedriftNr":"910825526","veilederNavIdent":"Z992785","tiltakstype":"VARIG_LONNSTILSKUDD","opprettetTidspunkt":"2023-01-23T15:08:53.014813","avtaleId":"d0abcf43-f240-442f-913b-8865521c40b3","avtaleNr":548,"sistEndret":"2023-01-30T10:39:22.029935206Z","annullertTidspunkt":null,"annullertGrunn":null,"slettemerket":false,"opprettetAvArbeidsgiver":false,"enhetGeografisk":"1860","enhetsnavnGeografisk":"NAV Lofoten","enhetOppfolging":"1860","enhetsnavnOppfolging":"NAV Lofoten","godkjentForEtterregistrering":false,"kvalifiseringsgruppe":"VARIG","formidlingsgruppe":"IARBS","tilskuddPeriode":[],"feilregistrert":false,"versjon":3,"deltakerFornavn":"Konge","deltakerEtternavn":"Syndebukk","deltakerTlf":"12121212","bedriftNavn":"MAURA OG KOLBU REGNSKAP","arbeidsgiverFornavn":"For","arbeidsgiverEtternavn":"Navn","arbeidsgiverTlf":"12121212","veilederFornavn":"Kontakt","veilederEtternavn":"Person","veilederTlf":"12121212","oppfolging":"Water spider things","tilrettelegging":"Water spider things","startDato":"2023-01-16","sluttDato":"2025-04-01","stillingprosent":100,"journalpostId":null,"arbeidsoppgaver":"Spindler i vannet","stillingstittel":"Water Spider","stillingStyrk08":4322,"stillingKonseptId":259822,"antallDagerPerUke":5,"refusjonKontaktperson":null,"mentorFornavn":null,"mentorEtternavn":null,"mentorOppgaver":null,"mentorAntallTimer":null,"mentorTimelonn":null,"mentorTlf":null,"arbeidsgiverKontonummer":"91311592950","lonnstilskuddProsent":60,"manedslonn":4000,"feriepengesats":0.143,"arbeidsgiveravgift":0.106,"harFamilietilknytning":false,"familietilknytningForklaring":null,"feriepengerBelop":5720,"otpSats":0.07,"otpBelop":3200,"arbeidsgiveravgiftBelop":5186,"sumLonnsutgifter":54106,"sumLonnstilskudd":32464,"manedslonn100pst":54106,"sumLønnstilskuddRedusert":null,"datoForRedusertProsent":null,"stillingstype":"FAST","maal":[],"inkluderingstilskuddsutgift":[],"inkluderingstilskuddBegrunnelse":null,"inkluderingstilskuddTotalBeløp":0,"godkjentAvDeltaker":"2023-01-23T15:12:07.444992","godkjentTaushetserklæringAvMentor":null,"godkjentAvArbeidsgiver":"2023-01-23T15:12:07.444992","godkjentAvVeileder":"2023-01-23T15:12:07.444992","godkjentAvBeslutter":null,"avtaleInngått":"2023-01-23T15:12:07.444992","ikrafttredelsestidspunkt":"2023-01-30T11:39:22.029904056","godkjentAvNavIdent":"Z992785","godkjentAvBeslutterNavIdent":null,"enhetKostnadssted":null,"enhetsnavnKostnadssted":null,"godkjentPaVegneGrunn":{"ikkeBankId":false,"reservert":false,"digitalKompetanse":false,"arenaMigreringDeltaker":true},"godkjentPaVegneAv":true,"godkjentPaVegneAvArbeidsgiverGrunn":{"klarerIkkeGiFaTilgang":false,"vetIkkeHvemSomKanGiTilgang":false,"farIkkeTilgangPersonvern":false,"arenaMigreringArbeidsgiver":true},"godkjentPaVegneAvArbeidsgiver":true,"innholdType":"FORLENGE","utførtAv":"Z992785","utførtAvRolle":"VEILEDER"}';
        String json2 = '{"hendelseType":"AVTALE_FORLENGET","avtaleStatus":"GJENNOMFØRES","deltakerFnr":"07860198775","mentorFnr":null,"bedriftNr":"910825526","veilederNavIdent":"Z992785","tiltakstype":"VARIG_LONNSTILSKUDD","opprettetTidspunkt":"2023-01-23T15:08:53.014813","avtaleId":"d0abcf43-f240-442f-913b-8865521c40b3","avtaleNr":548,"sistEndret":"2023-01-30T10:39:24.029935206Z","annullertTidspunkt":null,"annullertGrunn":null,"slettemerket":false,"opprettetAvArbeidsgiver":false,"enhetGeografisk":"1860","enhetsnavnGeografisk":"NAV Lofoten","enhetOppfolging":"1860","enhetsnavnOppfolging":"NAV Lofoten","godkjentForEtterregistrering":false,"kvalifiseringsgruppe":"VARIG","formidlingsgruppe":"IARBS","tilskuddPeriode":[],"feilregistrert":false,"versjon":3,"deltakerFornavn":"Donald","deltakerEtternavn":"Duck","deltakerTlf":"12121212","bedriftNavn":"MAURA OG KOLBU REGNSKAP","arbeidsgiverFornavn":"For","arbeidsgiverEtternavn":"Navn","arbeidsgiverTlf":"12121212","veilederFornavn":"Kontakt","veilederEtternavn":"Person","veilederTlf":"12121212","oppfolging":"Water spider things","tilrettelegging":"Water spider things","startDato":"2023-01-15","sluttDato":"2025-04-01","stillingprosent":100,"journalpostId":null,"arbeidsoppgaver":"Spindler i vannet","stillingstittel":"Water Spider","stillingStyrk08":4322,"stillingKonseptId":259822,"antallDagerPerUke":5,"refusjonKontaktperson":null,"mentorFornavn":null,"mentorEtternavn":null,"mentorOppgaver":null,"mentorAntallTimer":null,"mentorTimelonn":null,"mentorTlf":null,"arbeidsgiverKontonummer":"91311592950","lonnstilskuddProsent":60,"manedslonn":4000,"feriepengesats":0.143,"arbeidsgiveravgift":0.106,"harFamilietilknytning":false,"familietilknytningForklaring":null,"feriepengerBelop":5720,"otpSats":0.07,"otpBelop":3200,"arbeidsgiveravgiftBelop":5186,"sumLonnsutgifter":54106,"sumLonnstilskudd":32464,"manedslonn100pst":54106,"sumLønnstilskuddRedusert":null,"datoForRedusertProsent":null,"stillingstype":"FAST","maal":[],"inkluderingstilskuddsutgift":[],"inkluderingstilskuddBegrunnelse":null,"inkluderingstilskuddTotalBeløp":0,"godkjentAvDeltaker":"2023-01-23T15:12:07.444992","godkjentTaushetserklæringAvMentor":null,"godkjentAvArbeidsgiver":"2023-01-23T15:12:07.444992","godkjentAvVeileder":"2023-01-23T15:12:07.444992","godkjentAvBeslutter":null,"avtaleInngått":"2023-01-23T15:12:07.444992","ikrafttredelsestidspunkt":"2023-01-30T11:39:22.029904056","godkjentAvNavIdent":"Z992785","godkjentAvBeslutterNavIdent":null,"enhetKostnadssted":null,"enhetsnavnKostnadssted":null,"godkjentPaVegneGrunn":{"ikkeBankId":false,"reservert":false,"digitalKompetanse":false,"arenaMigreringDeltaker":true},"godkjentPaVegneAv":true,"godkjentPaVegneAvArbeidsgiverGrunn":{"klarerIkkeGiFaTilgang":false,"vetIkkeHvemSomKanGiTilgang":false,"farIkkeTilgangPersonvern":false,"arenaMigreringArbeidsgiver":true},"godkjentPaVegneAvArbeidsgiver":true,"innholdType":"FORLENGE","utførtAv":"Z992785","utførtAvRolle":"VEILEDER"}';
        String json3 = '{"hendelseType":"AVTALE_FORLENGET","avtaleStatus":"MANGLER_GODKJENNING","deltakerFnr":"07860198775","mentorFnr":null,"bedriftNr":"910825526","veilederNavIdent":"Z992785","tiltakstype":"VARIG_LONNSTILSKUDD","opprettetTidspunkt":"2023-01-23T15:08:53.014813","avtaleId":"d0abcf43-f240-442f-913b-8865521c40b3","avtaleNr":548,"sistEndret":"2023-01-30T10:39:23.029935206Z","annullertTidspunkt":null,"annullertGrunn":null,"slettemerket":false,"opprettetAvArbeidsgiver":false,"enhetGeografisk":"1860","enhetsnavnGeografisk":"NAV Lofoten","enhetOppfolging":"1860","enhetsnavnOppfolging":"NAV Lofoten","godkjentForEtterregistrering":false,"kvalifiseringsgruppe":"VARIG","formidlingsgruppe":"IARBS","tilskuddPeriode":[],"feilregistrert":false,"versjon":3,"deltakerFornavn":"Konge","deltakerEtternavn":"Syndebukk","deltakerTlf":"12121212","bedriftNavn":"MAURA OG KOLBU REGNSKAP","arbeidsgiverFornavn":"For","arbeidsgiverEtternavn":"Navn","arbeidsgiverTlf":"12121212","veilederFornavn":"Kontakt","veilederEtternavn":"Person","veilederTlf":"12121212","oppfolging":"Water spider things","tilrettelegging":"Water spider things","startDato":"2023-01-16","sluttDato":"2025-04-01","stillingprosent":100,"journalpostId":null,"arbeidsoppgaver":"Spindler i vannet","stillingstittel":"Water Spider","stillingStyrk08":4322,"stillingKonseptId":259822,"antallDagerPerUke":5,"refusjonKontaktperson":null,"mentorFornavn":null,"mentorEtternavn":null,"mentorOppgaver":null,"mentorAntallTimer":null,"mentorTimelonn":null,"mentorTlf":null,"arbeidsgiverKontonummer":"91311592950","lonnstilskuddProsent":60,"manedslonn":4000,"feriepengesats":0.143,"arbeidsgiveravgift":0.106,"harFamilietilknytning":false,"familietilknytningForklaring":null,"feriepengerBelop":5720,"otpSats":0.07,"otpBelop":3200,"arbeidsgiveravgiftBelop":5186,"sumLonnsutgifter":54106,"sumLonnstilskudd":32464,"manedslonn100pst":54106,"sumLønnstilskuddRedusert":null,"datoForRedusertProsent":null,"stillingstype":"FAST","maal":[],"inkluderingstilskuddsutgift":[],"inkluderingstilskuddBegrunnelse":null,"inkluderingstilskuddTotalBeløp":0,"godkjentAvDeltaker":"2023-01-23T15:12:07.444992","godkjentTaushetserklæringAvMentor":null,"godkjentAvArbeidsgiver":"2023-01-23T15:12:07.444992","godkjentAvVeileder":"2023-01-23T15:12:07.444992","godkjentAvBeslutter":null,"avtaleInngått":"2023-01-23T15:12:07.444992","ikrafttredelsestidspunkt":"2023-01-30T11:39:22.029904056","godkjentAvNavIdent":"Z992785","godkjentAvBeslutterNavIdent":null,"enhetKostnadssted":null,"enhetsnavnKostnadssted":null,"godkjentPaVegneGrunn":{"ikkeBankId":false,"reservert":false,"digitalKompetanse":false,"arenaMigreringDeltaker":true},"godkjentPaVegneAv":true,"godkjentPaVegneAvArbeidsgiverGrunn":{"klarerIkkeGiFaTilgang":false,"vetIkkeHvemSomKanGiTilgang":false,"farIkkeTilgangPersonvern":false,"arenaMigreringArbeidsgiver":true},"godkjentPaVegneAvArbeidsgiver":true,"innholdType":"FORLENGE","utførtAv":"Z992785","utførtAvRolle":"VEILEDER"}';
        String encodedValue1 = EncodingUtil.base64Encode(Blob.valueOf(json1));
        String encodedValue2 = EncodingUtil.base64Encode(Blob.valueOf(json2));
        String encodedValue3 = EncodingUtil.base64Encode(Blob.valueOf(json3));

        List<KafkaMessage__c> messages = new List<KafkaMessage__c>();

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'arbeidsgiver.tiltak-avtale-hendelse';
        msg1.CRM_Key__c = 'd0abcf43-f240-442f-913b-8865521c40b3';
        msg1.CRM_Value__c = encodedValue1;
        messages.add(msg1);

        KafkaMessage__c msg2 = new KafkaMessage__c();
        msg2.CRM_Topic__c = 'arbeidsgiver.tiltak-avtale-hendelse';
        msg2.CRM_Key__c = 'd0abcf43-f240-442f-913b-8865521c40b3';
        msg2.CRM_Value__c = encodedValue2;
        messages.add(msg2);

        KafkaMessage__c msg3 = new KafkaMessage__c();
        msg3.CRM_Topic__c = 'arbeidsgiver.tiltak-avtale-hendelse';
        msg3.CRM_Key__c = 'd0abcf43-f240-442f-913b-8865521c40b3';
        msg3.CRM_Value__c = encodedValue3;
        messages.add(msg3);

        Test.StartTest();
        KafkaToiAvtaleHandler handler = new KafkaToiAvtaleHandler();
        handler.processMessages(messages);
        Test.StopTest();

        List<Contract__c> avtaler = [
            SELECT
                Id,
                RecordTypeId,
                TAG_StartDate__c,
                TAG_EndDate__c,
                ExternalId__c,
                TAG_EmployerContactPhone__c,
                TAG_Status__c,
                TAG_MeasureParticipant__c,
                TAG_EmployerContact__c,
                TAG_Mentor__c,
                TAG_ExternalURL__c,
                TAG_Category__c,
                TAG_InternalContact__c,
                OwnerId,
                TAG_Account__c,
                TAG_NAVUnit__c,
                KafkaId__c
            FROM Contract__c
        ];

        List<ArenaActivity__c> aktiviteter = [
            SELECT
                Id,
                DateFrom__c,
                DateTo__c,
                DateTimeRegistered__c,
                DateTimeFrom__c,
                Aktivitetsgruppekode__c,
                TAG_Source__c,
                AktivitetStatuskode__c,
                AktivitetsKode__c,
                KafkaId__c,
                NAVIdent__c,
                Account__c,
                NAV_Kontor__c,
                CaseWorker__c
            FROM ArenaActivity__c
        ];

        System.assertEquals(1, avtaler.size());
        System.assertEquals(acc.id, avtaler[0].TAG_Account__c);
        System.assertEquals('548', avtaler[0].ExternalId__c);
        System.assertEquals('GJENNOMFØRES', avtaler[0].TAG_Status__c);
        System.assertEquals('Donald Duck', avtaler[0].TAG_MeasureParticipant__c);
        System.assertEquals('VARIG_LONNSTILSKUDD', avtaler[0].TAG_Category__c);
        System.assertEquals(1, aktiviteter.size());
        System.assertEquals('2023-01-15', String.valueOf(aktiviteter[0].DateFrom__c));
        System.assertEquals('GJENNOMFØRES', aktiviteter[0].AktivitetStatuskode__c);
    }

    @isTest
    static void updateExistingRecords() {
        Id avtRecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Measure Agreement'].id;
        //Id permissionSetId = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Arbeidsgiver_base'].Id;

        Account acc = new Account(Name = 'Test Employer 1', INT_OrganizationNumber__c = '910825526');
        insert acc;

        List<Account> accounts = [SELECT Id FROM Account];

        System.assertEquals(1, accounts.size(), 'Acc Inserted');

        List<User> users = TestDataFactory.getUsers(2, 'Standard User', false, false);
        users[0].CRM_NAV_Ident__c = 'Z992800';
        users[1].FirstName = 'Systembruker';
        users[1].LastName = 'Asynkron Prosessering';
        insert users;

        System.assertEquals(2, users.size(), 'User Inserted');

        Group g = new Group(Name = 'Test queue', DeveloperName = 'queue_219', Type = 'Queue');
        insert g;

        List<Group> groups = [SELECT Id FROM Group WHERE Name = 'Test queue'];

        System.assertEquals(1, groups.size(), 'Group Inserted');

        System.runAs(new User(Id = UserInfo.getUserId())) {
            QueueSobject qs = new QueueSobject(QueueId = g.Id, SobjectType = 'Contract__c');
            insert qs;
        }

        NavUnit__c unit = new NavUnit__c(Name = 'NAV Test', INT_UnitNumber__c = '0219', CRM_QueueId__c = g.Id);
        insert unit;

        List<NavUnit__c> units = [SELECT Id, INT_UnitNumber__c FROM NavUnit__c WHERE Name = 'NAV Test'];

        System.assertEquals(1, units.size(), 'Unit Inserted');
        System.assertEquals('0219', units[0].INT_UnitNumber__c, 'Unit nr Inserted');

        // System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        //     PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment(PermissionSetId = permissionSetId, AssigneeId =  users[1].Id);
        //     insert permissionSetAssignment;
        // }
        // permissionSetAssignment.PermissionSetId = permissionSetId;
        // permissionSetAssignment.AssigneeId =  users[1].Id;

        Contract__c con = new Contract__c(
            KafkaId__c = 'd0abcf43-f240-442f-913b-8865521c40b3',
            TAG_Status__c = 'MANGLER_GODKJENNING',
            ExternalId__c = '548',
            RecordTypeId = avtRecordTypeId
        );
        insert con;

        List<Contract__c> contracts = [SELECT Id FROM Contract__c];
        System.assertEquals(1, contracts.size(), 'Contract Inserted');

        ArenaActivity__c act = new ArenaActivity__c(
            KafkaId__c = 'd0abcf43-f240-442f-913b-8865521c40b3',
            AktivitetStatuskode__c = 'MANGLER_GODKJENNING'
        );
        insert act;

        List<ArenaActivity__c> aa = [SELECT Id FROM ArenaActivity__c];
        System.assertEquals(1, aa.size(), 'Arena Activity Inserted');

        String json1 = '{"hendelseType":"AVTALE_FORLENGET","avtaleStatus":"KLAR_FOR_OPPSTART","deltakerFnr":"07860198775","mentorFnr":null,"bedriftNr":"910825526","veilederNavIdent":"Z992785","tiltakstype":"VARIG_LONNSTILSKUDD","opprettetTidspunkt":"2023-01-23T15:08:53.014813","avtaleId":"d0abcf43-f240-442f-913b-8865521c40b3","avtaleNr":548,"sistEndret":"2023-01-30T10:39:22.029935206Z","annullertTidspunkt":null,"annullertGrunn":null,"slettemerket":false,"opprettetAvArbeidsgiver":false,"enhetGeografisk":"1860","enhetsnavnGeografisk":"NAV Lofoten","enhetOppfolging":"0219","enhetsnavnOppfolging":"NAV Lofoten","godkjentForEtterregistrering":false,"kvalifiseringsgruppe":"VARIG","formidlingsgruppe":"IARBS","tilskuddPeriode":[],"feilregistrert":false,"versjon":3,"deltakerFornavn":"Konge","deltakerEtternavn":"Syndebukk","deltakerTlf":"12121212","bedriftNavn":"MAURA OG KOLBU REGNSKAP","arbeidsgiverFornavn":"For","arbeidsgiverEtternavn":"Navn","arbeidsgiverTlf":"12121212","veilederFornavn":"Kontakt","veilederEtternavn":"Person","veilederTlf":"12121212","oppfolging":"Water spider things","tilrettelegging":"Water spider things","startDato":"2023-01-16","sluttDato":"2025-04-01","stillingprosent":100,"journalpostId":null,"arbeidsoppgaver":"Spindler i vannet","stillingstittel":"Water Spider","stillingStyrk08":4322,"stillingKonseptId":259822,"antallDagerPerUke":5,"refusjonKontaktperson":null,"mentorFornavn":null,"mentorEtternavn":null,"mentorOppgaver":null,"mentorAntallTimer":null,"mentorTimelonn":null,"mentorTlf":null,"arbeidsgiverKontonummer":"91311592950","lonnstilskuddProsent":60,"manedslonn":4000,"feriepengesats":0.143,"arbeidsgiveravgift":0.106,"harFamilietilknytning":false,"familietilknytningForklaring":null,"feriepengerBelop":5720,"otpSats":0.07,"otpBelop":3200,"arbeidsgiveravgiftBelop":5186,"sumLonnsutgifter":54106,"sumLonnstilskudd":32464,"manedslonn100pst":54106,"sumLønnstilskuddRedusert":null,"datoForRedusertProsent":null,"stillingstype":"FAST","maal":[],"inkluderingstilskuddsutgift":[],"inkluderingstilskuddBegrunnelse":null,"inkluderingstilskuddTotalBeløp":0,"godkjentAvDeltaker":"2023-01-23T15:12:07.444992","godkjentTaushetserklæringAvMentor":null,"godkjentAvArbeidsgiver":"2023-01-23T15:12:07.444992","godkjentAvVeileder":"2023-01-23T15:12:07.444992","godkjentAvBeslutter":null,"avtaleInngått":"2023-01-23T15:12:07.444992","ikrafttredelsestidspunkt":"2023-01-30T11:39:22.029904056","godkjentAvNavIdent":"Z992785","godkjentAvBeslutterNavIdent":null,"enhetKostnadssted":null,"enhetsnavnKostnadssted":null,"godkjentPaVegneGrunn":{"ikkeBankId":false,"reservert":false,"digitalKompetanse":false,"arenaMigreringDeltaker":true},"godkjentPaVegneAv":true,"godkjentPaVegneAvArbeidsgiverGrunn":{"klarerIkkeGiFaTilgang":false,"vetIkkeHvemSomKanGiTilgang":false,"farIkkeTilgangPersonvern":false,"arenaMigreringArbeidsgiver":true},"godkjentPaVegneAvArbeidsgiver":true,"innholdType":"FORLENGE","utførtAv":"Z992785","utførtAvRolle":"VEILEDER"}';
        String encodedValue1 = EncodingUtil.base64Encode(Blob.valueOf(json1));

        List<KafkaMessage__c> messages = new List<KafkaMessage__c>();

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'arbeidsgiver.tiltak-avtale-hendelse';
        msg1.CRM_Key__c = 'd0abcf43-f240-442f-913b-8865521c40b3';
        msg1.CRM_Value__c = encodedValue1;
        messages.add(msg1);

        Test.StartTest();
        KafkaToiAvtaleHandler handler = new KafkaToiAvtaleHandler();
        handler.processMessages(messages);
        Test.StopTest();

        List<Contract__c> avtaler = [
            SELECT
                Id,
                RecordTypeId,
                TAG_StartDate__c,
                TAG_EndDate__c,
                ExternalId__c,
                TAG_EmployerContactPhone__c,
                TAG_Status__c,
                TAG_MeasureParticipant__c,
                TAG_EmployerContact__c,
                TAG_Mentor__c,
                TAG_ExternalURL__c,
                TAG_Category__c,
                TAG_InternalContact__c,
                OwnerId,
                TAG_Account__c,
                TAG_NAVUnit__c,
                KafkaId__c
            FROM Contract__c
        ];

        List<ArenaActivity__c> aktiviteter = [
            SELECT
                Id,
                DateFrom__c,
                DateTo__c,
                DateTimeRegistered__c,
                DateTimeFrom__c,
                Aktivitetsgruppekode__c,
                TAG_Source__c,
                AktivitetStatuskode__c,
                AktivitetsKode__c,
                KafkaId__c,
                NAVIdent__c,
                Account__c,
                NAV_Kontor__c,
                CaseWorker__c
            FROM ArenaActivity__c
        ];

        System.assertEquals(1, avtaler.size());
        System.assertEquals(acc.id, avtaler[0].TAG_Account__c);
        System.assertEquals('548', avtaler[0].ExternalId__c);
        System.assertEquals('KLAR_FOR_OPPSTART', avtaler[0].TAG_Status__c);
        System.assertEquals('Konge Syndebukk', avtaler[0].TAG_MeasureParticipant__c);
        System.assertEquals('VARIG_LONNSTILSKUDD', avtaler[0].TAG_Category__c);
        System.assertEquals(1, aktiviteter.size());
        System.assertEquals('2023-01-16', String.valueOf(aktiviteter[0].DateFrom__c));
        System.assertEquals('KLAR_FOR_OPPSTART', aktiviteter[0].AktivitetStatuskode__c);
    }

    @isTest
    static void inactiveUserSysAsynkron() {
        Account acc = new Account(Name = 'Test Employer 1', INT_OrganizationNumber__c = '910825526');
        insert acc;

        List<Account> accounts = [SELECT Id FROM Account];

        System.assertEquals(1, accounts.size(), 'Acc Inserted');

        List<User> users = TestDataFactory.getUsers(2, 'Standard User', false, false);
        users[0].CRM_NAV_Ident__c = 'Z992800';
        users[0].IsActive = false;
        users[1].FirstName = 'Systembruker';
        users[1].LastName = 'Asynkron Prosessering';
        insert users;

        System.assertEquals(2, users.size(), 'User Inserted');

        Group g = new Group(Name = 'Test queue', DeveloperName = 'queue_219', Type = 'Queue');
        insert g;

        List<Group> groups = [SELECT Id FROM Group WHERE Name = 'Test queue'];

        System.assertEquals(1, groups.size(), 'Group Inserted');

        System.runAs(new User(Id = UserInfo.getUserId())) {
            QueueSobject qs = new QueueSobject(QueueId = g.Id, SobjectType = 'Contract__c');
            insert qs;
        }

        NavUnit__c unit = new NavUnit__c(Name = 'NAV Test', INT_UnitNumber__c = '0220', CRM_QueueId__c = g.Id);
        insert unit;

        List<NavUnit__c> units = [SELECT Id, INT_UnitNumber__c FROM NavUnit__c WHERE Name = 'NAV Test'];

        System.assertEquals(1, units.size(), 'Unit Inserted');
        System.assertEquals('0220', units[0].INT_UnitNumber__c, 'Unit nr Inserted');

        String json = '{"hendelseType":"STILLINGSBESKRIVELSE_ENDRET","avtaleStatus":"GJENNOMFØRES","deltakerFnr":"02129623805","mentorFnr":null,"bedriftNr":"910825526","veilederNavIdent":"Z992800","tiltakstype":"MIDLERTIDIG_LONNSTILSKUDD","opprettetTidspunkt":"2022-05-23T10:27:13.626211","avtaleId":"c9d8fe1e-c4d2-499e-bd16-af3a88b1e734","avtaleNr":397,"sistEndret":"2022-10-26T09:54:34.265048609Z","annullertTidspunkt":null,"annullertGrunn":null,"slettemerket":false,"opprettetAvArbeidsgiver":false,"enhetGeografisk":"0805","enhetsnavnGeografisk":"NAV Porsgrunn","enhetOppfolging":"0219","enhetsnavnOppfolging":"NAV Bærum","godkjentForEtterregistrering":true,"kvalifiseringsgruppe":"BFORM","formidlingsgruppe":"ARBS","tilskuddPeriode":[],"feilregistrert":false,"versjon":5,"deltakerFornavn":"Overfølsom","deltakerEtternavn":"Klovn","deltakerTlf":"12345676","bedriftNavn":"GAMLE FREDRIKSTAD OG RAMNES REGNSKA P","arbeidsgiverFornavn":"Dolly","arbeidsgiverEtternavn":"Duck","arbeidsgiverTlf":"12345678","veilederFornavn":"Onkel","veilederEtternavn":"Donald","veilederTlf":"12345678","oppfolging":"rtretyrteyrtey","tilrettelegging":"fdghdfghdfghfdgh","startDato":"2022-01-01","sluttDato":"2023-01-01","stillingprosent":100,"journalpostId":null,"arbeidsoppgaver":"trrtyrtrtytreyccxzc","stillingstittel":"Bussrengjører","stillingStyrk08":9122,"stillingKonseptId":168963,"antallDagerPerUke":5,"refusjonKontaktperson":null,"mentorFornavn":null,"mentorEtternavn":null,"mentorOppgaver":null,"mentorAntallTimer":null,"mentorTimelonn":null,"mentorTlf":null,"arbeidsgiverKontonummer":"91311592950","lonnstilskuddProsent":40,"manedslonn":20000,"feriepengesats":0.143,"arbeidsgiveravgift":0.106,"harFamilietilknytning":false,"familietilknytningForklaring":null,"feriepengerBelop":2860,"otpSats":0.1,"otpBelop":2286,"arbeidsgiveravgiftBelop":2665,"sumLonnsutgifter":27811,"sumLonnstilskudd":11124,"manedslonn100pst":27811,"sumLønnstilskuddRedusert":8343,"datoForRedusertProsent":"2022-07-01","stillingstype":"FAST","maal":[],"inkluderingstilskuddsutgift":[],"inkluderingstilskuddBegrunnelse":null,"inkluderingstilskuddTotalBeløp":0,"godkjentAvDeltaker":"2022-05-23T10:31:49.922613","godkjentTaushetserklæringAvMentor":null,"godkjentAvArbeidsgiver":"2022-05-23T10:31:18.693921","godkjentAvVeileder":"2022-05-23T10:31:49.922613","godkjentAvBeslutter":null,"avtaleInngått":"2022-05-23T10:31:49.922613","ikrafttredelsestidspunkt":"2022-10-26T11:54:34.265009244","godkjentAvNavIdent":"Z992800","godkjentAvBeslutterNavIdent":null,"enhetKostnadssted":null,"enhetsnavnKostnadssted":null,"godkjentPaVegneGrunn":{"ikkeBankId":true,"reservert":false,"digitalKompetanse":false,"arenaMigreringDeltaker":true},"godkjentPaVegneAv":true,"godkjentPaVegneAvArbeidsgiverGrunn":{"klarerIkkeGiFaTilgang":false,"vetIkkeHvemSomKanGiTilgang":false,"farIkkeTilgangPersonvern":false,"arenaMigreringArbeidsgiver":true},"godkjentPaVegneAvArbeidsgiver":false,"innholdType":"ENDRE_STILLING","utførtAv":"Z992800"}';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(json));

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'arbeidsgiver.tiltak-avtale-hendelse';
        msg1.CRM_Key__c = 'c9d8fe1e-c4d2-499e-bd16-af3a88b1e734';
        msg1.CRM_Value__c = encodedValue;

        Test.StartTest();
        KafkaToiAvtaleHandler handler = new KafkaToiAvtaleHandler();
        handler.processMessages(new List<KafkaMessage__c>{ msg1 });
        Test.StopTest();

        List<Contract__c> avtaler = [
            SELECT
                Id,
                RecordTypeId,
                TAG_StartDate__c,
                TAG_EndDate__c,
                ExternalId__c,
                TAG_EmployerContactPhone__c,
                TAG_Status__c,
                TAG_MeasureParticipant__c,
                TAG_EmployerContact__c,
                TAG_Mentor__c,
                TAG_ExternalURL__c,
                TAG_Category__c,
                TAG_InternalContact__c,
                OwnerId,
                TAG_Account__c,
                TAG_NAVUnit__c,
                KafkaId__c
            FROM Contract__c
        ];

        List<ArenaActivity__c> aktiviteter = [
            SELECT
                Id,
                DateFrom__c,
                DateTo__c,
                DateTimeRegistered__c,
                DateTimeFrom__c,
                Aktivitetsgruppekode__c,
                TAG_Source__c,
                AktivitetStatuskode__c,
                AktivitetsKode__c,
                KafkaId__c,
                NAVIdent__c,
                Account__c,
                NAV_Kontor__c,
                CaseWorker__c
            FROM ArenaActivity__c
        ];

        System.assertEquals(1, avtaler.size());
        System.assertEquals(acc.id, avtaler[0].TAG_Account__c);
        System.assertEquals(msg1.CRM_Key__c, avtaler[0].KafkaId__c);
        System.assertEquals('2022-01-01', String.valueOf(avtaler[0].TAG_StartDate__c));
        System.assertEquals('2023-01-01', String.valueOf(avtaler[0].TAG_EndDate__c));
        System.assertEquals('397', avtaler[0].ExternalId__c);
        System.assertEquals('GJENNOMFØRES', avtaler[0].TAG_Status__c);
        System.assertEquals('Overfølsom Klovn', avtaler[0].TAG_MeasureParticipant__c);
        System.assertEquals('Dolly Duck', avtaler[0].TAG_EmployerContact__c);
        System.assertEquals('12345678', avtaler[0].TAG_EmployerContactPhone__c);
        System.assertEquals(null, avtaler[0].TAG_Mentor__c);
        System.assertEquals(null, avtaler[0].TAG_NAVUnit__c);
        System.assertEquals(
            'https://arbeidsgiver.nav.no/tiltaksgjennomforing/avtale/c9d8fe1e-c4d2-499e-bd16-af3a88b1e734?bedrift=910825526',
            avtaler[0].TAG_ExternalURL__c
        );
        System.assertEquals('MIDLERTIDIG_LONNSTILSKUDD', avtaler[0].TAG_Category__c);
        System.assertEquals(null, avtaler[0].TAG_InternalContact__c);
        System.assertEquals(users[1].id, avtaler[0].OwnerId);
        System.assertEquals(1, aktiviteter.size());
        System.assertEquals('GJENNOMFØRES', aktiviteter[0].AktivitetStatuskode__c);
        System.assertEquals('2022-01-01', String.valueOf(aktiviteter[0].DateFrom__c));
        System.assertEquals('2023-01-01', String.valueOf(aktiviteter[0].DateTo__c));
        System.assertEquals('TLTAK', aktiviteter[0].Aktivitetsgruppekode__c);
        System.assertEquals('Z992800', aktiviteter[0].NAVIdent__c);
        System.assertEquals(null, aktiviteter[0].CaseWorker__c);
        System.assertEquals(acc.id, aktiviteter[0].Account__c);
        System.assertEquals(null, aktiviteter[0].NAV_Kontor__c);
        System.assertEquals('Tiltaksløsning', aktiviteter[0].TAG_Source__c);
    }

    @isTest
    static void NAVUnitWithoutQueue() {
        Account acc = new Account(Name = 'Test Employer 1', INT_OrganizationNumber__c = '910825526');
        insert acc;

        List<Account> accounts = [SELECT Id FROM Account];

        System.assertEquals(1, accounts.size(), 'Acc Inserted');

        List<User> users = TestDataFactory.getUsers(2, 'Standard User', false, false);
        users[0].CRM_NAV_Ident__c = 'Z992800';
        users[0].IsActive = false;
        users[1].FirstName = 'Systembruker';
        users[1].LastName = 'Asynkron Prosessering';
        insert users;

        System.assertEquals(2, users.size(), 'User Inserted');

        Group g = new Group(Name = 'Test queue', DeveloperName = 'queue_219', Type = 'Queue');
        insert g;

        List<Group> groups = [SELECT Id FROM Group WHERE Name = 'Test queue'];

        System.assertEquals(1, groups.size(), 'Group Inserted');

        System.runAs(new User(Id = UserInfo.getUserId())) {
            QueueSobject qs = new QueueSobject(QueueId = g.Id, SobjectType = 'Contract__c');
            insert qs;
        }

        NavUnit__c unit = new NavUnit__c(Name = 'NAV Test', INT_UnitNumber__c = '0220');
        insert unit;

        List<NavUnit__c> units = [SELECT Id, INT_UnitNumber__c FROM NavUnit__c WHERE Name = 'NAV Test'];

        System.assertEquals(1, units.size(), 'Unit Inserted');
        System.assertEquals('0220', units[0].INT_UnitNumber__c, 'Unit nr Inserted');

        String json = '{"hendelseType":"STILLINGSBESKRIVELSE_ENDRET","avtaleStatus":"GJENNOMFØRES","deltakerFnr":"02129623805","mentorFnr":null,"bedriftNr":"910825526","veilederNavIdent":"Z992111","tiltakstype":"MIDLERTIDIG_LONNSTILSKUDD","opprettetTidspunkt":"2022-05-23T10:27:13.626211","avtaleId":"c9d8fe1e-c4d2-499e-bd16-af3a88b1e734","avtaleNr":397,"sistEndret":"2022-10-26T09:54:34.265048609Z","annullertTidspunkt":null,"annullertGrunn":null,"slettemerket":false,"opprettetAvArbeidsgiver":false,"enhetGeografisk":"0805","enhetsnavnGeografisk":"NAV Porsgrunn","enhetOppfolging":"0220","enhetsnavnOppfolging":"NAV Bærum","godkjentForEtterregistrering":true,"kvalifiseringsgruppe":"BFORM","formidlingsgruppe":"ARBS","tilskuddPeriode":[],"feilregistrert":false,"versjon":5,"deltakerFornavn":"Overfølsom","deltakerEtternavn":"Klovn","deltakerTlf":"12345676","bedriftNavn":"GAMLE FREDRIKSTAD OG RAMNES REGNSKA P","arbeidsgiverFornavn":"Dolly","arbeidsgiverEtternavn":"Duck","arbeidsgiverTlf":"12345678","veilederFornavn":"Onkel","veilederEtternavn":"Donald","veilederTlf":"12345678","oppfolging":"rtretyrteyrtey","tilrettelegging":"fdghdfghdfghfdgh","startDato":"2022-01-01","sluttDato":"2023-01-01","stillingprosent":100,"journalpostId":null,"arbeidsoppgaver":"trrtyrtrtytreyccxzc","stillingstittel":"Bussrengjører","stillingStyrk08":9122,"stillingKonseptId":168963,"antallDagerPerUke":5,"refusjonKontaktperson":null,"mentorFornavn":null,"mentorEtternavn":null,"mentorOppgaver":null,"mentorAntallTimer":null,"mentorTimelonn":null,"mentorTlf":null,"arbeidsgiverKontonummer":"91311592950","lonnstilskuddProsent":40,"manedslonn":20000,"feriepengesats":0.143,"arbeidsgiveravgift":0.106,"harFamilietilknytning":false,"familietilknytningForklaring":null,"feriepengerBelop":2860,"otpSats":0.1,"otpBelop":2286,"arbeidsgiveravgiftBelop":2665,"sumLonnsutgifter":27811,"sumLonnstilskudd":11124,"manedslonn100pst":27811,"sumLønnstilskuddRedusert":8343,"datoForRedusertProsent":"2022-07-01","stillingstype":"FAST","maal":[],"inkluderingstilskuddsutgift":[],"inkluderingstilskuddBegrunnelse":null,"inkluderingstilskuddTotalBeløp":0,"godkjentAvDeltaker":"2022-05-23T10:31:49.922613","godkjentTaushetserklæringAvMentor":null,"godkjentAvArbeidsgiver":"2022-05-23T10:31:18.693921","godkjentAvVeileder":"2022-05-23T10:31:49.922613","godkjentAvBeslutter":null,"avtaleInngått":"2022-05-23T10:31:49.922613","ikrafttredelsestidspunkt":"2022-10-26T11:54:34.265009244","godkjentAvNavIdent":"Z992800","godkjentAvBeslutterNavIdent":null,"enhetKostnadssted":null,"enhetsnavnKostnadssted":null,"godkjentPaVegneGrunn":{"ikkeBankId":true,"reservert":false,"digitalKompetanse":false,"arenaMigreringDeltaker":true},"godkjentPaVegneAv":true,"godkjentPaVegneAvArbeidsgiverGrunn":{"klarerIkkeGiFaTilgang":false,"vetIkkeHvemSomKanGiTilgang":false,"farIkkeTilgangPersonvern":false,"arenaMigreringArbeidsgiver":true},"godkjentPaVegneAvArbeidsgiver":false,"innholdType":"ENDRE_STILLING","utførtAv":"Z992800"}';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(json));

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'arbeidsgiver.tiltak-avtale-hendelse';
        msg1.CRM_Key__c = 'c9d8fe1e-c4d2-499e-bd16-af3a88b1e734';
        msg1.CRM_Value__c = encodedValue;

        Test.StartTest();
        KafkaToiAvtaleHandler handler = new KafkaToiAvtaleHandler();
        handler.processMessages(new List<KafkaMessage__c>{ msg1 });
        Test.StopTest();

        List<Contract__c> avtaler = [
            SELECT
                Id,
                RecordTypeId,
                TAG_StartDate__c,
                TAG_EndDate__c,
                ExternalId__c,
                TAG_EmployerContactPhone__c,
                TAG_Status__c,
                TAG_MeasureParticipant__c,
                TAG_EmployerContact__c,
                TAG_Mentor__c,
                TAG_ExternalURL__c,
                TAG_Category__c,
                TAG_InternalContact__c,
                OwnerId,
                TAG_Account__c,
                TAG_NAVUnit__c,
                KafkaId__c
            FROM Contract__c
        ];

        List<ArenaActivity__c> aktiviteter = [
            SELECT
                Id,
                DateFrom__c,
                DateTo__c,
                DateTimeRegistered__c,
                DateTimeFrom__c,
                Aktivitetsgruppekode__c,
                TAG_Source__c,
                AktivitetStatuskode__c,
                AktivitetsKode__c,
                KafkaId__c,
                NAVIdent__c,
                Account__c,
                NAV_Kontor__c,
                CaseWorker__c
            FROM ArenaActivity__c
        ];

        System.assertEquals(1, avtaler.size());
        System.assertEquals(acc.id, avtaler[0].TAG_Account__c);
        System.assertEquals(users[1].id, avtaler[0].OwnerId);
        System.assertEquals(1, aktiviteter.size());
    }
    @isTest
    static void dateException() {
        Account acc = new Account(Name = 'Test Employer 1', INT_OrganizationNumber__c = '910825526');
        insert acc;

        List<Account> accounts = [SELECT Id FROM Account];

        System.assertEquals(1, accounts.size(), 'Acc Inserted');

        List<User> users = TestDataFactory.getUsers(1, 'Standard User', false, false);
        users[0].CRM_NAV_Ident__c = 'Z992800';
        insert users;

        System.assertEquals(1, users.size(), 'User Inserted');

        Group g = new Group(Name = 'Test queue', DeveloperName = 'queue_219', Type = 'Queue');
        insert g;

        List<Group> groups = [SELECT Id FROM Group WHERE Name = 'Test queue'];

        System.assertEquals(1, groups.size(), 'Group Inserted');

        System.runAs(new User(Id = UserInfo.getUserId())) {
            QueueSobject qs = new QueueSobject(QueueId = g.Id, SobjectType = 'Contract__c');
            insert qs;
        }

        NavUnit__c unit = new NavUnit__c(Name = 'NAV Test', INT_UnitNumber__c = '0219', CRM_QueueId__c = g.Id);
        insert unit;

        List<NavUnit__c> units = [SELECT Id, INT_UnitNumber__c FROM NavUnit__c WHERE Name = 'NAV Test'];

        System.assertEquals(1, units.size(), 'Unit Inserted');
        System.assertEquals('0219', units[0].INT_UnitNumber__c, 'Unit nr Inserted');

        String json = '{"hendelseType":"STILLINGSBESKRIVELSE_ENDRET","avtaleStatus":"GJENNOMFØRES","deltakerFnr":"02129623805","mentorFnr":null,"bedriftNr":"910825526","veilederNavIdent":"Z992800","tiltakstype":"MIDLERTIDIG_LONNSTILSKUDD","opprettetTidspunkt":"2022-05-23T10:27:13.626211","avtaleId":"c9d8fe1e-c4d2-499e-bd16-af3a88b1e734","avtaleNr":397,"sistEndret":"2022-10-26T09:54:34.265048609Z","annullertTidspunkt":null,"annullertGrunn":null,"slettemerket":false,"opprettetAvArbeidsgiver":false,"enhetGeografisk":"0805","enhetsnavnGeografisk":"NAV Porsgrunn","enhetOppfolging":"0219","enhetsnavnOppfolging":"NAV Bærum","godkjentForEtterregistrering":true,"kvalifiseringsgruppe":"BFORM","formidlingsgruppe":"ARBS","tilskuddPeriode":[],"feilregistrert":false,"versjon":5,"deltakerFornavn":"Overfølsom","deltakerEtternavn":"Klovn","deltakerTlf":"12345676","bedriftNavn":"GAMLE FREDRIKSTAD OG RAMNES REGNSKA P","arbeidsgiverFornavn":"Dolly","arbeidsgiverEtternavn":"Duck","arbeidsgiverTlf":"12345678","veilederFornavn":"Onkel","veilederEtternavn":"Donald","veilederTlf":"12345678","oppfolging":"rtretyrteyrtey","tilrettelegging":"fdghdfghdfghfdgh","startDato":"2022-01-01","sluttDato":"9999-01-01","stillingprosent":100,"journalpostId":null,"arbeidsoppgaver":"trrtyrtrtytreyccxzc","stillingstittel":"Bussrengjører","stillingStyrk08":9122,"stillingKonseptId":168963,"antallDagerPerUke":5,"refusjonKontaktperson":null,"mentorFornavn":null,"mentorEtternavn":null,"mentorOppgaver":null,"mentorAntallTimer":null,"mentorTimelonn":null,"mentorTlf":null,"arbeidsgiverKontonummer":"91311592950","lonnstilskuddProsent":40,"manedslonn":20000,"feriepengesats":0.143,"arbeidsgiveravgift":0.106,"harFamilietilknytning":false,"familietilknytningForklaring":null,"feriepengerBelop":2860,"otpSats":0.1,"otpBelop":2286,"arbeidsgiveravgiftBelop":2665,"sumLonnsutgifter":27811,"sumLonnstilskudd":11124,"manedslonn100pst":27811,"sumLønnstilskuddRedusert":8343,"datoForRedusertProsent":"2022-07-01","stillingstype":"FAST","maal":[],"inkluderingstilskuddsutgift":[],"inkluderingstilskuddBegrunnelse":null,"inkluderingstilskuddTotalBeløp":0,"godkjentAvDeltaker":"2022-05-23T10:31:49.922613","godkjentTaushetserklæringAvMentor":null,"godkjentAvArbeidsgiver":"2022-05-23T10:31:18.693921","godkjentAvVeileder":"2022-05-23T10:31:49.922613","godkjentAvBeslutter":null,"avtaleInngått":"2022-05-23T10:31:49.922613","ikrafttredelsestidspunkt":"2022-10-26T11:54:34.265009244","godkjentAvNavIdent":"Z992800","godkjentAvBeslutterNavIdent":null,"enhetKostnadssted":null,"enhetsnavnKostnadssted":null,"godkjentPaVegneGrunn":{"ikkeBankId":true,"reservert":false,"digitalKompetanse":false,"arenaMigreringDeltaker":true},"godkjentPaVegneAv":true,"godkjentPaVegneAvArbeidsgiverGrunn":{"klarerIkkeGiFaTilgang":false,"vetIkkeHvemSomKanGiTilgang":false,"farIkkeTilgangPersonvern":false,"arenaMigreringArbeidsgiver":true},"godkjentPaVegneAvArbeidsgiver":false,"innholdType":"ENDRE_STILLING","utførtAv":"Z992800"}';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(json));

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'arbeidsgiver.tiltak-avtale-hendelse';
        msg1.CRM_Key__c = 'c9d8fe1e-c4d2-499e-bd16-af3a88b1e734';
        msg1.CRM_Value__c = encodedValue;

        Test.StartTest();
        KafkaToiAvtaleHandler handler = new KafkaToiAvtaleHandler();
        handler.processMessages(new List<KafkaMessage__c>{ msg1 });
        Test.StopTest();

        List<Contract__c> avtaler = [
            SELECT
                Id,
                RecordTypeId,
                TAG_StartDate__c,
                TAG_EndDate__c,
                ExternalId__c,
                TAG_EmployerContactPhone__c,
                TAG_Status__c,
                TAG_MeasureParticipant__c,
                TAG_EmployerContact__c,
                TAG_Mentor__c,
                TAG_ExternalURL__c,
                TAG_Category__c,
                TAG_InternalContact__c,
                OwnerId,
                TAG_Account__c,
                TAG_NAVUnit__c,
                KafkaId__c
            FROM Contract__c
        ];

        List<ArenaActivity__c> aktiviteter = [
            SELECT
                Id,
                DateFrom__c,
                DateTo__c,
                DateTimeRegistered__c,
                DateTimeFrom__c,
                Aktivitetsgruppekode__c,
                TAG_Source__c,
                AktivitetStatuskode__c,
                AktivitetsKode__c,
                KafkaId__c,
                NAVIdent__c,
                Account__c,
                NAV_Kontor__c,
                CaseWorker__c
            FROM ArenaActivity__c
        ];

        System.assertEquals(1, avtaler.size());
        System.assertEquals(acc.id, avtaler[0].TAG_Account__c);
        System.assertEquals(msg1.CRM_Key__c, avtaler[0].KafkaId__c);
        System.assertEquals('2022-01-01', String.valueOf(avtaler[0].TAG_StartDate__c));
        //System.assertEquals(null, String.valueOf(avtaler[0].TAG_EndDate__c));
        System.assertEquals('397', avtaler[0].ExternalId__c);
        System.assertEquals('GJENNOMFØRES', avtaler[0].TAG_Status__c);
        System.assertEquals('Overfølsom Klovn', avtaler[0].TAG_MeasureParticipant__c);
        System.assertEquals('Dolly Duck', avtaler[0].TAG_EmployerContact__c);
        System.assertEquals('12345678', avtaler[0].TAG_EmployerContactPhone__c);
        System.assertEquals(null, avtaler[0].TAG_Mentor__c);
        System.assertEquals(
            'https://arbeidsgiver.nav.no/tiltaksgjennomforing/avtale/c9d8fe1e-c4d2-499e-bd16-af3a88b1e734?bedrift=910825526',
            avtaler[0].TAG_ExternalURL__c
        );
        System.assertEquals('MIDLERTIDIG_LONNSTILSKUDD', avtaler[0].TAG_Category__c);
        System.assertEquals(users[0].Id, avtaler[0].TAG_InternalContact__c);
        System.assertEquals(unit.Id, avtaler[0].TAG_NAVUnit__c);
        System.assertEquals(1, aktiviteter.size());
        System.assertEquals('GJENNOMFØRES', aktiviteter[0].AktivitetStatuskode__c);
        System.assertEquals('2022-01-01', String.valueOf(aktiviteter[0].DateFrom__c));
        System.assertEquals(null, String.valueOf(aktiviteter[0].DateTo__c));
        System.assertEquals('TLTAK', aktiviteter[0].Aktivitetsgruppekode__c);
        System.assertEquals('Z992800', aktiviteter[0].NAVIdent__c);
        System.assertEquals(users[0].Id, aktiviteter[0].CaseWorker__c);
        System.assertEquals(acc.id, aktiviteter[0].Account__c);
        System.assertEquals(unit.Id, aktiviteter[0].NAV_Kontor__c);
        System.assertEquals('Tiltaksløsning', aktiviteter[0].TAG_Source__c);
    }

    @isTest
    static void testWithMissingFields() {
        Account acc = new Account(Name = 'Test Employer 1', INT_OrganizationNumber__c = '910825526');
        insert acc;

        List<Account> accounts = [SELECT Id FROM Account];

        System.assertEquals(1, accounts.size(), 'Acc Inserted');

        List<User> users = TestDataFactory.getUsers(1, 'Standard User', false, false);
        users[0].CRM_NAV_Ident__c = 'Z992800';
        insert users;

        System.assertEquals(1, users.size(), 'User Inserted');

        Group g = new Group(Name = 'Test queue', DeveloperName = 'queue_219', Type = 'Queue');
        insert g;

        List<Group> groups = [SELECT Id FROM Group WHERE Name = 'Test queue'];

        System.assertEquals(1, groups.size(), 'Group Inserted');

        System.runAs(new User(Id = UserInfo.getUserId())) {
            QueueSobject qs = new QueueSobject(QueueId = g.Id, SobjectType = 'Contract__c');
            insert qs;
        }

        NavUnit__c unit = new NavUnit__c(Name = 'NAV Test', INT_UnitNumber__c = '0219', CRM_QueueId__c = g.Id);
        insert unit;

        List<NavUnit__c> units = [SELECT Id, INT_UnitNumber__c FROM NavUnit__c WHERE Name = 'NAV Test'];

        System.assertEquals(1, units.size(), 'Unit Inserted');
        System.assertEquals('0219', units[0].INT_UnitNumber__c, 'Unit nr Inserted');

        String json = '{"avtaleStatus":"GJENNOMFØRES","deltakerFnr":"02129623805","mentorFnr":null,"bedriftNr":"910825526","veilederNavIdent":"Z992800","tiltakstype":"MIDLERTIDIG_LONNSTILSKUDD","opprettetTidspunkt":"2022-05-23T10:27:13.626211","avtaleId":"c9d8fe1e-c4d2-499e-bd16-af3a88b1e734","avtaleNr":397,"sistEndret":"2022-10-26T09:54:34.265048609Z","annullertTidspunkt":null,"annullertGrunn":null,"slettemerket":false,"opprettetAvArbeidsgiver":false,"enhetGeografisk":"0805","enhetsnavnGeografisk":"NAV Porsgrunn","enhetOppfolging":"0219","enhetsnavnOppfolging":"NAV Bærum","godkjentForEtterregistrering":true,"kvalifiseringsgruppe":"BFORM","formidlingsgruppe":"ARBS","tilskuddPeriode":[],"feilregistrert":false,"versjon":5,"deltakerFornavn":"Overfølsom","deltakerEtternavn":"Klovn","deltakerTlf":"12345676","bedriftNavn":"GAMLE FREDRIKSTAD OG RAMNES REGNSKA P","arbeidsgiverFornavn":"Dolly","arbeidsgiverEtternavn":"Duck","arbeidsgiverTlf":"12345678","veilederFornavn":"Onkel","veilederEtternavn":"Donald","veilederTlf":"12345678","oppfolging":"rtretyrteyrtey","tilrettelegging":"fdghdfghdfghfdgh","startDato":"2022-01-01","sluttDato":"2023-01-01","stillingprosent":100,"journalpostId":null,"arbeidsoppgaver":"trrtyrtrtytreyccxzc","stillingstittel":"Bussrengjører","stillingStyrk08":9122,"stillingKonseptId":168963,"antallDagerPerUke":5,"refusjonKontaktperson":null,"mentorFornavn":null,"mentorEtternavn":null,"mentorOppgaver":null,"mentorAntallTimer":null,"mentorTimelonn":null,"mentorTlf":null,"arbeidsgiverKontonummer":"91311592950","lonnstilskuddProsent":40,"manedslonn":20000,"feriepengesats":0.143,"arbeidsgiveravgift":0.106,"harFamilietilknytning":false,"familietilknytningForklaring":null,"feriepengerBelop":2860,"otpSats":0.1,"otpBelop":2286,"arbeidsgiveravgiftBelop":2665,"sumLonnsutgifter":27811,"sumLonnstilskudd":11124,"manedslonn100pst":27811,"sumLønnstilskuddRedusert":8343,"datoForRedusertProsent":"2022-07-01","stillingstype":"FAST","maal":[],"inkluderingstilskuddsutgift":[],"inkluderingstilskuddBegrunnelse":null,"inkluderingstilskuddTotalBeløp":0,"godkjentAvDeltaker":"2022-05-23T10:31:49.922613","godkjentTaushetserklæringAvMentor":null,"godkjentAvArbeidsgiver":"2022-05-23T10:31:18.693921","godkjentAvVeileder":"2022-05-23T10:31:49.922613","godkjentAvBeslutter":null,"avtaleInngått":"2022-05-23T10:31:49.922613","ikrafttredelsestidspunkt":"2022-10-26T11:54:34.265009244","godkjentAvNavIdent":"Z992800","godkjentAvBeslutterNavIdent":null,"enhetKostnadssted":null,"enhetsnavnKostnadssted":null,"godkjentPaVegneGrunn":{"ikkeBankId":true,"reservert":false,"digitalKompetanse":false,"arenaMigreringDeltaker":true},"godkjentPaVegneAv":true,"godkjentPaVegneAvArbeidsgiverGrunn":{"klarerIkkeGiFaTilgang":false,"vetIkkeHvemSomKanGiTilgang":false,"farIkkeTilgangPersonvern":false,"arenaMigreringArbeidsgiver":true},"godkjentPaVegneAvArbeidsgiver":false,"utførtAv":"Z992800"}';
        String encodedValue = EncodingUtil.base64Encode(Blob.valueOf(json));

        KafkaMessage__c msg1 = new KafkaMessage__c();
        msg1.CRM_Topic__c = 'arbeidsgiver.tiltak-avtale-hendelse';
        msg1.CRM_Key__c = 'c9d8fe1e-c4d2-499e-bd16-af3a88b1e734';
        msg1.CRM_Value__c = encodedValue;

        Test.StartTest();
        KafkaToiAvtaleHandler handler = new KafkaToiAvtaleHandler();
        handler.processMessages(new List<KafkaMessage__c>{ msg1 });
        Test.StopTest();

        List<Contract__c> avtaler = [
            SELECT
                Id,
                RecordTypeId,
                TAG_StartDate__c,
                TAG_ContractId__c,
                TAG_ActionType__c,
                TAG_ContentType__c,
                TAG_EndDate__c,
                ExternalId__c,
                TAG_EmployerContactPhone__c,
                TAG_Status__c,
                TAG_MeasureParticipant__c,
                TAG_EmployerContact__c,
                TAG_Mentor__c,
                TAG_ExternalURL__c,
                TAG_Category__c,
                TAG_InternalContact__c,
                OwnerId,
                TAG_Account__c,
                TAG_NAVUnit__c,
                KafkaId__c
            FROM Contract__c
        ];

        System.assertEquals(1, avtaler.size());
        System.assertEquals(acc.id, avtaler[0].TAG_Account__c);
        System.assertEquals(msg1.CRM_Key__c, avtaler[0].KafkaId__c);
        System.assertEquals('2022-01-01', String.valueOf(avtaler[0].TAG_StartDate__c));
        System.assertEquals('2023-01-01', String.valueOf(avtaler[0].TAG_EndDate__c));
        System.assertEquals('397', avtaler[0].ExternalId__c);
        System.assertEquals('GJENNOMFØRES', avtaler[0].TAG_Status__c);
        System.assertEquals('Overfølsom Klovn', avtaler[0].TAG_MeasureParticipant__c);
        System.assertEquals('Dolly Duck', avtaler[0].TAG_EmployerContact__c);
        System.assertEquals('12345678', avtaler[0].TAG_EmployerContactPhone__c);
        System.assertEquals(null, avtaler[0].TAG_Mentor__c);
        System.assertEquals(
            'https://arbeidsgiver.nav.no/tiltaksgjennomforing/avtale/c9d8fe1e-c4d2-499e-bd16-af3a88b1e734?bedrift=910825526',
            avtaler[0].TAG_ExternalURL__c
        );
        System.assertEquals('MIDLERTIDIG_LONNSTILSKUDD', avtaler[0].TAG_Category__c);
        System.assertEquals(users[0].Id, avtaler[0].TAG_InternalContact__c);
        System.assertEquals(unit.Id, avtaler[0].TAG_NAVUnit__c);
        System.assertEquals(null, avtaler[0].TAG_ActionType__c);
        System.assertEquals(null, avtaler[0].TAG_ContentType__c);
        System.assertEquals('c9d8fe1e-c4d2-499e-bd16-af3a88b1e734', avtaler[0].TAG_ContractId__c);
    }
}
