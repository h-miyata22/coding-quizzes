require 'spec_helper'
require_relative '../../src/001/room/base'
require_relative '../../src/001/room/single'
require_relative '../../src/001/room/double'
require_relative '../../src/001/room/suite'
require_relative '../../src/001/reservation_system'

RSpec.describe ReservationSystem do
  describe '#check_reservation' do
    it 'returns error if year is less than 2024' do
      system = ReservationSystem.new('G123', 1, '2023-01-01')
      expect(system.check_reservation).to eq('error')
    end

    it 'returns not error if year is greater than 2024' do
      system = ReservationSystem.new('G123', 1, '2025-01-01')
      expect(system.check_reservation).not_to eq('error')
    end

    it 'returns error if month is less than 1' do
      system = ReservationSystem.new('G123', 1, '2024-00-01')
      expect(system.check_reservation).to eq('error')
    end

    it 'returns not error if month is greater than 1' do
      system = ReservationSystem.new('G123', 1, '2024-01-01')
      expect(system.check_reservation).not_to eq('error')
    end

    it 'returns not error if month is less than 12' do
      system = ReservationSystem.new('G123', 1, '2024-12-01')
      expect(system.check_reservation).not_to eq('error')
    end

    it 'returns not error if month is greater than 12' do
      system = ReservationSystem.new('G123', 1, '2024-13-01')
      expect(system.check_reservation).to eq('error')
    end

    it 'returns error if day is less than 1' do
      system = ReservationSystem.new('G123', 1, '2024-12-00')
      expect(system.check_reservation).to eq('error')
    end

    it 'returns not error if day is greater than 1' do
      system = ReservationSystem.new('G123', 1, '2024-12-01')
      expect(system.check_reservation).not_to eq('error')
    end

    it 'returns not error if day is greater than 31' do
      system = ReservationSystem.new('G123', 1, '2024-12-31')
      expect(system.check_reservation).not_to eq('error')
    end

    it 'returns error if day is greater than 31' do 
      system = ReservationSystem.new('G123', 1, '2024-12-32')
      expect(system.check_reservation).to eq('error')
    end

    # room_typeが1の場合
    describe 'room_typeが1の場合' do
      it '8月でなくゴールドメンバーでない場合' do
        system = ReservationSystem.new('X123', 1, '2024-01-01')
        expect(system.check_reservation).to eq('Single Room reserved for 2024-01-01. Price: 8000')
      end

      it '8月でなくゴールドメンバーである場合' do
        system = ReservationSystem.new('G123', 1, '2024-01-01')
        expect(system.check_reservation).to eq('Single Room reserved for 2024-01-01. Price: 7200')
      end

      it '8月でゴールドメンバーでない場合' do
        system = ReservationSystem.new('X123', 1, '2024-08-01')
        expect(system.check_reservation).to eq('Single Room reserved for 2024-08-01. Price: 12000')
      end

      it '8月でゴールドメンバーである場合' do
        system = ReservationSystem.new('G123', 1, '2024-08-01')
        expect(system.check_reservation).to eq('Single Room reserved for 2024-08-01. Price: 10800')
      end
    end

    # room_typeが2の場合
    describe 'room_typeが2の場合' do
      it '8月でなくゴールドメンバーでない場合' do
        system = ReservationSystem.new('X123', 2, '2024-01-01')
        expect(system.check_reservation).to eq('Double Room reserved for 2024-01-01. Price: 12000')
      end

      it '8月でなくゴールドメンバーである場合' do
        system = ReservationSystem.new('G123', 2, '2024-01-01')
        expect(system.check_reservation).to eq('Double Room reserved for 2024-01-01. Price: 10800')
      end

      it '8月でゴールドメンバーでない場合' do
        system = ReservationSystem.new('X123', 2, '2024-08-01')
        expect(system.check_reservation).to eq('Double Room reserved for 2024-08-01. Price: 18000')
      end

      it '8月でゴールドメンバーである場合' do
        system = ReservationSystem.new('G123', 2, '2024-08-01')
        expect(system.check_reservation).to eq('Double Room reserved for 2024-08-01. Price: 16200')
      end
    end

    # room_typeが3の場合
    describe 'room_typeが3の場合' do
      it '8月でなくゴールドメンバーでない場合' do
        system = ReservationSystem.new('X123', 3, '2024-01-01')
        expect(system.check_reservation).to eq('Suite reserved for 2024-01-01. Price: 20000')
      end

      it '8月でなくゴールドメンバーである場合' do
        system = ReservationSystem.new('G123', 3, '2024-01-01')
        expect(system.check_reservation).to eq('Suite reserved for 2024-01-01. Price: 18000')
      end

      it '8月でゴールドメンバーでない場合' do
        system = ReservationSystem.new('X123', 3, '2024-08-01')
        expect(system.check_reservation).to eq('Suite reserved for 2024-08-01. Price: 30000')
      end

      it '8月でゴールドメンバーである場合' do
        system = ReservationSystem.new('G123', 3, '2024-08-01')
        expect(system.check_reservation).to eq('Suite reserved for 2024-08-01. Price: 27000')
      end
    end

    # room_typeが1,2,3以外の場合
    describe 'room_typeが1,2,3以外の場合' do
      it 'room_typeが1,2,3以外の場合' do
        system = ReservationSystem.new('G123', 4, '2024-01-01')
        expect(system.check_reservation).to eq('error')
      end
    end
  end
end
