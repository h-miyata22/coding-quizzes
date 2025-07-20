// 使用例
import React, { useEffect, useState } from 'react';

// 基本的な使用方法
function UserProfile({ userId }) {
  const [user, setUser] = useState(null);
  
  useEffect(() => {
    // Simulate API call
    setTimeout(() => {
      setUser({ id: userId, name: 'John Doe', email: 'john@example.com' });
    }, 1000);
  }, [userId]);
  
  return (
    <div>
      <h2>{user.name}</h2>
      <p>{user.email}</p>
    </div>
  );
}

// withLoadingでラップ
const UserProfileWithLoading = withLoading(UserProfile);

function App() {
  return (
    <UserProfileWithLoading 
      userId={1} 
      isLoading={false} // This should be managed by HOC
    />
  );
}

// カスタムローディングコンポーネント
const CustomSpinner = () => (
  <div className="custom-spinner">
    <div className="spinner"></div>
    <p>Loading user data...</p>
  </div>
);

const UserListWithCustomLoading = withLoading(UserList, {
  LoadingComponent: CustomSpinner
});

// エラーハンドリング付き
function ProductList({ products, error }) {
  return (
    <div>
      {products.map(product => (
        <div key={product.id}>
          <h3>{product.name}</h3>
          <p>${product.price}</p>
        </div>
      ))}
    </div>
  );
}

const ProductListWithLoading = withLoading(ProductList, {
  errorMessage: 'Failed to load products'
});

// 複数のローディング状態
function Dashboard({ stats, recentActivity }) {
  return (
    <div>
      <section>
        <h2>Statistics</h2>
        <div>{stats.totalUsers} users</div>
        <div>{stats.totalRevenue} revenue</div>
      </section>
      
      <section>
        <h2>Recent Activity</h2>
        {recentActivity.map(activity => (
          <div key={activity.id}>{activity.description}</div>
        ))}
      </section>
    </div>
  );
}

const DashboardWithLoading = withLoading(Dashboard, {
  loadingProps: ['stats', 'recentActivity']
});

// 条件付きローディング
function SearchResults({ results, query }) {
  return (
    <div>
      <h2>Results for "{query}"</h2>
      {results.length === 0 ? (
        <p>No results found</p>
      ) : (
        results.map(result => (
          <div key={result.id}>
            <h3>{result.title}</h3>
            <p>{result.description}</p>
          </div>
        ))
      )}
    </div>
  );
}

const SearchResultsWithLoading = withLoading(SearchResults, {
  showLoadingIf: (props) => props.isSearching
});

// Skeletonローディング
const SkeletonLoader = () => (
  <div className="skeleton-loader">
    <div className="skeleton-header"></div>
    <div className="skeleton-line"></div>
    <div className="skeleton-line"></div>
    <div className="skeleton-line short"></div>
  </div>
);

const ArticleWithSkeleton = withLoading(Article, {
  LoadingComponent: SkeletonLoader,
  delay: 200 // Show loading only after 200ms
});

// 非同期データフェッチング統合
function Comments({ postId }) {
  const [comments, setComments] = useState([]);
  
  return (
    <div>
      {comments.map(comment => (
        <div key={comment.id}>
          <strong>{comment.author}</strong>
          <p>{comment.text}</p>
        </div>
      ))}
    </div>
  );
}

const CommentsWithLoading = withLoading(Comments, {
  fetchData: async (props) => {
    const response = await fetch(`/api/posts/${props.postId}/comments`);
    return response.json();
  },
  mapDataToProps: (data) => ({ comments: data })
});

// TypeScript使用例
interface UserData {
  id: number;
  name: string;
  email: string;
}

interface UserCardProps {
  user: UserData;
}

const UserCard: React.FC<UserCardProps> = ({ user }) => (
  <div className="user-card">
    <h3>{user.name}</h3>
    <p>{user.email}</p>
  </div>
);

const UserCardWithLoading = withLoading<UserCardProps>(UserCard);