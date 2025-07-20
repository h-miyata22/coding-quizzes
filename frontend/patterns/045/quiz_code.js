// 使用例
function App() {
  const [progress, setProgress] = useState(0);

  // アップロードをシミュレートする関数
  const simulateUpload = () => {
    setProgress(0);
    const interval = setInterval(() => {
      setProgress(prev => {
        if (prev >= 100) {
          clearInterval(interval);
          return 100;
        }
        return prev + 10;
      });
    }, 500);
  };

  return (
    <div style={{ padding: '20px', maxWidth: '500px' }}>
      <h2>ファイルアップロード</h2>
      
      <ProgressBar progress={progress} />
      
      <div style={{ marginTop: '20px' }}>
        <button onClick={simulateUpload}>
          アップロード開始
        </button>
        <button onClick={() => setProgress(0)} style={{ marginLeft: '10px' }}>
          リセット
        </button>
      </div>
      
      <div style={{ marginTop: '10px' }}>
        <button onClick={() => setProgress(25)}>25%</button>
        <button onClick={() => setProgress(50)} style={{ marginLeft: '5px' }}>50%</button>
        <button onClick={() => setProgress(75)} style={{ marginLeft: '5px' }}>75%</button>
        <button onClick={() => setProgress(100)} style={{ marginLeft: '5px' }}>100%</button>
      </div>
    </div>
  );
}

// ProgressBarコンポーネントを実装してください