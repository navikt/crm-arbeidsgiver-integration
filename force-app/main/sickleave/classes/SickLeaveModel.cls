public with sharing class SickLeaveModel implements IKafkaMessageParser{
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

	public static SickLeaveModel parse(String json, String key, String hash){
    String formattedJSON = json.replaceAll('"årstall":', '"arstall":');
    SickLeaveModel model = (SickLeaveModel) System.JSON.deserialize(
        formattedJSON, 
        SickLeaveModel.class 
        );
        model.jsonPayload = json;
        model.hash = hash;
        model.key = key;

		return model;
	} 
}