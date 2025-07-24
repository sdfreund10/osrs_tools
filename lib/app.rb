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
    # be sure to set the RACK_ENV in deployed environments. I guess rack protection locks to allowed hosts localhost
    set :environment, ENV.fetch("RACK_ENV", "development").to_sym
    set :root, File.dirname(__FILE__)
    set :views, File.dirname(__FILE__) + "/views"
    set :logger, Logger.new($stdout)
    set :bind, "0.0.0.0"
    set :port, ENV.fetch("PORT", 4567)
    set :session_secret, ENV.fetch("SESSION_SECRET") { SecureRandom.hex(64) }
    set :host_authorization, {permitted_hosts: []}
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
    suggestions = if params["long_term_goals"].nil?
      ActivitySuggestion.new(player_name: params["username"], account_type: params["account_type"], intensity: intensity).suggestions
    else
      ActivitySuggestion.new(player_name: params["username"], account_type: params["account_type"], intensity: intensity).suggest_from_prompt("What are your long term goals?", params["long_term_goals"])
    end
    erb :"suggestion/show", locals: {suggestions: suggestions}, layout: false
  rescue ActivitySuggestion::InvalidPlayerError => e
    logger.error "Error fetching suggestions: #{e.message}"
    status 400
    e.message
  end

  # User inputs goals, then compares them to WiseOldMan's progress, with a history chart
  get "/goals" do
    erb :"goals/index"
  end

  get "/health" do
    status 204
    "ok"
  end

  # endpoint osrs chores endpoint for tracking weekly progress (ex: 100 zulrah kc/week, 50k agility/week)

  # scrape wiki money making and filter by player stats

  # Bone shard calculator

  # Best giants foundry items
  #   Use GE prices, filter items that are actively traded, compare prices

  # Better BIS table - pul player stats and compare common weapons in low defense contexts

  # Flipping Algo
  #   Start with high-volume items, filter by margin and volatility, then sort by ROI
  #   24h margin compared to 7-day volatility?
  #   Filter by 95 percentile to ignore huge random spikes
  #   Only consider items with buy_limit * max roi above a certain level

  # maybe move to a config.ru for deploys?
  if app_file == $0
    logger.info "Starting..."
    logger.info ENV
    run!
  end
end
