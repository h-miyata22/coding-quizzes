# 出題意図

この問題は、設定管理システムのリファクタリングを通じて、戦略パターン、責任の連鎖パターン、ビルダーパターン、環境別設定の管理、型安全性を学習することを目的としています。

## 適用されたテーマ

1. **戦略パターン (Strategy Pattern)** - Practical Software Engineering Ch14
   - Formatter インターフェースと各フォーマッター実装
   - YamlFormatter, JsonFormatter, EnvFormatter
   - Validator インターフェースと各バリデーター実装

2. **責任の連鎖パターン** - Practical Software Engineering Ch14
   - ConfigValidatorが複数のバリデーターを連鎖的に実行
   - RequiredFieldValidator, TypeValidator, ReferenceValidator

3. **単一責任の原則 (SRP)** - プリンシパル オブ プログラミング
   - ConfigLoader: 設定ファイルの読み込み
   - ConfigStore: 設定の保存と管理
   - ConfigValidator: 設定の検証
   - ConfigExporter: 設定のエクスポート
   - VariableInterpolator: 変数の展開

4. **値オブジェクト** - Code Complete
   - Configuration: 不変の設定データ
   - ConfigSource: 設定のソース情報
   - ValidationResult: 検証結果
   - LoadResult: 読み込み結果

5. **環境オーバーレイパターン** - Tidy First?
   - EnvironmentOverlayで環境別設定を階層的に適用
   - デフォルト値と環境固有値のマージ

6. **型安全性** - Code Complete
   - ConfigSchemaで設定項目の型を定義
   - TypeCasterで環境変数の型変換
   - TypeValidatorで型の検証

7. **不変性 (Immutability)** - Tidy First?
   - Configurationが不変オブジェクト
   - with_dataメソッドで新しいインスタンスを生成

8. **ファクトリーパターン** - Practical Software Engineering Ch14
   - ConfigExporterがフォーマッターのファクトリー
   - 形式に応じた適切なフォーマッターを選択

9. **抽出クラス** - Refactoring
   - ConfigAccessorでネストされたキーのアクセスを分離
   - EnvironmentVariableOverriderで環境変数の処理を分離

10. **テンプレートメソッドパターン** - Practical Software Engineering Ch14
    - ConfigLoaderのloadメソッドが読み込みプロセスのテンプレート
    - 各ステップ（パース、オーバーレイ、補間）を順次実行

11. **Tell, Don't Ask原則** - プリンシパル オブ プログラミング
    - Configurationが自身のデータを管理
    - InterpolationResultが成功/失敗を内部で判断

12. **深いネストの回避** - Refactoring
    - 条件分岐をポリモーフィズムで置き換え
    - メソッドの抽出で複雑度を低減
    - 各責務を独立したクラスに分離