RSpec.configure do |config|
  config.around(:each, :caching) do |example|
    cache_original = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    example.run
    Rails.cache.clear
    Rails.cache = cache_original
  end
end