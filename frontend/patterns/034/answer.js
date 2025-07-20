import React, { useState, useMemo } from 'react';

function Pagination({ data, itemsPerPage = 10, renderItem }) {
  const [currentPage, setCurrentPage] = useState(1);

  // 総ページ数を計算
  const totalPages = Math.ceil(data.length / itemsPerPage);

  // 現在のページのデータを取得
  const currentData = useMemo(() => {
    const startIndex = (currentPage - 1) * itemsPerPage;
    const endIndex = startIndex + itemsPerPage;
    return data.slice(startIndex, endIndex);
  }, [data, currentPage, itemsPerPage]);

  // 表示範囲の計算
  const startIndex = (currentPage - 1) * itemsPerPage + 1;
  const endIndex = Math.min(startIndex + itemsPerPage - 1, data.length);

  // ページ番号の配列を生成
  const getPageNumbers = () => {
    const delta = 2; // 現在のページの前後に表示するページ数
    const range = [];
    const rangeWithDots = [];
    let l;

    for (let i = 1; i <= totalPages; i++) {
      if (i === 1 || i === totalPages || 
          (i >= currentPage - delta && i <= currentPage + delta)) {
        range.push(i);
      }
    }

    range.forEach((i) => {
      if (l) {
        if (i - l === 2) {
          rangeWithDots.push(l + 1);
        } else if (i - l !== 1) {
          rangeWithDots.push('...');
        }
      }
      rangeWithDots.push(i);
      l = i;
    });

    return rangeWithDots;
  };

  const handlePageChange = (page) => {
    if (page >= 1 && page <= totalPages && page !== currentPage) {
      setCurrentPage(page);
    }
  };

  // ページネーションボタンのスタイル
  const buttonStyle = {
    padding: '5px 10px',
    margin: '0 2px',
    border: '1px solid #ddd',
    background: '#fff',
    cursor: 'pointer',
    borderRadius: '4px'
  };

  const activeButtonStyle = {
    ...buttonStyle,
    background: '#007bff',
    color: '#fff',
    border: '1px solid #007bff'
  };

  const disabledButtonStyle = {
    ...buttonStyle,
    cursor: 'not-allowed',
    opacity: 0.5
  };

  return (
    <div>
      {/* 表示範囲情報 */}
      <div style={{ marginBottom: '10px', color: '#666' }}>
        Showing {startIndex}-{endIndex} of {data.length}
      </div>

      {/* データ表示エリア */}
      <div style={{ marginBottom: '20px' }}>
        {currentData.map(renderItem)}
      </div>

      {/* ページネーションコントロール */}
      <div style={{ display: 'flex', alignItems: 'center', gap: '5px' }}>
        {/* First ボタン */}
        <button
          onClick={() => handlePageChange(1)}
          disabled={currentPage === 1}
          style={currentPage === 1 ? disabledButtonStyle : buttonStyle}
        >
          First
        </button>

        {/* Previous ボタン */}
        <button
          onClick={() => handlePageChange(currentPage - 1)}
          disabled={currentPage === 1}
          style={currentPage === 1 ? disabledButtonStyle : buttonStyle}
        >
          Previous
        </button>

        {/* ページ番号 */}
        {getPageNumbers().map((number, index) => (
          number === '...' ? (
            <span key={`dots-${index}`} style={{ padding: '0 5px' }}>
              ...
            </span>
          ) : (
            <button
              key={number}
              onClick={() => handlePageChange(number)}
              style={currentPage === number ? activeButtonStyle : buttonStyle}
            >
              {number}
            </button>
          )
        ))}

        {/* Next ボタン */}
        <button
          onClick={() => handlePageChange(currentPage + 1)}
          disabled={currentPage === totalPages}
          style={currentPage === totalPages ? disabledButtonStyle : buttonStyle}
        >
          Next
        </button>

        {/* Last ボタン */}
        <button
          onClick={() => handlePageChange(totalPages)}
          disabled={currentPage === totalPages}
          style={currentPage === totalPages ? disabledButtonStyle : buttonStyle}
        >
          Last
        </button>
      </div>
    </div>
  );
}

// カスタムフックバージョン（再利用可能）
function usePagination(data, itemsPerPage = 10) {
  const [currentPage, setCurrentPage] = useState(1);
  
  const totalPages = Math.ceil(data.length / itemsPerPage);
  
  const paginatedData = useMemo(() => {
    const startIndex = (currentPage - 1) * itemsPerPage;
    const endIndex = startIndex + itemsPerPage;
    return data.slice(startIndex, endIndex);
  }, [data, currentPage, itemsPerPage]);

  const goToPage = (page) => {
    const pageNumber = Math.max(1, Math.min(page, totalPages));
    setCurrentPage(pageNumber);
  };

  return {
    currentPage,
    totalPages,
    paginatedData,
    goToPage,
    nextPage: () => goToPage(currentPage + 1),
    prevPage: () => goToPage(currentPage - 1),
    firstPage: () => goToPage(1),
    lastPage: () => goToPage(totalPages)
  };
}

export default Pagination;