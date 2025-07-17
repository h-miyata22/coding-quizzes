
# 決定木による分類システムを実装してください。
# ID3アルゴリズムを使用して、データから
# 自動的に分類ルールを学習します。
#
# 要件：
# 1. エントロピーと情報利得の計算
# 2. 最適な分割属性の選択
# 3. 再帰的な木の構築
# 4. 過学習を防ぐ枝刈り（プルーニング）
# 5. 新しいデータの分類予測
# 6. 決定木の可視化とルール抽出

# DecisionNode, DecisionTree, DataSet クラスを実装してください。

# 使用例:
# # データセット（天気による外出判断）
# data = [
#   { outlook: "sunny", temperature: "hot", humidity: "high", wind: "weak", play: "no" },
#   { outlook: "sunny", temperature: "hot", humidity: "high", wind: "strong", play: "no" },
#   { outlook: "overcast", temperature: "hot", humidity: "high", wind: "weak", play: "yes" },
#   { outlook: "rain", temperature: "mild", humidity: "high", wind: "weak", play: "yes" }
# ]
# 
# tree = DecisionTree.new
# tree.train(data, target: :play)
# 
# # 予測
# prediction = tree.predict(outlook: "sunny", temperature: "mild", humidity: "low", wind: "weak")
# # => "yes"
# 
# # ルールの抽出
# rules = tree.extract_rules
# # => ["IF outlook = overcast THEN play = yes",
# #     "IF outlook = sunny AND humidity = high THEN play = no", ...]
