require 'proxy/balancers/balancer'

class Sticky < Balancer
  def forward(data)
    server_for(data).call(data)
  end

  private
  def server_for(data)
    p data
    data = data.split(';').first
    servers[data.to_i % servers.size]
  end
end