# 出題意図

この問題は、在庫管理システムのリファクタリングを通じて、ドメインモデリング、リポジトリパターン、コマンドパターン、値オブジェクトの活用を学習することを目的としています。

## 適用されたテーマ

1. **ドメインモデリング** - Practical Software Engineering Ch11
   - Product, Warehouse, StockEntry, Customerなどのエンティティ
   - ビジネスロジックを適切なドメインオブジェクトに配置

2. **リポジトリパターン** - Practical Software Engineering Ch14
   - ProductRepository, WarehouseRepositoryでデータアクセスを抽象化
   - ビジネスロジックとデータ永続化の関心を分離

3. **コマンドパターン** - Practical Software Engineering Ch14
   - TransferStockCommand, SellProductCommandで複雑な操作をカプセル化
   - トランザクション的な操作を独立したオブジェクトとして表現

4. **値オブジェクト** - Code Complete
   - Money, Quantityクラスでプリミティブ型を置き換え
   - ビジネスルールを値オブジェクト内にカプセル化

5. **単一責任の原則 (SRP)** - プリンシパル オブ プログラミング
   - 各クラスが明確な単一の責務を持つ
   - Inventory: 在庫管理、AlertService: アラート、TransactionLog: 履歴

6. **Tell, Don't Ask原則** - プリンシパル オブ プログラミング
   - Warehouseがhas_stock?メソッドを提供
   - Inventoryが在庫管理のロジックを内包

7. **プリミティブ型の執着を排除** - Refactoring
   - 数値や文字列を意味のあるオブジェクトに置き換え
   - customer_nameをCustomerオブジェクトに

8. **ファーストクラスコレクション** - Code Complete
   - Inventoryクラスで在庫エントリのコレクションを管理
   - コレクション操作のロジックをカプセル化

9. **ビルダーパターン** - Practical Software Engineering Ch14
   - InventoryReportBuilderで複雑なレポート生成を構造化
   - 段階的な構築プロセスを明確に

10. **メソッドの抽出** - Refactoring
    - 長大なメソッドを意味のある単位に分割
    - calculate_total_quantity, build_product_sectionなど

11. **結果オブジェクト** - プリンシパル オブ プログラミング
    - OperationResultで成功/失敗を表現
    - 例外の代わりに明示的な結果を返す

12. **不変性** - Tidy First?
    - StockEntry, Money, Quantityは不変オブジェクト
    - 新しい状態は新しいインスタンスとして生成