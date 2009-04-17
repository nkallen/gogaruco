require 'proxy/balancers/balancer'

class LeastConnections < Balancer
  def forward(data)
    next_server do |server|
      server.call(data)
    end
  end

  private
  def next_server
    server = nil
    Thread.exclusive do
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