module InProcessLRUCache
  def get(data)
    @cache ||= []
    cache_hit = @cache.detect do |key, value|
      data == key
    end
    if !cache_hit
      $stats.set('cache_hit', 0)

      result = yield(data)
      @cache.unshift([data, result])
      @cache.slice!(2..-1)
      result
    else
      $stats.set('cache_hit', 1)

      cache_hit[1]
    end
  end
end