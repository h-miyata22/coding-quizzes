// 使用例
import React from 'react';

// ユーザー設定の保存
function UserSettings() {
  const [settings, setSettings] = useLocalStorage('userSettings', {
    theme: 'light',
    language: 'en',
    notifications: true
  });
  
  return (
    <div>
      <h2>Settings</h2>
      
      <select 
        value={settings.theme} 
        onChange={(e) => setSettings({...settings, theme: e.target.value})}
      >
        <option value="light">Light</option>
        <option value="dark">Dark</option>
      </select>
      
      <label>
        <input
          type="checkbox"
          checked={settings.notifications}
          onChange={(e) => setSettings({...settings, notifications: e.target.checked})}
        />
        Enable notifications
      </label>
      
      <button onClick={() => setSettings({
        theme: 'light',
        language: 'en',
        notifications: true
      })}>
        Reset to defaults
      </button>
    </div>
  );
}

// ショッピングカートの永続化
function ShoppingCart() {
  const [cart, setCart, removeCart] = useLocalStorage('shoppingCart', []);
  
  const addItem = (item) => {
    setCart([...cart, item]);
  };
  
  const clearCart = () => {
    removeCart(); // localStorageから削除
  };
  
  return (
    <div>
      <h2>Cart ({cart.length} items)</h2>
      {cart.map((item, index) => (
        <div key={index}>{item.name} - ${item.price}</div>
      ))}
      <button onClick={() => addItem({ name: 'Product', price: 10 })}>
        Add Item
      </button>
      <button onClick={clearCart}>Clear Cart</button>
    </div>
  );
}

// フォームの自動保存
function DraftForm() {
  const [formData, setFormData] = useLocalStorage('formDraft', {
    title: '',
    content: '',
    tags: []
  });
  
  const handleSubmit = (e) => {
    e.preventDefault();
    // フォーム送信処理
    console.log('Submitting:', formData);
    // 送信後はドラフトを削除
    setFormData({ title: '', content: '', tags: [] });
  };
  
  return (
    <form onSubmit={handleSubmit}>
      <input
        type="text"
        value={formData.title}
        onChange={(e) => setFormData({...formData, title: e.target.value})}
        placeholder="Title"
      />
      <textarea
        value={formData.content}
        onChange={(e) => setFormData({...formData, content: e.target.value})}
        placeholder="Content"
      />
      <div>Draft saved automatically</div>
      <button type="submit">Submit</button>
    </form>
  );
}

// プリミティブ値の保存
function Counter() {
  const [count, setCount] = useLocalStorage('counter', 0);
  
  return (
    <div>
      <h2>Persistent Counter: {count}</h2>
      <button onClick={() => setCount(count + 1)}>Increment</button>
      <button onClick={() => setCount(0)}>Reset</button>
    </div>
  );
}

// 複数のストレージフックの使用
function Dashboard() {
  const [user, setUser] = useLocalStorage('currentUser', null);
  const [preferences, setPreferences] = useLocalStorage('preferences', {
    dashboard: 'grid',
    sidebarOpen: true
  });
  const [recentActivity, setRecentActivity] = useLocalStorage('recentActivity', []);
  
  return (
    <div>
      {user ? (
        <div>Welcome, {user.name}!</div>
      ) : (
        <button onClick={() => setUser({ name: 'John Doe', id: 1 })}>
          Login
        </button>
      )}
      
      <label>
        <input
          type="checkbox"
          checked={preferences.sidebarOpen}
          onChange={(e) => setPreferences({
            ...preferences,
            sidebarOpen: e.target.checked
          })}
        />
        Show sidebar
      </label>
    </div>
  );
}