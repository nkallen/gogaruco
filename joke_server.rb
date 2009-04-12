#!/usr/bin/env ruby

require 'rubygems'
require 'eventmachine'

module JokeServer
  def receive_data(data)
    send_data("knock knock\n")
    # output w3c data with user, sys, and real
  end
end

EM.run do
  EM.start_server "0.0.0.0", 10001, JokeServer
end
