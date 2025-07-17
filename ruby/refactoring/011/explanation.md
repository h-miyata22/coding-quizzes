# 出題意図

この問題は、画像処理とキャッシュ管理のリファクタリングを通じて、キャッシュの抽象化、単一責任の原則、パフォーマンスを考慮した設計を学習することを目的としています。

## 適用されたテーマ

1. **単一責任の原則 (SRP)** - プリンシパル オブ プログラミング
   - ImageProcessor: 画像処理
   - CacheManager: キャッシュ管理
   - ThumbnailBatchProcessor: バッチ処理

2. **キャッシュの抽象化** - Design Patterns
   - CacheManagerクラスでキャッシュロジックをカプセル化
   - fetchメソッドで「キャッシュがあれば返す、なければ生成して保存」を実現

3. **テンプレートメソッドパターン** - Design Patterns
   - fetchメソッドがyieldを使用
   - キャッシュの存在チェックと生成ロジックを分離

4. **依存性注入** - Practical Software Engineering
   - CacheManagerを外部から注入
   - テスタビリティと柔軟性の向上

5. **名前付き定数** - Code Complete
   - DEFAULT_TTL, DEFAULT_CLEANUP_TTLなど
   - マジックナンバーを排除し意図を明確に

6. **ループをイテレータに置き換える** - Refactoring
   - forループをeach_with_objectに置き換え
   - Rubyらしい関数型プログラミング

7. **ファイルシステム操作の改善** - プリンシパル オブ プログラミング
   - Dir.globを使用してファイル一覧を取得
   - File.joinでパスを安全に結合

8. **例外処理の適切な使用** - プリンシパル オブ プログラミング
   - Errno::ENOENTを捕捉して競合状態を処理
   - ファイル削除時のエラーを適切にハンドリング

9. **メソッドの抽出** - Refactoring
   - 大きなメソッドを小さな、目的が明確なメソッドに分割
   - cache_expired?, file_expired?など

10. **ガード節** - Tidy First?
    - Dir.exist?チェックでディレクトリ存在を確認
    - 不要な処理を早期にスキップ