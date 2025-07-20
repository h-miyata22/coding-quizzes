// 使用例
import React from 'react';
import { BrowserRouter, Routes, Route, Link } from 'react-router-dom';

// App コンポーネントを実装してください
// 以下の要件を満たす必要があります：
// - HomePage, ProductList, ProductDetail, ShoppingCart を遅延ロード
// - 各ページコンポーネントは別ファイルからインポートされる想定
// - Suspense でローディング表示を管理
// - Error Boundary でエラーをハンドリング

function App() {
  // 実装してください
}

// 期待される使用方法
function Main() {
  return (
    <BrowserRouter>
      <nav>
        <Link to="/">Home</Link>
        <Link to="/products">Products</Link>
        <Link to="/products/123">Product Detail</Link>
        <Link to="/cart">Cart</Link>
      </nav>
      <App />
    </BrowserRouter>
  );
}

export default Main;