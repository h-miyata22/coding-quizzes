import React, { useState } from 'react';

function UserSearch({ searchUser }) {
  const [username, setUsername] = useState('');
  const [userData, setUserData] = useState(null);
  const [error, setError] = useState(null);
  const [isLoading, setIsLoading] = useState(false);

  // エラータイプに応じたメッセージを返す関数
  const getErrorMessage = (error) => {
    if (error.status === 404) {
      return 'ユーザーが見つかりませんでした';
    } else if (error.status === 429) {
      return 'リクエストが多すぎます。しばらく待ってから再度お試しください';
    } else if (error.status === 500) {
      return 'サーバーエラーが発生しました。時間をおいて再度お試しください';
    } else if (error.message && error.message.includes('Network')) {
      return 'ネットワークに接続できません。接続を確認してください';
    } else {
      return '予期しないエラーが発生しました';
    }
  };

  // 検索処理
  const handleSearch = async (e) => {
    e.preventDefault();
    
    if (!username.trim()) {
      return;
    }

    setIsLoading(true);
    setError(null);
    setUserData(null);

    try {
      const data = await searchUser(username);
      setUserData(data);
    } catch (err) {
      setError(err);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div style={{ maxWidth: '400px', margin: '0 auto' }}>
      <form onSubmit={handleSearch}>
        <div style={{ marginBottom: '10px' }}>
          <input
            type="text"
            value={username}
            onChange={(e) => setUsername(e.target.value)}
            placeholder="ユーザー名を入力"
            style={{ 
              width: '100%', 
              padding: '8px',
              fontSize: '16px'
            }}
          />
        </div>
        <button 
          type="submit" 
          disabled={isLoading}
          style={{ 
            padding: '8px 16px',
            cursor: isLoading ? 'not-allowed' : 'pointer',
            opacity: isLoading ? 0.6 : 1
          }}
        >
          {isLoading ? '検索中...' : '検索'}
        </button>
      </form>

      {error && (
        <div style={{ 
          color: 'red', 
          marginTop: '20px',
          padding: '10px',
          border: '1px solid red',
          borderRadius: '4px',
          backgroundColor: '#ffeeee'
        }}>
          {getErrorMessage(error)}
        </div>
      )}

      {userData && (
        <div style={{ 
          marginTop: '20px',
          padding: '20px',
          border: '1px solid #ddd',
          borderRadius: '8px'
        }}>
          <img 
            src={userData.avatar} 
            alt={userData.name}
            style={{ 
              width: '100px', 
              height: '100px',
              borderRadius: '50%',
              marginBottom: '10px'
            }}
          />
          <h3>{userData.name}</h3>
          <p>{userData.email}</p>
        </div>
      )}
    </div>
  );
}

export default UserSearch;