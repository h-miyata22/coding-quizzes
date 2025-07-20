import React, { useState, useCallback } from 'react';

function LoadMoreList({
  items,
  initialCount = 10,
  loadMoreCount = 10,
  renderItem,
  loadDelay = 1000
}) {
  const [displayCount, setDisplayCount] = useState(initialCount);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState(null);

  // 表示するアイテム
  const displayedItems = items.slice(0, displayCount);
  
  // まだ表示していないアイテムがあるか
  const hasMore = displayCount < items.length;

  // 「もっと見る」の処理
  const handleLoadMore = useCallback(async () => {
    setIsLoading(true);
    setError(null);

    try {
      // 実際のアプリではここでAPIを呼ぶ
      // ここではシミュレーションのため遅延を入れる
      await new Promise((resolve, reject) => {
        setTimeout(() => {
          // ランダムにエラーを発生させる（デモ用）
          if (Math.random() > 0.8) {
            reject(new Error('Failed to load more items'));
          } else {
            resolve();
          }
        }, loadDelay);
      });

      // 成功時は表示件数を増やす
      setDisplayCount(prev => Math.min(prev + loadMoreCount, items.length));
    } catch (err) {
      setError(err.message);
    } finally {
      setIsLoading(false);
    }
  }, [displayCount, items.length, loadMoreCount, loadDelay]);

  // エラー時の再試行
  const handleRetry = () => {
    setError(null);
    handleLoadMore();
  };

  return (
    <div>
      {/* アイテムリスト */}
      <div style={{ marginBottom: '20px' }}>
        {displayedItems.map((item, index) => (
          <div
            key={item.id || index}
            style={{
              animation: index >= displayCount - loadMoreCount 
                ? 'fadeIn 0.3s ease-in' 
                : 'none'
            }}
          >
            {renderItem(item)}
          </div>
        ))}
      </div>

      {/* ローディング表示 */}
      {isLoading && (
        <div style={{ 
          textAlign: 'center', 
          padding: '20px',
          color: '#666' 
        }}>
          読み込み中...
        </div>
      )}

      {/* エラー表示 */}
      {error && !isLoading && (
        <div style={{ 
          textAlign: 'center', 
          padding: '20px',
          color: '#d32f2f' 
        }}>
          <p>{error}</p>
          <button
            onClick={handleRetry}
            style={{
              padding: '8px 16px',
              background: '#d32f2f',
              color: 'white',
              border: 'none',
              borderRadius: '4px',
              cursor: 'pointer'
            }}
          >
            再試行
          </button>
        </div>
      )}

      {/* もっと見るボタン */}
      {hasMore && !isLoading && !error && (
        <div style={{ textAlign: 'center', padding: '20px' }}>
          <button
            onClick={handleLoadMore}
            style={{
              padding: '10px 30px',
              fontSize: '16px',
              background: '#1976d2',
              color: 'white',
              border: 'none',
              borderRadius: '4px',
              cursor: 'pointer',
              transition: 'background 0.3s'
            }}
            onMouseEnter={(e) => e.target.style.background = '#1565c0'}
            onMouseLeave={(e) => e.target.style.background = '#1976d2'}
          >
            もっと見る
          </button>
          <div style={{ 
            marginTop: '10px', 
            color: '#666',
            fontSize: '14px' 
          }}>
            {displayCount} / {items.length} 件を表示中
          </div>
        </div>
      )}

      {/* 全件表示済み */}
      {!hasMore && items.length > 0 && (
        <div style={{ 
          textAlign: 'center', 
          padding: '20px',
          color: '#666' 
        }}>
          すべての記事を表示しました
        </div>
      )}

      {/* CSSアニメーション */}
      <style jsx>{`
        @keyframes fadeIn {
          from {
            opacity: 0;
            transform: translateY(10px);
          }
          to {
            opacity: 1;
            transform: translateY(0);
          }
        }
      `}</style>
    </div>
  );
}

// 無限スクロール版（高度な実装）
function InfiniteLoadList({
  items,
  initialCount = 10,
  loadMoreCount = 10,
  renderItem,
  loadDelay = 1000,
  threshold = 100 // スクロール閾値
}) {
  const [displayCount, setDisplayCount] = useState(initialCount);
  const [isLoading, setIsLoading] = useState(false);
  const loadingRef = React.useRef(null);

  const displayedItems = items.slice(0, displayCount);
  const hasMore = displayCount < items.length;

  React.useEffect(() => {
    if (!hasMore || isLoading) return;

    const observer = new IntersectionObserver(
      (entries) => {
        if (entries[0].isIntersecting && !isLoading) {
          loadMore();
        }
      },
      {
        rootMargin: `${threshold}px`
      }
    );

    if (loadingRef.current) {
      observer.observe(loadingRef.current);
    }

    return () => {
      if (loadingRef.current) {
        observer.unobserve(loadingRef.current);
      }
    };
  }, [hasMore, isLoading, displayCount]);

  const loadMore = async () => {
    setIsLoading(true);
    
    await new Promise(resolve => setTimeout(resolve, loadDelay));
    
    setDisplayCount(prev => Math.min(prev + loadMoreCount, items.length));
    setIsLoading(false);
  };

  return (
    <div>
      {displayedItems.map((item, index) => (
        <div key={item.id || index}>
          {renderItem(item)}
        </div>
      ))}
      
      {hasMore && (
        <div ref={loadingRef} style={{ 
          textAlign: 'center', 
          padding: '20px' 
        }}>
          {isLoading ? '読み込み中...' : ''}
        </div>
      )}
    </div>
  );
}

export default LoadMoreList;