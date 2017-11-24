require "kafka"

kafka = Kafka.new(
  # At least one of these nodes must be available:
  seed_brokers: ["UKRB-INPFTVM-T01:9092"],

  # Set an optional client id in order to identify the client to Kafka:
)
kafka.each_message(topic: "CTF_topic") do |message|
  puts message.offset, message.key, message.value
end
