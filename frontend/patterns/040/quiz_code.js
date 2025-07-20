// 使用例
import React, { useState } from 'react';

// SearchFilters コンポーネントを useCallback で最適化してください
// 以下の要件を満たす必要があります：
// - 関数の不要な再生成を防ぐ
// - 適切な依存配列の設定
// - デバウンス処理の実装

function SearchFilters({ onSearch, categories }) {
  const [filters, setFilters] = useState({
    query: '',
    category: '',
    minPrice: '',
    maxPrice: '',
    inStock: false
  });

  // これらの関数を useCallback で最適化してください
  const handleQueryChange = (e) => {
    const newQuery = e.target.value;
    setFilters(prev => ({ ...prev, query: newQuery }));
    // デバウンス処理も追加してください
    onSearch({ ...filters, query: newQuery });
  };

  const handleCategoryChange = (e) => {
    const newCategory = e.target.value;
    setFilters(prev => ({ ...prev, category: newCategory }));
    onSearch({ ...filters, category: newCategory });
  };

  const handlePriceChange = (field) => (e) => {
    const newPrice = e.target.value;
    setFilters(prev => ({ ...prev, [field]: newPrice }));
    onSearch({ ...filters, [field]: newPrice });
  };

  const handleStockChange = (e) => {
    const inStock = e.target.checked;
    setFilters(prev => ({ ...prev, inStock }));
    onSearch({ ...filters, inStock });
  };

  // 実装してください
}

// 期待される使用方法
function ProductSearch() {
  const [searchResults, setSearchResults] = useState([]);
  const [isSearching, setIsSearching] = useState(false);

  const categories = ['Electronics', 'Clothing', 'Books', 'Home', 'Sports'];

  const performSearch = async (filters) => {
    setIsSearching(true);
    // API呼び出しのシミュレーション
    setTimeout(() => {
      console.log('Searching with filters:', filters);
      setSearchResults([
        { id: 1, name: 'Product 1', price: 100 },
        { id: 2, name: 'Product 2', price: 200 },
        // ... more results
      ]);
      setIsSearching(false);
    }, 500);
  };

  return (
    <div style={{ maxWidth: '800px', margin: '0 auto', padding: '20px' }}>
      <h1>Product Search</h1>
      
      <SearchFilters 
        onSearch={performSearch}
        categories={categories}
      />

      <div style={{ marginTop: '30px' }}>
        {isSearching ? (
          <p>Searching...</p>
        ) : (
          <div>
            <h3>Results ({searchResults.length})</h3>
            {searchResults.map(product => (
              <div key={product.id} style={{ 
                padding: '10px', 
                border: '1px solid #eee',
                marginBottom: '10px'
              }}>
                {product.name} - ${product.price}
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

export default ProductSearch;