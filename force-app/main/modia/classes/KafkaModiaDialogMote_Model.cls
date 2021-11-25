public with sharing class KafkaModiaDialogMote_Model {
        public String dialogmoteUuid { get; set; }
        public Long dialogmoteTidspunkt { get; set; }
        public String statusEndringType { get; set; }
        public Long statusEndringTidspunkt { get; set; }
        public String personIdent { get; set; }
        public String virksomhetsnummer { get; set; }
        public String enhetNr { get; set; }
        public String navIdent { get; set; }
        public Long tilfelleStartdato { get; set; }
        public Boolean arbeidstaker { get; set; }
        public Boolean arbeidsgiver { get; set; }
        public Boolean sykmelder { get; set; }
    
        public String key { get; set; }
        public String hash { get; set; }
        public String jsonPayload { get; set; }
    
        public static KafkaModiaDialogMote_Model parse(String json, String key, String hash) {
            KafkaModiaDialogMote_Model model = (KafkaModiaDialogMote_Model) System.JSON.deserialize(json, KafkaModiaDialogMote_Model.class);
            
            model.key = key;
            model.hash = hash;
            model.jsonPayload = json;

            return model;
        }
    }
