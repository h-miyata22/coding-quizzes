# ダイナミックテーマシステム

あなたは大規模なWebアプリケーションのテーマ管理システムを開発しています。
ユーザーの好みやシステム設定に応じて、アプリケーション全体のテーマを
動的に切り替える必要があります。

React Context APIとProvider Patternを使用して、
ライト/ダークモードの切り替えとカスタムテーマ色をサポートする
ThemeProviderシステムを実装してください。

## 要件
- `ThemeProvider` - テーマ状態を管理するProvider
- `useTheme` - テーマ情報にアクセスするカスタムフック
- ライト/ダークモードの切り替え
- カスタムプライマリカラーの設定
- システムの配色設定への自動追従（prefers-color-scheme）
- LocalStorageへのテーマ設定の永続化
- テーマ変更時のスムーズなトランジション
- SSR対応（初期レンダリング時のフラッシュ防止）

# 実行環境
- React 16.8+（Hooks、Context API対応）
- ES6+対応環境
- モダンブラウザ（CSS変数、prefers-color-scheme対応）