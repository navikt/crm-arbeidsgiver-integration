public with sharing class SykefravaerLand implements IKafkaMessageParser{

    public String kategori;
    public String kode;
    public sistePubliserteKvartal sistePubliserteKvartal;
    public siste4Kvartal siste4Kvartal; 

//Integer er hele tall, mens double tar med desimaltall. 
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
        public Kvartaler Kvartaler;     
    }

    public class Kvartaler{
        public Integer arstall;
        public Integer kvartal;
       
    }
    
}