require 'proxy/balancers/balancer'

class Random < Balancer
  def forward(data)
    servers.rand.call(data)
  end
end