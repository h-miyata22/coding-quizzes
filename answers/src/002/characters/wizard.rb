module Characters
  class Wizard < Base
    def initialize
      super(80, 120, 10, 8, %w[fireball heal])
    end

    def level_up
      @hp += 15
      @mp += 20
      @attack += 3
      @defense += 2
    end

    private

    def damage_rate(skill:)
      case skill
      when 'fireball'
        3.0
      else
        super
      end
    end

    def mp_cost(skill:)
      case skill
      when 'fireball'
        15
      else
        super
      end
    end
  end
end
