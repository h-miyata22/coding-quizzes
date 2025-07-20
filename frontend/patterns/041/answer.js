import React from 'react';

function UserDashboard({ user, loading }) {
  // ローディング中の表示
  if (loading) {
    return <div>Loading...</div>;
  }

  // ユーザー情報が取得できない場合
  if (!user) {
    return <div>アクセス権限がありません</div>;
  }

  // 権限に基づいた機能の制御
  const hasUserManagement = user.role === 'admin';
  const hasReportAccess = ['admin', 'manager', 'member'].includes(user.role);
  const hasDataExport = ['admin', 'manager'].includes(user.role);
  const hasSettings = ['admin', 'manager'].includes(user.role);

  return (
    <div className="dashboard">
      <h1>ダッシュボード</h1>
      <p>ようこそ、{user.name}さん ({user.role})</p>
      
      <div className="features">
        {hasUserManagement && (
          <div className="feature-card">
            <h3>ユーザー管理</h3>
            <button>ユーザー一覧を表示</button>
          </div>
        )}
        
        {hasReportAccess && (
          <div className="feature-card">
            <h3>レポート作成</h3>
            <button>新規レポート作成</button>
          </div>
        )}
        
        {hasDataExport && (
          <div className="feature-card">
            <h3>データエクスポート</h3>
            <button>CSVダウンロード</button>
          </div>
        )}
        
        {hasSettings && (
          <div className="feature-card">
            <h3>設定変更</h3>
            <button>設定画面へ</button>
          </div>
        )}
      </div>
    </div>
  );
}

export default UserDashboard;