# テキストエディタのUndo機能

あなたは簡単なテキストエディタアプリケーションを開発しています。
ユーザーが行った操作（文字の追加、削除、置換）を元に戻せるUndo機能が必要です。

Command Patternを使用して、実行可能な操作をカプセル化し、
Undo機能を実装するTextEditorクラスを作成してください。

## 要件
- `execute(command)` - コマンドを実行し、履歴に追加
- `undo()` - 直前の操作を取り消す
- `canUndo()` - Undo可能かどうかを返す
- `getText()` - 現在のテキストを取得
- コマンドは以下をサポート:
  - InsertCommand: 指定位置に文字列を挿入
  - DeleteCommand: 指定位置から指定長さの文字を削除
  - ReplaceCommand: 指定範囲の文字列を置換
- 各コマンドは`execute()`と`undo()`メソッドを持つ

# 実行環境
- Node.js 14+
- ES6+対応環境