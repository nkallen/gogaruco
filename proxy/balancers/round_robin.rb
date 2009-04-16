require 'proxy/balancers/balancer'

class RoundRobin < Balancer
  def forward(data)
    next_server.call(data)
  end

  private
  def next_server
    Thread.exclusive do
      @current ||= 0
      @current = (@current + 1) % servers.size
      servers[@current]
    end
  end
end