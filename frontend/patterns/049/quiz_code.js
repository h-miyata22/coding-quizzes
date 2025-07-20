// 使用例
function App() {
  // サンプルデータ
  const employees = [
    {
      id: 1,
      name: '田中 太郎',
      department: '開発部',
      position: 'シニアエンジニア',
      email: 'tanaka@example.com',
      avatar: 'https://via.placeholder.com/50?text=TT'
    },
    {
      id: 2,
      name: '佐藤 花子',
      department: 'マーケティング部',
      position: 'マネージャー',
      email: 'sato@example.com',
      avatar: 'https://via.placeholder.com/50?text=SH'
    },
    {
      id: 3,
      name: '鈴木 一郎',
      department: '開発部',
      position: 'ジュニアエンジニア',
      email: 'suzuki@example.com',
      avatar: 'https://via.placeholder.com/50?text=SI'
    },
    {
      id: 4,
      name: '山田 美優',
      department: '人事部',
      position: '人事担当',
      email: 'yamada@example.com',
      avatar: 'https://via.placeholder.com/50?text=YM'
    },
    {
      id: 5,
      name: '伊藤 健太',
      department: '営業部',
      position: '営業担当',
      email: 'ito@example.com',
      avatar: 'https://via.placeholder.com/50?text=IK'
    }
  ];

  return (
    <div style={{ maxWidth: '800px', margin: '40px auto', padding: '20px' }}>
      <h1>従業員ディレクトリ</h1>
      <EmployeeSearch employees={employees} />
    </div>
  );
}

// EmployeeSearchコンポーネントを実装してください