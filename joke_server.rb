#!/usr/bin/env ruby

['rubygems', 'eventmachine', 'activesupport', 'statosaurus', 'optparse'].each { |dependency| require dependency }

begin
  $options = {
    :port => 10001
  }
  OptionParser.new do |opts|
    opts.on('-p', "--port PORT", Integer) { |port| $options[:port] = port }
  end.parse!
end

begin
  logfile = File.join(File.dirname(__FILE__), 'log', File.basename(__FILE__) + '.log')
  $stats = Statosaurus.new(['job_user', 'job_sys', 'job_real'], Logger.new(logfile))
end

module JokeServer
  def receive_data(data)
    $stats.transaction do
      $stats.measure('job') do
        10000.times {}
        sleep rand
        send_data("knock knock\n")
      end
    end
  end
end

EM.run do
  EM.start_server "0.0.0.0", $options[:port], JokeServer
end
