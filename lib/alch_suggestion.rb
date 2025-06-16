require_relative "item"
# HEAVY WIP - no idea how to do this logic yet
class AlchSuggestion
  attr_reader :alchs, :capital, :num_items
  def initialize(alchs, capital, num_items)
    @alchs = alchs
    @capital = capital
    @num_items = num_items
  end

  def items
  end

  private

  def run
    # for num_items = 1, find an item that fills up the whole volume with the highest return under the capital limit
  end

  class SingleItemSuggestion
    attr_reader :alchs, :capital
    def initialize(alchs, capital)
      @alchs = alchs
      @capital = capital
    end

    # if the user is just interested in the best return and is ok if they run out
    def best_return
      affordable_items = Item.trade_candidates.filter do |item|
        # do something about how many the user can afford?
        purchase_size = [alchs, item.trade_limit].min
        item.instant_buy_price * purchase_size < capital
      end
      affordable_items.max_by do |item|
        purchase_size = [alchs, item.trade_limit].min
        item.profit * purchase_size
      end
    end
  end
end
