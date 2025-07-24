require_relative "prices_api"
require_relative "price"

class Item
  NATURE_RUNE_PRICE = 110 # typically less than this, but better to be conservative

  attr_reader :id, :name, :icon, :highalch, :limit, :members
  def initialize(id, name, icon, highalch, limit, members)
    @id = id
    @name = name
    @icon = icon
    @highalch = highalch
    @limit = limit
    @members = members
  end

  alias_method :trade_limit, :limit

  def price
    Price.find(id)
  end

  def price_range
    price&.range
  end

  def thumbnail
    return nil if icon.nil? || icon.empty?

    "https://oldschool.runescape.wiki/images/a/a2/#{icon.tr(" ", "_")}"
  rescue => e
    puts "Error fetching item thumbnail for ID=#{id}, Name=#{name}: #{e.message}"
    nil
  end

  def instant_buy_price
    price&.instant_buy_price
  end

  def instant_sell_price
    price&.instant_sell_price
  end

  def alch_profit
    return 0 if price.nil? || price.instant_buy_price.nil? # maybe this needs a fallback to the buy sell price for higher-volume items?
    return 0 if highalch.nil?

    highalch - price.instant_buy_price - NATURE_RUNE_PRICE
  rescue => e
    puts "Name=#{name}, ID=#{id}, highalch=#{highalch}, price=#{price.instant_buy_price} - Error fetching price data"
    raise e
  end

  alias_method :profit, :alch_profit

  def profitable?
    profit.positive?
  end

  def actively_traded?
    return false if price&.trade_volume.nil? || limit.nil?

    price.trade_volume > (limit / 2) # kinda arbitrary, but this is just a significant portion of the trade limit
  end

  def one_hour_alch_profit # profit from alching a full buy limit, or 1 hour of alching, whichever is less
    alchs_per_hour = [limit, 1200].min
    profit * alchs_per_hour
  end

  def profit_per_trade_offer # profit from alching an amount that feels reasonable to me, no logic, just my feelings
    profit * trade_offer_size
  end

  def profit_per_minute
    alchs_per_minute = [limit, 60].min
    profit * alchs_per_minute
  end

  # Kinda arbitrary, but I don't want to invest in more than 125 alchs at a time.
  # Most alchables have a buy limit under 125 anyway.
  def trade_offer_size
    [limit, 125].min
  end

  def cost_per_trade_offer
    return 0 if instant_buy_price.nil? || trade_offer_size <= 0

    trade_offer_size * instant_buy_price
  end

  def roi
    profit.to_f / instant_buy_price.to_f
  end

  def trade_volume
    price.trade_volume
  end

  def self.list
    PricesApi.items.map do |item|
      new(item["id"], item["name"], item["icon"], item["highalch"], item["limit"], item["members"])
    end
  end

  def self.trade_candidates
    list.select(&:profitable?).select(&:actively_traded?).sort_by(&:profit_per_trade_offer).reverse
  end

  def self.find(id)
    list.find { |item| item.id == id }
  end

  def self.find_by_name(name)
    list.find { |item| item.name.downcase == name.downcase }
  end

  def self.search(name)
    list.select { |item| item.name.downcase.include?(name.downcase) }
  end

  def self.nature_rune_price
    find_by_name("Nature rune")&.instant_buy_price || 110
  end
end
