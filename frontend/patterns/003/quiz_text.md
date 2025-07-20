# カスタムUIフレームワークのイベントシステム

あなたは独自のUIフレームワークを開発しており、DOMイベントのような
イベントバブリング機能を持つカスタムイベントシステムを実装する必要があります。

CustomEventSystemクラスを実装してください。
このクラスは、イベントの伝播（バブリング）とイベントオブジェクトの管理をサポートします。

## 要件
- `addEventListener(element, eventType, handler, useCapture)` - イベントリスナーを登録
- `removeEventListener(element, eventType, handler, useCapture)` - イベントリスナーを削除
- `dispatchEvent(element, event)` - イベントを発火し、親要素へバブリング
- イベントオブジェクトには`type`、`target`、`currentTarget`、`stopPropagation()`を含む
- `stopPropagation()`が呼ばれたらバブリングを停止
- 要素は`parent`プロパティで親要素を参照

# 実行環境
- Node.js 14+
- ES6+対応環境