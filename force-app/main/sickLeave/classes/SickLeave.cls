 public with sharing class SickLeave {

    public String kategori;
    public String kode;
    public sistePubliserteKvartal sistePubliserteKvartal;
    public siste4Kvartal siste4Kvartal; 

    public class sistePubliserteKvartal{
        public Integer arstall;
        public Integer kvartal;
        public Double prosent;
        public Double tapteDagsverk;
        public Double muligeDagsverk;
        public Double antallPersoner;
        public Boolean erMaskert;
    }

    public class siste4Kvartal{
        public Double prosent;
        public Double tapteDagsverk;
        public Double muligeDagsverk;
        public Double antallPersoner;
        public Boolean erMaskert;
        public List<Kvartaler> kvartaler;     
    }

    public class Kvartaler{
        public Integer arstall;
        public Integer kvartal;
       
    }

    public String jsonPayload;
    public String hash;
    public String key;

	public static SickLeave parse(String JSON, String key//, String hash ){ fjerner denne for å få sickleavehelper linje 8 til å funke. 
    ){
    String formattedJSON = json.replaceAll('"årstall":', '"arstall":');
    SickLeave model = (SickLeave) System.JSON.deserialize(
        formattedJSON, 
        SickLeave.class
        );
        model.jsonPayload = json;
       // model.hash = hash; tipper denne må tilbake, men må da endre koden slik at den er riktig i parsinga. 
        model.key = key;

		return model;
	} 
} 