# 出題意図

この問題は、メッセージキュー/Pub-Subシステムのリファクタリングを通じて、オブザーバーパターン、戦略パターン、フィルターパターン、イベント駆動アーキテクチャを学習することを目的としています。

## 適用されたテーマ

1. **オブザーバーパターン** - Practical Software Engineering Ch14
   - Pub-Subモデルの実装
   - SubscriberがMessageの通知を受け取る仕組み

2. **戦略パターン (Strategy Pattern)** - Practical Software Engineering Ch14
   - DeliveryStrategyで同期/非同期配信を切り替え
   - SyncDeliveryStrategy, AsyncDeliveryStrategy

3. **単一責任の原則 (SRP)** - プリンシパル オブ プログラミング
   - TopicRegistry: トピック管理
   - SubscriptionManager: 購読管理
   - MessageStore: メッセージ保存
   - DeliveryService: 配信処理
   - DeadLetterQueue: 失敗メッセージ管理

4. **フィルターパターン** - Code Complete
   - MessageFilterとその派生クラス
   - NullFilter, AttributeFilterで条件付き配信

5. **リポジトリパターン** - Practical Software Engineering Ch14
   - MessageStore, TopicRegistryでデータアクセスを抽象化
   - ビジネスロジックとデータ管理の分離

6. **値オブジェクト** - Code Complete
   - Message, Priority, MessageAttributes
   - 不変オブジェクトとしてデータを表現

7. **Dead Letter Queueパターン** - Practical Software Engineering Ch14
   - 配信失敗メッセージの別管理
   - エラー処理とリトライの分離

8. **結果オブジェクトパターン** - プリンシパル オブ プログラミング
   - SubscriptionResult, PublishResult
   - 成功/失敗を明示的に表現

9. **Tell, Don't Ask原則** - プリンシパル オブ プログラミング
   - Messageがexpired?で有効期限を判定
   - Subscriberがmatches_message?でフィルタリング

10. **スレッドセーフティ** - プリンシパル オブ プログラミング
    - Mutexを使用して並行アクセスから保護
    - TopicRegistry, SubscriptionManager, MessageStoreで実装

11. **クエリオブジェクト** - Refactoring
    - MessageQueryで複雑なクエリ操作をカプセル化
    - メソッドチェーンによる流暢なインターフェース

12. **イベント駆動アーキテクチャ** - Practical Software Engineering Ch10
    - 非同期メッセージ配信
    - リトライメカニズムの実装
    - 疎結合なコンポーネント設計