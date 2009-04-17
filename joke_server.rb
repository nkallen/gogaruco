#!/usr/bin/env ruby

['rubygems', 'eventmachine', 'activesupport', 'optparse'].each { |dependency| require dependency }
['util/statosaurus', 'util/line_buffered_connection'].each { |dependency| require dependency }

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
  $stats = Statosaurus.new(['job_user', 'job_sys', 'job_real', 'source_transaction_id'], Logger.new(logfile))
end

module JokeServer
  include LineBufferedConnection

  def receive_line(line)
    $stats.transaction do
      $stats.set('source_transaction_id', line)
      $stats.measure('job') do
        10000.times {}
        sleep rand
        send_data("KNOCK KNOCK\n")
      end
    end
  end
end

EM.run do
  EM.start_server "0.0.0.0", $options[:port], JokeServer
end
