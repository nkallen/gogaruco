class Server
  include Synchronizable

  attr_reader :port

  def initialize(host, port)
    @host, @port = host, port
    @connections = 0
  end

  def reserve
    synchronize(:connections) do
      @connections += 1
    end
  end

  def release
    synchronize(:connections) do
      @connections -= 1
    end
  end

  def call(data)
    TCPSocket.open(@host, @port) do |socket|
      socket.print(data)
      socket.readline
    end
  end
  
  def <=>(other)
    connections <=> other.connections
  end

  protected
  def connections
    @connections
  end
end