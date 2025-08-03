require_relative 'room/base'
require_relative 'room/suite'
require_relative 'room/double'
require_relative 'room/single'
require_relative 'reservation_system'

reservation_system = ReservationSystem.new('G123', 1, '2024-12-15')

puts reservation_system.check_reservation
