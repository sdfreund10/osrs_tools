require "dotenv/load"
require "functions_framework"
require_relative "app"

FunctionsFramework.http "app" do |request|
  # Call the app with the Rack request environment
  App.call(request.env)
end
