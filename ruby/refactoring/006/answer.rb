require 'logger'

class PaymentProcessor
  def initialize(logger = Logger.new(STDOUT))
    @logger = logger
  end

  def process_credit_card(amount, card_number, cvv)
    log_and_execute('credit card payment') do
      validator = CreditCardValidator.new
      validation_result = validator.validate(
        amount: amount,
        card_number: card_number,
        cvv: cvv
      )

      return validation_result unless validation_result[:success]

      process_payment('TXN', 0.5)
    end
  end

  def process_bank_transfer(amount, account_number, routing_number)
    log_and_execute('bank transfer') do
      validator = BankTransferValidator.new
      validation_result = validator.validate(
        amount: amount,
        account_number: account_number,
        routing_number: routing_number
      )

      return validation_result unless validation_result[:success]

      process_payment('BNK', 1.0)
    end
  end

  private

  def log_and_execute(operation_name)
    @logger.info "Starting #{operation_name} processing"

    result = yield

    if result[:success]
      @logger.info "#{operation_name.capitalize} processed successfully"
      @logger.info "Transaction ID: #{result[:transaction_id]}"
    end

    result
  rescue StandardError => e
    @logger.error "Error during #{operation_name}: #{e.message}"
    { success: false, error: e.message }
  end

  def process_payment(prefix, delay)
    @logger.info 'Processing payment...'
    sleep(delay) # APIコールのシミュレーション

    transaction_id = "#{prefix}#{Time.now.to_i}"
    { success: true, transaction_id: transaction_id }
  end
end

class BaseValidator
  def initialize(logger = Logger.new(STDOUT))
    @logger = logger
  end

  protected

  def validate_amount(amount)
    return true if amount && amount > 0

    @logger.error 'Invalid amount'
    false
  end

  def validation_error(message)
    { success: false, error: message }
  end

  def validation_success
    @logger.info 'Validation passed'
    { success: true }
  end
end

class CreditCardValidator < BaseValidator
  CARD_NUMBER_LENGTH = 16
  CVV_LENGTH = 3

  def validate(amount:, card_number:, cvv:)
    @logger.info "Amount: #{amount}"

    return validation_error('Invalid card number') unless valid_card_number?(card_number)

    return validation_error('Invalid CVV') unless valid_cvv?(cvv)

    return validation_error('Invalid amount') unless validate_amount(amount)

    validation_success
  end

  private

  def valid_card_number?(card_number)
    return false unless card_number&.length == CARD_NUMBER_LENGTH

    true
  rescue StandardError
    @logger.error 'Invalid card number length'
    false
  end

  def valid_cvv?(cvv)
    return false unless cvv&.length == CVV_LENGTH

    true
  rescue StandardError
    @logger.error 'Invalid CVV'
    false
  end
end

class BankTransferValidator < BaseValidator
  ROUTING_NUMBER_LENGTH = 9
  MIN_ACCOUNT_LENGTH = 8
  MAX_ACCOUNT_LENGTH = 12

  def validate(amount:, account_number:, routing_number:)
    @logger.info "Amount: #{amount}"

    return validation_error('Invalid account number') unless valid_account_number?(account_number)

    return validation_error('Invalid routing number') unless valid_routing_number?(routing_number)

    return validation_error('Invalid amount') unless validate_amount(amount)

    validation_success
  end

  private

  def valid_account_number?(account_number)
    return false unless account_number

    length = account_number.length
    return false unless length.between?(MIN_ACCOUNT_LENGTH, MAX_ACCOUNT_LENGTH)

    true
  rescue StandardError
    @logger.error 'Invalid account number'
    false
  end

  def valid_routing_number?(routing_number)
    return false unless routing_number&.length == ROUTING_NUMBER_LENGTH

    true
  rescue StandardError
    @logger.error 'Invalid routing number'
    false
  end
end
