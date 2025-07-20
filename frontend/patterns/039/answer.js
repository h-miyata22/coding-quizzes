import React, { useState, useRef, useEffect } from 'react';

// TaskItemの実装（メモ化なし - 比較用）
function TaskItemWithoutMemo({ task, onToggle, onDelete }) {
  const renderCount = useRef(0);
  renderCount.current += 1;

  return (
    <div style={{
      display: 'flex',
      alignItems: 'center',
      padding: '10px',
      marginBottom: '10px',
      background: '#f5f5f5',
      borderRadius: '4px',
      border: '1px solid #ddd'
    }}>
      <input
        type="checkbox"
        checked={task.completed}
        onChange={() => onToggle(task.id)}
        style={{ marginRight: '10px' }}
      />
      <span style={{
        flex: 1,
        textDecoration: task.completed ? 'line-through' : 'none',
        color: task.completed ? '#999' : '#333'
      }}>
        {task.text}
      </span>
      <span style={{
        fontSize: '12px',
        color: '#666',
        marginRight: '10px'
      }}>
        Renders: {renderCount.current}
      </span>
      <button
        onClick={() => onDelete(task.id)}
        style={{
          padding: '4px 8px',
          background: '#ff4444',
          color: 'white',
          border: 'none',
          borderRadius: '4px',
          cursor: 'pointer'
        }}
      >
        Delete
      </button>
    </div>
  );
}

// 最適化されたTaskItem（React.memo使用）
const TaskItem = React.memo(
  function TaskItem({ task, onToggle, onDelete }) {
    const renderCount = useRef(0);
    renderCount.current += 1;

    // レンダリング時に視覚的なフィードバック
    const [justRendered, setJustRendered] = useState(false);
    useEffect(() => {
      setJustRendered(true);
      const timer = setTimeout(() => setJustRendered(false), 300);
      return () => clearTimeout(timer);
    });

    return (
      <div style={{
        display: 'flex',
        alignItems: 'center',
        padding: '10px',
        marginBottom: '10px',
        background: justRendered ? '#e3f2fd' : '#f5f5f5',
        borderRadius: '4px',
        border: '1px solid #ddd',
        transition: 'background 0.3s ease'
      }}>
        <input
          type="checkbox"
          checked={task.completed}
          onChange={() => onToggle(task.id)}
          style={{ marginRight: '10px' }}
        />
        <span style={{
          flex: 1,
          textDecoration: task.completed ? 'line-through' : 'none',
          color: task.completed ? '#999' : '#333'
        }}>
          {task.text}
        </span>
        <span style={{
          fontSize: '12px',
          color: justRendered ? '#2196f3' : '#666',
          marginRight: '10px',
          fontWeight: justRendered ? 'bold' : 'normal'
        }}>
          Renders: {renderCount.current}
        </span>
        <button
          onClick={() => onDelete(task.id)}
          style={{
            padding: '4px 8px',
            background: '#ff4444',
            color: 'white',
            border: 'none',
            borderRadius: '4px',
            cursor: 'pointer'
          }}
        >
          Delete
        </button>
      </div>
    );
  },
  // カスタム比較関数
  (prevProps, nextProps) => {
    // タスクの内容が同じで、かつ関数参照も同じ場合は再レンダリングしない
    return (
      prevProps.task.id === nextProps.task.id &&
      prevProps.task.text === nextProps.task.text &&
      prevProps.task.completed === nextProps.task.completed &&
      prevProps.onToggle === nextProps.onToggle &&
      prevProps.onDelete === nextProps.onDelete
    );
  }
);

// より高度な実装（useCallbackと組み合わせ）
function OptimizedTaskList() {
  const [tasks, setTasks] = useState([
    { id: 1, text: 'Learn React', completed: false },
    { id: 2, text: 'Build an app', completed: false },
    { id: 3, text: 'Deploy to production', completed: false },
    { id: 4, text: 'Write documentation', completed: true },
    { id: 5, text: 'Add tests', completed: false }
  ]);

  const [inputValue, setInputValue] = useState('');

  // useCallbackで関数の参照を保持
  const toggleTask = React.useCallback((id) => {
    setTasks(prevTasks => 
      prevTasks.map(task => 
        task.id === id ? { ...task, completed: !task.completed } : task
      )
    );
  }, []);

  const deleteTask = React.useCallback((id) => {
    setTasks(prevTasks => prevTasks.filter(task => task.id !== id));
  }, []);

  const addTask = () => {
    if (inputValue.trim()) {
      setTasks([...tasks, {
        id: Date.now(),
        text: inputValue,
        completed: false
      }]);
      setInputValue('');
    }
  };

  return (
    <div style={{ maxWidth: '600px', margin: '0 auto', padding: '20px' }}>
      <h1>Optimized Task Manager</h1>
      
      <div style={{ marginBottom: '20px' }}>
        <input
          type="text"
          value={inputValue}
          onChange={(e) => setInputValue(e.target.value)}
          onKeyPress={(e) => e.key === 'Enter' && addTask()}
          placeholder="Add new task..."
          style={{ padding: '8px', width: '70%' }}
        />
        <button onClick={addTask} style={{ padding: '8px 16px', marginLeft: '10px' }}>
          Add Task
        </button>
      </div>

      <div>
        {tasks.map(task => (
          <TaskItem
            key={task.id}
            task={task}
            onToggle={toggleTask}
            onDelete={deleteTask}
          />
        ))}
      </div>

      <div style={{ marginTop: '20px', fontSize: '12px', color: '#666' }}>
        <p>✅ Optimized with React.memo and useCallback</p>
        <p>💡 Blue highlight = component just rendered</p>
        <p>📊 Watch render counts - only modified tasks re-render!</p>
      </div>
    </div>
  );
}

export default TaskItem;