import React, { Suspense, Component } from 'react';
import { Routes, Route } from 'react-router-dom';

// 各ページコンポーネントを遅延ロード
const HomePage = React.lazy(() => import('./pages/HomePage'));
const ProductList = React.lazy(() => import('./pages/ProductList'));
const ProductDetail = React.lazy(() => import('./pages/ProductDetail'));
const ShoppingCart = React.lazy(() => import('./pages/ShoppingCart'));

// エラーバウンダリコンポーネント
class ErrorBoundary extends Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError(error) {
    return { hasError: true };
  }

  componentDidCatch(error, errorInfo) {
    console.error('Error loading page:', error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return <div>Error loading page</div>;
    }

    return this.props.children;
  }
}

// ローディングコンポーネント
function LoadingFallback() {
  return <div>Loading...</div>;
}

// メインのAppコンポーネント
function App() {
  return (
    <ErrorBoundary>
      <Suspense fallback={<LoadingFallback />}>
        <Routes>
          <Route path="/" element={<HomePage />} />
          <Route path="/products" element={<ProductList />} />
          <Route path="/products/:id" element={<ProductDetail />} />
          <Route path="/cart" element={<ShoppingCart />} />
        </Routes>
      </Suspense>
    </ErrorBoundary>
  );
}

export default App;