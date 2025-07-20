// 使用例
import React, { useState } from 'react';

// エラーが発生する可能性のあるコンポーネント
function UserProfile({ userId }) {
  const [user, setUser] = useState(null);
  
  // This might throw an error
  if (!userId) {
    throw new Error('User ID is required');
  }
  
  // Simulate potential runtime error
  if (userId === 'invalid') {
    throw new Error('Invalid user ID format');
  }
  
  return (
    <div>
      <h2>User Profile</h2>
      <p>User ID: {userId}</p>
      {user && <p>Name: {user.name}</p>}
    </div>
  );
}

// withErrorBoundaryでラップ
const SafeUserProfile = withErrorBoundary(UserProfile);

function App() {
  return (
    <div>
      <h1>My App</h1>
      <SafeUserProfile userId="123" />
    </div>
  );
}

// カスタムエラーコンポーネント
const CustomErrorFallback = ({ error, resetError, errorInfo }) => (
  <div className="error-fallback">
    <h2>Oops! Something went wrong</h2>
    <details style={{ whiteSpace: 'pre-wrap' }}>
      <summary>Error details</summary>
      {error.toString()}
      <br />
      {errorInfo?.componentStack}
    </details>
    <button onClick={resetError}>Try again</button>
  </div>
);

const ProfileWithCustomError = withErrorBoundary(UserProfile, {
  FallbackComponent: CustomErrorFallback
});

// エラーロギング付き
const ProductList = ({ products }) => {
  if (!products) {
    throw new Error('Products data is required');
  }
  
  return (
    <div>
      {products.map(product => (
        <div key={product.id}>
          <h3>{product.name}</h3>
          <p>${product.price.toFixed(2)}</p>
        </div>
      ))}
    </div>
  );
};

const SafeProductList = withErrorBoundary(ProductList, {
  onError: (error, errorInfo) => {
    console.error('Product list error:', error);
    // Send to error tracking service
    errorTracker.report(error, errorInfo);
  }
});

// 環境別エラー表示
const DangerousComponent = () => {
  const random = Math.random();
  if (random < 0.5) {
    throw new Error('Random error occurred!');
  }
  
  return <div>Component rendered successfully!</div>;
};

const SafeDangerousComponent = withErrorBoundary(DangerousComponent, {
  showDetails: process.env.NODE_ENV === 'development'
});

// リトライ機能付き
function DataFetcher({ apiEndpoint }) {
  const [data, setData] = useState(null);
  const [attempts, setAttempts] = useState(0);
  
  React.useEffect(() => {
    fetch(apiEndpoint)
      .then(res => {
        if (!res.ok) throw new Error('Failed to fetch');
        return res.json();
      })
      .then(setData)
      .catch(err => {
        throw err; // This will be caught by error boundary
      });
  }, [apiEndpoint, attempts]);
  
  if (!data) return <div>Loading...</div>;
  
  return <div>{JSON.stringify(data)}</div>;
}

const SafeDataFetcher = withErrorBoundary(DataFetcher, {
  onReset: () => {
    // Clear cache or reset state before retry
    console.log('Resetting component state...');
  }
});

// ネストされたエラーバウンダリー
function ComplexApp() {
  return (
    <div>
      <Header />
      <main>
        <SafeSection1 />
        <SafeSection2 />
        <SafeSection3 />
      </main>
      <Footer />
    </div>
  );
}

const SafeSection1 = withErrorBoundary(Section1, {
  FallbackComponent: () => <div>Section 1 is temporarily unavailable</div>
});

// 非同期エラーハンドリング
function AsyncComponent() {
  const [error, setError] = useState(null);
  
  React.useEffect(() => {
    someAsyncOperation()
      .catch(err => {
        // Async errors need to be handled differently
        setError(err);
      });
  }, []);
  
  if (error) {
    throw error; // Re-throw to be caught by boundary
  }
  
  return <div>Async component content</div>;
}

const SafeAsyncComponent = withErrorBoundary(AsyncComponent);

// グローバルエラーハンドラー統合
const AppWithGlobalErrorBoundary = withErrorBoundary(App, {
  onError: (error, errorInfo) => {
    // Log to console
    console.error('Global error:', error);
    
    // Send to monitoring service
    if (window.Sentry) {
      window.Sentry.captureException(error, {
        contexts: { react: errorInfo }
      });
    }
    
    // Show user notification
    showErrorNotification('An unexpected error occurred');
  }
});