// 使用例
function App() {
  // 商品データ
  const products = [
    { id: 1, name: 'ノートパソコン', price: 89800, image: 'https://via.placeholder.com/100?text=PC' },
    { id: 2, name: 'ワイヤレスイヤホン', price: 24800, image: 'https://via.placeholder.com/100?text=Earphones' },
    { id: 3, name: 'スマートウォッチ', price: 34800, image: 'https://via.placeholder.com/100?text=Watch' },
    { id: 4, name: 'タブレット', price: 52800, image: 'https://via.placeholder.com/100?text=Tablet' },
    { id: 5, name: 'キーボード', price: 12800, image: 'https://via.placeholder.com/100?text=Keyboard' }
  ];

  return (
    <div style={{ maxWidth: '1200px', margin: '40px auto', padding: '20px' }}>
      <h1>オンラインショップ</h1>
      <ShoppingCart products={products} />
    </div>
  );
}

// ShoppingCartコンポーネントを実装してください