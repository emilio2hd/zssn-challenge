module ResponseHelper
  def json_response_body
    JSON.parse(response.body)
  end
end

RSpec.configure do |config|
  config.include ResponseHelper, type: :controller
  config.include ResponseHelper, type: :request
end