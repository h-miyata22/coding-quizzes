
# 簡易ブロックチェーンシステムを実装してください。
# 取引データの改ざん防止と、
# 分散台帳の基本機能を実現します。
#
# 要件：
# 1. ブロックのハッシュチェーン構造
# 2. Proof of Work（作業証明）の実装
# 3. トランザクションの検証と追加
# 4. チェーンの検証（改ざんチェック）
# 5. マークルツリーによる効率的な検証
# 6. 複数チェーンの競合解決

# Block, Transaction, Blockchain クラスを実装してください。

# 使用例:
# blockchain = Blockchain.new(difficulty: 2)
# 
# # トランザクションを追加
# blockchain.add_transaction("Alice", "Bob", 10)
# blockchain.add_transaction("Bob", "Charlie", 5)
# 
# # ブロックをマイニング
# blockchain.mine_pending_transactions("Miner1")
# 
# # 残高を確認
# balance = blockchain.get_balance("Bob")
# # => 5
# 
# # チェーンの検証
# valid = blockchain.valid_chain?
# # => true
# 
# # ブロックの改ざんを検出
# blockchain.chain[1].transactions[0].amount = 100
# valid = blockchain.valid_chain?
# # => false
