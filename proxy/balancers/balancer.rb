class Balancer
  attr_reader :servers

  def initialize(servers)
    @servers = servers
  end
end