// 使用例
function App() {
  return (
    <div style={{ maxWidth: '600px', margin: '40px auto', padding: '20px' }}>
      <h1>TODOリスト</h1>
      <TodoList />
    </div>
  );
}

// 初期データの例（実装時に使用可能）
const initialTodos = [
  { id: 1, text: 'Reactの勉強をする', completed: false },
  { id: 2, text: '買い物に行く', completed: true },
  { id: 3, text: 'コードレビューを依頼する', completed: false }
];

// TodoListコンポーネントを実装してください