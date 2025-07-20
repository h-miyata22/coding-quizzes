# リアクティブな状態管理システム

あなたはミニマルな状態管理ライブラリを開発しています。
オブジェクトのプロパティが変更されたときに、自動的に登録された
ウォッチャー関数を実行する仕組みが必要です。

ES6のProxyを使用して、プロパティの変更を検知し、
変更通知を送るcreateReactiveObjectファクトリ関数を実装してください。

## 要件
- `createReactiveObject(initialData)` - リアクティブなオブジェクトを作成
- `watch(object, property, callback)` - プロパティの変更を監視
- `unwatch(object, property, callback)` - 監視を解除
- プロパティが変更されたら、登録されたコールバックを実行
- コールバックには(newValue, oldValue, property)を渡す
- ネストしたオブジェクトの変更も検知

# 実行環境
- Node.js 14+
- ES6 Proxy対応環境