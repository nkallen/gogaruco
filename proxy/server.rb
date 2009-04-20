class Server
  include Synchronizable

  attr_reader :port

  def initialize(host, port)
    @host, @port = host, port
    synchronize(:connections) { @connections = 0 }
  end

  def reserve
    synchronize(:connections) do
      self.connections += 1
    end
  end

  def release
    synchronize(:connections) do
      self.connections -= 1
    end
  end

  def call(data)
    TCPSocket.open(@host, @port) do |socket|
      socket.print(data)
      socket.readline
    end
  end

  private
  # Whilst I'm not normally a fan of closing apis or gratuitously spreading
  # private around, this code is subject to thread safety concerns, so
  # assignment should be ensure local, or the value should not be accessible,
  # instead it should have a thread safe incr! and decr!.
  def connections
    @connections
  end

  def connections=(connections)
    @connections = connections
  end
end