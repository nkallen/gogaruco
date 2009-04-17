class Server
  include Synchronizable
    
  attr_reader :port

  def initialize(host, port)
    @host, @port = host, port
  end
  
  def connections
    @connections ||= 0
  end
  
  def connections=(connections)
    @connections = connections
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
    socket = TCPSocket.new(@host, @port)
    socket.print(data)
    socket.readline
  end
end