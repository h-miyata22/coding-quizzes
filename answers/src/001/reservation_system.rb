class ReservationSystem
  def initialize(user, room_type, date)
    @user = user
    @room_type = room_type
    @date = date
  end

  attr_reader :user, :room_type, :date

  def check_reservation
    return 'error' if user.nil? || room_type.nil? || date.nil? || room.nil?
    return 'error' unless reservable_date?

    display_reservation
  end

  private

  def display_reservation
    "#{room.name} reserved for #{date}. Price: #{price}"
  end

  def valid?
    return false if user.nil? || room_type.nil? || date.nil? || room.nil? || user_type.nil?
    return false unless reservable_date?

    true
  end

  def reservable_date?
    target_year = 2024

    return false if month < 1 || month > 12 || day < 1 || day > 31

    return year >= target_year
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
    date[0..3].to_i
  end

  def month
    date[5..6].to_i
  end

  def day
    date[8..9].to_i
  end

  def user_type
    user[0]
  end

  def price
    base_price = room.base_price

    if month == 8
      base_price *= room.aug_price_rate
    end

    if user_type == 'G'
      base_price *= room.g_user_price_rate
    end

    base_price.to_i
  end
end
