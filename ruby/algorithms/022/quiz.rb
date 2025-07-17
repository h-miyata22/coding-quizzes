
# 2人対戦ゲームのAIシステムを実装してください。
# ミニマックスアルゴリズムを使用して、
# 最適な手を計算します。
#
# 要件：
# 1. ゲーム状態の表現と有効手の生成
# 2. ミニマックスアルゴリズムの実装
# 3. アルファベータ枝刈りによる高速化
# 4. 評価関数の設計
# 5. 探索深度の制限と反復深化
# 6. 手の履歴と学習機能

# GameState, GameAI, MoveEvaluator クラスを実装してください。

# 使用例（三目並べ）:
# game = GameState.new(board_size: 3)
# ai = GameAI.new(max_depth: 9)
# 
# # 現在の盤面
# #  X | O | -
# #  - | X | -
# #  - | - | -
# 
# # AIが最適な手を計算
# best_move = ai.find_best_move(game, player: :X)
# # => { position: [2, 2], score: 100 }  # 勝利への手
# 
# # 評価値付きで可能な手を取得
# moves = ai.evaluate_all_moves(game, player: :X)
# # => [{ position: [0, 2], score: 50 }, { position: [2, 2], score: 100 }, ...]
