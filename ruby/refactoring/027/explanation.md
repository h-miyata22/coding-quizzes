# 出題意図

この問題は、銀行口座システムのリファクタリングを通じて、契約プログラミング（Design by Contract）、防御的プログラミング、事前条件・事後条件・不変条件の実装を学習することを目的としています。

## 適用されたテーマ

1. **契約プログラミング (Design by Contract)** - Code Complete
   - pre_condition, post_condition, assertメソッドによる契約の明示
   - with_contractメソッドで事前・事後条件を統合管理

2. **防御的プログラミング (Defensive Programming)** - Code Complete
   - guard_clauseによる引数の検証
   - AccountStateValidatorによる不変条件の検証
   - エラーハンドリングとリカバリー機能

3. **事前条件 (Preconditions)** - プリンシパル オブ プログラミング
   - メソッド呼び出し前の状態検証
   - 引数の妥当性チェック
   - 十分な資金があることの確認

4. **事後条件 (Postconditions)** - プリンシパル オブ プログラミング
   - メソッド実行後の状態検証
   - 残高の一貫性確認
   - 期待される結果の保証

5. **不変条件 (Invariants)** - プリンシパル オブ プログラミング
   - ensure_invariantsによるオブジェクト状態の一貫性保証
   - 口座番号のimmutability
   - 残高の型安全性

6. **値オブジェクト** - Code Complete
   - Moneyクラスで金額の型安全性を確保
   - InterestRateクラスで金利の妥当性を保証
   - 計算ミスと型エラーの防止

7. **単一責任の原則 (SRP)** - プリンシパル オブ プログラミング
   - TransferOperation: 振込処理の専用クラス
   - InterestCalculator: 利息計算の専用クラス
   - BulkTransactionProcessor: 一括処理の専用クラス
   - SummaryGenerator: サマリー生成の専用クラス

8. **アサーション (Assertions)** - Code Complete
   - 開発時のデバッグ支援
   - プログラムの前提条件の明示
   - 実行時の状態検証

9. **エラー処理戦略** - Code Complete
   - OperationResultパターンで成功/失敗を明示
   - 例外とリターンコードの使い分け
   - コントラクト違反の専用例外階層

10. **ガードクローズ (Guard Clauses)** - Tidy First?
    - 早期リターンによる条件チェック
    - ネストの削減と可読性向上

11. **抽出クラス** - Refactoring
    - TransactionHistoryクラスで履歴管理を分離
    - TransactionCalculatorで集計処理を分離
    - AccountSummaryで表示ロジックを分離

12. **値の置き換え** - Refactoring
    - プリミティブ型（数値）をMoneyオブジェクトに置き換え
    - ドメインの概念をコードで表現

## 防御的プログラミングのベストプラクティス

### 1. **入力値の検証**
- すべての公開メソッドで引数を検証
- 型チェックと範囲チェックの実装
- 不正な値の早期検出

### 2. **状態の一貫性保証**
- 不変条件の明示的チェック
- オブジェクトの状態が常に有効であることを保証
- 操作前後での整合性確認

### 3. **エラーの明示的処理**
- 戻り値での成功/失敗の明示
- 例外は契約違反など回復不可能な場合のみ
- エラー情報の詳細な記録