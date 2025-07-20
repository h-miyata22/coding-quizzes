import React, { useState } from 'react';

function ShoppingCart({ products }) {
  const [cart, setCart] = useState([]);
  const [message, setMessage] = useState('');

  // カートに商品を追加
  const addToCart = (product) => {
    const existingItem = cart.find(item => item.id === product.id);
    
    if (existingItem) {
      if (existingItem.quantity < 10) {
        setCart(cart.map(item =>
          item.id === product.id
            ? { ...item, quantity: item.quantity + 1 }
            : item
        ));
        showMessage(`${product.name}をカートに追加しました`);
      } else {
        showMessage('最大数量に達しています');
      }
    } else {
      setCart([...cart, { ...product, quantity: 1 }]);
      showMessage(`${product.name}をカートに追加しました`);
    }
  };

  // 数量を増やす
  const increaseQuantity = (id) => {
    setCart(cart.map(item => {
      if (item.id === id && item.quantity < 10) {
        return { ...item, quantity: item.quantity + 1 };
      }
      return item;
    }));
  };

  // 数量を減らす
  const decreaseQuantity = (id) => {
    setCart(cart.map(item => {
      if (item.id === id) {
        const newQuantity = item.quantity - 1;
        if (newQuantity === 0) {
          return null;
        }
        return { ...item, quantity: newQuantity };
      }
      return item;
    }).filter(Boolean));
  };

  // カートから削除
  const removeFromCart = (id) => {
    setCart(cart.filter(item => item.id !== id));
  };

  // メッセージを表示
  const showMessage = (text) => {
    setMessage(text);
    setTimeout(() => setMessage(''), 2000);
  };

  // 合計計算
  const subtotal = cart.reduce((sum, item) => sum + item.price * item.quantity, 0);
  const tax = Math.floor(subtotal * 0.1);
  const total = subtotal + tax;

  // カート内のアイテム数
  const itemCount = cart.reduce((sum, item) => sum + item.quantity, 0);

  return (
    <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '40px' }}>
      {/* 商品リスト */}
      <div>
        <h2>商品一覧</h2>
        <div style={{ display: 'grid', gap: '10px' }}>
          {products.map(product => (
            <div
              key={product.id}
              style={{
                display: 'flex',
                padding: '15px',
                border: '1px solid #ddd',
                borderRadius: '8px',
                alignItems: 'center'
              }}
            >
              <img
                src={product.image}
                alt={product.name}
                style={{ width: '80px', height: '80px', marginRight: '15px' }}
              />
              <div style={{ flex: 1 }}>
                <h3 style={{ margin: '0 0 5px 0' }}>{product.name}</h3>
                <p style={{ margin: 0, fontSize: '18px', fontWeight: 'bold' }}>
                  ¥{product.price.toLocaleString()}
                </p>
              </div>
              <button
                onClick={() => addToCart(product)}
                style={{
                  padding: '8px 16px',
                  backgroundColor: '#007bff',
                  color: 'white',
                  border: 'none',
                  borderRadius: '4px',
                  cursor: 'pointer'
                }}
              >
                カートに追加
              </button>
            </div>
          ))}
        </div>
      </div>

      {/* ショッピングカート */}
      <div>
        <h2>ショッピングカート ({itemCount}点)</h2>
        
        {message && (
          <div style={{
            padding: '10px',
            backgroundColor: '#d4edda',
            color: '#155724',
            borderRadius: '4px',
            marginBottom: '10px'
          }}>
            {message}
          </div>
        )}

        {cart.length === 0 ? (
          <div style={{
            padding: '40px',
            textAlign: 'center',
            backgroundColor: '#f8f9fa',
            borderRadius: '8px',
            color: '#666'
          }}>
            カートに商品がありません
          </div>
        ) : (
          <>
            <div style={{ marginBottom: '20px' }}>
              {cart.map(item => (
                <div
                  key={item.id}
                  style={{
                    display: 'flex',
                    padding: '15px',
                    borderBottom: '1px solid #eee',
                    alignItems: 'center'
                  }}
                >
                  <img
                    src={item.image}
                    alt={item.name}
                    style={{ width: '60px', height: '60px', marginRight: '15px' }}
                  />
                  <div style={{ flex: 1 }}>
                    <h4 style={{ margin: '0 0 5px 0' }}>{item.name}</h4>
                    <p style={{ margin: 0, color: '#666' }}>
                      ¥{item.price.toLocaleString()} × {item.quantity}
                    </p>
                  </div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                    <button
                      onClick={() => decreaseQuantity(item.id)}
                      style={{
                        width: '30px',
                        height: '30px',
                        border: '1px solid #ddd',
                        background: 'white',
                        cursor: 'pointer'
                      }}
                    >
                      -
                    </button>
                    <span style={{ minWidth: '30px', textAlign: 'center' }}>
                      {item.quantity}
                    </span>
                    <button
                      onClick={() => increaseQuantity(item.id)}
                      disabled={item.quantity >= 10}
                      style={{
                        width: '30px',
                        height: '30px',
                        border: '1px solid #ddd',
                        background: item.quantity >= 10 ? '#f0f0f0' : 'white',
                        cursor: item.quantity >= 10 ? 'not-allowed' : 'pointer'
                      }}
                    >
                      +
                    </button>
                    <button
                      onClick={() => removeFromCart(item.id)}
                      style={{
                        marginLeft: '10px',
                        padding: '5px 10px',
                        backgroundColor: '#dc3545',
                        color: 'white',
                        border: 'none',
                        borderRadius: '4px',
                        cursor: 'pointer'
                      }}
                    >
                      削除
                    </button>
                  </div>
                </div>
              ))}
            </div>

            <div style={{
              padding: '20px',
              backgroundColor: '#f8f9fa',
              borderRadius: '8px'
            }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '10px' }}>
                <span>小計:</span>
                <span>¥{subtotal.toLocaleString()}</span>
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '10px' }}>
                <span>消費税 (10%):</span>
                <span>¥{tax.toLocaleString()}</span>
              </div>
              <div style={{
                display: 'flex',
                justifyContent: 'space-between',
                fontSize: '20px',
                fontWeight: 'bold',
                borderTop: '2px solid #dee2e6',
                paddingTop: '10px'
              }}>
                <span>合計:</span>
                <span>¥{total.toLocaleString()}</span>
              </div>
            </div>
          </>
        )}
      </div>
    </div>
  );
}

export default ShoppingCart;