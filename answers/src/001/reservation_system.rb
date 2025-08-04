require 'date'

class ReservationSystem
  TARGET_YEAR = 2024
  HIGH_SEASON_MONTH = 8
  GOLD_USER_PREFIX = 'G'

  def initialize(user, room_type, date)
    @user = user
    @room_type = room_type
    @date = date
  end

  def check_reservation
    return 'error' unless valid?

    display_reservation
  end

  private

  attr_reader :user, :room_type, :date

  def display_reservation
    "#{room.name} reserved for #{date}. Price: #{price}"
  end

  def valid?
    !room.nil? && reservable_date?
  end

  def reservable_date?
    begin
      Date.parse(date)
    rescue Date::Error
      return false
    end

    year >= TARGET_YEAR
  end

  def room
    case room_type
        when 1
          Room::Single.new
        when 2
          Room::Double.new
        when 3
          Room::Suite.new
    end
  end

  def year
    Date.parse(date).year
  end

  def month
    Date.parse(date).month
  end

  def day
    Date.parse(date).day
  end

  def user_type_prefix
    user[0]
  end

  def price
    base_price = room.base_price

    if month == HIGH_SEASON_MONTH
      base_price *= room.aug_price_rate
    end

    if user_type_prefix == GOLD_USER_PREFIX
      base_price *= room.g_user_price_rate
    end

    base_price.to_i
  end
end
