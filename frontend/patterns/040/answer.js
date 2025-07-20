import React, { useState, useCallback, useRef, useEffect } from 'react';

// 最適化されたSearchFiltersコンポーネント
function SearchFilters({ onSearch, categories }) {
  const [filters, setFilters] = useState({
    query: '',
    category: '',
    minPrice: '',
    maxPrice: '',
    inStock: false
  });

  // デバウンス用のタイマーref
  const debounceTimerRef = useRef(null);

  // デバウンス処理を含む検索実行
  const debouncedSearch = useCallback((newFilters) => {
    if (debounceTimerRef.current) {
      clearTimeout(debounceTimerRef.current);
    }
    
    debounceTimerRef.current = setTimeout(() => {
      onSearch(newFilters);
    }, 300); // 300ms のデバウンス
  }, [onSearch]);

  // クエリ変更ハンドラー（デバウンス付き）
  const handleQueryChange = useCallback((e) => {
    const newQuery = e.target.value;
    setFilters(prev => {
      const newFilters = { ...prev, query: newQuery };
      debouncedSearch(newFilters);
      return newFilters;
    });
  }, [debouncedSearch]);

  // カテゴリ変更ハンドラー（即座に実行）
  const handleCategoryChange = useCallback((e) => {
    const newCategory = e.target.value;
    setFilters(prev => {
      const newFilters = { ...prev, category: newCategory };
      onSearch(newFilters); // カテゴリは即座に検索
      return newFilters;
    });
  }, [onSearch]);

  // 価格変更ハンドラー（デバウンス付き）
  const handlePriceChange = useCallback((field) => (e) => {
    const newPrice = e.target.value;
    setFilters(prev => {
      const newFilters = { ...prev, [field]: newPrice };
      debouncedSearch(newFilters);
      return newFilters;
    });
  }, [debouncedSearch]);

  // 在庫状態変更ハンドラー（即座に実行）
  const handleStockChange = useCallback((e) => {
    const inStock = e.target.checked;
    setFilters(prev => {
      const newFilters = { ...prev, inStock };
      onSearch(newFilters); // チェックボックスは即座に検索
      return newFilters;
    });
  }, [onSearch]);

  // クリーンアップ
  useEffect(() => {
    return () => {
      if (debounceTimerRef.current) {
        clearTimeout(debounceTimerRef.current);
      }
    };
  }, []);

  return (
    <div style={{ 
      padding: '20px', 
      background: '#f5f5f5',
      borderRadius: '8px'
    }}>
      <h2>Search Filters</h2>
      
      <div style={{ marginBottom: '15px' }}>
        <input
          type="text"
          placeholder="Search products..."
          value={filters.query}
          onChange={handleQueryChange}
          style={{ 
            width: '100%', 
            padding: '8px',
            fontSize: '16px'
          }}
        />
      </div>

      <div style={{ 
        display: 'grid', 
        gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))',
        gap: '15px'
      }}>
        <div>
          <label style={{ display: 'block', marginBottom: '5px' }}>
            Category
          </label>
          <select 
            value={filters.category}
            onChange={handleCategoryChange}
            style={{ width: '100%', padding: '8px' }}
          >
            <option value="">All Categories</option>
            {categories.map(cat => (
              <option key={cat} value={cat}>{cat}</option>
            ))}
          </select>
        </div>

        <div>
          <label style={{ display: 'block', marginBottom: '5px' }}>
            Min Price
          </label>
          <input
            type="number"
            placeholder="0"
            value={filters.minPrice}
            onChange={handlePriceChange('minPrice')}
            style={{ width: '100%', padding: '8px' }}
          />
        </div>

        <div>
          <label style={{ display: 'block', marginBottom: '5px' }}>
            Max Price
          </label>
          <input
            type="number"
            placeholder="999999"
            value={filters.maxPrice}
            onChange={handlePriceChange('maxPrice')}
            style={{ width: '100%', padding: '8px' }}
          />
        </div>

        <div style={{ display: 'flex', alignItems: 'center' }}>
          <label>
            <input
              type="checkbox"
              checked={filters.inStock}
              onChange={handleStockChange}
              style={{ marginRight: '8px' }}
            />
            In Stock Only
          </label>
        </div>
      </div>
    </div>
  );
}

// 高度な実装（カスタムフックを使用）
function useDebounce(callback, delay) {
  const timeoutRef = useRef(null);
  
  const debouncedCallback = useCallback((...args) => {
    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current);
    }
    
    timeoutRef.current = setTimeout(() => {
      callback(...args);
    }, delay);
  }, [callback, delay]);

  useEffect(() => {
    return () => {
      if (timeoutRef.current) {
        clearTimeout(timeoutRef.current);
      }
    };
  }, []);

  return debouncedCallback;
}

// カスタムフックを使用した実装
function OptimizedSearchFilters({ onSearch, categories }) {
  const [filters, setFilters] = useState({
    query: '',
    category: '',
    minPrice: '',
    maxPrice: '',
    inStock: false
  });

  const renderCount = useRef(0);
  renderCount.current += 1;

  // デバウンスされた検索関数
  const debouncedSearch = useDebounce(onSearch, 300);

  // 各ハンドラーをuseCallbackで最適化
  const updateFilter = useCallback((field, value, immediate = false) => {
    setFilters(prev => {
      const newFilters = { ...prev, [field]: value };
      
      if (immediate) {
        onSearch(newFilters);
      } else {
        debouncedSearch(newFilters);
      }
      
      return newFilters;
    });
  }, [onSearch, debouncedSearch]);

  const handleQueryChange = useCallback((e) => {
    updateFilter('query', e.target.value, false);
  }, [updateFilter]);

  const handleCategoryChange = useCallback((e) => {
    updateFilter('category', e.target.value, true);
  }, [updateFilter]);

  const handlePriceChange = useCallback((field) => (e) => {
    updateFilter(field, e.target.value, false);
  }, [updateFilter]);

  const handleStockChange = useCallback((e) => {
    updateFilter('inStock', e.target.checked, true);
  }, [updateFilter]);

  return (
    <div style={{ 
      padding: '20px', 
      background: '#f5f5f5',
      borderRadius: '8px',
      position: 'relative'
    }}>
      <div style={{
        position: 'absolute',
        top: '5px',
        right: '10px',
        fontSize: '12px',
        color: '#666'
      }}>
        Renders: {renderCount.current}
      </div>
      
      {/* 同じUIコンポーネント */}
      <h2>Optimized Search Filters</h2>
      
      <div style={{ marginBottom: '15px' }}>
        <input
          type="text"
          placeholder="Search products..."
          value={filters.query}
          onChange={handleQueryChange}
          style={{ 
            width: '100%', 
            padding: '8px',
            fontSize: '16px'
          }}
        />
      </div>

      {/* 残りのフィルターUI... */}
    </div>
  );
}

export default SearchFilters;