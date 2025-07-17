# 出題意図

この問題は、検索エンジン/インデックスシステムのリファクタリングを通じて、戦略パターン、ビルダーパターン、責任の連鎖パターン、イテレータパターン、リポジトリパターンを学習することを目的としています。

## 適用されたテーマ

1. **戦略パターン (Strategy Pattern)** - Practical Software Engineering Ch14
   - SortingStrategyとその派生クラスで異なるソート戦略を実装
   - ScoreSortingStrategy, DateSortingStrategy, TitleSortingStrategy

2. **ビルダーパターン** - Practical Software Engineering Ch14
   - QueryBuilderでクエリオブジェクトを段階的に構築
   - トークン化と構造化を分離

3. **責任の連鎖パターン** - Practical Software Engineering Ch14
   - FilterChainで複数のフィルターを連鎖的に適用
   - TagFilter, DateRangeFilterを組み合わせ可能に

4. **単一責任の原則 (SRP)** - プリンシパル オブ プログラミング
   - DocumentStore: ドキュメントの保存
   - InvertedIndex: 転置インデックスの管理
   - Indexer: インデックスの作成
   - Searcher: 検索の実行
   - TextAnalyzer: テキスト解析

5. **リポジトリパターン** - Practical Software Engineering Ch14
   - DocumentStoreでドキュメントの永続化を抽象化
   - SearchHistoryで検索履歴を管理

6. **値オブジェクト** - Code Complete
   - Document, Query, SearchResult, IndexEntry
   - 不変オブジェクトとしてデータを表現

7. **ファクトリーパターン** - Practical Software Engineering Ch14
   - SortingStrategyFactoryで適切なソート戦略を生成
   - 条件分岐をポリモーフィズムに置き換え

8. **テンプレートメソッドパターン** - Practical Software Engineering Ch14
   - Searcherのsearchメソッドが検索プロセスのテンプレート
   - 各ステップ（検索、スコアリング、フィルタリング、ソート）を定義

9. **Tell, Don't Ask原則** - プリンシパル オブ プログラミング
   - Documentが自身のデータを管理
   - SearchResultが検索結果の情報をカプセル化

10. **ループを関数型のメソッドに置き換える** - Refactoring
    - selectやmapを使用した関数型のアプローチ
    - 副作用を最小限に抑えた実装

11. **抽出クラス** - Refactoring
    - QueryTokenizerでクエリのトークン化を分離
    - Highlighterでハイライト処理を分離
    - ResultProcessorで結果の後処理を分離

12. **スレッドセーフティ** - プリンシパル オブ プログラミング
    - Mutexを使用して並行アクセスから保護
    - DocumentStore, InvertedIndex, SearchHistoryで実装