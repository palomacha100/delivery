require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'

abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end
RSpec.configure do |config|
  
  config.fixture_paths = [
    Rails.root.join('spec/fixtures')
  ]

  config.use_transactional_fixtures = true

  
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  config.include(
    Devise::Test::IntegrationHelpers,
    type: :request
  )
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end

  module APIRequestHelpers
    def api_sign_in(user, credential)
    post(
      "/sign_in",
      headers: {
          "Accept" => "application/json",
          "X-API-KEY" => credential.key
      },
      params: {
        login: {
          email: user.email,
          password: user.password
        }
      }
    )

    JSON.parse(response.body)
  end
end


RSpec.configure do |config|
    config.include FactoryBot::Syntax::Methods
    config.include APIRequestHelpers, type: :request
  end 

end

