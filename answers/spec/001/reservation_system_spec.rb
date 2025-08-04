require 'spec_helper'
require_relative '../../src/001/room/base'
require_relative '../../src/001/room/single'
require_relative '../../src/001/room/double'
require_relative '../../src/001/room/suite'
require_relative '../../src/001/reservation_system'

RSpec.describe ReservationSystem do
  describe '#check_reservation' do
    context 'yearが2024未満の場合' do
      it 'errorを返す' do
        system = ReservationSystem.new('G123', 1, '2023-01-01')
        expect(system.check_reservation).to eq('error')
      end
    end

    context 'yearが2024以上の場合' do
      it 'errorを返さない' do
        system = ReservationSystem.new('G123', 1, '2025-01-01')
        expect(system.check_reservation).not_to eq('error')
      end
    end

    context 'dateの形式が不正な場合' do
      it 'errorを返す' do
        system = ReservationSystem.new('G123', 1, '2024-02-30')
        expect(system.check_reservation).to eq('error')
      end
    end

    context 'dateの形式が正しい場合' do
      it 'errorを返さない' do
        system = ReservationSystem.new('G123', 1, '2024-01-01')
        expect(system.check_reservation).not_to eq('error')
      end
    end

    context 'room_typeが不正な値の場合' do
      it 'errorを返す' do
        system = ReservationSystem.new('G123', 4, '2024-01-01')
        expect(system.check_reservation).to eq('error')
      end
    end

    context 'room_typeが正しい値の場合' do
      it 'errorを返さない' do
        system = ReservationSystem.new('G123', 1, '2024-01-01')
        expect(system.check_reservation).not_to eq('error')
      end
    end

    context 'Single Roomの場合' do
      context '繁忙期の場合' do
        context 'ゴールドメンバーでない場合' do
          it '返り値が正しいこと' do
            system = ReservationSystem.new('X123', 1, '2024-08-01')
            expect(system.check_reservation).to eq('Single Room reserved for 2024-08-01. Price: 12000')
          end
        end

        context 'ゴールドメンバーである場合' do
          it '返り値が正しいこと' do
            system = ReservationSystem.new('G123', 1, '2024-08-01')
            expect(system.check_reservation).to eq('Single Room reserved for 2024-08-01. Price: 10800')
          end
        end
      end

      context '繁忙期でない場合' do
        context 'ゴールドメンバーでない場合' do
          it '返り値が正しいこと' do
            system = ReservationSystem.new('X123', 1, '2024-01-01')
            expect(system.check_reservation).to eq('Single Room reserved for 2024-01-01. Price: 8000')
          end
        end

        context 'ゴールドメンバーである場合' do
          it '返り値が正しいこと' do
            system = ReservationSystem.new('G123', 1, '2024-01-01')
            expect(system.check_reservation).to eq('Single Room reserved for 2024-01-01. Price: 7200')
          end
        end
      end
    end

    context 'Double Roomの場合' do
      context '繁忙期の場合' do
        context 'ゴールドメンバーでない場合' do
          it '返り値が正しいこと' do
            system = ReservationSystem.new('X123', 2, '2024-08-01')
            expect(system.check_reservation).to eq('Double Room reserved for 2024-08-01. Price: 18000')
          end
        end

        context 'ゴールドメンバーである場合' do
          it '返り値が正しいこと' do
            system = ReservationSystem.new('G123', 2, '2024-08-01')
            expect(system.check_reservation).to eq('Double Room reserved for 2024-08-01. Price: 16200')
          end
        end
      end

      context '繁忙期でない場合' do
        context 'ゴールドメンバーでない場合' do
          it '返り値が正しいこと' do
            system = ReservationSystem.new('X123', 2, '2024-01-01')
            expect(system.check_reservation).to eq('Double Room reserved for 2024-01-01. Price: 12000')
          end
        end

        context 'ゴールドメンバーである場合' do
          it '返り値が正しいこと' do
            system = ReservationSystem.new('G123', 2, '2024-01-01')
            expect(system.check_reservation).to eq('Double Room reserved for 2024-01-01. Price: 10800')
          end
        end
      end
    end

    context 'Suite Roomの場合' do
      context '繁忙期の場合' do
        context 'ゴールドメンバーでない場合' do
          it '返り値が正しいこと' do
            system = ReservationSystem.new('X123', 3, '2024-08-01')
            expect(system.check_reservation).to eq('Suite reserved for 2024-08-01. Price: 30000')
          end
        end

        context 'ゴールドメンバーである場合' do
          it '返り値が正しいこと' do
            system = ReservationSystem.new('G123', 3, '2024-08-01')
            expect(system.check_reservation).to eq('Suite reserved for 2024-08-01. Price: 27000')
          end
        end
      end

      context '繁忙期でない場合' do
        context 'ゴールドメンバーでない場合' do
          it '返り値が正しいこと' do
            system = ReservationSystem.new('X123', 3, '2024-01-01')
            expect(system.check_reservation).to eq('Suite reserved for 2024-01-01. Price: 20000')
          end
        end

        context 'ゴールドメンバーである場合' do
          it '返り値が正しいこと' do
            system = ReservationSystem.new('G123', 3, '2024-01-01')
            expect(system.check_reservation).to eq('Suite reserved for 2024-01-01. Price: 18000')
          end
        end
      end
    end
  end
end
