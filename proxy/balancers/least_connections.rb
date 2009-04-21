require 'proxy/balancers/balancer'

class LeastConnections < Balancer
  include Synchronizable
  
  def forward(data)
    next_server do |server|
      server.call(data)
    end
  end

  private
  def next_server
    server = nil
    synchronize(:next_server) do
      server = servers.min
      server.reserve
    end

    yield server

  ensure
    server.release
  end
end