#!/usr/bin/env ruby

options = {
  :count => 10,
  :base_port => 1000
}
OptionParser.new do |opts|
  opts.on('-n', "--number COUNT", Integer) { |count| options[:count] = count }
  opts.on('-p', "--port PORT", Integer) { |count| options[:port] = port }
end.parse!

options[:count].times do |count|
  port = options[:base_port] + count
  System.fork("./joke_server.rb -p#{port}")
end
