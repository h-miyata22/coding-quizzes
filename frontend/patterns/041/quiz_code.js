// 使用例
function App() {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // ユーザー情報を取得する処理をシミュレート
    setTimeout(() => {
      // 実際の実装では、APIからユーザー情報を取得
      setUser({ 
        name: 'John Doe', 
        role: 'manager' // 'admin', 'manager', 'member' のいずれか
      });
      setLoading(false);
    }, 1000);
  }, []);

  return (
    <UserDashboard 
      user={user} 
      loading={loading}
    />
  );
}

// UserDashboardコンポーネントを実装してください