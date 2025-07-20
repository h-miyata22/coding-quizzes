// 使用例
function App() {
  // APIシミュレーション関数
  const searchUser = async (username) => {
    // デモ用: 特定のユーザー名でエラーをシミュレート
    if (username === 'notfound') {
      throw { status: 404 };
    } else if (username === 'toomany') {
      throw { status: 429 };
    } else if (username === 'servererror') {
      throw { status: 500 };
    } else if (username === 'network') {
      throw new Error('Network Error');
    } else if (username === 'unknown') {
      throw new Error('Unknown Error');
    }

    // 正常なレスポンス
    await new Promise(resolve => setTimeout(resolve, 1000));
    return {
      name: username,
      email: `${username}@example.com`,
      avatar: `https://via.placeholder.com/150?text=${username}`
    };
  };

  return (
    <div>
      <h1>ユーザー検索</h1>
      <UserSearch searchUser={searchUser} />
    </div>
  );
}

// UserSearchコンポーネントを実装してください