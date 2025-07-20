// 使用例
import React from 'react';

// カウントダウンタイマー
function CountdownTimer() {
  const {
    time,
    isRunning,
    start,
    pause,
    reset,
    formattedTime
  } = useTimer({
    initialTime: 300, // 5分
    mode: 'countdown',
    onComplete: () => {
      alert('Time is up!');
    }
  });
  
  return (
    <div>
      <h2>Countdown Timer</h2>
      <div className="timer-display">{formattedTime}</div>
      <button onClick={isRunning ? pause : start}>
        {isRunning ? 'Pause' : 'Start'}
      </button>
      <button onClick={reset}>Reset</button>
    </div>
  );
}

// ストップウォッチ
function Stopwatch() {
  const {
    time,
    isRunning,
    start,
    pause,
    reset,
    formattedTime
  } = useTimer({
    mode: 'stopwatch'
  });
  
  return (
    <div>
      <h2>Stopwatch</h2>
      <div className="timer-display">{formattedTime}</div>
      <button onClick={isRunning ? pause : start}>
        {isRunning ? 'Pause' : 'Start'}
      </button>
      <button onClick={reset}>Reset</button>
      <div>Elapsed seconds: {time}</div>
    </div>
  );
}

// ポモドーロタイマー
function PomodoroTimer() {
  const [mode, setMode] = useState('work'); // 'work' | 'break'
  
  const {
    time,
    isRunning,
    start,
    pause,
    reset,
    setTime,
    formattedTime
  } = useTimer({
    initialTime: 25 * 60, // 25分
    mode: 'countdown',
    onComplete: () => {
      if (mode === 'work') {
        setMode('break');
        setTime(5 * 60); // 5分休憩
        start();
      } else {
        setMode('work');
        setTime(25 * 60); // 25分作業
      }
    }
  });
  
  return (
    <div>
      <h2>Pomodoro Timer</h2>
      <div>Mode: {mode === 'work' ? '🔥 Work' : '☕ Break'}</div>
      <div className="timer-display">{formattedTime}</div>
      <button onClick={isRunning ? pause : start}>
        {isRunning ? 'Pause' : 'Start'}
      </button>
      <button onClick={() => {
        reset();
        setMode('work');
      }}>
        Reset Session
      </button>
    </div>
  );
}

// クイズタイマー
function QuizTimer({ onTimeUp }) {
  const {
    time,
    formattedTime
  } = useTimer({
    initialTime: 60,
    mode: 'countdown',
    autoStart: true,
    onComplete: onTimeUp
  });
  
  const getTimerColor = () => {
    if (time > 30) return 'green';
    if (time > 10) return 'orange';
    return 'red';
  };
  
  return (
    <div style={{ color: getTimerColor() }}>
      Time remaining: {formattedTime}
    </div>
  );
}

// ワークアウトインターバルタイマー
function IntervalTimer() {
  const [rounds, setRounds] = useState(0);
  const [isWork, setIsWork] = useState(true);
  
  const {
    time,
    isRunning,
    start,
    pause,
    reset,
    setTime,
    formattedTime
  } = useTimer({
    initialTime: 20,
    mode: 'countdown',
    onComplete: () => {
      if (isWork) {
        setIsWork(false);
        setTime(10); // 10秒休憩
        start();
      } else {
        setIsWork(true);
        setRounds(r => r + 1);
        setTime(20); // 20秒運動
        start();
      }
    }
  });
  
  return (
    <div>
      <h2>Interval Training</h2>
      <div>Round: {rounds + 1}</div>
      <div>Phase: {isWork ? '💪 Work' : '😌 Rest'}</div>
      <div className="timer-display">{formattedTime}</div>
      <button onClick={isRunning ? pause : start}>
        {isRunning ? 'Pause' : 'Start'}
      </button>
      <button onClick={() => {
        reset();
        setRounds(0);
        setIsWork(true);
      }}>
        Reset
      </button>
    </div>
  );
}

// セッションタイムアウト警告
function SessionTimeout() {
  const [showWarning, setShowWarning] = useState(false);
  
  const { time, reset } = useTimer({
    initialTime: 600, // 10分
    mode: 'countdown',
    autoStart: true,
    onComplete: () => {
      // セッション終了処理
      logout();
    }
  });
  
  useEffect(() => {
    if (time <= 60 && time > 0) {
      setShowWarning(true);
    }
  }, [time]);
  
  const extendSession = () => {
    reset();
    setShowWarning(false);
  };
  
  return (
    <>
      {showWarning && (
        <div className="warning-modal">
          <p>Your session will expire in {time} seconds</p>
          <button onClick={extendSession}>Extend Session</button>
        </div>
      )}
    </>
  );
}