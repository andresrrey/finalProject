class TeamsController < ApplicationController
  require "kafka"

  def index
    kafka = Kafka.new(seed_brokers: ["UKRB-INPFTVM-T01:9092"])

    # Consumers with the same group id will form a Consumer Group together.
    consumer = kafka.consumer(group_id: "my-consumer")
    # Messages will not be marked as processed automatically. If you shut down the
    # consumer without calling `#mark_message_as_processed` first, the consumer will
    # not resume where you left off!
    # Our messages are JSON with a `type` field and other stuff.
    consumer.subscribe("CTF_countriesbyteam")

    # Stop the consumer when the SIGTERM signal is sent to the process.
    # It's better to shut down gracefully than to kill the process.
     trap("TERM") { consumer.stop }

    @values=[
        {name: "Series A", data: series_a},
        {name: "Series B", data: series_b}
    ]

    # This will loop indefinitely, yielding each message in turn.
    #consumer.each_message do |message|
    #  @values[message.key]= message.value
    #end

    return @values
  end

end
