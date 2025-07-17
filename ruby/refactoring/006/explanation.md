# 出題意図

この問題は、決済処理システムのリファクタリングを通じて、ログ処理の分離、継承を使った設計、クロスカッティング関心事の扱い方を学習することを目的としています。

## 適用されたテーマ

1. **関心の分離 (Separation of Concerns)** - Code Complete, Practical Software Engineering
   - ログ処理をビジネスロジックから分離
   - 検証ロジックを別クラスに抽出

2. **テンプレートメソッドパターン** - Design Patterns, Refactoring
   - log_and_executeメソッドで共通のログ処理をテンプレート化
   - 共通のアルゴリズムを定義し、yieldで具体的な処理を実行

3. **継承によるコードの再利用** - Code Complete
   - BaseValidatorで共通の検証ロジックを定義
   - サブクラスで特化した検証を実装

4. **依存性注入 (Dependency Injection)** - Practical Software Engineering
   - Loggerオブジェクトを外部から注入
   - テスタビリティと柔軟性の向上

5. **DRY原則** - プリンシプル オブ プログラミング
   - 重複したログ出力と検証ロジックを排除
   - 共通処理をメソッドに抽出

6. **名前付き定数** - Code Complete, Refactoring
   - CARD_NUMBER_LENGTH, CVV_LENGTHなどでマジックナンバーを排除
   - 意図が明確で変更が容易

7. **ガード節** - Tidy First?
   - 各検証メソッドで早期リターン
   - ネストの減少と読みやすさの向上

8. **シンボルを使ったハッシュ** - メタプログラミングRuby
   - { success: false, error: message }のようなシンボル構文
   - Rubyらしい読みやすいコード

9. **例外処理の一元化** - プリンシプル オブ プログラミング
   - rescue節で例外を捕捉し、一貫したエラーレスポンスを返す
   - エラーハンドリングの一貫性

10. **高凝集性** - Practical Software Engineering
    - 各クラスが関連する機能をまとめて持つ
    - PaymentProcessorは決済処理、Validatorは検証に特化