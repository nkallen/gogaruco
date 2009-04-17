#!/usr/bin/env ruby

['rubygems', 'eventmachine', 'activesupport', 'optparse'].each { |dependency| require dependency }
['util/statosaurus', 'util/line_buffered_connection', 'util/in_process_lru_cache'].each { |dependency| require dependency }

begin
  $options = {
    :port => 10001
  }
  OptionParser.new do |opts|
    opts.on('-p', "--port PORT", Integer) { |port| $options[:port] = port }
  end.parse!
end

begin
  logfile = File.join(File.dirname(__FILE__), 'log', File.basename(__FILE__, '.rb') + '.log')
  $stats = Statosaurus.new(['job_user', 'job_sys', 'job_real', 'source_transaction_id'], Logger.new(logfile))
end

module JokeServer
  include LineBufferedConnection

  def receive_line(line)
    $stats.transaction do
      data, source_transaction_id = line.split(';')
      $stats.set('source_transaction_id', data)
      $stats.measure('job') do
        100000.times { Time.now }
        sleep rand
        result = "KNOCK KNOCK: #{data}\n"
        send_data(result)
      end
    end
  end
end

EM.run do
  EM.start_server "0.0.0.0", $options[:port], JokeServer
end
