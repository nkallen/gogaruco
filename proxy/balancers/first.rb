require 'proxy/balancers/balancer'

class First < Balancer
  def forward(data)
    servers.first.call(data)
  end
end