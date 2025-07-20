import { useState, useEffect, useRef, useCallback } from 'react';

function useTimer({
  initialTime = 0,
  mode = 'countdown',
  autoStart = false,
  onComplete = null
} = {}) {
  const [time, setTime] = useState(initialTime);
  const [isRunning, setIsRunning] = useState(autoStart);
  const intervalRef = useRef(null);
  const onCompleteRef = useRef(onComplete);
  
  // onCompleteコールバックを更新
  useEffect(() => {
    onCompleteRef.current = onComplete;
  }, [onComplete]);
  
  // タイマーの開始
  const start = useCallback(() => {
    setIsRunning(true);
  }, []);
  
  // タイマーの一時停止
  const pause = useCallback(() => {
    setIsRunning(false);
  }, []);
  
  // タイマーのリセット
  const reset = useCallback(() => {
    setIsRunning(false);
    setTime(initialTime);
  }, [initialTime]);
  
  // 時間の設定
  const setTimeWrapper = useCallback((seconds) => {
    setTime(seconds);
  }, []);
  
  // 時間のフォーマット（MM:SS）
  const formatTime = useCallback((seconds) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }, []);
  
  // タイマーの実行
  useEffect(() => {
    if (isRunning) {
      intervalRef.current = setInterval(() => {
        setTime(prevTime => {
          if (mode === 'countdown') {
            const newTime = Math.max(0, prevTime - 1);
            
            // カウントダウンが0になったら
            if (newTime === 0 && prevTime === 1) {
              setIsRunning(false);
              if (onCompleteRef.current) {
                onCompleteRef.current();
              }
            }
            
            return newTime;
          } else {
            // ストップウォッチモード
            return prevTime + 1;
          }
        });
      }, 1000);
    } else {
      if (intervalRef.current) {
        clearInterval(intervalRef.current);
        intervalRef.current = null;
      }
    }
    
    return () => {
      if (intervalRef.current) {
        clearInterval(intervalRef.current);
        intervalRef.current = null;
      }
    };
  }, [isRunning, mode]);
  
  return {
    time,
    isRunning,
    start,
    pause,
    reset,
    setTime: setTimeWrapper,
    formattedTime: formatTime(time)
  };
}

export default useTimer;