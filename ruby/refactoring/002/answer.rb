class GameCharacter
  attr_reader :hp, :mp, :attack, :defense, :skills

  def initialize(character_class)
    @character_class = character_class.to_sym
    stats = CHARACTER_STATS[@character_class]
    raise ArgumentError, "Unknown character class: #{character_class}" unless stats

    @hp = stats[:hp]
    @mp = stats[:mp]
    @attack = stats[:attack]
    @defense = stats[:defense]
    @skills = stats[:skills]
  end

  def attack_enemy(enemy, skill_name = 'normal')
    damage = calculate_damage(skill_name)
    final_damage = apply_defense(damage, enemy.defense)
    enemy.take_damage(final_damage)
    final_damage
  end

  def level_up
    growth = LEVEL_UP_STATS[@character_class]
    @hp += growth[:hp]
    @mp += growth[:mp]
    @attack += growth[:attack]
    @defense += growth[:defense]
  end

  def take_damage(damage)
    @hp -= damage
    @hp = 0 if @hp < 0
  end

  private

  CHARACTER_STATS = {
    warrior: {
      hp: 150, mp: 30, attack: 25, defense: 20,
      skills: %w[slash guard]
    },
    wizard: {
      hp: 80, mp: 120, attack: 10, defense: 8,
      skills: %w[fireball heal]
    },
    archer: {
      hp: 100, mp: 50, attack: 20, defense: 12,
      skills: %w[arrow multishot]
    }
  }.freeze

  SKILL_COSTS = {
    warrior: { slash: { mp: 5, multiplier: 1.5 } },
    wizard: { fireball: { mp: 15, multiplier: 3.0 } },
    archer: { multishot: { mp: 10, multiplier: 2.0 } }
  }.freeze

  LEVEL_UP_STATS = {
    warrior: { hp: 30, mp: 5, attack: 5, defense: 4 },
    wizard: { hp: 15, mp: 20, attack: 3, defense: 2 },
    archer: { hp: 20, mp: 10, attack: 4, defense: 3 }
  }.freeze

  DEFENSE_REDUCTION_RATE = 0.5

  def calculate_damage(skill_name)
    return @attack if skill_name == 'normal'

    skill_info = SKILL_COSTS[@character_class]&.fetch(skill_name.to_sym, nil)
    return 0 unless skill_info && can_use_skill?(skill_info[:mp])

    consume_mp(skill_info[:mp])
    @attack * skill_info[:multiplier]
  end

  def can_use_skill?(mp_cost)
    @mp >= mp_cost
  end

  def consume_mp(mp_cost)
    @mp -= mp_cost
  end

  def apply_defense(damage, enemy_defense)
    reduced_damage = damage - (enemy_defense * DEFENSE_REDUCTION_RATE)
    [reduced_damage, 0].max
  end
end
