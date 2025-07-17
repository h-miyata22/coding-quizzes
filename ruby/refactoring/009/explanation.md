# 出題意图

この問題は、注文処理システムのリファクタリングを通じて、イベント駆動アーキテクチャ、オブザーバーパターン、トランザクション処理の実装を学習することを目的としています。

## 適用されたテーマ

1. **オブザーバーパターン (Observer Pattern)** - Design Patterns
   - EventBusでイベントの発行と購読を管理
   - 注文確定後の各処理をルーズカップリング

2. **単一責任の原則 (SRP)** - プリンシパル オブ プログラミング
   - 各ハンドラークラスが1つの明確な責任を持つ
   - StockReducer, CustomerNotifier, PointsManagerなど

3. **トランザクション処理** - Practical Software Engineering
   - ActiveRecord::Base.transactionでデータの整合性を保証
   - 失敗時のロールバックを自動化

4. **オープンクローズド原則 (OCP)** - Code Complete
   - 新しいイベントハンドラーの追加が容易
   - 既存のコードを変更せずに機能拡張可能

5. **バリデーターパターン** - Design Patterns
   - OrderValidatorで注文の検証ロジックを分離
   - 検証ロジックの再利用とテストが容易

6. **ガード節** - Tidy First?
   - validateメソッドで早期リターン
   - ネストの減少と読みやすさの向上

7. **テンプレートメソッドパターン** - Design Patterns
   - EmailBuilderでメール本文の構築ロジックをカプセル化
   - Heredocを使用して読みやすいテンプレート

8. **名前付き定数** - Code Complete
   - POINTS_RATE, SALES_CHANNELなど
   - マジックナンバーを排除し意図を明確に

9. **例外処理のローカライズ** - プリンシパル オブ プログラミング
   - EventBus#publish内で個別ハンドラーのエラーをキャッチ
   - 1つのハンドラーの失敗が他に影響しない

10. **プライベートメソッドの活用** - Code Complete
    - 各クラスの内部実装をprivateメソッドで隠蔽
    - 公開インターフェースを最小限に