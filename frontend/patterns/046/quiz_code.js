// 使用例
function App() {
  const [notifications, setNotifications] = useState([
    { id: 1, type: 'success', message: '保存が完了しました', visible: false },
    { id: 2, type: 'warning', message: 'ネットワーク速度が遅いようです', visible: false },
    { id: 3, type: 'error', message: 'アップロードに失敗しました', visible: false },
    { id: 4, type: 'info', message: '新しいアップデートがあります', visible: false }
  ]);

  const showNotification = (id) => {
    setNotifications(prev => 
      prev.map(notif => 
        notif.id === id ? { ...notif, visible: true } : notif
      )
    );
  };

  const hideNotification = (id) => {
    setNotifications(prev => 
      prev.map(notif => 
        notif.id === id ? { ...notif, visible: false } : notif
      )
    );
  };

  return (
    <div style={{ padding: '20px' }}>
      <h2>通知メッセージデモ</h2>
      
      <div style={{ marginBottom: '20px' }}>
        <button onClick={() => showNotification(1)} style={{ marginRight: '10px' }}>
          成功通知を表示
        </button>
        <button onClick={() => showNotification(2)} style={{ marginRight: '10px' }}>
          警告通知を表示
        </button>
        <button onClick={() => showNotification(3)} style={{ marginRight: '10px' }}>
          エラー通知を表示
        </button>
        <button onClick={() => showNotification(4)}>
          情報通知を表示
        </button>
      </div>

      <div style={{ position: 'relative', minHeight: '200px' }}>
        {notifications.map((notification) => (
          <NotificationMessage
            key={notification.id}
            isVisible={notification.visible}
            type={notification.type}
            message={notification.message}
            onClose={() => hideNotification(notification.id)}
          />
        ))}
      </div>
    </div>
  );
}

// NotificationMessageコンポーネントを実装してください