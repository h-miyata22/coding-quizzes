// 使用例
import React from 'react';

// LazyChart コンポーネントを実装してください
// 以下の要件を満たす必要があります：
// - chartType に応じて適切なチャートコンポーネントを遅延ロード
// - IntersectionObserver で可視性を監視
// - 可視領域に入ったらコンポーネントをロード
// - ローディング中はスケルトンUI表示

function LazyChart({ chartType, data }) {
  // 実装してください
}

// 期待される使用方法
function Dashboard() {
  const salesData = { /* ... */ };
  const heatMapData = { /* ... */ };
  const visualizationData = { /* ... */ };

  return (
    <div className="dashboard">
      <h1>Analytics Dashboard</h1>
      
      <div style={{ height: '1000px' }}>
        {/* スクロールが必要な長いコンテンツ */}
        <p>Scroll down to see charts...</p>
      </div>

      <LazyChart chartType="DataChart" data={salesData} />
      <LazyChart chartType="HeatMap" data={heatMapData} />
      <LazyChart chartType="3DVisualization" data={visualizationData} />
    </div>
  );
}

// スケルトンUIの例
function ChartSkeleton() {
  return (
    <div style={{
      height: '300px',
      background: '#f0f0f0',
      borderRadius: '8px',
      animation: 'pulse 1.5s ease-in-out infinite'
    }}>
      <div style={{ padding: '20px', color: '#999' }}>
        Loading chart...
      </div>
    </div>
  );
}

export default Dashboard;