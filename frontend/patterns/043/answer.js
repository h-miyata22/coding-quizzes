import React, { useState, useEffect } from 'react';

function WeatherDisplay({ fetchWeatherData }) {
  const [weatherData, setWeatherData] = useState(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isRefreshing, setIsRefreshing] = useState(false);

  // 天気データを取得する関数
  const loadWeatherData = async () => {
    try {
      const data = await fetchWeatherData();
      setWeatherData(data);
    } catch (error) {
      console.error('天気データの取得に失敗しました:', error);
    } finally {
      setIsLoading(false);
      setIsRefreshing(false);
    }
  };

  // コンポーネントマウント時にデータを取得
  useEffect(() => {
    loadWeatherData();
  }, []);

  // 更新ボタンのハンドラ
  const handleRefresh = () => {
    setIsRefreshing(true);
    loadWeatherData();
  };

  // 初回ローディング中の表示
  if (isLoading) {
    return (
      <div style={{ textAlign: 'center', padding: '20px' }}>
        <div style={{ fontSize: '24px', marginBottom: '10px' }}>🌀</div>
        <p>天気情報を取得中...</p>
      </div>
    );
  }

  // データが取得できなかった場合
  if (!weatherData) {
    return (
      <div style={{ textAlign: 'center', padding: '20px' }}>
        <p>天気情報を取得できませんでした</p>
        <button onClick={handleRefresh}>再読み込み</button>
      </div>
    );
  }

  // 天気情報の表示
  return (
    <div style={{ padding: '20px', border: '1px solid #ddd', borderRadius: '8px' }}>
      <h2>{weatherData.city}の天気</h2>
      <div style={{ marginBottom: '10px' }}>
        <p>天気: {weatherData.condition}</p>
        <p>気温: {weatherData.temperature.toFixed(1)}°C</p>
        <p>湿度: {weatherData.humidity}%</p>
      </div>
      <button 
        onClick={handleRefresh} 
        disabled={isRefreshing}
        style={{
          padding: '8px 16px',
          cursor: isRefreshing ? 'not-allowed' : 'pointer',
          opacity: isRefreshing ? 0.6 : 1
        }}
      >
        {isRefreshing ? '更新中...' : '更新'}
      </button>
    </div>
  );
}

export default WeatherDisplay;