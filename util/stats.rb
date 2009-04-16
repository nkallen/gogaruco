require 'activesupport'

class Stats
  attr_accessor :transaction_id

  def initialize(fields, logger)
    @fields = fields
    @values = {}
    @logger = logger
    @logger.info("# Fields: " + fields.join(" "))
  end

  def measure(field, &block)
    measurement = Benchmark.measure(&block)
    @values["#{field}_user"] = measurement.utime
    @values["#{field}_sys"] = measurement.stime
    @values["#{field}_real"] = measurement.real
  end
  
  def transaction
    @transaction_id = "#{Process.pid}-#{Time.now.to_i}-#{rand(9999)}"
    yield
    print
    @values = {}
  end
  
  private
  def print
    prefix = [Time.now.iso8601, @transaction_id].join(" ")
    info = @fields.collect { |field| @values[field] || "-" }.join(" ")
    @logger.info(prefix + " " + info)
  end
end