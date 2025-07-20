// 使用例
import React from 'react';

// LazyImage コンポーネントを実装してください
// 以下の要件を満たす必要があります：
// - IntersectionObserverで可視性を監視
// - 画像の遅延ロード
// - ローディング状態の表示
// - エラーハンドリング

function LazyImage({ 
  src, 
  alt, 
  placeholder = '#f0f0f0',  // プレースホルダーの背景色
  errorSrc = '/error-image.png',  // エラー時の代替画像
  ...props 
}) {
  // 実装してください
}

// 期待される使用方法
function BlogPost() {
  const images = [
    { id: 1, src: '/images/photo1.jpg', alt: 'Beautiful landscape' },
    { id: 2, src: '/images/photo2.jpg', alt: 'City skyline' },
    { id: 3, src: '/images/photo3.jpg', alt: 'Nature scene' },
    // ... 多数の画像
  ];

  return (
    <article style={{ maxWidth: '800px', margin: '0 auto' }}>
      <h1>My Travel Blog</h1>
      
      <p>Some introductory text...</p>
      
      {images.map(image => (
        <div key={image.id} style={{ marginBottom: '2rem' }}>
          <LazyImage
            src={image.src}
            alt={image.alt}
            style={{
              width: '100%',
              height: '400px',
              objectFit: 'cover',
              borderRadius: '8px'
            }}
          />
          <p>Description for {image.alt}</p>
        </div>
      ))}
    </article>
  );
}

// 期待される動作：
// 1. 初期表示時は placeholder の背景色
// 2. スクロールで画像が近づくとロード開始
// 3. ロード完了でフェードイン表示
// 4. エラー時は errorSrc の画像を表示

export default BlogPost;