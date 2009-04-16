#!/usr/bin/env ruby

require 'rubygems'
require 'eventmachine'
require 'util/stats'

$stats = Stats.new(['job_user', 'job_sys', 'job_real'], Logger.new(STDOUT))

module JokeServer
  def receive_data(data)
    $stats.transaction do
      $stats.measure('job') { send_data("knock knock\n") }
    end
  end
end

EM.run do
  EM.start_server "0.0.0.0", 10001, JokeServer
end
