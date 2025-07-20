// 使用例
function App() {
  const handleSubmit = (cardData) => {
    console.log('カード情報:', cardData);
    alert('決済処理を実行します');
  };

  return (
    <div style={{ maxWidth: '400px', margin: '40px auto' }}>
      <h2>クレジットカード情報</h2>
      <CreditCardForm onSubmit={handleSubmit} />
    </div>
  );
}

// CreditCardFormコンポーネントを実装してください