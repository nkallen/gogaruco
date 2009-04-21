class InProcessLRUCache
  def initialize(max_keys)
    @max_keys = max_keys
  end
  
  def get(key)
    @cache ||= {}
    @lru ||= []
    
    @lru << key

    result = @cache[key]
    $stats.set('cache_hit', !!result)
    if !result
      free_least_recently_used_item
      result = @cache[key] = yield(key) if block_given?
    end
    result
  end
  
  private
  def free_least_recently_used_item
    @cache.delete(@lru.shift) if @cache.size >= @max_keys
  end
end