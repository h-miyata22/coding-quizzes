class TaxCalculator
  def initialize
    @tax_tables = TaxTableRegistry.new
    @deduction_tables = DeductionTableRegistry.new
    @configuration = TaxSystemConfiguration.new
  end

  def calculate_tax(income, country, filing_status, year)
    tax_context = TaxContext.new(
      income: income,
      country: country,
      filing_status: filing_status,
      year: year
    )

    tax_brackets = @tax_tables.get_brackets(tax_context)
    calculator = ProgressiveTaxCalculator.new(tax_brackets)

    calculator.calculate(income)
  end

  def get_tax_brackets(country, year, filing_status = nil)
    tax_context = TaxContext.new(
      country: country,
      year: year,
      filing_status: filing_status
    )

    @tax_tables.get_brackets(tax_context)
  end

  def get_deduction_amount(country, year, filing_status, deduction_type)
    deduction_context = DeductionContext.new(
      country: country,
      year: year,
      filing_status: filing_status,
      deduction_type: deduction_type
    )

    @deduction_tables.get_amount(deduction_context)
  end

  def is_tax_year_valid?(year)
    @configuration.valid_years.include?(year)
  end

  def get_supported_countries
    @configuration.supported_countries
  end

  def get_filing_statuses(country)
    @configuration.filing_statuses_for(country)
  end
end

class TaxContext
  attr_reader :income, :country, :year, :filing_status

  def initialize(country:, year:, income: nil, filing_status: nil)
    @income = income
    @country = country.to_s.upcase
    @year = year.to_i
    @filing_status = filing_status&.to_s
  end

  def key
    [@country, @year, @filing_status].compact.join('_')
  end
end

class DeductionContext
  attr_reader :country, :year, :filing_status, :deduction_type

  def initialize(country:, year:, filing_status:, deduction_type:)
    @country = country.to_s.upcase
    @year = year.to_i
    @filing_status = filing_status.to_s
    @deduction_type = deduction_type.to_s
  end

  def key
    [@country, @year, @filing_status, @deduction_type].join('_')
  end
end

class TaxBracket
  attr_reader :min_income, :max_income, :rate, :base_tax, :bracket_start

  def initialize(min_income:, max_income:, rate:, base_tax: nil, bracket_start: nil)
    @min_income = min_income
    @max_income = max_income
    @rate = rate
    @base_tax = base_tax
    @bracket_start = bracket_start || min_income
  end

  def includes?(income)
    income >= @min_income && income <= @max_income
  end

  def calculate_tax(income)
    return 0 if income < @min_income

    taxable_in_bracket = [income, @max_income].min - @bracket_start
    bracket_tax = taxable_in_bracket * @rate

    (@base_tax || 0) + bracket_tax
  end

  def to_h
    {
      min: @min_income,
      max: @max_income == Float::INFINITY ? Float::INFINITY : @max_income,
      rate: @rate
    }
  end
end

class ProgressiveTaxCalculator
  def initialize(tax_brackets)
    @tax_brackets = tax_brackets
  end

  def calculate(income)
    applicable_bracket = find_bracket(income)
    return 0 unless applicable_bracket

    applicable_bracket.calculate_tax(income)
  end

  private

  def find_bracket(income)
    @tax_brackets.find { |bracket| bracket.includes?(income) }
  end
end

class TaxTableRegistry
  def initialize
    @tables = build_tax_tables
  end

  def get_brackets(tax_context)
    table_key = tax_context.key
    brackets_data = @tables[table_key]

    raise UnsupportedTaxJurisdiction, "No tax table for #{table_key}" unless brackets_data

    brackets_data
  end

  private

  def build_tax_tables
    TableBuilder.new.build_all_tables
  end
end

class TableBuilder
  def build_all_tables
    tables = {}

    # US Tables
    tables.merge!(build_us_tables)

    # Canada Tables
    tables.merge!(build_canada_tables)

    # UK Tables
    tables.merge!(build_uk_tables)

    # Japan Tables
    tables.merge!(build_japan_tables)

    tables
  end

  private

  def build_us_tables
    {
      'US_2023_single' => build_us_2023_single,
      'US_2023_married_joint' => build_us_2023_married_joint,
      'US_2023_married_separate' => build_us_2023_married_separate,
      'US_2022_single' => build_us_2022_single
    }
  end

  def build_us_2023_single
    build_progressive_brackets([
                                 { min: 0, max: 11_000, rate: 0.10 },
                                 { min: 11_001, max: 44_725, rate: 0.12, base: 1100, start: 11_000 },
                                 { min: 44_726, max: 95_375, rate: 0.22, base: 5147, start: 44_725 },
                                 { min: 95_376, max: 182_050, rate: 0.24, base: 16_290, start: 95_375 },
                                 { min: 182_051, max: 231_250, rate: 0.32, base: 37_104, start: 182_050 },
                                 { min: 231_251, max: 578_125, rate: 0.35, base: 52_832, start: 231_250 },
                                 { min: 578_126, max: Float::INFINITY, rate: 0.37, base: 174_238.25, start: 578_125 }
                               ])
  end

  def build_us_2023_married_joint
    build_progressive_brackets([
                                 { min: 0, max: 22_000, rate: 0.10 },
                                 { min: 22_001, max: 89_450, rate: 0.12, base: 2200, start: 22_000 },
                                 { min: 89_451, max: 190_750, rate: 0.22, base: 10_294, start: 89_450 },
                                 { min: 190_751, max: 364_200, rate: 0.24, base: 32_580, start: 190_750 },
                                 { min: 364_201, max: 462_500, rate: 0.32, base: 74_208, start: 364_200 },
                                 { min: 462_501, max: 693_750, rate: 0.35, base: 105_664, start: 462_500 },
                                 { min: 693_751, max: Float::INFINITY, rate: 0.37, base: 186_601.5, start: 693_750 }
                               ])
  end

  def build_us_2023_married_separate
    build_progressive_brackets([
                                 { min: 0, max: 11_000, rate: 0.10 },
                                 { min: 11_001, max: 44_725, rate: 0.12, base: 1100, start: 11_000 },
                                 { min: 44_726, max: 95_375, rate: 0.22, base: 5147, start: 44_725 },
                                 { min: 95_376, max: 182_100, rate: 0.24, base: 16_290, start: 95_375 },
                                 { min: 182_101, max: 231_250, rate: 0.32, base: 37_104, start: 182_100 },
                                 { min: 231_251, max: 346_875, rate: 0.35, base: 52_832, start: 231_250 },
                                 { min: 346_876, max: Float::INFINITY, rate: 0.37, base: 93_300.75, start: 346_875 }
                               ])
  end

  def build_us_2022_single
    build_progressive_brackets([
                                 { min: 0, max: 10_275, rate: 0.10 },
                                 { min: 10_276, max: 41_775, rate: 0.12, base: 1027.5, start: 10_275 },
                                 { min: 41_776, max: Float::INFINITY, rate: 0.22, base: 4807.5, start: 41_775 }
                               ])
  end

  def build_canada_tables
    {
      'CANADA_2023_' => build_canada_2023
    }
  end

  def build_canada_2023
    build_progressive_brackets([
                                 { min: 0, max: 53_359, rate: 0.15 },
                                 { min: 53_360, max: 106_717, rate: 0.205, base: 8003.85, start: 53_359 },
                                 { min: 106_718, max: 165_430, rate: 0.26, base: 18_942.4, start: 106_717 },
                                 { min: 165_431, max: 235_675, rate: 0.29, base: 34_207.78, start: 165_430 },
                                 { min: 235_676, max: Float::INFINITY, rate: 0.33, base: 54_581.05, start: 235_675 }
                               ])
  end

  def build_uk_tables
    {
      'UK_2023_' => build_uk_2023
    }
  end

  def build_uk_2023
    build_progressive_brackets([
                                 { min: 0, max: 12_570, rate: 0.0 },
                                 { min: 12_571, max: 50_270, rate: 0.20, base: 0, start: 12_570 },
                                 { min: 50_271, max: 125_140, rate: 0.40, base: 7540, start: 50_270 },
                                 { min: 125_141, max: Float::INFINITY, rate: 0.45, base: 37_488, start: 125_140 }
                               ])
  end

  def build_japan_tables
    {
      'JAPAN_2023_' => build_japan_2023
    }
  end

  def build_japan_2023
    build_progressive_brackets([
                                 { min: 0, max: 1_950_000, rate: 0.05 },
                                 { min: 1_950_001, max: 3_300_000, rate: 0.10, base: 97_500, start: 1_950_000 },
                                 { min: 3_300_001, max: 6_950_000, rate: 0.20, base: 232_500, start: 3_300_000 },
                                 { min: 6_950_001, max: 9_000_000, rate: 0.23, base: 962_500, start: 6_950_000 },
                                 { min: 9_000_001, max: 18_000_000, rate: 0.33, base: 1_434_000, start: 9_000_000 },
                                 { min: 18_000_001, max: 40_000_000, rate: 0.40, base: 4_404_000, start: 18_000_000 },
                                 { min: 40_000_001, max: Float::INFINITY, rate: 0.45, base: 13_204_000,
                                   start: 40_000_000 }
                               ])
  end

  def build_progressive_brackets(bracket_data)
    bracket_data.map do |data|
      TaxBracket.new(
        min_income: data[:min],
        max_income: data[:max],
        rate: data[:rate],
        base_tax: data[:base],
        bracket_start: data[:start]
      )
    end
  end
end

class DeductionTableRegistry
  def initialize
    @deduction_tables = build_deduction_tables
  end

  def get_amount(deduction_context)
    table_key = deduction_context.key
    @deduction_tables[table_key] || 0
  end

  private

  def build_deduction_tables
    DeductionTableBuilder.new.build_all_tables
  end
end

class DeductionTableBuilder
  def build_all_tables
    tables = {}

    # US Deductions
    tables.merge!(build_us_deductions)

    # Canada Deductions
    tables.merge!(build_canada_deductions)

    tables
  end

  private

  def build_us_deductions
    us_2023_standard = {
      'US_2023_single_standard' => 13_850,
      'US_2023_married_joint_standard' => 27_700,
      'US_2023_married_separate_standard' => 13_850,
      'US_2023_single_personal_exemption' => 0,
      'US_2023_married_joint_personal_exemption' => 0,
      'US_2023_married_separate_personal_exemption' => 0
    }

    us_2022_standard = {
      'US_2022_single_standard' => 12_950,
      'US_2022_married_joint_standard' => 25_900
    }

    us_2023_standard.merge(us_2022_standard)
  end

  def build_canada_deductions
    {
      'CANADA_2023_single_basic_personal' => 15_000,
      'CANADA_2023_married_basic_personal' => 15_000,
      'CANADA_2023_common_law_basic_personal' => 15_000,
      'CANADA_2023_single_canada_employment' => 1368,
      'CANADA_2023_married_canada_employment' => 1368,
      'CANADA_2023_common_law_canada_employment' => 1368
    }
  end
end

class TaxSystemConfiguration
  def initialize
    @config = load_configuration
  end

  def valid_years
    @config[:valid_years]
  end

  def supported_countries
    @config[:supported_countries]
  end

  def filing_statuses_for(country)
    @config[:filing_statuses][country.to_s.upcase] || []
  end

  private

  def load_configuration
    {
      valid_years: [2020, 2021, 2022, 2023],
      supported_countries: %w[US CANADA UK JAPAN],
      filing_statuses: {
        'US' => %w[single married_joint married_separate head_of_household],
        'CANADA' => %w[single married common_law],
        'UK' => %w[single married],
        'JAPAN' => %w[single married]
      }
    }
  end
end

# Lookup Tables as Data
class TaxRateTable
  def self.us_2023_rates
    {
      single: [
        [0, 11_000, 0.10],
        [11_001, 44_725, 0.12],
        [44_726, 95_375, 0.22],
        [95_376, 182_050, 0.24],
        [182_051, 231_250, 0.32],
        [231_251, 578_125, 0.35],
        [578_126, Float::INFINITY, 0.37]
      ],
      married_joint: [
        [0, 22_000, 0.10],
        [22_001, 89_450, 0.12],
        [89_451, 190_750, 0.22],
        [190_751, 364_200, 0.24],
        [364_201, 462_500, 0.32],
        [462_501, 693_750, 0.35],
        [693_751, Float::INFINITY, 0.37]
      ]
    }
  end
end

class CountryTaxProcessor
  def self.for_country(country)
    case country.upcase
    when 'US'
      USTaxProcessor.new
    when 'CANADA'
      CanadaTaxProcessor.new
    when 'UK'
      UKTaxProcessor.new
    when 'JAPAN'
      JapanTaxProcessor.new
    else
      raise UnsupportedTaxJurisdiction, "Unsupported country: #{country}"
    end
  end
end

class USTaxProcessor
  def calculate_tax(income, year, filing_status)
    # US-specific tax calculation logic using table lookups
  end
end

class CanadaTaxProcessor
  def calculate_tax(income, year, filing_status)
    # Canada-specific tax calculation logic using table lookups
  end
end

class UKTaxProcessor
  def calculate_tax(income, year, filing_status)
    # UK-specific tax calculation logic using table lookups
  end
end

class JapanTaxProcessor
  def calculate_tax(income, year, filing_status)
    # Japan-specific tax calculation logic using table lookups
  end
end

# Custom Exceptions
class UnsupportedTaxJurisdiction < StandardError; end
class InvalidTaxContext < StandardError; end

# Alternative Table-Driven Implementation using Hash Lookups
class SimpleTaxCalculator
  TAX_BRACKETS = {
    'US_2023_single' => [
      { income_range: 0..11_000, rate: 0.10, base: 0, start: 0 },
      { income_range: 11_001..44_725, rate: 0.12, base: 1100, start: 11_000 },
      { income_range: 44_726..95_375, rate: 0.22, base: 5147, start: 44_725 }
      # ... more brackets
    ],
    'CANADA_2023' => [
      { income_range: 0..53_359, rate: 0.15, base: 0, start: 0 },
      { income_range: 53_360..106_717, rate: 0.205, base: 8003.85, start: 53_359 }
      # ... more brackets
    ]
  }.freeze

  def calculate_tax(income, country, filing_status, year)
    key = build_table_key(country, year, filing_status)
    brackets = TAX_BRACKETS[key]

    return 0 unless brackets

    applicable_bracket = brackets.find { |b| b[:income_range].cover?(income) }
    return 0 unless applicable_bracket

    calculate_bracket_tax(income, applicable_bracket)
  end

  private

  def build_table_key(country, year, filing_status)
    [country.upcase, year, filing_status].compact.join('_')
  end

  def calculate_bracket_tax(income, bracket)
    taxable_amount = income - bracket[:start]
    bracket[:base] + (taxable_amount * bracket[:rate])
  end
end
