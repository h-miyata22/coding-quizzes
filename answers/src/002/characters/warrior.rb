module Characters
  class Warrior < Base
    def initialize
      super(150, 30, 25, 20, %w[slash guard])
    end

    def level_up
      @hp += 30
      @mp += 5
      @attack += 5
      @defense += 4
    end

    private

    def damage_rate(skill:)
      case skill
      when 'slash'
        1.5
      else
        super
      end
    end

    def mp_cost(skill:)
      case skill
      when 'slash'
        5
      else
        super
      end
    end
  end
end
