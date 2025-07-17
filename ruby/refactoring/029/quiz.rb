class TaxCalculator
  def calculate_tax(income, country, filing_status, year)
    tax = 0

    if country == 'US'
      if year == 2023
        if filing_status == 'single'
          tax = if income <= 11_000
                  income * 0.10
                elsif income <= 44_725
                  1100 + (income - 11_000) * 0.12
                elsif income <= 95_375
                  5147 + (income - 44_725) * 0.22
                elsif income <= 182_050
                  16_290 + (income - 95_375) * 0.24
                elsif income <= 231_250
                  37_104 + (income - 182_050) * 0.32
                elsif income <= 578_125
                  52_832 + (income - 231_250) * 0.35
                else
                  174_238.25 + (income - 578_125) * 0.37
                end
        elsif filing_status == 'married_joint'
          tax = if income <= 22_000
                  income * 0.10
                elsif income <= 89_450
                  2200 + (income - 22_000) * 0.12
                elsif income <= 190_750
                  10_294 + (income - 89_450) * 0.22
                elsif income <= 364_200
                  32_580 + (income - 190_750) * 0.24
                elsif income <= 462_500
                  74_208 + (income - 364_200) * 0.32
                elsif income <= 693_750
                  105_664 + (income - 462_500) * 0.35
                else
                  186_601.5 + (income - 693_750) * 0.37
                end
        elsif filing_status == 'married_separate'
          tax = if income <= 11_000
                  income * 0.10
                elsif income <= 44_725
                  1100 + (income - 11_000) * 0.12
                elsif income <= 95_375
                  5147 + (income - 44_725) * 0.22
                elsif income <= 182_100
                  16_290 + (income - 95_375) * 0.24
                elsif income <= 231_250
                  37_104 + (income - 182_100) * 0.32
                elsif income <= 346_875
                  52_832 + (income - 231_250) * 0.35
                else
                  93_300.75 + (income - 346_875) * 0.37
                end
        end
      elsif year == 2022
        if filing_status == 'single'
          tax = if income <= 10_275
                  income * 0.10
                elsif income <= 41_775
                  1027.5 + (income - 10_275) * 0.12
                else
                  4807.5 + (income - 41_775) * 0.22
                end
        end
      end
    elsif country == 'Canada'
      if year == 2023
        tax = if income <= 53_359
                income * 0.15
              elsif income <= 106_717
                8003.85 + (income - 53_359) * 0.205
              elsif income <= 165_430
                18_942.4 + (income - 106_717) * 0.26
              elsif income <= 235_675
                34_207.78 + (income - 165_430) * 0.29
              else
                54_581.05 + (income - 235_675) * 0.33
              end
      end
    elsif country == 'UK'
      if year == 2023
        tax = if income <= 12_570
                0
              elsif income <= 50_270
                (income - 12_570) * 0.20
              elsif income <= 125_140
                7540 + (income - 50_270) * 0.40
              else
                37_488 + (income - 125_140) * 0.45
              end
      end
    elsif country == 'Japan'
      if year == 2023
        tax = if income <= 1_950_000
                income * 0.05
              elsif income <= 3_300_000
                97_500 + (income - 1_950_000) * 0.10
              elsif income <= 6_950_000
                232_500 + (income - 3_300_000) * 0.20
              elsif income <= 9_000_000
                962_500 + (income - 6_950_000) * 0.23
              elsif income <= 18_000_000
                1_434_000 + (income - 9_000_000) * 0.33
              elsif income <= 40_000_000
                4_404_000 + (income - 18_000_000) * 0.40
              else
                13_204_000 + (income - 40_000_000) * 0.45
              end
      end
    else
      puts "Unknown country: #{country}"
      return 0
    end

    tax
  end

  def get_tax_brackets(country, year, filing_status = nil)
    brackets = []

    if country == 'US' && year == 2023
      if filing_status == 'single'
        brackets = [
          { min: 0, max: 11_000, rate: 0.10 },
          { min: 11_001, max: 44_725, rate: 0.12 },
          { min: 44_726, max: 95_375, rate: 0.22 },
          { min: 95_376, max: 182_050, rate: 0.24 },
          { min: 182_051, max: 231_250, rate: 0.32 },
          { min: 231_251, max: 578_125, rate: 0.35 },
          { min: 578_126, max: Float::INFINITY, rate: 0.37 }
        ]
      elsif filing_status == 'married_joint'
        brackets = [
          { min: 0, max: 22_000, rate: 0.10 },
          { min: 22_001, max: 89_450, rate: 0.12 },
          { min: 89_451, max: 190_750, rate: 0.22 },
          { min: 190_751, max: 364_200, rate: 0.24 },
          { min: 364_201, max: 462_500, rate: 0.32 },
          { min: 462_501, max: 693_750, rate: 0.35 },
          { min: 693_751, max: Float::INFINITY, rate: 0.37 }
        ]
      end
    elsif country == 'Canada' && year == 2023
      brackets = [
        { min: 0, max: 53_359, rate: 0.15 },
        { min: 53_360, max: 106_717, rate: 0.205 },
        { min: 106_718, max: 165_430, rate: 0.26 },
        { min: 165_431, max: 235_675, rate: 0.29 },
        { min: 235_676, max: Float::INFINITY, rate: 0.33 }
      ]
    end

    brackets
  end

  def get_deduction_amount(country, year, filing_status, deduction_type)
    amount = 0

    if country == 'US'
      if year == 2023
        case deduction_type
        when 'standard'
          if filing_status == 'single'
            amount = 13_850
          elsif filing_status == 'married_joint'
            amount = 27_700
          elsif filing_status == 'married_separate'
            amount = 13_850
          end
        when 'personal_exemption'
          amount = 0
        end
      elsif year == 2022
        case deduction_type
        when 'standard'
          if filing_status == 'single'
            amount = 12_950
          elsif filing_status == 'married_joint'
            amount = 25_900
          end
        end
      end
    elsif country == 'Canada'
      if year == 2023
        case deduction_type
        when 'basic_personal'
          amount = 15_000
        when 'canada_employment'
          amount = 1368
        end
      end
    end

    amount
  end

  def is_tax_year_valid?(year)
    valid_years = [2020, 2021, 2022, 2023]
    valid_years.include?(year)
  end

  def get_supported_countries
    %w[US Canada UK Japan]
  end

  def get_filing_statuses(country)
    statuses = []

    case country
    when 'US'
      statuses = %w[single married_joint married_separate head_of_household]
    when 'Canada'
      statuses = %w[single married common_law]
    when 'UK'
      statuses = %w[single married]
    when 'Japan'
      statuses = %w[single married]
    end

    statuses
  end
end
