#!/usr/bin/env ruby

require 'optparse'

begin
  $options = {
    :count => 10,
    :base_port => 10000
  }
  OptionParser.new do |opts|
    opts.on('-n', "--number COUNT", Integer) { |count| $options[:count] = count }
    opts.on('-p', "--port PORT", Integer) { |count| $options[:port] = port }
  end.parse!
end

$options[:count].times do |count|
  port = $options[:base_port] + count + 1
  fork { exec("./joke_server.rb -p#{port}") }
end
