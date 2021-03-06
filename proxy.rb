#!/usr/bin/env ruby

['rubygems', 'activesupport', 'eventmachine', 'socket', 'optparse'].each { |dependency| require dependency }
['util/statosaurus', 'util/synchronizable', 'util/line_buffered_connection', 'util/deferrable'].each { |dependency| require dependency }
['proxy/server', 'proxy/balancers/first', 'proxy/balancers/random', 'proxy/balancers/round_robin', 'proxy/balancers/least_connections', 'proxy/balancers/sticky'].each { |dependency| require dependency }

begin
  $options = {
    :balancer => First,
    :port => 10000,
    :count => 10,
    :host => "0.0.0.0"
  }
  OptionParser.new do |opts|
    opts.on('-b', "--balancer BALANCER", String) { |balancer| $options[:balancer] = balancer.constantize }
    opts.on('-n', "--number COUNT", Integer)     { |count| $options[:count] = count }
    opts.on('-p', "--port PORT", Integer)        { |port| $options[:port] = port }
  end.parse!
end

begin
  logfile = File.join(File.dirname(__FILE__), 'log', File.basename(__FILE__, '.rb') + '.log')
  $stats = Statosaurus.new(['job_user', 'job_sys', 'job_real', 'server'], Logger.new(logfile))
end

module ProxyServer
  include LineBufferedConnection, Deferrable
  extend Synchronizable

  @@servers = (1..$options[:count]).inject([]) do |servers, i|
    servers << Server.new($options[:host], $options[:port] + i)
  end
  @@balancer = $options[:balancer].new(@@servers)

  def self.forward(data)
    @@balancer.forward(data)
  end
  
  def receive_line(line)
    defer do
      $stats.transaction do
        $stats.measure('job') do
          message = "#{line};#{$stats.transaction_id}\n"
          send_data(ProxyServer.forward(message))
        end
      end
    end
  end
end

EM.run do
  EM.start_server $options[:host], $options[:port], ProxyServer
end