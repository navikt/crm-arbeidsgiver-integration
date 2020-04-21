public class KafkaPermitteringHandler_Model {

	public String id {get; set;}
	public String bedriftsnummer {get; set;}
	public String sendtInnTidspunkt {get; set;}
	public String type {get; set;}
	public String kontaktNavn {get; set;}
	public String kontaktTlf {get; set;}
	public String kontaktEpost {get; set;}
	public Date varsletAnsattDato {get; set;}
	public Date varsletNavDato {get; set;}
	public Date startDato {get; set;}
	public Date sluttDato {get; set;}
	public String fritekst {get; set;}
	public Integer antallBerorte {get; set;}
	public String arsakskode {get; set;}
	public String arsakstekst {get; set;}
	public List<Yrkeskategorier> yrkeskategorier {get; set;}
	public List<Bedrift> bedrift {get; set;}

	public String jsonPayload {get; set;}


	public KafkaPermitteringHandler_Model( JSONParser parser ) {
		while ( parser.nextToken() != System.JSONToken.END_OBJECT ) {
			if ( parser.getCurrentToken() == System.JSONToken.FIELD_NAME ) {
				String text = parser.getText();
				if ( parser.nextToken() != System.JSONToken.VALUE_NULL ) {
					if ( text == 'id' ) {
						id = parser.getText();
					} else if ( text == 'bedriftsnummer' ) {
						bedriftsnummer = parser.getText();
					} else if ( text == 'sendtInnTidspunkt' ) {
						sendtInnTidspunkt = parser.getText();
					} else if ( text == 'type' ) {
						type = parser.getText();
					} else if ( text == 'kontaktNavn' ) {
						kontaktNavn = parser.getText();
					} else if ( text == 'kontaktTlf' ) {
						kontaktTlf = parser.getText();
					} else if ( text == 'kontaktEpost' ) {
						kontaktEpost = parser.getText();
					} else if ( text == 'varsletAnsattDato' ) {
						varsletAnsattDato = date.valueOf( parser.getText() );
					} else if ( text == 'varsletNavDato' ) {
						varsletNavDato = date.valueOf( parser.getText() );
					} else if ( text == 'startDato' ) {
						startDato = date.valueOf( parser.getText() );
					} else if ( text == 'sluttDato' ) {
						sluttDato = date.valueOf( parser.getText() );
					} else if ( text == 'fritekst' ) {
						fritekst = parser.getText();
					} else if ( text == 'antallBerorte' ) {
						antallBerorte = parser.getIntegerValue();
					} else if ( text == 'årsakskode' ) {
						arsakskode = parser.getText();
					} else if ( text == 'årsakstekst' ) {
						arsakstekst = parser.getText();
					} else if ( text == 'yrkeskategorier' ) {
						yrkeskategorier = arrayOfYrkeskategorier( parser );
					} else if ( text == 'bedrift' ) {
						bedrift = arrayOfBedrift( parser );
					} else {
						System.debug( LoggingLevel.WARN, 'KafkaPermitteringHandler_Model consuming unrecognized property: ' + text );
						consumeObject( parser );
					}
				}
			}
		}
	}

	public class Yrkeskategorier {
		public Integer konseptId {get; set;}
		public String styrk08 {get; set;}
		public String label {get; set;}

		public Yrkeskategorier( JSONParser parser ) {
			while ( parser.nextToken() != System.JSONToken.END_OBJECT ) {
				if ( parser.getCurrentToken() == System.JSONToken.FIELD_NAME ) {
					String text = parser.getText();
					if ( parser.nextToken() != System.JSONToken.VALUE_NULL ) {
						if ( text == 'konseptId' ) {
							konseptId = parser.getIntegerValue();
						} else if ( text == 'styrk08' ) {
							styrk08 = parser.getText();
						} else if ( text == 'label' ) {
							label = parser.getText();
						} else {
							System.debug( LoggingLevel.WARN, 'Yrkeskategorier consuming unrecognized property: ' + text );
							consumeObject( parser );
						}
					}
				}
			}
		}
	}

	public class Bedrift {
		public String bedriftNr {get; set;}
		public String bedriftNavn {get; set;}
		public Integer antallBerorte {get; set;}

		public Bedrift( JSONParser parser ) {
			while ( parser.nextToken() != System.JSONToken.END_OBJECT ) {
				if ( parser.getCurrentToken() == System.JSONToken.FIELD_NAME ) {
					String text = parser.getText();
					if ( parser.nextToken() != System.JSONToken.VALUE_NULL ) {
						if ( text == 'bedriftNr' ) {
							bedriftNr = parser.getText();
						} else if ( text == 'bedriftNavn' ) {
							bedriftNavn = parser.getText();
						} else if ( text == 'antallBerorte' ) {
							antallBerorte = parser.getIntegerValue();
						} else {
							System.debug( LoggingLevel.WARN, 'Bedrift consuming unrecognized property: ' + text );
							consumeObject( parser );
						}
					}
				}
			}
		}
	}

	public static KafkaPermitteringHandler_Model parse( String json ) {
		System.JSONParser parser = System.JSON.createParser( json );

		KafkaPermitteringHandler_Model p = new KafkaPermitteringHandler_Model( parser );
		p.jsonPayload = json;

		return p;
	}

	public static void consumeObject( System.JSONParser parser ) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if ( curr == System.JSONToken.START_OBJECT ||
			     curr == System.JSONToken.START_ARRAY ) {
				depth++;
			} else if ( curr == System.JSONToken.END_OBJECT ||
			            curr == System.JSONToken.END_ARRAY ) {
				depth--;
			}
		} while ( depth > 0 && parser.nextToken() != null );
	}

	private static List<Yrkeskategorier> arrayOfYrkeskategorier( System.JSONParser p ) {
		List<Yrkeskategorier> res = new List<Yrkeskategorier>();
		if ( p.getCurrentToken() == null ) { p.nextToken(); }
		while ( p.nextToken() != System.JSONToken.END_ARRAY ) {
			res.add( new Yrkeskategorier( p ) );
		}

		return res;
	}

	private static List<Bedrift> arrayOfBedrift( System.JSONParser p ) {
		List<Bedrift> res = new List<Bedrift>();
		if ( p.getCurrentToken() == null ) { p.nextToken(); }
		while ( p.nextToken() != System.JSONToken.END_ARRAY ) {
			res.add( new Bedrift( p ) );
		}

		return res;
	}
}