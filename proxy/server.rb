class Server
  def initialize(host, port)
    @socket = TCPSocket.new(host, port)
    @free = true
  end

  def call(data)
    Thread.exclusive do
      @socket.print(data)
      @socket.gets
    end
  end
end