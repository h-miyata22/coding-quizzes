// 使用例
import React, { useState, useEffect } from 'react';

// 基本的な使用方法
function ProductList() {
  const [currentPage, setCurrentPage] = useState(1);
  const [pageSize, setPageSize] = useState(10);
  const totalItems = 250;
  
  return (
    <div>
      <div className="product-grid">
        {/* Products display */}
      </div>
      
      <Pagination
        currentPage={currentPage}
        totalItems={totalItems}
        pageSize={pageSize}
        onPageChange={setCurrentPage}
        onPageSizeChange={setPageSize}
      />
    </div>
  );
}

// 高度な設定
function UserTable() {
  const [pagination, setPagination] = useState({
    page: 1,
    size: 20,
    total: 1000
  });
  
  const handlePageChange = (page) => {
    setPagination(prev => ({ ...prev, page }));
    // Fetch new data
  };
  
  return (
    <>
      <table>
        {/* Table content */}
      </table>
      
      <Pagination
        currentPage={pagination.page}
        totalItems={pagination.total}
        pageSize={pagination.size}
        onPageChange={handlePageChange}
        showPageSizeSelector
        pageSizeOptions={[10, 20, 50, 100]}
        showQuickJumper
        showTotal={(total, range) => `${range[0]}-${range[1]} of ${total} items`}
      />
    </>
  );
}

// コンパクトモード
function CommentSection() {
  const [page, setPage] = useState(1);
  const commentsPerPage = 5;
  const totalComments = 47;
  
  return (
    <div className="comments">
      {/* Comments */}
      
      <Pagination
        currentPage={page}
        totalItems={totalComments}
        pageSize={commentsPerPage}
        onPageChange={setPage}
        compact
      />
    </div>
  );
}

// URLパラメータ同期
function SearchResults() {
  const [searchParams, setSearchParams] = useSearchParams();
  const page = Number(searchParams.get('page')) || 1;
  const size = Number(searchParams.get('size')) || 10;
  
  const updateURL = (newPage, newSize) => {
    setSearchParams({
      page: newPage,
      size: newSize,
      q: searchParams.get('q') // preserve other params
    });
  };
  
  return (
    <div>
      <div className="search-results">
        {/* Results */}
      </div>
      
      <Pagination
        currentPage={page}
        totalItems={500}
        pageSize={size}
        onPageChange={(p) => updateURL(p, size)}
        onPageSizeChange={(s) => updateURL(1, s)}
        syncWithURL
      />
    </div>
  );
}

// カスタムスタイル
function StyledPagination() {
  const [page, setPage] = useState(1);
  
  return (
    <Pagination
      currentPage={page}
      totalItems={200}
      pageSize={15}
      onPageChange={setPage}
      className="custom-pagination"
      previousText="← Previous"
      nextText="Next →"
      firstText="⇤ First"
      lastText="Last ⇥"
    />
  );
}

// 無限スクロールとの組み合わせ
function HybridList() {
  const [page, setPage] = useState(1);
  const [hasMore, setHasMore] = useState(true);
  
  const loadMore = () => {
    if (page < 10) {
      setPage(page + 1);
    } else {
      setHasMore(false);
    }
  };
  
  return (
    <div>
      <InfiniteScroll
        loadMore={loadMore}
        hasMore={hasMore}
      >
        {/* Items */}
      </InfiniteScroll>
      
      <Pagination
        currentPage={page}
        totalItems={100}
        pageSize={10}
        onPageChange={setPage}
        hideOnSinglePage
      />
    </div>
  );
}

// レスポンシブ対応
function ResponsivePagination() {
  const [page, setPage] = useState(1);
  
  return (
    <Pagination
      currentPage={page}
      totalItems={300}
      pageSize={12}
      onPageChange={setPage}
      responsive={{
        mobile: { siblingCount: 0 },
        tablet: { siblingCount: 1 },
        desktop: { siblingCount: 2 }
      }}
    />
  );
}

// アクセシビリティ重視
function AccessibleTable() {
  const [page, setPage] = useState(1);
  const pageSize = 25;
  const total = 150;
  
  return (
    <div role="region" aria-label="Data table with pagination">
      <table>
        <caption>
          User Data (Page {page} of {Math.ceil(total / pageSize)})
        </caption>
        {/* Table content */}
      </table>
      
      <Pagination
        currentPage={page}
        totalItems={total}
        pageSize={pageSize}
        onPageChange={setPage}
        ariaLabel="Table pagination"
        getItemAriaLabel={(type, page, selected) => {
          if (type === 'page') {
            return `${selected ? 'Current page, ' : ''}Go to page ${page}`;
          }
          return `Go to ${type} page`;
        }}
      />
    </div>
  );
}

// サーバーサイドページネーション
function ServerPaginatedList() {
  const [data, setData] = useState({ items: [], total: 0 });
  const [loading, setLoading] = useState(false);
  const [pagination, setPagination] = useState({ page: 1, size: 20 });
  
  useEffect(() => {
    const fetchData = async () => {
      setLoading(true);
      const response = await fetch(
        `/api/items?page=${pagination.page}&size=${pagination.size}`
      );
      const result = await response.json();
      setData(result);
      setLoading(false);
    };
    
    fetchData();
  }, [pagination]);
  
  return (
    <div>
      {loading ? (
        <div>Loading...</div>
      ) : (
        <div>{/* Display items */}</div>
      )}
      
      <Pagination
        currentPage={pagination.page}
        totalItems={data.total}
        pageSize={pagination.size}
        onPageChange={(page) => setPagination(prev => ({ ...prev, page }))}
        onPageSizeChange={(size) => setPagination({ page: 1, size })}
        disabled={loading}
      />
    </div>
  );
}