# 出題意図

この問題は、複雑な価格計算ロジックのリファクタリングを通じて、ストラテジーパターン、ポリシーパターン、ビジネスルールのカプセル化を学習することを目的としています。

## 適用されたテーマ

1. **ストラテジーパターン** - Design Patterns
   - Discount基底クラスと各種割引クラス
   - 異なる割引ロジックを交換可能に

2. **ポリシーパターン** - Design Patterns
   - PricingRulesで適用する割引の選択ロジックを管理
   - ビジネスルールの中央集権化

3. **データ駆動型設計** - Code Complete
   - DISCOUNT_RULES、RANK_DISCOUNTSなどのハッシュでルールを管理
   - 条件分岐をデータ構造に置き換え

4. **オープンクローズド原則 (OCP)** - Code Complete
   - 新しい割引タイプの追加が容易
   - 既存コードを変更せずに拡張可能

5. **単一責任の原則 (SRP)** - プリンシパル オブ プログラミング
   - 各割引クラスが1つの割引ロジックに特化
   - PriceCalculationが価格計算の流れを管理

6. **テンプレートメソッドパターン** - Design Patterns
   - Discount基底クラスでapplyメソッドのテンプレートを定義
   - discount_rateをサブクラスで実装

7. **ガード節** - Tidy First?
   - applicable?メソッドで適用可否をチェック
   - 不要な割引計算をスキップ

8. **名前付き定数** - Code Complete
   - MINIMUM_MARGIN_RATE, REQUIRED_ITEMSなど
   - マジックナンバーを排除し意図を明確に

9. **ループをイテレータに置き換える** - Refactoring
   - forループをcount、selectなどのEnumerableメソッドに
   - Rubyらしい関数型プログラミング

10. **ファーストクラスコレクション** - Code Complete
    - SeasonalSaleをクラスとしてモデル化
    - ビジネスルールをオブジェクトとして扱う