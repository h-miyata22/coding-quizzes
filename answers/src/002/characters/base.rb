module Characters
  class Base
    def initialize(hp, mp, attack, defense, skills)
      @hp = hp
      @mp = mp
      @attack = attack
      @defense = defense
      @skills = skills
    end

    attr_reader :defense
    attr_accessor :hp

    def level_up
      raise NotImplementedError, 'Subclass must implement this method'
    end

    def attack_enemy(enemy:, skill: 'normal')
      unless can_use_skill?(skill:)
        raise ArgumentError, "Skill #{skill} is not available"
      end

      unless has_enough_mp?(skill:)
        raise ArgumentError, "Not enough MP to use skill #{skill}"
      end

      consume_mp(skill:)
      damage = calculate_damage(skill:, enemy:)
      enemy.hp -= damage
      damage
    end

    def has_enough_mp?(skill:)
      mp_cost(skill:) <= @mp
    end

    private

    def calculate_damage(skill:, enemy:)
      base_damage = base_damage(skill:)
      damage_reduction = enemy.defense * 0.5
      final_damage = base_damage - damage_reduction
      final_damage = 0 if final_damage < 0
      final_damage
    end

    def base_damage(skill:)
      @attack * damage_rate(skill:)
    end

    def damage_rate(skill:)
      case skill
      when 'normal'
        1.0
      else
        raise NotImplementedError, 'Subclass must implement this method'
      end
    end

    def can_use_skill?(skill:)
      skill == 'normal' || @skills.include?(skill)
    end

    def consume_mp(skill:)
      cost = mp_cost(skill:)
      @mp -= cost
    end

    def mp_cost(skill:)
      case skill
      when 'normal'
        0
      else
        raise NotImplementedError, 'Subclass must implement mp_cost method'
      end
    end
  end
end
