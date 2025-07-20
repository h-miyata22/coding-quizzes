// 使用例

// ボタンコンポーネントの作成
const primaryButton = createUIComponent('button', {
  text: 'Click Me',
  variant: 'primary',
  size: 'medium',
  onClick: () => console.log('Button clicked!')
});

// レンダリング
console.log(primaryButton.render());
// Output: <button class="btn btn-primary btn-medium">Click Me</button>

// 更新
primaryButton.update({
  text: 'Updated Text',
  variant: 'secondary'
});
console.log(primaryButton.render());
// Output: <button class="btn btn-secondary btn-medium">Updated Text</button>

// カードコンポーネントの作成
const userCard = createUIComponent('card', {
  title: 'User Profile',
  content: 'John Doe - Software Engineer',
  footer: 'Last updated: Today',
  variant: 'elevated'
});

console.log(userCard.render());
// Output: 
// <div class="card card-elevated">
//   <div class="card-header">User Profile</div>
//   <div class="card-body">John Doe - Software Engineer</div>
//   <div class="card-footer">Last updated: Today</div>
// </div>

// モーダルコンポーネントの作成
const confirmModal = createUIComponent('modal', {
  title: 'Confirm Action',
  content: 'Are you sure you want to proceed?',
  isOpen: false,
  onConfirm: () => console.log('Confirmed!'),
  onCancel: () => console.log('Cancelled!')
});

console.log(confirmModal.render());
// Output: <div class="modal" style="display: none;">...</div>

// モーダルを開く
confirmModal.update({ isOpen: true });
console.log(confirmModal.render());
// Output: <div class="modal" style="display: block;">...</div>

// 複数のボタンを作成（それぞれ独立した状態を持つ）
const button1 = createUIComponent('button', { text: 'Button 1' });
const button2 = createUIComponent('button', { text: 'Button 2' });

button1.update({ text: 'Updated 1' });
console.log(button1.render()); // Button 1のみ更新される
console.log(button2.render()); // Button 2は変更なし

// 無効なタイプ
try {
  const invalid = createUIComponent('invalid', {});
} catch (error) {
  console.error(error.message); // 'Unknown component type: invalid'
}

// コンポーネントの破棄
primaryButton.destroy(); // イベントリスナーの削除など