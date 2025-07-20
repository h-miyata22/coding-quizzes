import React, { useState, useCallback, Suspense } from 'react';

function VideoEditorLoader() {
  const [VideoEditor, setVideoEditor] = useState(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState(null);

  const loadVideoEditor = useCallback(async () => {
    if (VideoEditor) return; // 既にロード済みの場合は何もしない

    setIsLoading(true);
    setError(null);

    try {
      // 動的インポートでVideoEditorコンポーネントをロード
      const module = await import('./components/VideoEditor');
      const VideoEditorComponent = module.default;
      
      // React.lazyを使わずに、直接コンポーネントを保存
      setVideoEditor(() => VideoEditorComponent);
    } catch (err) {
      console.error('Failed to load video editor:', err);
      setError('エディターの読み込みに失敗しました');
    } finally {
      setIsLoading(false);
    }
  }, [VideoEditor]);

  // エラー状態
  if (error) {
    return <div>{error}</div>;
  }

  // ローディング状態
  if (isLoading) {
    return <div>動画エディターを読み込み中...</div>;
  }

  // VideoEditorがロード済みの場合
  if (VideoEditor) {
    return <VideoEditor />;
  }

  // 初期状態（ボタン表示）
  return (
    <button onClick={loadVideoEditor}>
      動画を編集
    </button>
  );
}

// 別解: React.lazyとSuspenseを使用したバージョン
function VideoEditorLoaderAlternative() {
  const [showEditor, setShowEditor] = useState(false);
  
  // React.lazyは関数外で定義する必要がある
  const VideoEditor = React.lazy(() => import('./components/VideoEditor'));

  if (!showEditor) {
    return (
      <button onClick={() => setShowEditor(true)}>
        動画を編集
      </button>
    );
  }

  return (
    <Suspense fallback={<div>動画エディターを読み込み中...</div>}>
      <VideoEditor />
    </Suspense>
  );
}

export default VideoEditorLoader;