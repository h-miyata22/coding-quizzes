# 出題意図

この問題は、メトリクス収集システムのリファクタリングを通じて、戦略パターン、ファクトリーパターン、単一責任の原則、ポリモーフィズムによる条件分岐の置き換えを学習することを目的としています。

## 適用されたテーマ

1. **戦略パターン (Strategy Pattern)** - Practical Software Engineering Ch14
   - MetricCollectorの派生クラスで異なるメトリクス収集戦略を実装
   - PerformanceCollector, AvailabilityCollector, ErrorRateCollector

2. **ファクトリーパターン (Factory Pattern)** - Practical Software Engineering Ch14
   - ServiceFactoryでサービスインスタンスを生成
   - MetricCollectorFactoryでコレクターインスタンスを生成

3. **単一責任の原則 (SRP)** - プリンシパル オブ プログラミング
   - MetricsCollector: 全体の調整
   - Service: サービスの実行
   - MetricCollector: メトリクス収集
   - Report: レポートデータの保持
   - FileLogger: ログ出力
   - EmailNotifier: 通知

4. **条件分岐をポリモーフィズムで置き換える** - Refactoring
   - 大きなcase文を継承とポリモーフィズムで置き換え
   - 各サービスタイプごとにクラスを作成

5. **ファーストクラスコレクション** - Code Complete
   - ErrorCollectionクラスでエラーのコレクションをカプセル化
   - グループ化や集計のロジックを内包

6. **名前付き定数** - Code Complete
   - ALERT_THRESHOLD_SECONDS, CHECK_COUNT等
   - マジックナンバーを排除し意図を明確に

7. **Tell, Don't Ask原則** - プリンシパル オブ プログラミング
   - AvailabilityResultがsuccess_rateを計算
   - ErrorCollectionがgroup_by_typeを提供

8. **依存性注入 (DI)** - Practical Software Engineering Ch11
   - LoggerとNotifierを注入可能に
   - テストしやすい設計

9. **メソッドの抽出** - Refactoring
   - 大きなメソッドを小さく意味のある単位に分割
   - measure, check, formatなど

10. **データクランプの解消** - Refactoring
    - Reportクラスで関連するデータをまとめる
    - PerformanceMetricsで性能測定データを構造化

11. **Feature Envy の解消** - Refactoring
    - 各クラスが自身のデータを操作するように変更
    - ReportFormatterがReportのフォーマットを担当

12. **並列継承階層の統一** - Refactoring
    - ServiceとMetricCollectorの階層を適切に分離
    - 各責務を明確に定義