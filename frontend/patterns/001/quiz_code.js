// 使用例
const chatEvents = new EventEmitter();

// メッセージ受信時の処理
chatEvents.on('message', (user, text) => {
  console.log(`${user}: ${text}`);
});

// ユーザーのオンライン状態変更
chatEvents.on('userStatus', (user, status) => {
  console.log(`${user} is now ${status}`);
});

// 通知音を鳴らす処理
const playSound = () => console.log('♪ New message sound');
chatEvents.on('message', playSound);

// イベント発火
chatEvents.emit('message', 'Alice', 'Hello everyone!');
chatEvents.emit('userStatus', 'Bob', 'online');

// 通知音を解除
chatEvents.off('message', playSound);

// 再度メッセージイベント発火（通知音は鳴らない）
chatEvents.emit('message', 'Charlie', 'Hi there!');