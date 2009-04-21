#!/usr/bin/env ruby

['rubygems', 'eventmachine', 'activesupport', 'optparse'].each { |dependency| require dependency }
['util/statosaurus', 'util/synchronizable', 'util/line_buffered_connection', 'util/in_process_lru_cache'].each { |dependency| require dependency }

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
  $stats = Statosaurus.new(['cache_hit', 'job_user', 'job_sys', 'job_real', 'source_transaction_id'], Logger.new(logfile))
end

module JokeServer
  include LineBufferedConnection
  
  def self.cache
    @cache ||= InProcessLRUCache.new(2)
  end

  def receive_line(line)
    $stats.transaction do
      data, source_transaction_id = line.split(';')
      $stats.set('source_transaction_id', source_transaction_id)
      $stats.measure('job') do
        result = JokeServer.cache.get(data) do
          100000.times { Time.now }
          sleep rand
          "KNOCK KNOCK: #{data}\n"
        end
        send_data(result)
      end
    end
  end
end

EM.run do
  EM.start_server "0.0.0.0", $options[:port], JokeServer
end
