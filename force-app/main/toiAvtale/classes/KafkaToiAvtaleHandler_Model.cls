public class KafkaToiAvtaleHandler_Model {

    public String hendelseType { get; set; }
	public String avtaleStatus { get; set; }
	public String deltakerFnr { get; set; }
	public String mentorFnr { get; set; }
	public String bedriftNr { get; set; }
	public String veilederNavIdent { get; set; }
	public String tiltakstype { get; set; }
	public String opprettetTidspunkt { get; set; }
	public String id { get; set; }
	public String avtaleNr { get; set; }
	public String sistEndret { get; set; }
	public String annullertTidspunkt { get; set; }
	public String annullertGrunn { get; set; }
	public Boolean slettemerket { get; set; }
	public Boolean opprettetAvArbeidsgiver { get; set; }
	public String enhetGeografisk { get; set; }
	public String enhetsnavnGeografisk { get; set; }
	public String enhetOppfolging { get; set; }
	public String enhetsnavnOppfolging { get; set; }
	public Boolean godkjentForEtterregistrering { get; set; }
	public String kvalifiseringsgruppe { get; set; }
	public String formidlingsgruppe { get; set; }
	public List<String> tilskuddPeriode { get; set; }
	public Boolean feilregistrert { get; set; }
	public Integer versjon { get; set; }
	public String deltakerFornavn { get; set; }
	public String deltakerEtternavn { get; set; }
	public String deltakerTlf { get; set; }
	public String bedriftNavn { get; set; }
	public String arbeidsgiverFornavn { get; set; }
	public String arbeidsgiverEtternavn { get; set; }
	public String arbeidsgiverTlf { get; set; }
	public String veilederFornavn { get; set; }
	public String veilederEtternavn { get; set; }
	public String veilederTlf { get; set; }
	public String oppfolging { get; set; }
	public String tilrettelegging { get; set; }
	public String startDato { get; set; }
	public String sluttDato { get; set; }
	public Integer stillingprosent { get; set; }
	public String journalpostId { get; set; }
	public String arbeidsoppgaver { get; set; }
	public String stillingstittel { get; set; }
	public Integer stillingStyrk08 { get; set; }
	public Integer stillingKonseptId { get; set; }
	public Integer antallDagerPerUke { get; set; }
	public String refusjonKontaktperson { get; set; }
	public String mentorFornavn { get; set; }
	public String mentorEtternavn { get; set; }
	public String mentorOppgaver { get; set; }
	public String mentorAntallTimer { get; set; }
	public String mentorTimelonn { get; set; }
	public String mentorTlf { get; set; }
	public String arbeidsgiverKontonummer { get; set; }
	public Integer lonnstilskuddProsent { get; set; }
	public Integer manedslonn { get; set; }
	public Double feriepengesats { get; set; }
	public Double arbeidsgiveravgift { get; set; }
	public Boolean harFamilietilknytning { get; set; }
	public String familietilknytningForklaring { get; set; }
	public Integer feriepengerBelop { get; set; }
	public Double otpSats { get; set; }
	public Integer otpBelop { get; set; }
	public Integer arbeidsgiveravgiftBelop { get; set; }
	public Integer sumLonnsutgifter { get; set; }
	public Integer sumLonnstilskudd { get; set; }
	public Integer manedslonn100pst { get; set; }
	//public Integer sumLønnstilskuddRedusert { get; set; }
	public String datoForRedusertProsent { get; set; }
	public String stillingstype { get; set; }
	public List<String> maal { get; set; }
	public List<String> inkluderingstilskuddsutgift { get; set; }
	public String inkluderingstilskuddBegrunnelse { get; set; }
	//public Integer inkluderingstilskuddTotalBeløp { get; set; }
	public String godkjentAvDeltaker { get; set; }
	//public String godkjentTaushetserklæringAvMentor { get; set; }
	public String godkjentAvArbeidsgiver { get; set; }
	public String godkjentAvVeileder { get; set; }
	public String godkjentAvBeslutter { get; set; }
	//public String avtaleInngått { get; set; }
	public String ikrafttredelsestidspunkt { get; set; }
	public String godkjentAvNavIdent { get; set; }
	public String godkjentAvBeslutterNavIdent { get; set; }
	public String enhetKostnadssted { get; set; }
	public String enhetsnavnKostnadssted { get; set; }
	public GodkjentPaVegneGrunn godkjentPaVegneGrunn { get; set; }
	public Boolean godkjentPaVegneAv { get; set; }
	public String godkjentPaVegneAvArbeidsgiverGrunn { get; set; }
	public Boolean godkjentPaVegneAvArbeidsgiver { get; set; }
	public String innholdType { get; set; }
	//public String utførtAv { get; set; }

	public class GodkjentPaVegneGrunn {
		public Boolean ikkeBankId { get; set; }
		public Boolean reservert { get; set; }
		public Boolean digitalKompetanse { get; set; }
	}

    public String jsonPayload { get; set; }
    public String hash { get; set; }
    public String key { get; set; }

    public static KafkaToiAvtaleHandler_Model parse(String json, String key, String hash) {
        KafkaToiAvtaleHandler_Model model = (KafkaToiAvtaleHandler_Model) System.JSON.deserialize(
            json,
            KafkaToiAvtaleHandler_Model.class
        );
        model.jsonPayload = json;
        model.hash = hash;
        model.key = key;

        return model;
    }
}
