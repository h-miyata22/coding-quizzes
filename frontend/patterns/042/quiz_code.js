// 使用例
function App() {
  const products = [
    { id: 1, name: 'ノートパソコン', price: 98000, stock: 12, category: 'コンピュータ' },
    { id: 2, name: 'ワイヤレスマウス', price: 3980, stock: 0, category: '周辺機器' },
    { id: 3, name: 'USBメモリ 32GB', price: 1280, stock: 3, category: 'ストレージ' },
    { id: 4, name: 'キーボード', price: 5800, stock: 8, category: '周辺機器' },
    { id: 5, name: 'モニター 24インチ', price: 28000, stock: 4, category: 'ディスプレイ' }
  ];

  // 空の配列を渡した場合のテスト用
  // const products = [];

  return (
    <div>
      <h1>在庫管理システム</h1>
      <ProductList products={products} />
    </div>
  );
}

// ProductListコンポーネントを実装してください