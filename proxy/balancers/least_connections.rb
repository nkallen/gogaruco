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
      server = servers.shift
    end

    yield server
  ensure
    Thread.exclusive do
      servers.push server
    end
  end
end