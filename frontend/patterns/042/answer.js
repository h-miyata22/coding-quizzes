import React from 'react';

function ProductList({ products }) {
  // 商品が一つもない場合の処理
  if (products.length === 0) {
    return <div>商品がありません</div>;
  }

  // 価格を日本円フォーマットに変換する関数
  const formatPrice = (price) => {
    return `¥${price.toLocaleString('ja-JP')}`;
  };

  // 在庫状況に応じた表示を返す関数
  const getStockDisplay = (stock) => {
    if (stock === 0) {
      return <span style={{ color: 'red' }}>在庫切れ</span>;
    } else if (stock < 5) {
      return <span style={{ color: 'orange' }}>在庫僅少 ({stock})</span>;
    } else {
      return <span>在庫数: {stock}</span>;
    }
  };

  return (
    <div className="product-list">
      {products.map(product => (
        <div key={product.id} className="product-card" style={{
          border: '1px solid #ddd',
          padding: '16px',
          marginBottom: '12px',
          borderRadius: '8px'
        }}>
          <h3>{product.name}</h3>
          <p>カテゴリ: {product.category}</p>
          <p className="price" style={{ fontSize: '18px', fontWeight: 'bold' }}>
            {formatPrice(product.price)}
          </p>
          <p className="stock">
            {getStockDisplay(product.stock)}
          </p>
        </div>
      ))}
    </div>
  );
}

export default ProductList;