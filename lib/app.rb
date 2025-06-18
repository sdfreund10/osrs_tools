require "dotenv/load"
require "sinatra/base"
require "sinatra/custom_logger"
require "logger"
require "rack/protection"

require_relative "item"
require_relative "price"
require_relative "activity_suggestion"

class App < Sinatra::Base
  enable :sessions
  use Rack::Protection::AuthenticityToken
  helpers Sinatra::CustomLogger

  configure do
    set :root, File.dirname(__FILE__)
    set :views, File.dirname(__FILE__) + "/views"
    set :logger, Logger.new($stdout)
    set :bind, "0.0.0.0"
    set :port, ENV.fetch("PORT", 4567)
    set :protection, host_authorization: {
      permitted_hosts: ->(env) do
        current_host = env["HTTP_HOST"] || env["SERVER_NAME"]
        if current_host && !permitted_hosts.include?(current_host)
          permitted_hosts << current_host
        end
        permitted_hosts
      end
    }
    set :session_secret, ENV.fetch("SESSION_SECRET") { SecureRandom.hex(64) }
  end

  before do
    @request_start_time = Time.now
    logger.info "Request started: #{request.request_method} #{request.path}, Params: #{request.params.inspect}"
  end

  after do
    logger.info "Request completed: #{request.request_method} #{request.path} - Status: #{response.status} - #{Time.now - @request_start_time}s"
  end

  helpers do
    def format_number(price)
      price.to_s.gsub(/\B(?=(...)*\b)/, ",")
    end

    def intensity_color_class(intensity)
      return "" if intensity.nil?

      if intensity.include?("Low")
        "pico-color-green-400"
      elsif intensity.include?("Medium")
        "pico-color-amber-300"
      elsif intensity.include?("High")
        "pico-color-red-400"
      else
        ""
      end
    end
  end

  get "/" do
    redirect to("/alchemist")
  end

  get "/alchemist" do
    items = Item.trade_candidates.first(20)
    erb :"alchemist/index", locals: {items: items, last_updated_at: PricesApi.prices_refreshed_at}
  end

  get "/suggestion" do
    erb :"suggestion/index"
  end

  post "/suggestion" do
    intensity = {1 => "Low", 2 => "Low-Medium", 3 => "Medium", 4 => "Medium-High", 5 => "High"}[params["intensity"].to_i]
    suggestions = ActivitySuggestion.new(player_name: params["username"], account_type: params["account_type"], intensity: intensity).suggestions.shuffle
    erb :"suggestion/show", locals: {suggestions: suggestions}, layout: false
  rescue ActivitySuggestion::InvalidPlayerError => e
    logger.error "Error fetching suggestions: #{e.message}"
    status 400
    e.message
  end

  # User can dismiss suggestion and replace it with a new one
  #   Is this worthwhile? Why not just regenerate a new set of suggestions?
  post "/suggestions/refresh" do
  end

  # User inputs goals, then compares them to WiseOldMan's progress, with a history chart
  get "/goals" do
    erb :"goals/index"
  end

  # endpoint osrs chores endpoint for tracking weekly progress (ex: 100 zulrah kc/week, 50k agility/week)

  # scrape wiki money making and filter by player stats

  # Bone shard calculator

  # Best giants foundry items
  #   Use GE prices, filter items that are actively traded, compare prices

  # maybe move to a config.ru for deploys?
  if app_file == $0
    logger.info "Starting..."
    logger.info ENV
    run!
  end
end
