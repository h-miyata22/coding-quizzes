// 使用例
const state = createReactiveObject({
  user: {
    name: 'Alice',
    age: 25
  },
  settings: {
    theme: 'light',
    notifications: true
  }
});

// ユーザー名の変更を監視
watch(state.user, 'name', (newValue, oldValue, property) => {
  console.log(`${property} changed from ${oldValue} to ${newValue}`);
});

// テーマの変更を監視
watch(state.settings, 'theme', (newValue, oldValue) => {
  console.log(`Theme changed to ${newValue}`);
  document.body.className = `theme-${newValue}`;
});

// 年齢の変更を監視（複数のウォッチャー）
const ageLogger = (newValue) => console.log(`Age is now ${newValue}`);
const ageValidator = (newValue) => {
  if (newValue < 0) console.error('Age cannot be negative!');
};

watch(state.user, 'age', ageLogger);
watch(state.user, 'age', ageValidator);

// 値を変更
state.user.name = 'Bob';        // Output: name changed from Alice to Bob
state.settings.theme = 'dark';   // Output: Theme changed to dark
state.user.age = 30;            // Output: Age is now 30

// ウォッチャーを解除
unwatch(state.user, 'age', ageLogger);
state.user.age = 35;            // ageValidatorのみ実行される

// ネストしたオブジェクトも動作
state.user.name = 'Charlie';    // Output: name changed from Bob to Charlie