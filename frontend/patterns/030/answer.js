import React, { useState, useEffect, useCallback, useMemo } from 'react';

// Pagination component
function Pagination({
  currentPage,
  totalItems,
  pageSize = 10,
  onPageChange,
  onPageSizeChange,
  pageSizeOptions = [10, 20, 50, 100],
  showPageSizeSelector = false,
  showQuickJumper = false,
  showTotal,
  compact = false,
  hideOnSinglePage = false,
  siblingCount = 1,
  boundaryCount = 1,
  disabled = false,
  className = '',
  previousText = '‹',
  nextText = '›',
  firstText = '«',
  lastText = '»',
  ariaLabel = 'Pagination Navigation',
  getItemAriaLabel,
  responsive,
  syncWithURL = false
}) {
  const [jumpValue, setJumpValue] = useState('');
  
  // Calculate total pages
  const totalPages = Math.ceil(totalItems / pageSize);
  
  // Hide if only one page and hideOnSinglePage is true
  if (hideOnSinglePage && totalPages <= 1) {
    return null;
  }
  
  // Get responsive sibling count
  const getSiblingCount = () => {
    if (!responsive) return siblingCount;
    
    if (window.innerWidth < 768 && responsive.mobile) {
      return responsive.mobile.siblingCount ?? 0;
    } else if (window.innerWidth < 1024 && responsive.tablet) {
      return responsive.tablet.siblingCount ?? 1;
    } else if (responsive.desktop) {
      return responsive.desktop.siblingCount ?? 2;
    }
    
    return siblingCount;
  };
  
  const [responsiveSiblingCount, setResponsiveSiblingCount] = useState(getSiblingCount());
  
  // Update sibling count on resize
  useEffect(() => {
    if (!responsive) return;
    
    const handleResize = () => {
      setResponsiveSiblingCount(getSiblingCount());
    };
    
    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, [responsive]);
  
  // Generate page numbers with ellipsis
  const pages = useMemo(() => {
    const pageNumbers = [];
    const leftSiblingIndex = Math.max(currentPage - responsiveSiblingCount, 1);
    const rightSiblingIndex = Math.min(currentPage + responsiveSiblingCount, totalPages);
    
    // Add first pages
    for (let i = 1; i <= Math.min(boundaryCount, totalPages); i++) {
      pageNumbers.push(i);
    }
    
    // Add ellipsis if needed
    if (leftSiblingIndex > boundaryCount + 2) {
      pageNumbers.push('start-ellipsis');
    } else if (leftSiblingIndex === boundaryCount + 2) {
      pageNumbers.push(boundaryCount + 1);
    }
    
    // Add sibling pages
    for (let i = leftSiblingIndex; i <= rightSiblingIndex; i++) {
      if (i > boundaryCount && i <= totalPages - boundaryCount) {
        pageNumbers.push(i);
      }
    }
    
    // Add ellipsis if needed
    if (rightSiblingIndex < totalPages - boundaryCount - 1) {
      pageNumbers.push('end-ellipsis');
    } else if (rightSiblingIndex === totalPages - boundaryCount - 1) {
      pageNumbers.push(totalPages - boundaryCount);
    }
    
    // Add last pages
    for (let i = Math.max(totalPages - boundaryCount + 1, 1); i <= totalPages; i++) {
      if (i > rightSiblingIndex) {
        pageNumbers.push(i);
      }
    }
    
    // Remove duplicates
    return [...new Set(pageNumbers)];
  }, [currentPage, totalPages, responsiveSiblingCount, boundaryCount]);
  
  // Handle page change
  const handlePageChange = useCallback((page) => {
    if (page >= 1 && page <= totalPages && page !== currentPage && !disabled) {
      onPageChange(page);
    }
  }, [currentPage, totalPages, onPageChange, disabled]);
  
  // Handle page size change
  const handlePageSizeChange = useCallback((e) => {
    const newSize = Number(e.target.value);
    if (onPageSizeChange) {
      onPageSizeChange(newSize);
      // Reset to first page when page size changes
      if (currentPage !== 1) {
        onPageChange(1);
      }
    }
  }, [onPageSizeChange, onPageChange, currentPage]);
  
  // Handle quick jump
  const handleQuickJump = useCallback((e) => {
    e.preventDefault();
    const page = Number(jumpValue);
    if (page >= 1 && page <= totalPages) {
      handlePageChange(page);
      setJumpValue('');
    }
  }, [jumpValue, totalPages, handlePageChange]);
  
  // Keyboard navigation
  useEffect(() => {
    const handleKeyDown = (e) => {
      if (disabled) return;
      
      // Only handle if pagination is focused
      if (!document.activeElement.closest('.pagination')) return;
      
      switch (e.key) {
        case 'ArrowLeft':
          e.preventDefault();
          handlePageChange(currentPage - 1);
          break;
        case 'ArrowRight':
          e.preventDefault();
          handlePageChange(currentPage + 1);
          break;
        case 'Home':
          e.preventDefault();
          handlePageChange(1);
          break;
        case 'End':
          e.preventDefault();
          handlePageChange(totalPages);
          break;
      }
    };
    
    document.addEventListener('keydown', handleKeyDown);
    return () => document.removeEventListener('keydown', handleKeyDown);
  }, [currentPage, totalPages, handlePageChange, disabled]);
  
  // Calculate range
  const startItem = (currentPage - 1) * pageSize + 1;
  const endItem = Math.min(currentPage * pageSize, totalItems);
  
  // Get ARIA label for items
  const getAriaLabel = (type, page, selected = false) => {
    if (getItemAriaLabel) {
      return getItemAriaLabel(type, page, selected);
    }
    
    switch (type) {
      case 'first':
        return 'Go to first page';
      case 'previous':
        return 'Go to previous page';
      case 'page':
        return selected ? `Current page, page ${page}` : `Go to page ${page}`;
      case 'next':
        return 'Go to next page';
      case 'last':
        return 'Go to last page';
      default:
        return '';
    }
  };
  
  // Render page button
  const renderPageButton = (page, type = 'page') => {
    const isEllipsis = typeof page === 'string' && page.includes('ellipsis');
    const isSelected = page === currentPage;
    const isDisabled = disabled || 
      (type === 'previous' && currentPage === 1) ||
      (type === 'next' && currentPage === totalPages) ||
      (type === 'first' && currentPage === 1) ||
      (type === 'last' && currentPage === totalPages);
    
    if (isEllipsis) {
      return (
        <span key={page} className="pagination-ellipsis">
          ...
        </span>
      );
    }
    
    return (
      <button
        key={`${type}-${page}`}
        onClick={() => {
          if (type === 'previous') handlePageChange(currentPage - 1);
          else if (type === 'next') handlePageChange(currentPage + 1);
          else if (type === 'first') handlePageChange(1);
          else if (type === 'last') handlePageChange(totalPages);
          else handlePageChange(page);
        }}
        disabled={isDisabled}
        aria-label={getAriaLabel(type, page, isSelected)}
        aria-current={isSelected ? 'page' : undefined}
        className={`pagination-item ${type} ${isSelected ? 'active' : ''} ${isDisabled ? 'disabled' : ''}`}
      >
        {type === 'previous' ? previousText :
         type === 'next' ? nextText :
         type === 'first' ? firstText :
         type === 'last' ? lastText :
         page}
      </button>
    );
  };
  
  return (
    <nav aria-label={ariaLabel} className={`pagination ${compact ? 'compact' : ''} ${className}`}>
      {/* Total information */}
      {showTotal && !compact && (
        <span className="pagination-total">
          {typeof showTotal === 'function' 
            ? showTotal(totalItems, [startItem, endItem])
            : `Total ${totalItems} items`}
        </span>
      )}
      
      {/* Page size selector */}
      {showPageSizeSelector && !compact && (
        <select
          value={pageSize}
          onChange={handlePageSizeChange}
          disabled={disabled}
          aria-label="Items per page"
          className="pagination-size-selector"
        >
          {pageSizeOptions.map(size => (
            <option key={size} value={size}>
              {size} / page
            </option>
          ))}
        </select>
      )}
      
      {/* Pagination controls */}
      <div className="pagination-list" role="list">
        {/* First page button */}
        {!compact && renderPageButton(1, 'first')}
        
        {/* Previous page button */}
        {renderPageButton(currentPage - 1, 'previous')}
        
        {/* Page numbers */}
        {!compact && pages.map(page => renderPageButton(page))}
        
        {/* Compact mode current page */}
        {compact && (
          <span className="pagination-compact-info">
            {currentPage} / {totalPages}
          </span>
        )}
        
        {/* Next page button */}
        {renderPageButton(currentPage + 1, 'next')}
        
        {/* Last page button */}
        {!compact && renderPageButton(totalPages, 'last')}
      </div>
      
      {/* Quick jumper */}
      {showQuickJumper && !compact && (
        <form onSubmit={handleQuickJump} className="pagination-jumper">
          <label>
            Go to
            <input
              type="number"
              min="1"
              max={totalPages}
              value={jumpValue}
              onChange={(e) => setJumpValue(e.target.value)}
              disabled={disabled}
              className="pagination-jumper-input"
            />
          </label>
          <button type="submit" disabled={disabled}>
            Go
          </button>
        </form>
      )}
    </nav>
  );
}

// Default styles (can be overridden with CSS)
const defaultStyles = `
  .pagination {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 8px;
  }
  
  .pagination-list {
    display: flex;
    gap: 4px;
  }
  
  .pagination-item {
    padding: 6px 12px;
    border: 1px solid #ddd;
    background: white;
    cursor: pointer;
    transition: all 0.2s;
  }
  
  .pagination-item:hover:not(.disabled) {
    background: #f5f5f5;
  }
  
  .pagination-item.active {
    background: #1890ff;
    color: white;
    border-color: #1890ff;
  }
  
  .pagination-item.disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }
  
  .pagination-ellipsis {
    padding: 6px;
  }
  
  .pagination.compact .pagination-compact-info {
    padding: 6px 12px;
  }
  
  .pagination-size-selector {
    padding: 6px;
    border: 1px solid #ddd;
  }
  
  .pagination-jumper {
    display: flex;
    align-items: center;
    gap: 4px;
  }
  
  .pagination-jumper-input {
    width: 50px;
    padding: 4px;
    border: 1px solid #ddd;
  }
`;

// Add default styles to document if not already present
if (typeof document !== 'undefined' && !document.getElementById('pagination-default-styles')) {
  const style = document.createElement('style');
  style.id = 'pagination-default-styles';
  style.textContent = defaultStyles;
  document.head.appendChild(style);
}

export default Pagination;