/**
 * Created by jordanmathews on 23/02/2022.
 */

public interface IKafkaMessageParser {
    IKafkaMessageParser parse(String json, String key, String hash);
}
