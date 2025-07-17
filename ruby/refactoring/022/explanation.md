# 出題意図

この問題は、キャッシングシステムのリファクタリングを通じて、戦略パターン、プロキシパターン、デコレータパターン、スレッドセーフティ、インターフェース分離の原則を学習することを目的としています。

## 適用されたテーマ

1. **戦略パターン (Strategy Pattern)** - Practical Software Engineering Ch14
   - EvictionPolicyとその派生クラスで異なる削除戦略を実装
   - LRUEvictionPolicy, FIFOEvictionPolicy, SizeBasedEvictionPolicy

2. **単一責任の原則 (SRP)** - プリンシパル オブ プログラミング
   - CacheStorage: データの保存
   - TTLManager: 有効期限の管理
   - CacheStatistics: 統計情報の収集
   - EvictionPolicy: 削除戦略
   - AccessOrderTracker: アクセス順序の追跡

3. **依存性注入 (DI)** - Practical Software Engineering Ch11
   - Logger, EvictionPolicyを注入可能に
   - テストしやすく拡張可能な設計

4. **ヌルオブジェクトパターン** - Refactoring
   - NullLoggerでログ出力の有無を統一的に処理
   - 条件分岐を削除しコードを簡潔に

5. **値オブジェクト** - Code Complete
   - CacheEntry: キャッシュエントリの不変表現
   - StatisticsSummary: 統計情報の値オブジェクト

6. **スレッドセーフティ** - プリンシパル オブ プログラミング
   - Mutexを使用して並行アクセスから保護
   - CacheStorage, AccessOrderTracker, CacheStatisticsで実装

7. **抽出クラス** - Refactoring
   - BulkOperationクラスで複数キー操作を分離
   - AccessOrderTrackerでLRU追跡ロジックを分離

8. **テンプレートメソッドパターン** - Practical Software Engineering Ch14
   - EvictionPolicyの基本クラスで共通インターフェースを定義
   - 派生クラスで具体的な実装を提供

9. **Tell, Don't Ask原則** - プリンシパル オブ プログラミング
   - CacheEntryがtouchメソッドでアクセス時刻を更新
   - TTLManagerがexpired?で有効期限を判定

10. **インターフェース分離の原則 (ISP)** - プリンシパル オブ プログラミング
    - Loggerインターフェースを最小限に
    - 必要なメソッドのみを公開

11. **条件分岐をポリモーフィズムで置き換える** - Refactoring
    - デバッグログの出力をLoggerの実装に委譲
    - 削除戦略の選択をポリモーフィズムで実現

12. **メソッドの抽出** - Refactoring
    - handle_hit, handle_miss, ensure_capacityなど
    - 複雑なロジックを理解しやすい単位に分割