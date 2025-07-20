// 使用例
const eventSystem = new CustomEventSystem();

// 要素の階層構造を作成
const root = { id: 'root', parent: null };
const container = { id: 'container', parent: root };
const button = { id: 'button', parent: container };

// ルート要素でクリックイベントをリスン（バブリングフェーズ）
eventSystem.addEventListener(root, 'click', (event) => {
  console.log(`Root clicked! Target: ${event.target.id}, CurrentTarget: ${event.currentTarget.id}`);
});

// コンテナでクリックイベントをリスン
eventSystem.addEventListener(container, 'click', (event) => {
  console.log(`Container clicked! Target: ${event.target.id}`);
  // ここでバブリングを停止
  event.stopPropagation();
});

// ボタンでクリックイベントをリスン
eventSystem.addEventListener(button, 'click', (event) => {
  console.log(`Button clicked! Target: ${event.target.id}`);
});

// カスタムイベントを作成して発火
const clickEvent = {
  type: 'click',
  target: button,
  currentTarget: null,
  _propagationStopped: false,
  stopPropagation() {
    this._propagationStopped = true;
  }
};

// ボタンからイベントを発火
eventSystem.dispatchEvent(button, clickEvent);
// Expected output:
// Button clicked! Target: button
// Container clicked! Target: button
// (Rootは stopPropagation() のため実行されない)