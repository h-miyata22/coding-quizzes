require_relative 'base'
require_relative 'warrior'
require_relative 'wizard'
require_relative 'archer'

module Characters
  class Factory
    def self.create(type)
      case type
      when 'warrior'
        Warrior.new
      when 'wizard'
        Wizard.new
      when 'archer'
        Archer.new
      else
        raise ArgumentError, "Unknown character type: #{type}"
      end
    end
  end
end
