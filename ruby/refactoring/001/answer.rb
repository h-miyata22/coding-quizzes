class ReservationSystem
  ROOM_TYPES = {
    single: { id: 1, name: 'Single room', base_price: 8000 },
    double: { id: 2, name: 'Double room', base_price: 12_000 },
    suite: { id: 3, name: 'Suite', base_price: 20_000 }
  }.freeze

  PEAK_SEASON_MONTH = '08'
  PEAK_SEASON_MULTIPLIER = 1.5
  GOLD_MEMBER_DISCOUNT = 0.9
  GOLD_MEMBER_PREFIX = 'G'

  def check_reservation(user, room_type_id, date_string)
    return 'error' unless valid_user?(user)
    return 'error' unless valid_date?(date_string)

    room_type = find_room_type(room_type_id)
    return 'error' unless room_type

    price = calculate_price(room_type[:base_price], date_string, user)
    "#{room_type[:name]} reserved for #{date_string}. Price: #{price}"
  end

  private

  def valid_user?(user)
    !user.nil?
  end

  def valid_date?(date_string)
    return false unless date_string.match?(/\A\d{4}-\d{2}-\d{2}\z/)

    year, month, day = date_string.split('-').map(&:to_i)

    year >= 2024 &&
      month.between?(1, 12) &&
      day.between?(1, days_in_month(month, year))
  end

  def days_in_month(month, year)
    case month
    when 2
      leap_year?(year) ? 29 : 28
    when 4, 6, 9, 11
      30
    else
      31
    end
  end

  def leap_year?(year)
    (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
  end

  def find_room_type(room_type_id)
    ROOM_TYPES.values.find { |type| type[:id] == room_type_id }
  end

  def calculate_price(base_price, date_string, user)
    price = base_price
    price *= PEAK_SEASON_MULTIPLIER if peak_season?(date_string)
    price *= GOLD_MEMBER_DISCOUNT if gold_member?(user)
    price.to_i
  end

  def peak_season?(date_string)
    date_string[5..6] == PEAK_SEASON_MONTH
  end

  def gold_member?(user)
    user.start_with?(GOLD_MEMBER_PREFIX)
  end
end
