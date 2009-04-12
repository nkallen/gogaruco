#!/usr/bin/env ruby

require 'rubygems'
require 'eventmachine'
require 'socket'

class Server
  def initialize(host, port)
    @socket = TCPSocket.new(host, port)
  end

  def forward(data)
    @socket.print(data)
    @socket.gets
  end
end

module ProxyServer
  def receive_data(data)
    send_data(server.forward(data))
    # output w3c data with user, sys, and real
  end
  
  def server
    # RoundRobinSocketBalancer.new(socket1, socket2, socket3)
    # RandomSocketBalancer.new(socket1, socket2, socket3)
    # BusynessSocketBalancer.new(socket1, socket2, socket3)
    # StickySocketBalancer.new(socket1, socket2, socket3)
    @server ||= Server.new("0.0.0.0", 10001)
  end
end

EM.run do
  EM.start_server "0.0.0.0", 10000, ProxyServer
end
