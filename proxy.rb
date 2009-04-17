#!/usr/bin/env ruby

['rubygems', 'activesupport', 'eventmachine', 'socket', 'optparse', 'statosaurus'].each { |dependency| require dependency }
['util/line_protocol', 'proxy/server', 'proxy/balancers/first', 'proxy/balancers/random', 'proxy/balancers/round_robin', 'proxy/balancers/least_connections'].each { |dependency| require dependency }

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
  logfile = File.join(File.dirname(__FILE__), 'log', File.basename(__FILE__) + '.log')
  $stats = Statosaurus.new(['job_user', 'job_sys', 'job_real'], Logger.new(logfile))
end

module ProxyServer
  include LineProtocol
  include EventMachine::Deferrable
  
  def call(data)
    proxy = self
    p "spawning"
    EventMachine.spawn do
      $stats.transaction do
        $stats.measure('job') do
          message = $stats.transaction_id + "\n"
          response = ProxyServer.forward(message)
          proxy.send_data(response)
          p "finished"
        end
      end
    end.run
  end

  def self.forward(data)
    balancer.forward(data)
  end

  private
  def self.servers
    Thread.exclusive do
      @servers ||= (1..$options[:count]).inject([]) do |servers, i|
        servers << Server.new($options[:host], $options[:port] + i)
      end
    end
  end

  def self.balancer
    Thread.exclusive do
      @balancer ||= $options[:balancer].new(servers)
    end
  end
end

EM.run do
  EM.start_server $options[:host], $options[:port], ProxyServer
end