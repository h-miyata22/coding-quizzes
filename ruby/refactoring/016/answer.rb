require 'time'

class EventScheduler
  def create_event(title, start_time_str, duration_hours)
    start_time = parse_time(start_time_str)
    return { error: 'Invalid time format' } unless start_time

    time_range = TimeRange.new(start_time, duration_hours)
    validator = EventValidator.new(time_range)

    validation_result = validator.validate
    return validation_result unless validation_result[:success]

    conflict = ConflictChecker.new.find_conflict(time_range)
    return { error: "Time slot conflicts with existing event: #{conflict.title}" } if conflict

    event = Event.create!(
      title: title,
      start_time: time_range.start_time,
      end_time: time_range.end_time,
      duration: duration_hours
    )

    { success: true, event: event }
  end

  def get_available_slots(date_str, slot_duration_hours)
    date = parse_date(date_str)
    return [] unless date

    business_hours = BusinessHours.new(date)
    scheduler = SlotFinder.new(business_hours, slot_duration_hours)

    scheduler.find_available_slots
  end

  private

  def parse_time(time_str)
    Time.parse(time_str)
  rescue ArgumentError
    nil
  end

  def parse_date(date_str)
    Date.parse(date_str)
  rescue ArgumentError
    nil
  end
end

class TimeRange
  attr_reader :start_time, :end_time, :duration_hours

  def initialize(start_time, duration_hours)
    @start_time = start_time
    @duration_hours = duration_hours
    @end_time = start_time + (duration_hours * 3600)
  end

  def overlaps?(other)
    return false unless other

    (start_time >= other.start_time && start_time < other.end_time) ||
      (end_time > other.start_time && end_time <= other.end_time) ||
      (start_time <= other.start_time && end_time >= other.end_time)
  end

  def covers?(time)
    time >= start_time && time < end_time
  end
end

class EventValidator
  MINIMUM_DURATION = 0
  MAXIMUM_DURATION = 24

  def initialize(time_range)
    @time_range = time_range
  end

  def validate
    return { error: 'Start time must be in the future' } if past_event?
    unless valid_duration?
      return { error: "Duration must be between #{MINIMUM_DURATION} and #{MAXIMUM_DURATION} hours" }
    end

    { success: true }
  end

  private

  def past_event?
    @time_range.start_time < Time.now
  end

  def valid_duration?
    @time_range.duration_hours > MINIMUM_DURATION &&
      @time_range.duration_hours <= MAXIMUM_DURATION
  end
end

class ConflictChecker
  def find_conflict(time_range)
    Event.all.find { |event| event_overlaps?(event, time_range) }
  end

  private

  def event_overlaps?(event, time_range)
    event_range = TimeRange.new(event.start_time, event.duration)
    time_range.overlaps?(event_range)
  end
end

class BusinessHours
  DEFAULT_START_HOUR = 9
  DEFAULT_END_HOUR = 18

  attr_reader :date, :start_time, :end_time

  def initialize(date, start_hour: DEFAULT_START_HOUR, end_hour: DEFAULT_END_HOUR)
    @date = date
    @start_time = Time.new(date.year, date.month, date.day, start_hour, 0)
    @end_time = Time.new(date.year, date.month, date.day, end_hour, 0)
  end

  def covers?(time)
    time >= start_time && time <= end_time
  end
end

class SlotFinder
  def initialize(business_hours, slot_duration_hours)
    @business_hours = business_hours
    @slot_duration_seconds = slot_duration_hours * 3600
  end

  def find_available_slots
    events = events_in_business_hours
    build_slots_around_events(events)
  end

  private

  def events_in_business_hours
    Event.where(
      start_time: @business_hours.start_time...@business_hours.end_time
    ).order(:start_time)
  end

  def build_slots_around_events(events)
    slots = []
    current_time = @business_hours.start_time

    events.each do |event|
      slots << create_slot(current_time, event.start_time) if slot_fits_before?(current_time, event.start_time)
      current_time = event.end_time
    end

    if slot_fits_before?(current_time, @business_hours.end_time)
      slots << create_slot(current_time, @business_hours.end_time)
    end

    slots
  end

  def slot_fits_before?(start_time, end_time)
    start_time + @slot_duration_seconds <= end_time
  end

  def create_slot(start_time, end_time)
    { start: start_time, end: end_time }
  end
end
