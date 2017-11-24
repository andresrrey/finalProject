class TeamsController < ApplicationController
  require "kafka"
  require 'json'
  def index

    kafka = Kafka.new(seed_brokers: ["UKRB-INPFTVM-T01:9092"])
    $hash={'2':{}, '3':{}, '4':{} ,'5':{}, '6':{}, '7':{}, '8':{}, '9':{}}
      offset = :earliest
      start_time=Time.now

    loop do
        messages = kafka.fetch_messages(topic: "CTF_countriesbyteam", partition: 0, offset: offset, max_wait_time: 2)
        break if Time.now > start_time + 5
        messages.each do |message|
          if !message.nil?
            puts JSON.parse(message.value)['id']
            puts JSON.parse(message.value)['name']
            puts JSON.parse(message.value)['ts']
            puts JSON.parse(message.value)['countries']
            if $hash[(JSON.parse(message.value)['id'])].nil?
              $hash[(JSON.parse(message.value)['id'])]=Hash.new()
            end
            $hash[(JSON.parse(message.value)['id'])][JSON.parse(message.value)['ts']]=JSON.parse(message.value)['countries']
            puts $hash[(JSON.parse(message.value)['id'])]
            # $recent_messages << [message.value]
          end
        end
        break
      end
    $hash={'2':{}, '3':{}, '4':{} ,'5':{}, '6':{}, '7':{}, '8':{}, '9':{}}
      $recent_messages=[
                            {name: "ItWorksOnMyContainer", data: $hash[9]},
                            {name: "Access Denied", data: $hash[8]},
                            {name: "Demogorgons", data: $hash[7]},
                            {name: "avadne", data: $hash[6]},
                            {name: "Bits Please", data: $hash[5]},
                            {name: "Los Jimmys", data: $hash[4]},
                            {name: "Los Borbotones", data: $hash[3]},
                            {name: "Chanfle", data: $hash[2]}
      ]

    start_time=Time.now

    loop do
      messages = kafka.fetch_messages(topic: "CTF_pointsbyteam", partition: 0, offset: offset, max_wait_time: 2)
      break if Time.now > start_time + 5
      messages.each do |message|
        if !message.nil?
          puts JSON.parse(message.value)['id']
          puts JSON.parse(message.value)['name']
          puts JSON.parse(message.value)['ts']
          puts JSON.parse(message.value)['points']
          if $hash[(JSON.parse(message.value)['id'])].nil?
            $hash[(JSON.parse(message.value)['id'])]=Hash.new()
          end
          $hash[(JSON.parse(message.value)['id'])][JSON.parse(message.value)['ts']]=JSON.parse(message.value)['points']
          puts $hash[(JSON.parse(message.value)['id'])]
          # $recent_messages << [message.value]
        end
      end
      break
    end

    $recent_messages1=[
        {name: "ItWorksOnMyContainer", data: $hash[9]},
        {name: "Access Denied", data: $hash[8]},
        {name: "Demogorgons", data: $hash[7]},
        {name: "avadne", data: $hash[6]},
        {name: "Bits Please", data: $hash[5]},
        {name: "Los Jimmys", data: $hash[4]},
        {name: "Los Borbotones", data: $hash[3]},
        {name: "Chanfle", data: $hash[2]}
    ]
      rescue Exception => e
        puts 'CONSUMER ERROR'
        puts "#{e}\n#{e.cause}"
        exit(1)
      return $recent_messages, $recent_messages1
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
