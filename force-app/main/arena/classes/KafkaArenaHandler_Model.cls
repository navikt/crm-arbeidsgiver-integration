public with sharing class KafkaArenaHandler_Model {

	public Integer orgnrMorselskap { get; set; }
	public Integer bedriftsnr { get; set; }
	public String aktivitetStatuskode { get; set; }
	public String beskrivelse { get; set; }
	public String saksbehandler { get; set; }
	public String aktivitetskode { get; set; }
	public String fraDato { get; set; }
	public String tilDato { get; set; }
	public String regDato { get; set; }
	public String regUser { get; set; }
	public String aktivitetsgruppekode { get; set; }
	public String aktivitetstypebeskrivelse { get; set; }
	public String aktivitetstypenavn { get; set; }
	public String fornavn { get; set; }
	public String etternavn { get; set; }
	public String navIdent { get; set; }

	public static KafkaArenaHandler_Model parse( String json ) {
		return (KafkaArenaHandler_Model) System.JSON.deserialize( json, KafkaArenaHandler_Model.class );
	}
}