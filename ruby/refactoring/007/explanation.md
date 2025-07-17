# 出題意図

この問題は、ショッピングカートのリファクタリングを通じて、状態管理の分離、ストラテジーパターン、リポジトリパターンの実装を学習することを目的としています。

## 適用されたテーマ

1. **ストラテジーパターン** - Design Patterns, Practical Software Engineering
   - PricingStrategyクラスで価格計算ロジックをカプセル化
   - 異なる価格計算ルールを柔軟に切り替え可能

2. **リポジトリパターン** - Design Patterns
   - CouponRepositoryでクーポンデータの管理を一元化
   - データアクセスロジックをビジネスロジックから分離

3. **不可変性の原則** - プリンシプル オブ プログラミング
   - @totalの状態を保持せず、常に計算で求める
   - 状態の不整合を防ぐ

4. **ループをパイプラインに置き換える** - Refactoring
   - forループをRubyのEnumerableメソッドに置き換え
   - find, reject!, sumなどの高階関数を活用

5. **単一責任の原則 (SRP)** - プリンシベル オブ プログラミング
   - ShoppingCart: 商品の管理
   - PriceCalculator: 価格計算
   - Coupon: クーポン情報の保持
   - CouponRepository: クーポンデータの取得

6. **名前付き定数** - Code Complete
   - DEFAULT_TAX_RATE, FREE_SHIPPING_THRESHOLDなど
   - マジックナンバーを排除し、意図を明確に

7. **Tell, Don't Ask原則** - プリンシパル オブ プログラミング
   - オブジェクトにデータを問い合わせるのではなく、何をすべきか伝える
   - free_shipping?メソッドでカプセル化

8. **ガード節** - Tidy First?
   - valid_item?で早期リターン
   - ネストの減少と読みやすさの向上

9. **メモイゼーション** - Code Complete
   - @subtotal ||= calculate_subtotalで計算結果をキャッシュ
   - 同じ計算の繰り返しを回避

10. **小さなクラスとコンポジション** - Code Complete, UNIX哲学
    - 各クラスが小さく、明確な責任を持つ
    - クラスを組み合わせて機能を実現