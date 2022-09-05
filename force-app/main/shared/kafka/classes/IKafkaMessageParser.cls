public interface IKafkaMessageParser {
    IKafkaMessageParser parse(String json, String key, String hash);
}
