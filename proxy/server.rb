class Server
  include Synchronizable
    
  attr_reader :port

  include Deferrable

  def initialize(host, port)
    @host, @port = host, port
  end

  def call(data)
    socket = TCPSocket.new(@host, @port)
    socket.print(data)
    socket.readline
  end
end