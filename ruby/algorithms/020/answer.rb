require 'digest'
require 'time'
require 'json'

class Transaction
  attr_accessor :from, :to, :amount, :timestamp

  def initialize(from, to, amount)
    @from = from
    @to = to
    @amount = amount
    @timestamp = Time.now
  end

  def calculate_hash
    Digest::SHA256.hexdigest("#{@from}#{@to}#{@amount}#{@timestamp}")
  end

  def to_h
    {
      from: @from,
      to: @to,
      amount: @amount,
      timestamp: @timestamp.to_s
    }
  end

  def valid?
    return false if @amount <= 0
    return false if @from == @to
    return false if @from.nil? || @to.nil?

    true
  end
end

class Block
  attr_accessor :index, :timestamp, :transactions, :previous_hash, :nonce, :hash

  def initialize(index, transactions, previous_hash)
    @index = index
    @timestamp = Time.now
    @transactions = transactions
    @previous_hash = previous_hash
    @nonce = 0
    @hash = calculate_hash
  end

  def calculate_hash
    data = "#{@index}#{@timestamp}#{transactions_data}#{@previous_hash}#{@nonce}"
    Digest::SHA256.hexdigest(data)
  end

  def mine_block(difficulty)
    target = '0' * difficulty

    until @hash[0...difficulty] == target
      @nonce += 1
      @hash = calculate_hash
    end

    puts "Block mined: #{@hash}"
  end

  def has_valid_transactions?
    @transactions.all?(&:valid?)
  end

  def merkle_root
    return nil if @transactions.empty?

    # トランザクションのハッシュリストを作成
    hashes = @transactions.map(&:calculate_hash)

    # マークルツリーを構築
    while hashes.length > 1
      new_hashes = []

      hashes.each_slice(2) do |pair|
        combined = if pair.length == 2
                     pair[0] + pair[1]
                   else
                     pair[0] + pair[0] # 奇数の場合は複製
                   end
        new_hashes << Digest::SHA256.hexdigest(combined)
      end

      hashes = new_hashes
    end

    hashes.first
  end

  private

  def transactions_data
    @transactions.map(&:to_h).to_json
  end
end

class Blockchain
  attr_accessor :chain, :difficulty, :pending_transactions, :mining_reward

  def initialize(difficulty: 2)
    @chain = [create_genesis_block]
    @difficulty = difficulty
    @pending_transactions = []
    @mining_reward = 100
  end

  def create_genesis_block
    genesis_transaction = Transaction.new('genesis', 'genesis', 0)
    Block.new(0, [genesis_transaction], '0')
  end

  def get_latest_block
    @chain.last
  end

  def add_transaction(from, to, amount)
    transaction = Transaction.new(from, to, amount)

    # 送金元の残高チェック（ジェネシスとマイニング報酬は除く）
    if from != 'genesis' && from != 'System'
      balance = get_balance(from)
      return false if balance < amount
    end

    return false unless transaction.valid?

    @pending_transactions << transaction
    true
  end

  def mine_pending_transactions(mining_reward_address)
    # マイニング報酬のトランザクションを追加
    reward_transaction = Transaction.new('System', mining_reward_address, @mining_reward)
    transactions = @pending_transactions + [reward_transaction]

    block = Block.new(
      @chain.length,
      transactions,
      get_latest_block.hash
    )

    block.mine_block(@difficulty)
    @chain << block

    # ペンディングトランザクションをクリア
    @pending_transactions = []
  end

  def get_balance(address)
    balance = 0

    @chain.each do |block|
      block.transactions.each do |transaction|
        if transaction.from == address
          balance -= transaction.amount
        elsif transaction.to == address
          balance += transaction.amount
        end
      end
    end

    balance
  end

  def valid_chain?
    (1...@chain.length).each do |i|
      current_block = @chain[i]
      previous_block = @chain[i - 1]

      # 現在のブロックのハッシュが正しいか
      return false unless current_block.hash == current_block.calculate_hash

      # 前のブロックのハッシュが正しいか
      return false unless current_block.previous_hash == previous_block.hash

      # ハッシュが難易度を満たしているか
      return false unless current_block.hash[0...@difficulty] == '0' * @difficulty

      # トランザクションが有効か
      return false unless current_block.has_valid_transactions?
    end

    true
  end

  def replace_chain(new_chain)
    # より長いチェーンで置き換える（最長チェーンルール）
    if new_chain.length > @chain.length && valid_chain_data?(new_chain)
      @chain = new_chain
      true
    else
      false
    end
  end

  def get_transaction_history(address)
    history = []

    @chain.each do |block|
      block.transactions.each do |transaction|
        next unless transaction.from == address || transaction.to == address

        history << {
          block_index: block.index,
          timestamp: transaction.timestamp,
          from: transaction.from,
          to: transaction.to,
          amount: transaction.amount
        }
      end
    end

    history
  end

  def calculate_hash_rate(duration_seconds)
    return 0 if @chain.length < 2

    total_nonces = @chain[1..-1].sum(&:nonce)
    total_nonces.to_f / duration_seconds
  end

  def blockchain_info
    {
      height: @chain.length,
      difficulty: @difficulty,
      total_transactions: @chain.sum { |block| block.transactions.length },
      pending_transactions: @pending_transactions.length,
      is_valid: valid_chain?
    }
  end

  private

  def valid_chain_data?(chain_data)
    # 外部チェーンの検証
    return false if chain_data.empty?
    return false unless chain_data[0].index == 0

    (1...chain_data.length).each do |i|
      current = chain_data[i]
      previous = chain_data[i - 1]

      return false unless current.hash == current.calculate_hash
      return false unless current.previous_hash == previous.hash
      return false unless current.hash[0...@difficulty] == '0' * @difficulty
    end

    true
  end
end

# テスト
if __FILE__ == $0
  puts '=== Creating Blockchain ==='
  blockchain = Blockchain.new(difficulty: 2)

  puts "\n=== Adding Transactions ==="
  # 初期資金をマイニング
  blockchain.mine_pending_transactions('Alice')

  # トランザクションを追加
  blockchain.add_transaction('Alice', 'Bob', 30)
  blockchain.add_transaction('Alice', 'Charlie', 20)
  puts "Pending transactions: #{blockchain.pending_transactions.length}"

  puts "\n=== Mining Block 2 ==="
  start_time = Time.now
  blockchain.mine_pending_transactions('Miner1')
  mining_time = Time.now - start_time
  puts "Mining took: #{'%.2f' % mining_time} seconds"

  # さらにトランザクション
  blockchain.add_transaction('Bob', 'David', 10)
  blockchain.add_transaction('Charlie', 'Eve', 5)

  puts "\n=== Mining Block 3 ==="
  blockchain.mine_pending_transactions('Miner2')

  puts "\n=== Balances ==="
  %w[Alice Bob Charlie David Eve Miner1 Miner2].each do |person|
    balance = blockchain.get_balance(person)
    puts "#{person}: #{balance}"
  end

  puts "\n=== Chain Validation ==="
  puts "Is chain valid? #{blockchain.valid_chain?}"

  puts "\n=== Tampering Test ==="
  # ブロックを改ざん
  puts 'Tampering with block 1...'
  blockchain.chain[1].transactions[0].amount = 1000
  puts "Is chain valid after tampering? #{blockchain.valid_chain?}"

  # ハッシュを再計算して改ざんを隠そうとする
  puts "\nRecalculating hash..."
  blockchain.chain[1].hash = blockchain.chain[1].calculate_hash
  puts "Is chain valid? #{blockchain.valid_chain?}"

  puts "\n=== Blockchain Info ==="
  info = blockchain.blockchain_info
  info.each { |k, v| puts "#{k}: #{v}" }

  puts "\n=== Transaction History for Alice ==="
  history = blockchain.get_transaction_history('Alice')
  history.each do |tx|
    puts "Block #{tx[:block_index]}: #{tx[:from]} → #{tx[:to]}: #{tx[:amount]}"
  end

  puts "\n=== Merkle Root Demo ==="
  blockchain.chain[1..2].each do |block|
    puts "Block #{block.index} Merkle Root: #{block.merkle_root}"
  end
end
