// 使用例
import React, { useState } from 'react';

// 基本的な使用方法
function App() {
  return (
    <AuthProvider>
      <Router />
    </AuthProvider>
  );
}

function Router() {
  const { user, isAuthenticated } = useAuth();
  
  return (
    <div>
      {isAuthenticated ? (
        <AuthenticatedApp user={user} />
      ) : (
        <LoginPage />
      )}
    </div>
  );
}

// ログインフォーム
function LoginPage() {
  const [credentials, setCredentials] = useState({ email: '', password: '' });
  const { login, loading, error } = useAuth();
  
  const handleSubmit = async (e) => {
    e.preventDefault();
    await login(credentials.email, credentials.password);
  };
  
  return (
    <form onSubmit={handleSubmit}>
      <h2>Login</h2>
      {error && <p style={{ color: 'red' }}>{error}</p>}
      
      <input
        type="email"
        placeholder="Email"
        value={credentials.email}
        onChange={(e) => setCredentials({ ...credentials, email: e.target.value })}
        required
      />
      
      <input
        type="password"
        placeholder="Password"
        value={credentials.password}
        onChange={(e) => setCredentials({ ...credentials, password: e.target.value })}
        required
      />
      
      <button type="submit" disabled={loading}>
        {loading ? 'Logging in...' : 'Login'}
      </button>
    </form>
  );
}

// 認証済みアプリケーション
function AuthenticatedApp() {
  const { user, logout } = useAuth();
  
  return (
    <div>
      <header>
        <h1>Welcome, {user.name}!</h1>
        <nav>
          <a href="/dashboard">Dashboard</a>
          <a href="/profile">Profile</a>
          {user.role === 'admin' && <a href="/admin">Admin Panel</a>}
          <button onClick={logout}>Logout</button>
        </nav>
      </header>
      
      <main>
        <Routes>
          <Route path="/dashboard" element={<Dashboard />} />
          <Route path="/profile" element={<Profile />} />
          <Route 
            path="/admin" 
            element={
              <RequireRole role="admin">
                <AdminPanel />
              </RequireRole>
            } 
          />
        </Routes>
      </main>
    </div>
  );
}

// 権限ベースのコンポーネント保護
function RequireRole({ role, children }) {
  const { user } = useAuth();
  
  if (user?.role !== role) {
    return <div>Access denied. You need {role} permissions.</div>;
  }
  
  return children;
}

// ユーザープロフィール
function Profile() {
  const { user, updateUser } = useAuth();
  const [editing, setEditing] = useState(false);
  const [formData, setFormData] = useState({
    name: user.name,
    email: user.email
  });
  
  const handleUpdate = async (e) => {
    e.preventDefault();
    await updateUser(formData);
    setEditing(false);
  };
  
  return (
    <div className="profile">
      <h2>My Profile</h2>
      
      {editing ? (
        <form onSubmit={handleUpdate}>
          <input
            type="text"
            value={formData.name}
            onChange={(e) => setFormData({ ...formData, name: e.target.value })}
          />
          <input
            type="email"
            value={formData.email}
            onChange={(e) => setFormData({ ...formData, email: e.target.value })}
          />
          <button type="submit">Save</button>
          <button type="button" onClick={() => setEditing(false)}>Cancel</button>
        </form>
      ) : (
        <div>
          <p>Name: {user.name}</p>
          <p>Email: {user.email}</p>
          <p>Role: {user.role}</p>
          <button onClick={() => setEditing(true)}>Edit Profile</button>
        </div>
      )}
    </div>
  );
}

// 初期ローディング状態
function AppWithAuth() {
  return (
    <AuthProvider>
      <AuthChecker />
    </AuthProvider>
  );
}

function AuthChecker() {
  const { loading } = useAuth();
  
  if (loading) {
    return <div>Loading authentication...</div>;
  }
  
  return <Router />;
}

// 条件付きレンダリング
function Navigation() {
  const { isAuthenticated, user } = useAuth();
  
  return (
    <nav>
      <a href="/">Home</a>
      {isAuthenticated ? (
        <>
          <a href="/dashboard">Dashboard</a>
          <span>Hello, {user.name}</span>
          <LogoutButton />
        </>
      ) : (
        <>
          <a href="/login">Login</a>
          <a href="/signup">Sign Up</a>
        </>
      )}
    </nav>
  );
}

// 再利用可能なログアウトボタン
function LogoutButton() {
  const { logout } = useAuth();
  
  return (
    <button onClick={logout} className="logout-button">
      Sign Out
    </button>
  );
}

// API呼び出しでの認証トークン使用
function SecureDataFetcher() {
  const { token } = useAuth();
  const [data, setData] = useState(null);
  
  useEffect(() => {
    if (!token) return;
    
    fetch('/api/secure-data', {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    })
    .then(res => res.json())
    .then(setData)
    .catch(console.error);
  }, [token]);
  
  return (
    <div>
      {data ? (
        <pre>{JSON.stringify(data, null, 2)}</pre>
      ) : (
        <p>Loading secure data...</p>
      )}
    </div>
  );
}