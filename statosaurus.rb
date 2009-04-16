class Statosaurus
  attr_accessor :transaction_id

  def initialize(fields, logger)
    @fields = fields.sort
    @values = {}
    @logger = logger
    @logger.info("# Fields: " + fields.join(" "))
  end

  def measure(field, &block)
    measurement = Benchmark.measure(&block)
    @values["#{field}_real"] = min(measurement.real)
    @values["#{field}_sys"] = min(measurement.stime)
    @values["#{field}_user"] = min(measurement.utime)
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
    info = @fields.collect { |field| format(@values[field]) }.join(" ")
    @logger.info(prefix + " " + info)
  end
  
  def min(n)
    [n, 10e-5].max
  end
  
  def format(value)
    case value
    when NilClass
      "-"
    when Float
      "%f" % value
    else
      value.to_s
    end
  end
end