import React from 'react';

function ProgressBar({ progress }) {
  // 進捗率を安全な範囲に制限
  const safeProgress = Math.max(0, Math.min(100, progress));
  
  // 進捗率に応じた色を決定
  const getProgressColor = (value) => {
    if (value <= 30) {
      return '#ff4444';
    } else if (value <= 70) {
      return '#ff8800';
    } else {
      return '#44ff44';
    }
  };

  return (
    <div>
      <div style={{
        width: '100%',
        height: '20px',
        backgroundColor: '#f0f0f0',
        borderRadius: '10px',
        overflow: 'hidden',
        position: 'relative'
      }}>
        <div style={{
          width: `${safeProgress}%`,
          height: '100%',
          backgroundColor: getProgressColor(safeProgress),
          transition: 'width 0.3s ease-out, background-color 0.3s ease-out',
          borderRadius: '10px',
          position: 'relative'
        }}>
        </div>
      </div>
      
      <div style={{
        marginTop: '10px',
        textAlign: 'center',
        fontSize: '16px',
        fontWeight: 'bold'
      }}>
        {safeProgress === 100 ? '完了！' : `${safeProgress}%`}
      </div>
    </div>
  );
}

export default ProgressBar;