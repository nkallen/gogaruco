#!/usr/bin/env ruby

require 'rubygems'
require 'eventmachine'
require 'activesupport'
require 'statosaurus'

begin
  logfile = File.join(File.dirname(__FILE__), 'log', File.basename(__FILE__) + '.log')
  $stats = Statosaurus.new(['job_user', 'job_sys', 'job_real'], Logger.new(logfile))
end

module JokeServer
  def receive_data(data)
    $stats.transaction do
      $stats.measure('job') do
        100.times {}
        sleep 0.1
        send_data("knock knock\n")
      end
    end
  end
end

EM.run do
  EM.start_server "0.0.0.0", 10001, JokeServer
end
