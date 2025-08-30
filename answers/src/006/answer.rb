require 'logger'

class ValidationError < StandardError; end

class BasePaymentProcessor

  def initialize(logger:, amount:, process_name:, transaction_prefix:)
    @logger = logger
    @amount = amount
    @process_name = process_name
    @transaction_prefix = transaction_prefix
  end

  def process
    perform_processing
  rescue ValidationError => e
    @logger.error(e.message)
    { success: false, error: e.message }
  end

  private

  def check_condition(condition, error_message)
    raise ValidationError, error_message unless condition
  end

  def common_validate
    check_condition(@amount > 0, "Invalid amount")
  end

  def specific_validate
    raise NotImplementedError, 'Subclass must implement this method'
  end

  def issue_transaction_id
    @transaction_id = "#{@transaction_prefix}#{Time.now.to_i}"
  end

  def specific_process
    raise NotImplementedError, 'Subclass must implement this method'
  end

  def perform_processing
    @logger.info("Starting #{@process_name} processing")
    @logger.info("Amount: #{@amount}")

    common_validate
    specific_validate

    @logger.info("Validation passed")

    issue_transaction_id

    specific_process

    @logger.info("Transaction ID: #{@transaction_id}")

    { success: true, transaction_id: @transaction_id }
  end
end

class CreditCardPaymentProcessor < BasePaymentProcessor
  CARD_NUMBER_LENGTH = 16
  CVV_LENGTH = 3

  def initialize(amount:, card_number:, cvv:, logger:)
    super(amount: amount, process_name: 'credit card payment', transaction_prefix: 'TXN', logger: logger)
    @card_number = card_number
    @cvv = cvv
  end

  private

  def specific_validate
    check_condition(@card_number.length == CARD_NUMBER_LENGTH, "Invalid card number length")
    check_condition(@cvv.length == CVV_LENGTH, "Invalid CVV")
  end

  def specific_process
    @logger.info("Processing payment...")
    sleep(0.5)
    @logger.info("Payment processed successfully")
  end
end

class BankTransferPaymentProcessor < BasePaymentProcessor
  MIN_ACCOUNT_NUMBER_LENGTH = 8
  MAX_ACCOUNT_NUMBER_LENGTH = 12
  ROUTING_NUMBER_LENGTH = 9

  def initialize(amount:, account_number:, routing_number:, logger:)
    super(amount: amount, process_name: 'bank transfer', transaction_prefix: 'BNK', logger: logger)
    @account_number = account_number
    @routing_number = routing_number
  end

  private

  def specific_validate
    check_condition(@account_number.length.between?(MIN_ACCOUNT_NUMBER_LENGTH, MAX_ACCOUNT_NUMBER_LENGTH), "Invalid account number")
    check_condition(@routing_number.length == ROUTING_NUMBER_LENGTH, "Invalid routing number")
  end

  def specific_process
    @logger.info("Processing transfer...")
    sleep(1.0)
    @logger.info("Transfer processed successfully")
  end
end
