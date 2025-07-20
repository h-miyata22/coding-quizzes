// 使用例
import React from 'react';

// VirtualList コンポーネントを実装してください
// 以下の要件を満たす必要があります：
// - 固定高さアイテムの仮想スクロール
// - 可視範囲のみのレンダリング
// - スムーズなスクロール
// - overscanによるバッファリング

function VirtualList({
  items,
  height,      // コンテナの高さ
  itemHeight,  // 各アイテムの高さ（固定）
  renderItem,  // アイテムのレンダリング関数
  overscan = 3 // 表示範囲外のバッファアイテム数
}) {
  // 実装してください
}

// 期待される使用方法
function MessageList() {
  // 5000件のメッセージデータ
  const messages = Array.from({ length: 5000 }, (_, i) => ({
    id: i,
    sender: `User ${i % 10}`,
    text: `This is message #${i}. Lorem ipsum dolor sit amet...`,
    timestamp: new Date(Date.now() - i * 60000).toLocaleTimeString()
  }));

  return (
    <div>
      <h1>Messages</h1>
      <VirtualList
        items={messages}
        height={600}
        itemHeight={80}
        renderItem={({ item, style }) => (
          <div style={{
            ...style,
            padding: '10px',
            borderBottom: '1px solid #eee',
            display: 'flex',
            flexDirection: 'column'
          }}>
            <div style={{ fontWeight: 'bold' }}>
              {item.sender} - {item.timestamp}
            </div>
            <div style={{ marginTop: '5px' }}>
              {item.text}
            </div>
          </div>
        )}
      />
    </div>
  );
}

export default MessageList;