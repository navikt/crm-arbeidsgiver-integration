public with sharing class KontaktSkjemaModel {
    public String type { get; set; }
    public String municipalityCode { get; set; }
    public String regionCode { get; set; }
    public String organisationName { get; set; }
    public String organisationNumber { get; set; }
    public String name { get; set; }
    public String firstName { get; set; }
    public String lastName { get; set; }
    public String email { get; set; }
    public String phoneNo { get; set; }
    public String jsonPayload { get; set; }

    public static KontaktSkjemaModel deserializeData(RestRequest request) {
        String requestString = request.requestBody.toString();
        KontaktSkjemaModel rw = (KontaktSkjemaModel) JSON.deserialize(requestString, KontaktSkjemaModel.class);
        rw.jsonPayload = requestString;

        return rw;
    }
}
