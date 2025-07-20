// 使用例
import React, { useState } from 'react';

// Pagination コンポーネントを実装してください
// 以下の要件を満たす必要があります：
// - データの分割表示
// - ページ移動機能
// - 表示範囲の情報表示

function Pagination({ 
  data, 
  itemsPerPage = 10, 
  renderItem 
}) {
  // 実装してください
}

// 期待される使用方法
function UserList() {
  // 10,000件のダミーユーザーデータ
  const users = Array.from({ length: 10000 }, (_, i) => ({
    id: i + 1,
    name: `User ${i + 1}`,
    email: `user${i + 1}@example.com`,
    role: i % 3 === 0 ? 'Admin' : 'User'
  }));

  return (
    <div>
      <h1>User Management</h1>
      <Pagination
        data={users}
        itemsPerPage={20}
        renderItem={(user) => (
          <div key={user.id} style={{ 
            padding: '10px', 
            borderBottom: '1px solid #eee' 
          }}>
            <strong>{user.name}</strong> - {user.email} ({user.role})
          </div>
        )}
      />
    </div>
  );
}

// 期待される表示例：
// Showing 1-20 of 10,000
// [First] [Previous] [1] 2 3 4 5 ... [500] [Next] [Last]
// 
// User 1 - user1@example.com (Admin)
// User 2 - user2@example.com (User)
// ...

export default UserList;