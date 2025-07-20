import React, { useState, useMemo } from 'react';

function EmployeeSearch({ employees }) {
  const [searchQuery, setSearchQuery] = useState('');

  // 検索結果をフィルタリング
  const filteredEmployees = useMemo(() => {
    if (!searchQuery.trim()) {
      return employees;
    }

    const query = searchQuery.toLowerCase();
    return employees.filter(employee =>
      employee.name.toLowerCase().includes(query) ||
      employee.department.toLowerCase().includes(query) ||
      employee.position.toLowerCase().includes(query)
    );
  }, [searchQuery, employees]);

  // テキストをハイライトする関数
  const highlightText = (text, query) => {
    if (!query.trim()) {
      return text;
    }

    const regex = new RegExp(`(${query})`, 'gi');
    const parts = text.split(regex);

    return parts.map((part, index) => {
      if (part.toLowerCase() === query.toLowerCase()) {
        return (
          <span
            key={index}
            style={{ backgroundColor: '#ffeb3b', fontWeight: 'bold' }}
          >
            {part}
          </span>
        );
      }
      return part;
    });
  };

  return (
    <div>
      {/* 検索フィールド */}
      <div style={{ position: 'relative', marginBottom: '20px' }}>
        <input
          type="text"
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          placeholder="名前、部署、役職で検索"
          style={{
            width: '100%',
            padding: '12px 40px 12px 12px',
            fontSize: '16px',
            border: '1px solid #ddd',
            borderRadius: '4px'
          }}
        />
        {searchQuery && (
          <button
            onClick={() => setSearchQuery('')}
            style={{
              position: 'absolute',
              right: '10px',
              top: '50%',
              transform: 'translateY(-50%)',
              background: 'none',
              border: 'none',
              fontSize: '20px',
              cursor: 'pointer',
              color: '#999'
            }}
          >
            ×
          </button>
        )}
      </div>

      {/* 検索結果数 */}
      {searchQuery && (
        <div style={{ marginBottom: '10px', color: '#666' }}>
          {filteredEmployees.length}件の結果が見つかりました
        </div>
      )}

      {/* 従業員リスト */}
      {filteredEmployees.length > 0 ? (
        <div style={{ display: 'grid', gap: '10px' }}>
          {filteredEmployees.map(employee => (
            <div
              key={employee.id}
              style={{
                display: 'flex',
                alignItems: 'center',
                padding: '15px',
                border: '1px solid #e0e0e0',
                borderRadius: '8px',
                backgroundColor: '#f9f9f9'
              }}
            >
              <img
                src={employee.avatar}
                alt={employee.name}
                style={{
                  width: '50px',
                  height: '50px',
                  borderRadius: '50%',
                  marginRight: '15px'
                }}
              />
              <div style={{ flex: 1 }}>
                <h3 style={{ margin: '0 0 5px 0', fontSize: '18px' }}>
                  {highlightText(employee.name, searchQuery)}
                </h3>
                <div style={{ color: '#666', fontSize: '14px' }}>
                  <div>
                    部署: {highlightText(employee.department, searchQuery)}
                  </div>
                  <div>
                    役職: {highlightText(employee.position, searchQuery)}
                  </div>
                  <div>{employee.email}</div>
                </div>
              </div>
            </div>
          ))}
        </div>
      ) : (
        <div
          style={{
            textAlign: 'center',
            padding: '40px',
            color: '#999'
          }}
        >
          {searchQuery ? '該当する従業員が見つかりません' : '従業員が登録されていません'}
        </div>
      )}
    </div>
  );
}

export default EmployeeSearch;