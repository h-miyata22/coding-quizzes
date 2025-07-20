import React, { useState, useEffect, useRef, Suspense } from 'react';

// チャートコンポーネントの動的インポートマップ
const chartComponents = {
  DataChart: React.lazy(() => import('./charts/DataChart')),
  HeatMap: React.lazy(() => import('./charts/HeatMap')),
  '3DVisualization': React.lazy(() => import('./charts/3DVisualization'))
};

// スケルトンUIコンポーネント
function ChartSkeleton() {
  return (
    <div style={{
      height: '300px',
      background: '#f0f0f0',
      borderRadius: '8px',
      animation: 'pulse 1.5s ease-in-out infinite',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center'
    }}>
      <style jsx>{`
        @keyframes pulse {
          0% { opacity: 1; }
          50% { opacity: 0.4; }
          100% { opacity: 1; }
        }
      `}</style>
      <div style={{ color: '#999' }}>
        Loading chart...
      </div>
    </div>
  );
}

// 遅延ロードチャートコンポーネント
function LazyChart({ chartType, data }) {
  const [isVisible, setIsVisible] = useState(false);
  const containerRef = useRef(null);

  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            setIsVisible(true);
            // 一度表示されたら監視を停止
            observer.unobserve(entry.target);
          }
        });
      },
      {
        // ビューポートに入る100px前からロードを開始
        rootMargin: '100px',
        threshold: 0.01
      }
    );

    if (containerRef.current) {
      observer.observe(containerRef.current);
    }

    return () => {
      if (containerRef.current) {
        observer.unobserve(containerRef.current);
      }
    };
  }, []);

  const ChartComponent = chartComponents[chartType];

  if (!ChartComponent) {
    return (
      <div style={{ height: '300px', color: 'red' }}>
        Unknown chart type: {chartType}
      </div>
    );
  }

  return (
    <div 
      ref={containerRef} 
      style={{ 
        minHeight: '300px',
        marginBottom: '20px'
      }}
    >
      {isVisible ? (
        <Suspense fallback={<ChartSkeleton />}>
          <ChartComponent data={data} />
        </Suspense>
      ) : (
        <ChartSkeleton />
      )}
    </div>
  );
}

// カスタムフックバージョン（再利用可能）
function useIntersectionObserver(options = {}) {
  const [isVisible, setIsVisible] = useState(false);
  const elementRef = useRef(null);

  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            setIsVisible(true);
            observer.unobserve(entry.target);
          }
        });
      },
      options
    );

    const element = elementRef.current;
    if (element) {
      observer.observe(element);
    }

    return () => {
      if (element) {
        observer.unobserve(element);
      }
    };
  }, [options.rootMargin, options.threshold]);

  return [elementRef, isVisible];
}

// カスタムフックを使用したバージョン
function LazyChartWithHook({ chartType, data }) {
  const [containerRef, isVisible] = useIntersectionObserver({
    rootMargin: '100px',
    threshold: 0.01
  });

  const ChartComponent = chartComponents[chartType];

  if (!ChartComponent) {
    return (
      <div style={{ height: '300px', color: 'red' }}>
        Unknown chart type: {chartType}
      </div>
    );
  }

  return (
    <div 
      ref={containerRef} 
      style={{ 
        minHeight: '300px',
        marginBottom: '20px'
      }}
    >
      {isVisible ? (
        <Suspense fallback={<ChartSkeleton />}>
          <ChartComponent data={data} />
        </Suspense>
      ) : (
        <ChartSkeleton />
      )}
    </div>
  );
}

export default LazyChart;