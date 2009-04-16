#!/usr/bin/env ruby

['rubygems', 'activesupport', 'eventmachine', 'socket', 'optparse', 'statosaurus'].each { |dependency| require dependency }
['proxy/server', 'proxy/balancers/first', 'proxy/balancers/random', 'proxy/balancers/round_robin'].each { |dependency| require dependency }

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
  def receive_data(data)
    $stats.transaction do # TODO propagate txnid to server.
      $stats.measure('job') do
        send_data(ProxyServer.forward(data))
      end
    end
  end

  def self.forward(data)
    balancer.forward(data)
  end

  private
  def self.servers
    @servers ||= (1..$options[:count]).inject([]) do |servers, i|
      servers << Server.new($options[:host], $options[:port] + i)
    end
  end

  def self.balancer
    @balancer ||= $options[:balancer].new(servers)
  end
end

EM.run do
  EM.start_server $options[:host], $options[:port], ProxyServer
end