require 'forwardable'

class BankAccount
  include ContractProgramming
  extend Forwardable

  attr_reader :account_number, :balance

  def_delegators :@transaction_history, :size, :empty?

  def initialize(account_number, initial_balance)
    pre_condition { account_number.is_a?(String) && !account_number.empty? }
    pre_condition { initial_balance.is_a?(Numeric) && initial_balance >= 0 }

    @account_number = account_number.freeze
    @balance = Money.new(initial_balance)
    @transaction_history = TransactionHistory.new
    @state_validator = AccountStateValidator.new

    post_condition { @balance.amount >= 0 }
    post_condition { @account_number.frozen? }
  end

  def deposit(amount)
    amount_money = Money.new(amount)

    with_contract(
      pre: -> { amount_money.positive? },
      post: -> { @balance >= old_balance }
    ) do
      @balance = @balance.add(amount_money)
      record_transaction(DepositTransaction.new(amount_money, @balance))

      ensure_invariants

      OperationResult.success(balance: @balance)
    end
  end

  def withdraw(amount)
    amount_money = Money.new(amount)

    with_contract(
      pre: -> { amount_money.positive? && sufficient_funds?(amount_money) },
      post: -> { @balance == old_balance.subtract(amount_money) }
    ) do
      @balance = @balance.subtract(amount_money)
      record_transaction(WithdrawTransaction.new(amount_money, @balance))

      ensure_invariants

      OperationResult.success(balance: @balance)
    end
  end

  def transfer(amount, target_account)
    amount_money = Money.new(amount)

    with_contract(
      pre: -> { amount_money.positive? },
      pre: -> { target_account.is_a?(BankAccount) },
      pre: -> { target_account != self },
      pre: -> { sufficient_funds?(amount_money) },
      post: -> { @balance == old_balance.subtract(amount_money) }
    ) do
      transfer_operation = TransferOperation.new(self, target_account, amount_money)
      transfer_operation.execute

      ensure_invariants
      target_account.send(:ensure_invariants)

      OperationResult.success(balance: @balance)
    end
  end

  def calculate_interest(rate)
    interest_rate = InterestRate.new(rate)

    with_contract(
      pre: -> { interest_rate.valid? },
      post: -> { @balance >= old_balance }
    ) do
      interest_calculator = InterestCalculator.new(interest_rate)
      interest_amount = interest_calculator.calculate(@balance)

      @balance = @balance.add(interest_amount)
      record_transaction(InterestTransaction.new(interest_amount, interest_rate, @balance))

      ensure_invariants

      OperationResult.success(interest: interest_amount, balance: @balance)
    end
  end

  def apply_fee(fee_amount)
    fee_money = Money.new(fee_amount)

    with_contract(
      pre: -> { fee_money.non_negative? }
    ) do
      @balance = @balance.subtract(fee_money)
      record_transaction(FeeTransaction.new(fee_money, @balance))

      warn_if_negative_balance

      # 不変条件は緩和（手数料により一時的にマイナス残高を許可）

      OperationResult.success(balance: @balance)
    end
  end

  def bulk_transactions(transactions)
    guard_clause { transactions.is_a?(Array) }
    guard_clause { transactions.all? { |t| t.is_a?(Hash) } }

    processor = BulkTransactionProcessor.new(self)
    result = processor.process(transactions)

    ensure_invariants if result.any_successful?

    result
  end

  def account_summary
    SummaryGenerator.new(self, @transaction_history).generate
  end

  def transaction_history
    @transaction_history.to_a.freeze
  end

  protected

  def receive_transfer(amount, source_account)
    @balance = @balance.add(amount)
    record_transaction(TransferInTransaction.new(amount, source_account.account_number, @balance))
  end

  private

  def sufficient_funds?(amount)
    @balance >= amount
  end

  def record_transaction(transaction)
    assert { transaction.respond_to?(:to_h) }

    @transaction_history.add(transaction)
  end

  def ensure_invariants
    @state_validator.validate(self)
  end

  def warn_if_negative_balance
    return unless @balance.negative?

    puts "Warning: Account #{@account_number} balance is negative: #{@balance}"
  end
end

module ContractProgramming
  def pre_condition(&block)
    raise PreconditionViolation, 'Precondition failed' unless block.call
  end

  def post_condition(&block)
    raise PostconditionViolation, 'Postcondition failed' unless block.call
  end

  def assert(&block)
    raise AssertionError, 'Assertion failed' unless block.call
  end

  def guard_clause(&block)
    raise ArgumentError, 'Guard clause failed' unless block.call
  end

  def with_contract(pre: [], post: [])
    pre_conditions = Array(pre)
    post_conditions = Array(post)

    # Capture state for post-conditions
    old_balance = @balance if respond_to?(:balance)

    # Check preconditions
    pre_conditions.each do |condition|
      condition = condition.curry[binding] if condition.arity == 1
      raise PreconditionViolation unless condition.call
    end

    # Execute operation
    result = yield

    # Check postconditions
    post_conditions.each do |condition|
      condition_proc = condition.arity == 0 ? condition : condition.curry[binding]
      raise PostconditionViolation unless condition_proc.call
    end

    result
  rescue StandardError => e
    handle_contract_violation(e)
    raise
  end

  private

  def handle_contract_violation(error)
    puts "Contract violation: #{error.message}"
    puts "Account: #{@account_number}" if @account_number
    puts "Current balance: #{@balance}" if @balance
  end
end

class Money
  include Comparable

  attr_reader :amount

  def initialize(amount)
    raise ArgumentError, 'Amount must be numeric' unless amount.is_a?(Numeric)

    @amount = amount.round(2)
  end

  def add(other)
    Money.new(@amount + other.amount)
  end

  def subtract(other)
    Money.new(@amount - other.amount)
  end

  def multiply(multiplier)
    Money.new(@amount * multiplier)
  end

  def <=>(other)
    @amount <=> other.amount
  end

  def positive?
    @amount > 0
  end

  def negative?
    @amount < 0
  end

  def non_negative?
    @amount >= 0
  end

  def zero?
    @amount == 0
  end

  def to_s
    format('%.2f', @amount)
  end
end

class InterestRate
  attr_reader :rate

  def initialize(rate)
    @rate = rate
  end

  def valid?
    @rate.is_a?(Numeric) && @rate >= 0 && @rate <= 1
  end

  def to_f
    @rate.to_f
  end
end

class Transaction
  attr_reader :amount, :timestamp, :balance_after

  def initialize(amount, balance_after)
    @amount = amount
    @balance_after = balance_after
    @timestamp = Time.now
  end

  def type
    self.class.name.gsub('Transaction', '').downcase
  end

  def to_h
    {
      type: type,
      amount: @amount.amount,
      timestamp: @timestamp,
      balance_after: @balance_after.amount
    }
  end
end

class DepositTransaction < Transaction; end
class WithdrawTransaction < Transaction; end
class FeeTransaction < Transaction; end

class InterestTransaction < Transaction
  attr_reader :rate

  def initialize(amount, rate, balance_after)
    super(amount, balance_after)
    @rate = rate
  end

  def to_h
    super.merge(rate: @rate.to_f)
  end
end

class TransferOutTransaction < Transaction
  attr_reader :target_account_number

  def initialize(amount, target_account_number, balance_after)
    super(amount, balance_after)
    @target_account_number = target_account_number
  end

  def to_h
    super.merge(target: @target_account_number)
  end
end

class TransferInTransaction < Transaction
  attr_reader :source_account_number

  def initialize(amount, source_account_number, balance_after)
    super(amount, balance_after)
    @source_account_number = source_account_number
  end

  def to_h
    super.merge(source: @source_account_number)
  end
end

class TransactionHistory
  def initialize
    @transactions = []
    @mutex = Mutex.new
  end

  def add(transaction)
    @mutex.synchronize do
      @transactions << transaction
    end
  end

  def to_a
    @mutex.synchronize do
      @transactions.dup
    end
  end

  def size
    @transactions.size
  end

  def empty?
    @transactions.empty?
  end

  def each(&block)
    @transactions.each(&block)
  end
end

class TransferOperation
  def initialize(source_account, target_account, amount)
    @source_account = source_account
    @target_account = target_account
    @amount = amount
  end

  def execute
    # Atomic transfer operation
    @source_account.instance_variable_set(:@balance,
                                          @source_account.balance.subtract(@amount))

    @target_account.send(:receive_transfer, @amount, @source_account)

    # Record transactions
    @source_account.send(:record_transaction,
                         TransferOutTransaction.new(@amount, @target_account.account_number, @source_account.balance))
  end
end

class InterestCalculator
  def initialize(interest_rate)
    @interest_rate = interest_rate
  end

  def calculate(balance)
    balance.multiply(@interest_rate.to_f)
  end
end

class BulkTransactionProcessor
  def initialize(account)
    @account = account
  end

  def process(transactions)
    results = BulkTransactionResult.new

    transactions.each do |transaction_data|
      result = process_single_transaction(transaction_data)
      results.add_result(result)
    end

    results
  end

  private

  def process_single_transaction(data)
    case data[:type]
    when 'deposit'
      @account.deposit(data[:amount])
    when 'withdraw'
      @account.withdraw(data[:amount])
    when 'fee'
      @account.apply_fee(data[:fee] || 0)
    else
      OperationResult.failure("Unknown transaction type: #{data[:type]}")
    end
  rescue StandardError => e
    OperationResult.failure(e.message)
  end
end

class BulkTransactionResult
  def initialize
    @successful = 0
    @failed = 0
    @errors = []
  end

  def add_result(result)
    if result.success?
      @successful += 1
    else
      @failed += 1
      @errors << result.error
    end
  end

  def any_successful?
    @successful > 0
  end

  def summary
    "Bulk transaction completed: #{@successful} successful, #{@failed} failed"
  end

  def to_h
    {
      successful: @successful,
      failed: @failed,
      errors: @errors
    }
  end
end

class OperationResult
  attr_reader :value, :error

  def self.success(value = true)
    new(success: true, value: value)
  end

  def self.failure(error)
    new(success: false, error: error)
  end

  def initialize(success:, value: nil, error: nil)
    @success = success
    @value = value
    @error = error
  end

  def success?
    @success
  end

  def failure?
    !@success
  end
end

class AccountStateValidator
  def validate(account)
    validate_account_number(account.account_number)
    validate_balance(account.balance)
    validate_transaction_history(account.transaction_history)
  end

  private

  def validate_account_number(account_number)
    return if account_number.is_a?(String) && account_number.frozen?

    raise InvariantViolation,
          'Account number must be frozen string'
  end

  def validate_balance(balance)
    raise InvariantViolation, 'Balance must be Money object' unless balance.is_a?(Money)
  end

  def validate_transaction_history(history)
    raise InvariantViolation, 'Transaction history must be array' unless history.is_a?(Array)
  end
end

class SummaryGenerator
  def initialize(account, transaction_history)
    @account = account
    @transaction_history = transaction_history
  end

  def generate
    calculator = TransactionCalculator.new(@transaction_history.to_a)

    summary = AccountSummary.new(
      account_number: @account.account_number,
      current_balance: @account.balance,
      transaction_count: @transaction_history.size,
      total_deposits: calculator.total_deposits,
      total_withdrawals: calculator.total_withdrawals
    )

    summary.display
    summary
  end
end

class TransactionCalculator
  def initialize(transactions)
    @transactions = transactions
  end

  def total_deposits
    credit_transactions.sum { |t| t.amount.amount }
  end

  def total_withdrawals
    debit_transactions.sum { |t| t.amount.amount }
  end

  private

  def credit_transactions
    @transactions.select { |t| credit_transaction?(t) }
  end

  def debit_transactions
    @transactions.select { |t| debit_transaction?(t) }
  end

  def credit_transaction?(transaction)
    %w[deposit transfer_in interest].include?(transaction.type)
  end

  def debit_transaction?(transaction)
    %w[withdraw transfer_out fee].include?(transaction.type)
  end
end

class AccountSummary
  def initialize(account_number:, current_balance:, transaction_count:, total_deposits:, total_withdrawals:)
    @account_number = account_number
    @current_balance = current_balance
    @transaction_count = transaction_count
    @total_deposits = total_deposits
    @total_withdrawals = total_withdrawals
  end

  def display
    puts "Account Number: #{@account_number}"
    puts "Current Balance: #{@current_balance}"
    puts "Transaction Count: #{@transaction_count}"
    puts "Total Deposits: #{@total_deposits}"
    puts "Total Withdrawals: #{@total_withdrawals}"
  end
end

# Contract Programming Exceptions
class ContractViolation < StandardError; end
class PreconditionViolation < ContractViolation; end
class PostconditionViolation < ContractViolation; end
class AssertionError < ContractViolation; end
class InvariantViolation < ContractViolation; end
