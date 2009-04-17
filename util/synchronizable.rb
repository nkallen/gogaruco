module Synchronizable
  def mutex
    @mutex ||= Hash.new do |h,k|
      h[k] = Mutex.new
    end
  end
  
  def synchronize(name, &block)
    mutex[name].synchronize(&block)
  end
end