// 使用例
function App() {
  // APIシミュレーション関数（実際の実装では本物のAPIを使用）
  const fetchWeatherData = async () => {
    // 2秒の遅延をシミュレート
    await new Promise(resolve => setTimeout(resolve, 2000));
    
    // モックデータを返す
    return {
      city: '東京',
      temperature: 22.5,
      condition: '晴れ',
      humidity: 65
    };
  };

  return (
    <div>
      <h1>天気予報アプリ</h1>
      <WeatherDisplay fetchWeatherData={fetchWeatherData} />
    </div>
  );
}

// WeatherDisplayコンポーネントを実装してください