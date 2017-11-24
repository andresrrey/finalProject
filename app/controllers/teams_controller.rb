class TeamsController < ApplicationController
  require "kafka"

  def index
    @recent_messages = []
    Thread.new do
      $consumer.subscribe(with_prefix(CTF_countriesbyteam))
      begin
        $consumer.each_message do |message|
          $recent_messages << [message, {received_at: message.ts}]
          $recent_messages.shift if $recent_messages.length > 10
          puts "consumer received message! local message count: #{$recent_messages.size} offset=#{message.offset}"
        end
      rescue Exception => e
        puts 'CONSUMER ERROR'
        puts "#{e}\n#{e.backtrace.join("\n")}"
        exit(1)
      end
    end
    return @recent_messages
  end




  def indexold
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




    @values=[{20.day.ago => 5, 1368174456 => 4, "2013-05-07 00:00:00 UTC" => 7},{20.day.ago => 2, 1368174456 => 7, "2013-05-07 00:00:00 UTC" => 8}]

    # This will loop indefinitely, yielding each message in turn.
    #consumer.each_message do |message|
    #  @values[message.key]= message.value
    #end

    return @values
  end

end
