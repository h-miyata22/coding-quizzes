import React, { useState, useRef, useCallback, useEffect } from 'react';

function VirtualList({
  items,
  height,
  itemHeight,
  renderItem,
  overscan = 3
}) {
  const [scrollTop, setScrollTop] = useState(0);
  const scrollElementRef = useRef(null);

  // 表示範囲の計算
  const startIndex = Math.max(0, Math.floor(scrollTop / itemHeight) - overscan);
  const endIndex = Math.min(
    items.length - 1,
    Math.ceil((scrollTop + height) / itemHeight) + overscan
  );

  // 表示するアイテムの取得
  const visibleItems = items.slice(startIndex, endIndex + 1);

  // 全体の高さ（スクロールバーを正しく表示するため）
  const totalHeight = items.length * itemHeight;

  // 表示位置のオフセット
  const offsetY = startIndex * itemHeight;

  // スクロールイベントハンドラ
  const handleScroll = useCallback((e) => {
    setScrollTop(e.target.scrollTop);
  }, []);

  return (
    <div
      ref={scrollElementRef}
      onScroll={handleScroll}
      style={{
        height,
        overflow: 'auto',
        position: 'relative'
      }}
    >
      {/* 全体の高さを確保するための要素 */}
      <div style={{ height: totalHeight, position: 'relative' }}>
        {/* 実際にレンダリングする要素のコンテナ */}
        <div
          style={{
            transform: `translateY(${offsetY}px)`,
            position: 'absolute',
            top: 0,
            left: 0,
            right: 0
          }}
        >
          {visibleItems.map((item, index) => {
            const actualIndex = startIndex + index;
            return renderItem({
              item,
              index: actualIndex,
              style: {
                position: 'absolute',
                top: index * itemHeight,
                height: itemHeight,
                left: 0,
                right: 0
              }
            });
          })}
        </div>
      </div>
    </div>
  );
}

// パフォーマンス最適化版（requestAnimationFrameを使用）
function VirtualListOptimized({
  items,
  height,
  itemHeight,
  renderItem,
  overscan = 3
}) {
  const [scrollTop, setScrollTop] = useState(0);
  const scrollElementRef = useRef(null);
  const animationFrameRef = useRef(null);

  // 表示範囲の計算
  const startIndex = Math.max(0, Math.floor(scrollTop / itemHeight) - overscan);
  const endIndex = Math.min(
    items.length - 1,
    Math.ceil((scrollTop + height) / itemHeight) + overscan
  );

  const visibleItems = items.slice(startIndex, endIndex + 1);
  const totalHeight = items.length * itemHeight;
  const offsetY = startIndex * itemHeight;

  // スクロールイベントハンドラ（requestAnimationFrameで最適化）
  const handleScroll = useCallback((e) => {
    if (animationFrameRef.current) {
      cancelAnimationFrame(animationFrameRef.current);
    }
    
    animationFrameRef.current = requestAnimationFrame(() => {
      setScrollTop(e.target.scrollTop);
    });
  }, []);

  // クリーンアップ
  useEffect(() => {
    return () => {
      if (animationFrameRef.current) {
        cancelAnimationFrame(animationFrameRef.current);
      }
    };
  }, []);

  return (
    <div
      ref={scrollElementRef}
      onScroll={handleScroll}
      style={{
        height,
        overflow: 'auto',
        position: 'relative',
        willChange: 'transform' // GPUアクセラレーションのヒント
      }}
    >
      <div style={{ height: totalHeight, position: 'relative' }}>
        <div
          style={{
            transform: `translateY(${offsetY}px)`,
            position: 'absolute',
            top: 0,
            left: 0,
            right: 0,
            willChange: 'transform'
          }}
        >
          {visibleItems.map((item, index) => {
            const actualIndex = startIndex + index;
            return (
              <div
                key={item.id || actualIndex}
                style={{
                  position: 'absolute',
                  top: index * itemHeight,
                  height: itemHeight,
                  left: 0,
                  right: 0
                }}
              >
                {renderItem({
                  item,
                  index: actualIndex,
                  style: {
                    height: '100%',
                    boxSizing: 'border-box'
                  }
                })}
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}

export default VirtualList;