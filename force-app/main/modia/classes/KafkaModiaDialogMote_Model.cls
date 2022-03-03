public with sharing class KafkaModiaDialogMote_Model implements IKafkaMessageParser {
    public String statusEndringTidspunkt { get; set; }
    public String dialogmoteTidspunkt { get; set; }
    public String statusEndringType { get; set; }
    public String virksomhetsnummer { get; set; }
    public String tilfelleStartdato { get; set; }
    public String dialogmoteUuid { get; set; }
    public String personIdent { get; set; }
    public String navIdent { get; set; }
    public String enhetNr { get; set; }

    public Boolean arbeidstaker { get; set; }
    public Boolean arbeidsgiver { get; set; }
    public Boolean sykmelder { get; set; }

    public String jsonPayload { get; set; }
    public String hash { get; set; }
    public String key { get; set; }

    public static KafkaModiaDialogMote_Model parse(String json, String key, String hash) {
        String formattedJSON = json.replaceAll('"dialogmoteTidspunkt": ', '"dialogmoteTidspunkt": "')
            .replaceAll('"statusEndringTidspunkt": ', '"statusEndringTidspunkt": "')
            .replaceAll('"tilfelleStartdato": ', '"tilfelleStartdato": "')
            .replaceAll('Z, ', 'Z",');

        KafkaModiaDialogMote_Model model = (KafkaModiaDialogMote_Model) System.JSON.deserialize(
            formattedJSON,
            KafkaModiaDialogMote_Model.class
        );
        model.jsonPayload = json;
        model.hash = hash;
        model.key = key;

        return model;
    }
}
