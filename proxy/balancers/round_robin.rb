require 'proxy/balancers/balancer'

class RoundRobin < Balancer
  include Synchronizable
    
  def forward(data)
    next_server.call(data)
  end

  private
  def next_server
    synchronize(:next_server) do
      @current ||= 0
      @current = (@current + 1) % servers.size
      servers[@current]
    end
  end
end