module Deferrable
  def defer(&block)
    (@queue ||= Queue.new) << block
    @thread ||= Thread.new do
      while true
        @queue.pop.call
      end
    end
  end
end