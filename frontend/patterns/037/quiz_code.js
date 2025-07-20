// 使用例
import React from 'react';

// LoadMoreList コンポーネントを実装してください
// 以下の要件を満たす必要があります：
// - 初期表示件数の制御
// - 「もっと見る」での追加読み込み
// - ローディング状態の管理
// - エラーハンドリング

function LoadMoreList({
  items,              // 全アイテムの配列
  initialCount = 10,  // 初期表示件数
  loadMoreCount = 10, // 追加読み込み件数
  renderItem,         // アイテムのレンダリング関数
  loadDelay = 1000    // 読み込みシミュレーションの遅延（ミリ秒）
}) {
  // 実装してください
}

// 期待される使用方法
function NewsFeed() {
  // 100件のニュース記事データ
  const newsArticles = Array.from({ length: 100 }, (_, i) => ({
    id: i + 1,
    title: `Breaking News ${i + 1}: Important Update`,
    summary: `This is the summary for news article ${i + 1}. Lorem ipsum dolor sit amet...`,
    publishedAt: new Date(Date.now() - i * 3600000).toLocaleString(),
    category: ['Tech', 'Business', 'Sports', 'Entertainment'][i % 4]
  }));

  return (
    <div style={{ maxWidth: '600px', margin: '0 auto', padding: '20px' }}>
      <h1>Latest News</h1>
      <LoadMoreList
        items={newsArticles}
        renderItem={(article) => (
          <article 
            key={article.id}
            style={{
              padding: '15px',
              marginBottom: '10px',
              border: '1px solid #eee',
              borderRadius: '8px',
              animation: 'fadeIn 0.3s ease-in'
            }}
          >
            <h3 style={{ margin: '0 0 10px' }}>{article.title}</h3>
            <p style={{ margin: '0 0 10px', color: '#666' }}>
              {article.summary}
            </p>
            <div style={{ fontSize: '0.9em', color: '#999' }}>
              {article.category} • {article.publishedAt}
            </div>
          </article>
        )}
      />
    </div>
  );
}

// CSSアニメーション
const styles = `
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
`;

export default NewsFeed;