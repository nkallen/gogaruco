['rubygems', 'eventmachine'].each { |dependency| require dependency }

module LineProtocol
  def receive_data(data)
    @data ||= ""
    if first_newline = data.index("\n")
      call(@data + data[0..first_newline])
      @data = ""
      data_after_first_newline = \
        data[(first_newline+1)..-1]
      if data_after_first_newline
        receive_data(data_after_first_newline)
      end
    end
  end
end