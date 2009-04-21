module Synchronizable
  @@mutex = Mutex.new
  
  def mutex(mutex)
    @@mutex.synchronize do
      (@mutexes ||= Hash.new do |h,k|
        h[k] = Mutex.new
      end)[mutex]
    end
  end

  def synchronize(name, &block)
    mutex(name).synchronize(&block)
  end
end