# 出題意図

この問題は、タスクキュー/ジョブスケジューラーのリファクタリングを通じて、状態パターン、戦略パターン、テンプレートメソッドパターン、スレッドセーフティを学習することを目的としています。

## 適用されたテーマ

1. **状態パターン (State Pattern)** - Practical Software Engineering Ch14
   - TaskStateとその派生クラスでタスクのライフサイクルを管理
   - PendingState, RunningState, CompletedState, RetryingState, FailedState

2. **戦略パターン (Strategy Pattern)** - Practical Software Engineering Ch14
   - TaskHandlerとその派生クラスで異なるタスクタイプの処理を実装
   - EmailHandler, HttpRequestHandler, DataProcessingHandler, ReportGenerationHandler

3. **テンプレートメソッドパターン** - Practical Software Engineering Ch14
   - TaskStateの基本クラスでexecuteメソッドのテンプレートを定義
   - 各状態クラスで具体的な実装を提供

4. **単一責任の原則 (SRP)** - プリンシパル オブ プログラミング
   - TaskQueue: キューの管理
   - TaskExecutor: タスクの実行
   - StatusTracker: ステータスの追跡
   - PriorityQueue: 優先度付きキュー
   - RateLimiter: レート制限

5. **値オブジェクト** - Code Complete
   - Priority: 優先度を表現
   - TaskInfo: タスク情報の不変表現
   - StatusSummary: ステータスサマリーの値オブジェクト

6. **条件分岐をポリモーフィズムで置き換える** - Refactoring
   - 大きなcase文をTaskHandlerの派生クラスに分解
   - 各ハンドラーが特定のタスクタイプの処理を担当

7. **スレッドセーフティ** - プリンシパル オブ プログラミング
   - Mutexを使用してPriorityQueueとStatusTrackerを保護
   - 並行アクセスに対する安全性を確保

8. **リトライポリシー** - Practical Software Engineering Ch14
   - RetryPolicyクラスでリトライロジックをカプセル化
   - 指数バックオフの実装

9. **Tell, Don't Ask原則** - プリンシパル オブ プログラミング
   - タスクが自身の状態遷移を管理
   - can_retry?メソッドでリトライ可否を判断

10. **ビルダーパターンの概念** - Practical Software Engineering Ch14
    - Task.createメソッドでタスクの生成を簡潔に
    - 必要なデフォルト値を設定

11. **イベント駆動コールバック** - プリンシパル オブ プログラミング
    - on_success, on_failureコールバックの適切な呼び出し
    - 状態遷移時のフック（on_enter）

12. **効率的なデータ構造** - Code Complete
    - 二分探索を使用した優先度キューへの挿入
    - O(log n)の挿入性能を実現