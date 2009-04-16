class Server
  def initialize(host, port)
    @socket = TCPSocket.new(host, port)
  end

  def call(data)
    @socket.print(data)
    @socket.gets
  end
end