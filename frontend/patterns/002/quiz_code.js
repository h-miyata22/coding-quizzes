// 使用例
const eventManager = new EventManager();

// ウィジェットA
const widgetA = { id: 'widget-a' };
eventManager.subscribe(widgetA, 'data-update', (data) => {
  console.log('Widget A received:', data);
});
eventManager.subscribe(widgetA, 'error', (error) => {
  console.log('Widget A error:', error);
});

// ウィジェットB
const widgetB = { id: 'widget-b' };
eventManager.subscribe(widgetB, 'data-update', (data) => {
  console.log('Widget B received:', data);
});

// データ更新イベント発火
eventManager.emit('data-update', { value: 100 });
// Output: Widget A received: { value: 100 }
// Output: Widget B received: { value: 100 }

// ウィジェットAのエラーリスナーのみ削除
eventManager.unsubscribe(widgetA, 'error', /* callback reference */);

// ウィジェットBをすべて削除（メモリクリーンアップ）
eventManager.unsubscribeAll(widgetB);

// 再度データ更新イベント発火
eventManager.emit('data-update', { value: 200 });
// Output: Widget A received: { value: 200 }
// (Widget Bは削除されたので出力されない)