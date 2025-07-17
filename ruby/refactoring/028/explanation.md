# 出題意図

この問題は、ドキュメント処理システムのリファクタリングを通じて、ビジターパターン（Visitor Pattern）による条件分岐の置き換え、Open-Closed原則の適用、ダブルディスパッチの実装を学習することを目的としています。

## 適用されたテーマ

1. **ビジターパターン (Visitor Pattern)** - Practical Software Engineering Ch14
   - DocumentVisitorとその派生クラスで操作を外部化
   - 新しい操作を既存のクラス階層を変更せずに追加可能

2. **条件分岐をポリモーフィズムで置き換える** - Refactoring
   - 大きなcase文をvisitメソッドのポリモーフィズムに置き換え
   - 型チェックの除去とコードの拡張性向上

3. **Open-Closed原則 (OCP)** - プリンシパル オブ プログラミング
   - 新しいドキュメントタイプや操作を既存コードの変更なしに追加
   - 拡張に対して開いて、修正に対して閉じた設計

4. **ダブルディスパッチ** - Practical Software Engineering Ch14
   - acceptメソッドとvisitメソッドの組み合わせ
   - 実行時の型に基づく動的な処理選択

5. **単一責任の原則 (SRP)** - プリンシパル オブ プログラミング
   - 各Visitorクラスが特定の操作のみを担当
   - MetadataExtractor, SizeCalculator, PreviewGeneratorなど責務の分離

6. **ファクトリーパターン** - Practical Software Engineering Ch14
   - DocumentFactoryでドキュメントオブジェクトの生成を集約
   - 型に応じた適切なオブジェクト生成

7. **戦略パターンとの組み合わせ** - Practical Software Engineering Ch14
   - 各種Calculator、Extractor、Generatorクラス
   - 同じインターフェースで異なる処理を実装

8. **抽出クラス** - Refactoring
   - 機能別にクラスを分離（Analysis、Validator、Calculatorなど）
   - 大きなクラスを責務に応じて分割

9. **インターフェース分離の原則 (ISP)** - プリンシパル オブ プログラミング
   - DocumentVisitorで必要なメソッドのみを定義
   - クライアントが不要な依存関係を持たない設計

10. **Tell, Don't Ask原則** - プリンシパル オブ プログラミング
    - Documentオブジェクトがacceptメソッドで処理を委譲
    - 外部からの型チェックを排除

11. **値オブジェクト** - Code Complete
    - 各種Documentクラスでドメインオブジェクトを表現
    - データとその操作を適切にカプセル化

12. **ガード節** - Tidy First?
    - バリデーターでの早期エラー検出
    - 不正な状態の早期発見

## ビジターパターンの利点

### 1. **新しい操作の追加が容易**
- 新しいVisitorクラスを作成するだけで新機能追加
- 既存のDocumentクラスを変更する必要なし

### 2. **関連する操作の集約**
- 同じ種類の操作（メタデータ抽出、バリデーションなど）を一箇所に集約
- コードの理解と保守が容易

### 3. **型安全性の向上**
- コンパイル時に不正な操作を検出
- ランタイムエラーの減少

## 設計の拡張性

### 1. **新しいドキュメント形式への対応**
```ruby
class SpreadsheetDocument < Document
  def accept(visitor)
    visitor.visit_spreadsheet_document(self)
  end
end
```

### 2. **新しい操作の追加**
```ruby
class CompressionVisitor < DocumentVisitor
  # 各ドキュメントタイプの圧縮処理
end
```

この設計により、機能の追加時に既存コードを変更せず、安全に拡張できるシステムを実現できます。