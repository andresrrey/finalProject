class TeamsController < ApplicationController
  require "kafka"
  require 'json'
  def index

    kafka = Kafka.new(seed_brokers: ["UKRB-INPFTVM-T01:9092"])
    # Consumers with the same group id will form a Consumer Group together.
    $consumer = kafka.consumer(group_id: "my-consumer")
    $recent_messages=
        {name: "Demogorgons", data: {20.day.ago => 5, 1368174456 => 4}} ,
        {name: "ITWORKSONMYCONTAINER", data: {20.day.ago => 2, 1368174456 => 3}}

    $consumer.subscribe("CTF_countriesbyteam")
      $counter=0
      offset = :earliest
      start_time=Time.now
      loop do
        messages = kafka.fetch_messages(topic: "CTF_countriesbyteam", partition: 0, offset: offset, max_wait_time: 2)
        break if Time.now > start_time + 5
        messages.each do |message|
          if !message.nil?
             puts JSON.parse(message.value)['id']
             puts JSON.parse(message.value)['name']
            #$recent_messages << [message.value]
          end
        end
        break
      end

          #[{20.day.ago => 5, 1368174456 => 4, "2013-05-07 00:00:00 UTC" => 7},{20.day.ago => 5, 1368174456 => 4, "2013-05-07 00:00:00 UTC" => 7}]
      #$consumer.each_message do |message|
      #    if !message.nil?
      #      $recent_messages << [message]
      #      puts message.value
      #    end
      #    $recent_messages.shift if $recent_messages.length > 10
      #    puts "consumer received message! local message count: #{$recent_messages.size} offset=#{message.offset}"
      #    $consumer.stop
      #end
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
