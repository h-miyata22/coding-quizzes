# 出題意図

この問題は、データベースアクセスコードのリファクタリングを通じて、SQLインジェクション対策、リポジトリパターン、N+1問題の考慮などを学習することを目的としています。

## 適用されたテーマ

1. **SQLインジェクション対策** - プリンシプル オブ プログラミング（安全性原理）
   - 文字列結合ではなくパラメータバインディングを使用
   - ?プレースホルダーで安全なSQL実行

2. **リポジトリパターン** - Design Patterns, Practical Software Engineering
   - UserRepositoryでデータアクセスロジックをカプセル化
   - ビジネスロジックとデータアクセス層の分離

3. **アクティブレコードパターン** - Patterns of Enterprise Application Architecture
   - Userクラスがデータと振る舞いをカプセル化
   - ドメインオブジェクトとしての責任を明確に

4. **プレゼンターパターン** - Design Patterns
   - UserPresenterで表示用のデータ整形を担当
   - ビューに応じた柔軟なデータ表現

5. **遅延読み込み (Lazy Loading)** - Patterns of Enterprise Application Architecture
   - posts_countやfollowers_countを必要になるまで読み込まない
   - ||演算子でキャッシュしてパフォーマンス向上

6. **依存性注入** - Practical Software Engineering
   - UserServiceにリポジトリを注入
   - テスタビリティと柔軟性の向上

7. **DRY原則** - プリンシプル オブ プログラミング
   - count_recordsメソッドでカウント処理を一元化
   - 重複したSQLクエリを排除

8. **名前付き定数** - Code Complete
   - DEFAULT_PAGE_SIZE, LATEST_POSTS_LIMITなど
   - マジックナンバーを排除し意図を明確に

9. **単一責任の原則 (SRP)** - プリンシプル オブ プログラミング
   - UserService: ビジネスロジックの調整
   - UserRepository: データアクセス
   - User: ドメインロジック
   - UserPresenter: 表示用データ整形

10. **ガード節** - Tidy First?
    - keyword.nil? || keyword.empty?のチェック
    - 早期リターンでネストを減らす