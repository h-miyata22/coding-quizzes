# 出題意図

この問題は、環境設定管理のリファクタリングを通じて、設定の抽象化、テンプレートメソッドパターン、ファーストクラスコレクションの活用を学習することを目的としています。

## 適用されたテーマ

1. **テンプレートメソッドパターン** - Design Patterns
   - BaseConfigクラスで共通の設定構築ロジックを定義
   - サブクラスで環境固有の設定を実装

2. **ファーストクラスコレクション** - Code Complete
   - Environmentクラスで環境情報をモデル化
   - 文字列ではなくオブジェクトとして環境を扱う

3. **DRY原則** - プリンシパル オブ プログラミング
   - env_value, env_intメソッドで環境変数取得ロジックを一元化
   - 重複した条件分岐を排除

4. **ファクトリパターン** - Design Patterns
   - ConfigBuilderで設定タイプに応じたクラスを生成
   - 設定の生成ロジックをカプセル化

5. **単一責任の原則 (SRP)** - プリンシパル オブ プログラミング
   - DatabaseConfig: データベース設定
   - RedisConfig: Redis設定
   - ApiEndpointsConfig: APIエンドポイント設定

6. **オープンクローズド原則 (OCP)** - Code Complete
   - 新しい設定タイプの追加が容易
   - 新しい環境の追加も簡単

7. **メソッドエイリアス** - メタプログラミングRuby
   - alias_methodでtest環境のdevelopment設定を再利用
   - コードの重複を避ける

8. **ガード節** - Tidy First?
   - empty?チェックで空文字列を適切に処理
   - rescueで例外をキャッチしてデフォルト値を返す

9. **名前付き定数** - Code Complete
   - DEFAULT_PORT, VALID_ENVIRONMENTSなど
   - マジックナンバーを排除し意図を明確に

10. **transform_valuesの活用** - メタプログラミングRuby
    - ハッシュの値を変換する際に便利なメソッド
    - 環境変数のオーバーライドを簡潔に実装