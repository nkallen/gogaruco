module Synchronizable
  @@mutex = Mutex.new

  def mutex
    # Yup, this is nasty, but it's the only way without patching
    # initialize/new and having included and extended callbacks.
    @@mutex.synchronize do
      @mutex ||= Hash.new do |h,k|
        @@mutex.synchronize do
          h[k] = Mutex.new
        end
      end
    end
  end

  def synchronize(name, &block)
    mutex[name].synchronize(&block)
  end
end