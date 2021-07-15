public class KafkaSykefravaerHandler_Model {
    
    public String orgnr { get; set; }
    public Integer arstall { get; set; }
    public Integer kvartal { get; set; }
    public Decimal tapteDagsverk { get; set; } 
    public Decimal muligeDagsverk { get; set; }
    public Integer antallPersoner { get; set; }
    public Decimal prosent { get; set; }
    public Boolean erMaskert { get; set; }
    public Naering5Siffer naering { get; set; }
    public Sektor sektor { get; set; }
    public Land land { get; set; }

    public String jsonPayload { get; set; }
    public String key { get; set; }

    public KafkaSykefravaerHandler_Model(JSONParser parser) {
        parser.nextToken();
        parser.nextToken();
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'orgnr') {
                        orgnr = parser.getText();
                    }
                    else if (text == 'årstall') {
                        arstall = integer.valueOf(parser.getText());
                    }
                    else if (text == 'kvartal') {
                        kvartal = parser.getIntegerValue();
                    }
                    else if (text == 'tapteDagsverk') {
                        tapteDagsverk = parser.getDecimalValue();
                    }
                    else if (text == 'muligeDagsverk') {
                        muligeDagsverk = parser.getDecimalValue();
                    }
                    else if (text == 'antallPersoner') {
                        antallPersoner = parser.getIntegerValue();
                    }
                    else if (text == 'prosent') {
                        prosent = parser.getDecimalValue();
                    }
                    else if (text == 'erMaskert') {
                        erMaskert = parser.getBooleanValue();
                    }
                    else if (text == 'næring5SifferSykefravær') {
                        KafkaSykefravaerHandler_Model.Naering5Siffer modelNaering = new KafkaSykefravaerHandler_Model.Naering5Siffer();
                        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                                String naeringText = parser.getText();
                                parser.nextToken();
                                if (naeringText == 'kode') {
                                    modelNaering.kode = parser.getText();
                                }
                                else if (naeringText == 'tapteDagsverk') {
                                    modelNaering.tapteDagsverk = decimal.valueOf(parser.getText());
                                }
                                else if (naeringText == 'muligeDagsverk') {
                                    modelNaering.muligeDagsverk = parser.getDecimalValue();
                                }
                                else if (naeringText == 'antallPersoner') {
                                    modelNaering.antallPersoner = parser.getIntegerValue();
                                }
                                else if (naeringText == 'prosent') {
                                    modelNaering.prosent = parser.getDecimalValue();
                                    naering = modelNaering;
                                }
                            }
                        }
                    }
                    else if(text == 'sektorSykefravær') {
                        KafkaSykefravaerHandler_Model.Sektor modelSektor = new KafkaSykefravaerHandler_Model.Sektor();
                        while(parser.nextToken() != System.JSONToken.END_OBJECT) {
                            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                                String sektorText = parser.getText();
                                parser.nextToken();
                                if (sektorText == 'kode') {
                                    modelSektor.kode = parser.getText();
                                }
                                else if (sektorText == 'tapteDagsverk') {
                                    modelSektor.tapteDagsverk = decimal.valueOf(parser.getText());
                                }
                                else if (sektorText == 'muligeDagsverk') {
                                    modelSektor.muligeDagsverk = parser.getDecimalValue();
                                }
                                else if (sektorText == 'antallPersoner') {
                                    modelSektor.antallPersoner = parser.getIntegerValue();
                                }
                                else if (sektorText == 'prosent') {
                                    modelSektor.prosent = parser.getDecimalValue();
                                    sektor = modelSektor;
                                }
                            }
                        }
                    }
                    else if(text == 'landSykefravær') {
                        KafkaSykefravaerHandler_Model.Land modelLand = new KafkaSykefravaerHandler_Model.Land();
                        while(parser.nextToken() != JSONToken.END_OBJECT) {
                            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                                String landText = parser.getText();
                                parser.nextToken();
                                if (landText == 'kode') {
                                    modelLand.kode = parser.getText();
                                }
                                else if (landText == 'tapteDagsverk') {
                                    modelLand.tapteDagsverk = decimal.valueOf(parser.getText());
                                }
                                else if (landText == 'muligeDagsverk') {
                                    modelLand.muligeDagsverk = parser.getDecimalValue();
                                }
                                else if (landText == 'antallPersoner') {
                                    modelLand.antallPersoner = parser.getIntegerValue();
                                }
                                else if (landText == 'prosent') {
                                    modelLand.prosent = parser.getDecimalValue();
                                    land = modelLand;
                                }
                            }
                        }
                    }
                    else {
                        System.debug(LoggingLevel.WARN, 'Sykefravaer consuming unrecognized property: ' + text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }

    public static KafkaSykefravaerHandler_Model parse(String json, String key) {
        System.JSONParser parser = System.JSON.createParser(json);

        KafkaSykefravaerHandler_Model p = new KafkaSykefravaerHandler_Model(parser);
        p.jsonPayload = json;
        p.key = key;

        return p;
    }

    public class Naering5Siffer {
        public String kode { get; set; }
        public Decimal tapteDagsverk { get; set; } 
        public Decimal muligeDagsverk { get; set; }
        public Integer antallPersoner { get; set; }
        public Decimal prosent { get; set; }

    }

    public class Sektor {
        public String kode { get; set; }
        public Decimal tapteDagsverk { get; set; } 
        public Decimal muligeDagsverk { get; set; }
        public Integer antallPersoner { get; set; }
        public Decimal prosent { get; set; }
    }

    public class Land {
        public String kode { get; set; }
        public Decimal tapteDagsverk { get; set; } 
        public Decimal muligeDagsverk { get; set; }
        public Integer antallPersoner { get; set; }
        public Decimal prosent { get; set; }
    }

    public static void consumeObject(System.JSONParser parser) {
        Integer depth = 0;
        do {
            System.JSONToken curr = parser.getCurrentToken();
            if (curr == System.JSONToken.START_OBJECT || curr == System.JSONToken.START_ARRAY) {
                depth++;
            } else if (curr == System.JSONToken.END_OBJECT || curr == System.JSONToken.END_ARRAY) {
                depth--;
            }
        } while (depth > 0 && parser.nextToken() != null);
    }
}
