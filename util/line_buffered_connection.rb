['rubygems', 'eventmachine'].each { |dependency| require dependency }

module LineBufferedConnection
  def receive_data(data)
    (@buffer ||= BufferedTokenizer.new).extract(data).each do |line|
      receive_line(line)
    end
  end
end