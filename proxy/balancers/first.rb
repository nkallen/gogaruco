require 'proxy/balancers/balancer'

class First < Balancer
  def initialize(servers)
    @servers = servers
  end

  def forward(data)
    servers.first.call(data)
  end
end