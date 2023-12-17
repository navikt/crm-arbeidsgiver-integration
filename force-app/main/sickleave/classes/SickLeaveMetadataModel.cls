public with sharing class SickLeaveMetadataModel implements IKafkaMessageParser{
    public String orgnr;
    public String arstall;
    public String kvartal;
    public String naring;
    public String naringskode;
    public String bransje;
    public String sektor;

    public String jsonPayload;
    public String hash;
    public String key;

	public static SickLeaveMetadataModel parse(String json, String key , String hash){
    SickLeaveMetadataModel model = (SickLeaveMetadataModel) System.JSON.deserialize(
        json, 
        SickLeaveMetadataModel.class 
        );
        model.jsonPayload = json;
        model.hash = hash;
        model.key = key;

		return model;
	} 
}