import React, { useState, useEffect } from 'react';

function NotificationMessage({ isVisible, type, message, onClose }) {
  const [shouldRender, setShouldRender] = useState(isVisible);
  const [isAnimating, setIsAnimating] = useState(false);

  useEffect(() => {
    if (isVisible) {
      setShouldRender(true);
      // 次のフレームでアニメーションを開始
      requestAnimationFrame(() => {
        setIsAnimating(true);
      });
    } else {
      setIsAnimating(false);
      // アニメーション完了後にDOMから削除
      const timer = setTimeout(() => {
        setShouldRender(false);
      }, 500); // アニメーション時間と同じ
      return () => clearTimeout(timer);
    }
  }, [isVisible]);

  if (!shouldRender) {
    return null;
  }

  // タイプに応じたスタイルを設定
  const typeStyles = {
    success: { backgroundColor: '#d4edda', icon: '✓' },
    warning: { backgroundColor: '#fff3cd', icon: '⚠' },
    error: { backgroundColor: '#f8d7da', icon: '✗' },
    info: { backgroundColor: '#d1ecf1', icon: 'ℹ' }
  };

  const currentStyle = typeStyles[type] || typeStyles.info;

  return (
    <div style={{
      position: 'relative',
      backgroundColor: currentStyle.backgroundColor,
      border: '1px solid rgba(0, 0, 0, 0.1)',
      borderRadius: '4px',
      padding: '12px 40px 12px 12px',
      marginBottom: '10px',
      opacity: isAnimating ? 1 : 0,
      transform: isAnimating ? 'translateY(0)' : 'translateY(-20px)',
      transition: 'opacity 0.5s ease-out, transform 0.5s ease-out',
      display: 'flex',
      alignItems: 'center'
    }}>
      <span style={{ fontSize: '20px', marginRight: '10px' }}>
        {currentStyle.icon}
      </span>
      <span>{message}</span>
      <button
        onClick={onClose}
        style={{
          position: 'absolute',
          right: '10px',
          top: '50%',
          transform: 'translateY(-50%)',
          background: 'none',
          border: 'none',
          fontSize: '20px',
          cursor: 'pointer',
          opacity: 0.5,
          transition: 'opacity 0.2s'
        }}
        onMouseEnter={(e) => e.target.style.opacity = 1}
        onMouseLeave={(e) => e.target.style.opacity = 0.5}
      >
        ×
      </button>
    </div>
  );
}

export default NotificationMessage;