import React, { useState } from 'react';

function CreditCardForm({ onSubmit }) {
  const [cardNumber, setCardNumber] = useState('');
  const [expiryDate, setExpiryDate] = useState('');
  const [cvv, setCvv] = useState('');
  const [cardHolder, setCardHolder] = useState('');
  const [errors, setErrors] = useState({});

  // カード番号のフォーマット
  const formatCardNumber = (value) => {
    const cleaned = value.replace(/\s/g, '');
    const match = cleaned.match(/.{1,4}/g);
    return match ? match.join(' ') : '';
  };

  // カード番号の変更ハンドラ
  const handleCardNumberChange = (e) => {
    const value = e.target.value.replace(/\D/g, ''); // 数字以外を削除
    if (value.length <= 16) {
      setCardNumber(value);
      if (value.length !== 16 && value.length > 0) {
        setErrors(prev => ({ ...prev, cardNumber: 'カード番号は16桁で入力してください' }));
      } else {
        setErrors(prev => ({ ...prev, cardNumber: '' }));
      }
    }
  };

  // 有効期限の変更ハンドラ
  const handleExpiryDateChange = (e) => {
    let value = e.target.value.replace(/\D/g, '');
    
    if (value.length >= 2) {
      const month = value.substring(0, 2);
      const year = value.substring(2, 4);
      
      // 月のバリデーション
      if (parseInt(month) > 12 || parseInt(month) === 0) {
        setErrors(prev => ({ ...prev, expiryDate: '月は01-12の範囲で入力してください' }));
      } else {
        setErrors(prev => ({ ...prev, expiryDate: '' }));
      }
      
      value = month + (year ? '/' + year : '');
    }
    
    if (value.length <= 5) {
      setExpiryDate(value);
    }
  };

  // CVVの変更ハンドラ
  const handleCvvChange = (e) => {
    const value = e.target.value.replace(/\D/g, '');
    if (value.length <= 4) {
      setCvv(value);
      if (value.length < 3 && value.length > 0) {
        setErrors(prev => ({ ...prev, cvv: 'CVVは3-4桁で入力してください' }));
      } else {
        setErrors(prev => ({ ...prev, cvv: '' }));
      }
    }
  };

  // カードホルダー名の変更ハンドラ
  const handleCardHolderChange = (e) => {
    const value = e.target.value.replace(/[^a-zA-Z\s]/g, '').toUpperCase();
    setCardHolder(value);
  };

  // フォームのバリデーション
  const isFormValid = () => {
    return cardNumber.length === 16 && 
           expiryDate.length === 5 && 
           cvv.length >= 3 && 
           cardHolder.trim().length > 0 &&
           !Object.values(errors).some(error => error);
  };

  // フォーム送信
  const handleSubmit = (e) => {
    e.preventDefault();
    if (isFormValid()) {
      onSubmit({
        cardNumber: formatCardNumber(cardNumber),
        expiryDate,
        cvv,
        cardHolder
      });
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <div style={{ marginBottom: '15px' }}>
        <label>カード番号</label>
        <input
          type="text"
          value={formatCardNumber(cardNumber)}
          onChange={handleCardNumberChange}
          placeholder="1234 5678 9012 3456"
          style={{ width: '100%', padding: '8px', fontSize: '16px' }}
        />
        {errors.cardNumber && <span style={{ color: 'red', fontSize: '12px' }}>{errors.cardNumber}</span>}
      </div>

      <div style={{ display: 'flex', gap: '15px', marginBottom: '15px' }}>
        <div style={{ flex: 1 }}>
          <label>有効期限</label>
          <input
            type="text"
            value={expiryDate}
            onChange={handleExpiryDateChange}
            placeholder="MM/YY"
            style={{ width: '100%', padding: '8px', fontSize: '16px' }}
          />
          {errors.expiryDate && <span style={{ color: 'red', fontSize: '12px' }}>{errors.expiryDate}</span>}
        </div>
        <div style={{ flex: 1 }}>
          <label>CVV</label>
          <input
            type="text"
            value={cvv}
            onChange={handleCvvChange}
            placeholder="123"
            style={{ width: '100%', padding: '8px', fontSize: '16px' }}
          />
          {errors.cvv && <span style={{ color: 'red', fontSize: '12px' }}>{errors.cvv}</span>}
        </div>
      </div>

      <div style={{ marginBottom: '20px' }}>
        <label>カードホルダー名</label>
        <input
          type="text"
          value={cardHolder}
          onChange={handleCardHolderChange}
          placeholder="TARO YAMADA"
          style={{ width: '100%', padding: '8px', fontSize: '16px' }}
        />
      </div>

      <button
        type="submit"
        disabled={!isFormValid()}
        style={{
          width: '100%',
          padding: '12px',
          fontSize: '16px',
          backgroundColor: isFormValid() ? '#007bff' : '#ccc',
          color: 'white',
          border: 'none',
          borderRadius: '4px',
          cursor: isFormValid() ? 'pointer' : 'not-allowed'
        }}
      >
        決済する
      </button>
    </form>
  );
}

export default CreditCardForm;