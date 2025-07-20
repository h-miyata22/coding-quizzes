// 使用例
import React from 'react';

// PriorityRenderer コンポーネントを実装してください
// 以下の要件を満たす必要があります：
// - 優先度に基づく段階的レンダリング
// - criticalは即座に表示
// - 他は優先度順に遅延表示
// - スムーズなアニメーション

function PriorityRenderer({ 
  priority = 'normal', // 'critical' | 'high' | 'normal' | 'low'
  children,
  placeholder
}) {
  // 実装してください
}

// 期待される使用方法
function LandingPage() {
  return (
    <div style={{ maxWidth: '1200px', margin: '0 auto' }}>
      {/* ヒーローセクション - 最重要 */}
      <PriorityRenderer 
        priority="critical"
        placeholder={<div style={{ height: '400px', background: '#f0f0f0' }} />}
      >
        <section style={{ 
          height: '400px', 
          background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
          color: 'white',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          fontSize: '3rem'
        }}>
          <h1>Welcome to Our Service</h1>
        </section>
      </PriorityRenderer>

      {/* 主要機能 - 高優先度 */}
      <PriorityRenderer 
        priority="high"
        placeholder={<div style={{ height: '300px', background: '#f5f5f5' }} />}
      >
        <section style={{ padding: '50px', textAlign: 'center' }}>
          <h2>Key Features</h2>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '20px', marginTop: '30px' }}>
            <div>Feature 1</div>
            <div>Feature 2</div>
            <div>Feature 3</div>
          </div>
        </section>
      </PriorityRenderer>

      {/* 価格プラン - 通常優先度 */}
      <PriorityRenderer 
        priority="normal"
        placeholder={<div style={{ height: '400px', background: '#fafafa' }} />}
      >
        <section style={{ padding: '50px', background: '#f8f8f8' }}>
          <h2>Pricing Plans</h2>
          <div>Plan details here...</div>
        </section>
      </PriorityRenderer>

      {/* フッター - 低優先度 */}
      <PriorityRenderer 
        priority="low"
        placeholder={<div style={{ height: '200px', background: '#e0e0e0' }} />}
      >
        <footer style={{ padding: '30px', background: '#333', color: 'white' }}>
          <p>© 2024 Company. All rights reserved.</p>
        </footer>
      </PriorityRenderer>
    </div>
  );
}

export default LandingPage;