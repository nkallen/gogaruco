count = 10

count.times do |count|
  port = 1000 + count
  System.fork("./joke_server.rb -p#{port}")
end
