class TeamsController < ApplicationController
  require "kafka"

  def index

    kafka = Kafka.new(seed_brokers: ["UKRB-INPFTVM-T01:9092"])
    # Consumers with the same group id will form a Consumer Group together.
    $consumer = kafka.consumer(group_id: "my-consumer")
      $recent_messages = []
      $consumer.subscribe("CTF_countriesbyteam")
      $counter=0
      offset = :earliest

      loop do
        messages = kafka.fetch_messages(topic: "CTF_countriesbyteam", partition: 10, offset: offset)
        break if messages.empty?
        messages.each do |message|
          if !message.nil?
             puts message.value
            $recent_messages << [message]
          end
        end
      end
     # $consumer.each_message do |message|
     #     if !message.nil?
     #       $recent_messages << [message]
     #     end
     #     $recent_messages.shift if $recent_messages.length > 10
     #     puts "consumer received message! local message count: #{$recent_messages.size} offset=#{message.offset}"
     #   break
     # end
      rescue Exception => e
        puts 'CONSUMER ERROR'
        puts "#{e}\n#{e.cause}"
        exit(1)
      return $recent_messages
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




    @values=[]
    # This will loop indefinitely, yielding each message in turn.
    counter=0
    consumer.each_message do |message|
      if counter >=5
        break
      end
      @values[message.key]= message.value
      counter+=1
    end

    return @values
  end

end
