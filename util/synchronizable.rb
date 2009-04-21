module Synchronizable
  @@mutex = Mutex.new
  @@mutexes = Hash.new do |h,k|
    h[k] = Mutex.new
  end
  
  def mutex(mutex)
    @@mutex.synchronize do
      @@mutexes[mutex]
    end
  end

  def synchronize(name, &block)
    mutex(name).synchronize(&block)
  end
end