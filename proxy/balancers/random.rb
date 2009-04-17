require 'proxy/balancers/balancer'

class Random < Balancer
  def forward(data)
    server = servers.rand
    $stats.set('server', server.port)
    server.call(data)
  end
end