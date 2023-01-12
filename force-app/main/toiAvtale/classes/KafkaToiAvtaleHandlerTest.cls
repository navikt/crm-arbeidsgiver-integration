@isTest
public with sharing class KafkaToiAvtaleHandlerTest {
    @isTest
    static void processMessage() {
        Account acc = new Account(Name = 'Test Employer 1', INT_OrganizationNumber__c = '910825526');
        insert acc;

        List<Account> accounts = [
            SELECT Id
            FROM Account
        ];

        System.assertEquals(1, accounts.size(), 'Acc Inserted');

        List<User> users = TestDataFactory.getUsers(1, 'Standard User', false, false);
        users[0].CRM_NAV_Ident__c = 'Z992800';
        insert users;

        System.assertEquals(1, users.size(), 'User Inserted');

        Group g = new Group(Name = 'Test queue', DeveloperName = 'queue_219', Type = 'Queue');
        insert g;

        List<Group> groups = [
            SELECT Id
            FROM Group
            WHERE Name = 'Test queue'
        ];

        System.assertEquals(1, groups.size(), 'Group Inserted');

        NavUnit__c unit = new NavUnit__c(Name = 'NAV Test', INT_UnitNumber__c = '0219', CRM_QueueId__c = g.Id);
        insert unit;

        List<NavUnit__c> units = [
            SELECT Id, INT_UnitNumber__c
            FROM NavUnit__c
            WHERE Name = 'NAV Test'
        ];

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
            SELECT Id, RecordTypeId, TAG_StartDate__c, TAG_EndDate__c, ExternalId__c, TAG_Status__c, TAG_MeasureParticipant__c, TAG_EmployerContact__c, TAG_Mentor__c, TAG_ExternalURL__c, TAG_Category__c, TAG_InternalContact__c, OwnerId, TAG_Account__c, TAG_NAVUnit__c, KafkaHash__c, KafkaId__c
            FROM Contract__c
        ];

        System.assertEquals(1, avtaler.size());
        System.assertEquals(acc.id, avtaler[0].TAG_Account__c);
        System.assertEquals(msg1.CRM_Key__c, avtaler[0].KafkaId__c);
        System.assertEquals(msg1.CRM_Value__c, avtaler[0].KafkaHash__c);
        System.assertEquals('2022-01-01', String.valueOf(avtaler[0].TAG_StartDate__c));
        System.assertEquals('2023-01-01', String.valueOf(avtaler[0].TAG_EndDate__c));
        System.assertEquals('397', avtaler[0].ExternalId__c);
        System.assertEquals('GJENNOMFØRES', avtaler[0].TAG_Status__c);
        System.assertEquals('Overfølsom Klovn', avtaler[0].TAG_MeasureParticipant__c);
        System.assertEquals('Dolly Duck', avtaler[0].TAG_EmployerContact__c);
        System.assertEquals(null, avtaler[0].TAG_Mentor__c);
        System.assertEquals('https://arbeidsgiver.labs.nais.io/tiltaksgjennomforing/avtale/c9d8fe1e-c4d2-499e-bd16-af3a88b1e734?bedrift=910825526', avtaler[0].TAG_ExternalURL__c);
        System.assertEquals('MIDLERTIDIG_LONNSTILSKUDD', avtaler[0].TAG_Category__c);
        System.assertEquals(users[0].Id, avtaler[0].TAG_InternalContact__c);
        System.assertEquals(users[0].Id, avtaler[0].OwnerId);
        System.assertEquals(unit.Id, avtaler[0].TAG_NAVUnit__c);
    }
    @isTest
    static void missingUserMatch() {
        Account acc = new Account(Name = 'Test Employer 1', INT_OrganizationNumber__c = '910825526');
        insert acc;

        List<Account> accounts = [
            SELECT Id
            FROM Account
        ];

        System.assertEquals(1, accounts.size(), 'Acc Inserted');

        List<User> users = TestDataFactory.getUsers(1, 'Standard User', false, false);
        users[0].CRM_NAV_Ident__c = 'Z000000';
        insert users;

        System.assertEquals(1, users.size(), 'User Inserted');

        Group g = new Group(Name = 'Test queue', DeveloperName = 'queue_219', Type = 'Queue');
        insert g;

        List<Group> groups = [
            SELECT Id
            FROM Group
            WHERE Name = 'Test queue'
        ];

        System.assertEquals(1, groups.size(), 'Group Inserted');

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            QueueSobject qs = new QueueSobject(QueueId = g.Id, SobjectType = 'Contract__c');
                insert qs;
        }

        NavUnit__c unit = new NavUnit__c(Name = 'NAV Test', INT_UnitNumber__c = '0219', CRM_QueueId__c = g.Id);
        insert unit;

        List<NavUnit__c> units = [
            SELECT Id, INT_UnitNumber__c
            FROM NavUnit__c
            WHERE Name = 'NAV Test'
        ];

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
            SELECT Id, RecordTypeId, TAG_StartDate__c, TAG_EndDate__c, ExternalId__c, TAG_Status__c, TAG_MeasureParticipant__c, TAG_EmployerContact__c, TAG_Mentor__c, TAG_ExternalURL__c, TAG_Category__c, TAG_InternalContact__c, OwnerId, TAG_Account__c, TAG_NAVUnit__c, KafkaHash__c, KafkaId__c
            FROM Contract__c
        ];

        System.assertEquals(1, avtaler.size());
        System.assertEquals(acc.id, avtaler[0].TAG_Account__c);
        System.assertEquals(msg1.CRM_Key__c, avtaler[0].KafkaId__c);
        System.assertEquals(msg1.CRM_Value__c, avtaler[0].KafkaHash__c);
        System.assertEquals('2022-01-01', String.valueOf(avtaler[0].TAG_StartDate__c));
        System.assertEquals('2023-01-01', String.valueOf(avtaler[0].TAG_EndDate__c));
        System.assertEquals('397', avtaler[0].ExternalId__c);
        System.assertEquals('GJENNOMFØRES', avtaler[0].TAG_Status__c);
        System.assertEquals('Overfølsom Klovn', avtaler[0].TAG_MeasureParticipant__c);
        System.assertEquals('Dolly Duck', avtaler[0].TAG_EmployerContact__c);
        System.assertEquals(null, avtaler[0].TAG_Mentor__c);
        System.assertEquals('https://arbeidsgiver.labs.nais.io/tiltaksgjennomforing/avtale/c9d8fe1e-c4d2-499e-bd16-af3a88b1e734?bedrift=910825526', avtaler[0].TAG_ExternalURL__c);
        System.assertEquals('MIDLERTIDIG_LONNSTILSKUDD', avtaler[0].TAG_Category__c);
        System.assert(String.isBlank(avtaler[0].TAG_InternalContact__c));
        System.assertEquals(g.Id, avtaler[0].OwnerId);
        System.assertEquals(unit.Id, avtaler[0].TAG_NAVUnit__c);
    }

    @isTest
    static void processMessageWithMoreNulls() {
        Account acc = new Account(Name = 'Test Employer 1', INT_OrganizationNumber__c = '910825526');
        insert acc;

        List<Account> accounts = [
            SELECT Id
            FROM Account
        ];

        System.assertEquals(1, accounts.size(), 'Acc Inserted');

        List<User> users = TestDataFactory.getUsers(1, 'Standard User', false, false);
        users[0].CRM_NAV_Ident__c = 'Z992800';
        insert users;

        System.assertEquals(1, users.size(), 'User Inserted');

        Group g = new Group(Name = 'Test queue', DeveloperName = 'queue_219', Type = 'Queue');
        insert g;

        List<Group> groups = [
            SELECT Id
            FROM Group
            WHERE Name = 'Test queue'
        ];

        System.assertEquals(1, groups.size(), 'Group Inserted');

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            QueueSobject qs = new QueueSobject(QueueId = g.Id, SobjectType = 'Contract__c');
                insert qs;
        }

        NavUnit__c unit = new NavUnit__c(Name = 'NAV Test', INT_UnitNumber__c = '0219', CRM_QueueId__c = g.Id);
        insert unit;

        List<NavUnit__c> units = [
            SELECT Id, INT_UnitNumber__c
            FROM NavUnit__c
            WHERE Name = 'NAV Test'
        ];

        System.assertEquals(1, units.size(), 'Unit Inserted');
        System.assertEquals('0219', units[0].INT_UnitNumber__c, 'Unit nr Inserted');

        String json = '{"hendelseType":"STILLINGSBESKRIVELSE_ENDRET","avtaleStatus":"GJENNOMFØRES","deltakerFnr":"02129623805","mentorFnr":null,"bedriftNr":"910825526","veilederNavIdent":null,"tiltakstype":"MIDLERTIDIG_LONNSTILSKUDD","opprettetTidspunkt":"2022-05-23T10:27:13.626211","avtaleId":"c9d8fe1e-c4d2-499e-bd16-af3a88b1e734","avtaleNr":397,"sistEndret":"2022-10-26T09:54:34.265048609Z","annullertTidspunkt":null,"annullertGrunn":null,"slettemerket":false,"opprettetAvArbeidsgiver":false,"enhetGeografisk":"0805","enhetsnavnGeografisk":"NAV Porsgrunn","enhetOppfolging":"0219","enhetsnavnOppfolging":"NAV Bærum","godkjentForEtterregistrering":true,"kvalifiseringsgruppe":"BFORM","formidlingsgruppe":"ARBS","tilskuddPeriode":[],"feilregistrert":false,"versjon":5,"deltakerFornavn":"Overfølsom","deltakerEtternavn":"Klovn","deltakerTlf":"12345676","bedriftNavn":"GAMLE FREDRIKSTAD OG RAMNES REGNSKA P","arbeidsgiverFornavn":"Dolly","arbeidsgiverEtternavn":"Duck","arbeidsgiverTlf":"12345678","veilederFornavn":"Onkel","veilederEtternavn":"Donald","veilederTlf":"12345678","oppfolging":"rtretyrteyrtey","tilrettelegging":"fdghdfghdfghfdgh","startDato":"2022-01-01","sluttDato":null,"stillingprosent":100,"journalpostId":null,"arbeidsoppgaver":"trrtyrtrtytreyccxzc","stillingstittel":"Bussrengjører","stillingStyrk08":9122,"stillingKonseptId":168963,"antallDagerPerUke":5,"refusjonKontaktperson":null,"mentorFornavn":null,"mentorEtternavn":null,"mentorOppgaver":null,"mentorAntallTimer":null,"mentorTimelonn":null,"mentorTlf":null,"arbeidsgiverKontonummer":"91311592950","lonnstilskuddProsent":40,"manedslonn":20000,"feriepengesats":0.143,"arbeidsgiveravgift":0.106,"harFamilietilknytning":false,"familietilknytningForklaring":null,"feriepengerBelop":2860,"otpSats":0.1,"otpBelop":2286,"arbeidsgiveravgiftBelop":2665,"sumLonnsutgifter":27811,"sumLonnstilskudd":11124,"manedslonn100pst":27811,"sumLønnstilskuddRedusert":8343,"datoForRedusertProsent":"2022-07-01","stillingstype":"FAST","maal":[],"inkluderingstilskuddsutgift":[],"inkluderingstilskuddBegrunnelse":null,"inkluderingstilskuddTotalBeløp":0,"godkjentAvDeltaker":"2022-05-23T10:31:49.922613","godkjentTaushetserklæringAvMentor":null,"godkjentAvArbeidsgiver":"2022-05-23T10:31:18.693921","godkjentAvVeileder":"2022-05-23T10:31:49.922613","godkjentAvBeslutter":null,"avtaleInngått":"2022-05-23T10:31:49.922613","ikrafttredelsestidspunkt":"2022-10-26T11:54:34.265009244","godkjentAvNavIdent":"Z992800","godkjentAvBeslutterNavIdent":null,"enhetKostnadssted":null,"enhetsnavnKostnadssted":null,"godkjentPaVegneGrunn":{"ikkeBankId":true,"reservert":false,"digitalKompetanse":false},"godkjentPaVegneAv":true,"godkjentPaVegneAvArbeidsgiverGrunn":null,"godkjentPaVegneAvArbeidsgiver":false,"innholdType":"ENDRE_STILLING","utførtAv":"Z992800"}';
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
            SELECT Id, RecordTypeId, TAG_StartDate__c, TAG_EndDate__c, ExternalId__c, TAG_Status__c, TAG_MeasureParticipant__c, TAG_EmployerContact__c, TAG_Mentor__c, TAG_ExternalURL__c, TAG_Category__c, TAG_InternalContact__c, OwnerId, TAG_Account__c, TAG_NAVUnit__c, KafkaHash__c, KafkaId__c
            FROM Contract__c
        ];

        System.assertEquals(1, avtaler.size());
        System.assertEquals(acc.id, avtaler[0].TAG_Account__c);
        System.assertEquals(msg1.CRM_Key__c, avtaler[0].KafkaId__c);
        System.assertEquals(msg1.CRM_Value__c, avtaler[0].KafkaHash__c);
        System.assertEquals('2022-01-01', String.valueOf(avtaler[0].TAG_StartDate__c));
        System.assertEquals(null, String.valueOf(avtaler[0].TAG_EndDate__c));
        System.assertEquals('397', avtaler[0].ExternalId__c);
        System.assertEquals('GJENNOMFØRES', avtaler[0].TAG_Status__c);
        System.assertEquals('Overfølsom Klovn', avtaler[0].TAG_MeasureParticipant__c);
        System.assertEquals('Dolly Duck', avtaler[0].TAG_EmployerContact__c);
        System.assertEquals(null, avtaler[0].TAG_Mentor__c);
        System.assertEquals('https://arbeidsgiver.labs.nais.io/tiltaksgjennomforing/avtale/c9d8fe1e-c4d2-499e-bd16-af3a88b1e734?bedrift=910825526', avtaler[0].TAG_ExternalURL__c);
        System.assertEquals('MIDLERTIDIG_LONNSTILSKUDD', avtaler[0].TAG_Category__c);
        System.assert(String.isBlank(avtaler[0].TAG_InternalContact__c));
        System.assertEquals(g.Id, avtaler[0].OwnerId);
        System.assertEquals(unit.Id, avtaler[0].TAG_NAVUnit__c);
    }
}
