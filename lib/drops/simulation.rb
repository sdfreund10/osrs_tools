module Drops
  class KcToFinishSimulation
    def initialize(boss = GeneralGraardor)
      @boss = boss
    end

    def simulate!
      1_000.times.map do
        Grind.new(@boss).simulate!
      end
    end
  end

  class Grind
    attr_reader :kc, :drops
    def initialize(boss = GeneralGraardor)
      @kc = 0
      @drops = {} # drop => [kc1, kc2, ...]
      @boss = boss
    end

    def simulate!
      until complete?
        @kc += 1
        drop = @boss.generate
        if drop
          # puts "Got a #{drop} at KC #{@kc}!"
          @drops[drop] ||= []
          @drops[drop] << @kc
        end
      end

      puts "Grind completed after #{@kc} kills!"
      puts "Drops received:"
      @drops.each do |drop, kcs|
        puts "- #{kcs.length} #{drop} at kcs #{kcs.join(", ")}"
      end
      self
    end

    def complete?
      @drops.keys.sort == @boss.items.sort
    end
  end

  class Boss
    attr_reader :name
    def initialize(name, drops)
      @name = name
      @drops = drops
    end

    def items
      @drops.keys
    end

    def generate
      seed = rand
      drop = nil

      @drops.each do |item, rate|
        if seed < rate
          drop = item
          break
        else
          seed -= rate
        end
      end
      drop
    end
  end

  GeneralGraardor = Boss.new(
    "General Graardor",
    {
      "Bandos chestplate" => 1.0 / 381,
      "Bandos tassets" => 1.0 / 381,
      "Bandos boots" => 1.0 / 381,
      "Bandos hilt" => 1.0 / 508
      # "Godsword shard 1" => 1.0 / 762,
      # "Godsword shard 2" => 1.0 / 726,
      # "Godsword shard 3" => 1.0 / 762
    }
  )
end
