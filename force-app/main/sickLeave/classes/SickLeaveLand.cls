 public with sharing class SickLeaveLand {

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

	public static SickLeaveLand parse(String JSON, String key , String hash){
    String formattedJSON = json.replaceAll('"årstall":', '"arstall":');
    SickLeaveLand model = (SickLeaveLand) System.JSON.deserialize(
        formattedJSON, 
        SickLeaveLand.class
        );
        model.jsonPayload = json;
        model.hash = hash;
        model.key = key;

		return model;
	} 
} 