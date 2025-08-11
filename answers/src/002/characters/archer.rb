module Characters
  class Archer < Base
    def initialize
      super(100, 50, 20, 12, %w[arrow multishot])
    end

    def level_up
      @hp += 20
      @mp += 10
      @attack += 4
      @defense += 3
    end

    private

    def damage_rate(skill:)
      case skill
      when 'multishot'
        2.0
      else
        super
      end
    end

    def mp_cost(skill:)
      case skill
      when 'multishot'
        10
      else
        super
      end
    end
  end
end
