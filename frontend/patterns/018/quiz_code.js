// 使用例
import React, { useState } from 'react';

// ユーザー一覧の取得
function UserList() {
  const { data, loading, error, refetch } = useFetch('/api/users');
  
  if (loading) return <div>Loading users...</div>;
  if (error) return (
    <div>
      Error: {error.message}
      <button onClick={refetch}>Retry</button>
    </div>
  );
  
  return (
    <div>
      <h2>Users</h2>
      {data.map(user => (
        <div key={user.id}>{user.name}</div>
      ))}
      <button onClick={refetch}>Refresh</button>
    </div>
  );
}

// 動的URLでの使用
function UserProfile({ userId }) {
  const { data, loading, error } = useFetch(`/api/users/${userId}`);
  
  if (loading) return <div>Loading profile...</div>;
  if (error) return <div>Error loading profile</div>;
  
  return (
    <div>
      <h2>{data.name}</h2>
      <p>Email: {data.email}</p>
      <p>Role: {data.role}</p>
    </div>
  );
}

// 検索機能での使用
function ProductSearch() {
  const [searchTerm, setSearchTerm] = useState('');
  const [query, setQuery] = useState('');
  
  const { data, loading, error } = useFetch(
    query ? `/api/products/search?q=${query}` : null
  );
  
  const handleSearch = (e) => {
    e.preventDefault();
    setQuery(searchTerm);
  };
  
  return (
    <div>
      <form onSubmit={handleSearch}>
        <input
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          placeholder="Search products..."
        />
        <button type="submit">Search</button>
      </form>
      
      {loading && <div>Searching...</div>}
      {error && <div>Search failed</div>}
      {data && (
        <div>
          {data.results.map(product => (
            <div key={product.id}>
              {product.name} - ${product.price}
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

// カスタムオプションでの使用
function AuthorizedData() {
  const token = localStorage.getItem('authToken');
  
  const { data, loading, error, refetch } = useFetch('/api/protected-data', {
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    }
  });
  
  if (loading) return <div>Loading protected data...</div>;
  if (error) {
    if (error.status === 401) {
      return <div>Unauthorized. Please login.</div>;
    }
    return <div>Error: {error.message}</div>;
  }
  
  return (
    <div>
      <h2>Protected Data</h2>
      <pre>{JSON.stringify(data, null, 2)}</pre>
    </div>
  );
}

// POSTリクエストでの使用
function CreatePost() {
  const [title, setTitle] = useState('');
  const [content, setContent] = useState('');
  const [submitUrl, setSubmitUrl] = useState(null);
  
  const { data, loading, error } = useFetch(submitUrl, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ title, content })
  });
  
  const handleSubmit = (e) => {
    e.preventDefault();
    setSubmitUrl('/api/posts');
  };
  
  if (data) {
    return <div>Post created successfully! ID: {data.id}</div>;
  }
  
  return (
    <form onSubmit={handleSubmit}>
      <input
        value={title}
        onChange={(e) => setTitle(e.target.value)}
        placeholder="Title"
      />
      <textarea
        value={content}
        onChange={(e) => setContent(e.target.value)}
        placeholder="Content"
      />
      <button type="submit" disabled={loading}>
        {loading ? 'Creating...' : 'Create Post'}
      </button>
      {error && <div>Error: {error.message}</div>}
    </form>
  );
}

// ページネーションでの使用
function PaginatedList() {
  const [page, setPage] = useState(1);
  const { data, loading, error } = useFetch(`/api/items?page=${page}&limit=10`);
  
  return (
    <div>
      {loading && <div>Loading page {page}...</div>}
      {error && <div>Error loading data</div>}
      {data && (
        <>
          {data.items.map(item => (
            <div key={item.id}>{item.name}</div>
          ))}
          <div>
            <button 
              onClick={() => setPage(p => Math.max(1, p - 1))}
              disabled={page === 1}
            >
              Previous
            </button>
            <span>Page {page}</span>
            <button 
              onClick={() => setPage(p => p + 1)}
              disabled={!data.hasMore}
            >
              Next
            </button>
          </div>
        </>
      )}
    </div>
  );
}