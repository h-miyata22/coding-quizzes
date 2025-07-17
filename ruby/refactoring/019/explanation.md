# 出題意図

この問題は、データ処理パイプラインのリファクタリングを通じて、パイプラインパターン、関数型プログラミングの概念、不変性、戦略パターンを学習することを目的としています。

## 適用されたテーマ

1. **パイプラインパターン** - Practical Software Engineering Ch14
   - DataPipelineクラスで処理をステージの連鎖として表現
   - 各ステージが独立して動作し、組み合わせ可能

2. **単一責任の原則 (SRP)** - プリンシパル オブ プログラミング
   - FileReader: ファイル読み込み
   - ValidationStage: バリデーション
   - TransformationStage: 変換処理
   - FilteringStage: フィルタリング
   - SortingStage: ソート
   - FileWriter: ファイル書き込み

3. **戦略パターン (Strategy Pattern)** - Practical Software Engineering Ch14
   - Validator、Transformer、Filterの各インターフェース
   - 具体的な処理を差し替え可能に

4. **ループを関数型のメソッドに置き換える** - Refactoring
   - for文をmap、select、reject、reduceに置き換え
   - より表現力豊かで簡潔なコード

5. **不変性 (Immutability)** - Tidy First?
   - ProcessingContextが不変オブジェクト
   - with_dataやwith_statisticsで新しいインスタンスを生成

6. **ビルダーパターン** - Practical Software Engineering Ch14
   - DataPipelineのadd_stageメソッドでチェーン可能なAPI
   - 流暢なインターフェース

7. **値オブジェクト** - Code Complete
   - Statisticsクラスで統計情報をカプセル化
   - ValidationResultで検証結果を構造化

8. **Tell, Don't Ask原則** - プリンシパル オブ プログラミング
   - 各クラスが自身の責務を内部で処理
   - 外部からの細かい制御を避ける

9. **条件分岐をポリモーフィズムで置き換える** - Refactoring
   - 多数のif文を各種ValidatorやTransformerクラスに分離
   - Open-Closed原則に従った拡張可能な設計

10. **メソッドの抽出** - Refactoring
    - 長大なメソッドを意味のある単位に分割
    - build_validators、build_transformersなど

11. **バブルソートを標準ソートに置き換える** - Refactoring
    - 手動実装のソートアルゴリズムをArray#sortに
    - 効率的で信頼性の高い実装

12. **関数型プログラミングの概念** - Meta Programming Ruby
    - reduceを使用したパイプライン処理
    - 副作用を最小限に抑えた設計
    - データの変換を中心とした処理フロー