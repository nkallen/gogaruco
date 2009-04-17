require 'proxy/balancers/balancer'

class LeastConnections < Balancer
  include Synchronizable
  
  def forward(data)
    next_server do |server|
      $stats.set('server', server.port)
      server.call(data)
    end
  end

  private
  def next_server
    server = nil
    synchronize(:next_server) do
      server = servers.min do |s1, s2|
        s1.connections <=> s2.connections
      end
      server.reserve
    end

    yield server

  ensure
    server.release
  end
end