#!/usr/bin/env ruby

['rubygems', 'activesupport', 'eventmachine', 'socket', 'optparse'].each { |dependency| require dependency }
['util/statosaurus', 'util/line_buffered_connection', 'proxy/server', 'proxy/balancers/first', 'proxy/balancers/random', 'proxy/balancers/round_robin', 'proxy/balancers/least_connections'].each { |dependency| require dependency }

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
  include LineBufferedConnection
  
  def receive_line(line)
    EventMachine.defer do
      $stats.transaction do
        $stats.measure('job') do
          message = $stats.transaction_id + "\n"
          p "forwarding"
          sleep 0
          response = ProxyServer.forward(message)
          p "sending data"
          sleep 0
          send_data(response)
          p "sent"
        end
      end
    end
  end
  
  def defer(&block)
    p "pushed block"
    (@queue ||= Queue.new) << block
    initialize_thread
  end
  
  def initialize_thread
    @thread ||= Thread.new do
      while true
        p "looking"
        @queue.pop.call
      end
    end
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