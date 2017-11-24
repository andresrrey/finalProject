class TeamsController < ApplicationController
  require "kafka"

  def index
    kafka = Kafka.new(
        # At least one of these nodes must be available:
        seed_brokers: ["UKRB-INPFTVM-T01:9092"],

        # Set an optional client id in order to identify the client to Kafka:
    )
    @values=Hash.new
    kafka.each_message(topic: "CTF_countriesbyteam") do |message|
      @values[message.key]=message.value

    end
    return @values
  end

end
