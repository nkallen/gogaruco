module InProcessLRUCache
  def get(data)
    @cache ||= []
    cache_hit = @cache.detect do |key, value|
      data == key
    end
    if !cache_hit
      result = yield(data)
      @cache.unshift([data, result])
      @cache.slice!(2..-1)
      result
    else
      cache_hit[1]
    end
  end
end