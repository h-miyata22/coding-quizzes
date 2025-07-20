// 使用例
import React, { useState } from 'react';

// TaskItem コンポーネントを React.memo で最適化してください
// 以下の要件を満たす必要があります：
// - 不要な再レンダリングを防ぐ
// - カスタム比較関数の実装
// - レンダリング回数の表示

function TaskItem({ task, onToggle, onDelete }) {
  // 実装してください
  // ヒント: React.memoを使用し、適切な比較関数を定義する
}

// 期待される使用方法
function TaskList() {
  const [tasks, setTasks] = useState([
    { id: 1, text: 'Learn React', completed: false },
    { id: 2, text: 'Build an app', completed: false },
    { id: 3, text: 'Deploy to production', completed: false },
    { id: 4, text: 'Write documentation', completed: true },
    { id: 5, text: 'Add tests', completed: false }
  ]);

  const [inputValue, setInputValue] = useState('');

  const toggleTask = (id) => {
    setTasks(tasks.map(task => 
      task.id === id ? { ...task, completed: !task.completed } : task
    ));
  };

  const deleteTask = (id) => {
    setTasks(tasks.filter(task => task.id !== id));
  };

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
      <h1>Task Manager</h1>
      
      <div style={{ marginBottom: '20px' }}>
        <input
          type="text"
          value={inputValue}
          onChange={(e) => setInputValue(e.target.value)}
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
        Tip: Watch the render count next to each task. 
        Only the modified task should re-render!
      </div>
    </div>
  );
}

export default TaskList;