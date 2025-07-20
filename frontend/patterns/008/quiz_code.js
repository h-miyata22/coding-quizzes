// 使用例
const initialState = {
  user: {
    name: 'Guest',
    isLoggedIn: false
  },
  cart: {
    items: [],
    total: 0
  },
  ui: {
    isLoading: false,
    theme: 'light'
  }
};

const store = createStore(initialState);

// 状態の取得
console.log(store.getState().user.name); // 'Guest'

// 状態変更の購読
const unsubscribe1 = store.subscribe((newState, oldState) => {
  console.log('State changed:', { newState, oldState });
});

const unsubscribe2 = store.subscribe((newState) => {
  console.log('Cart total:', newState.cart.total);
});

// 状態の更新（部分更新）
store.setState({
  user: {
    name: 'Alice',
    isLoggedIn: true
  }
});
// Output: State changed: { newState: {...}, oldState: {...} }
// Output: Cart total: 0

// カートの更新
store.setState({
  cart: {
    items: [{id: 1, name: 'Book', price: 1000}],
    total: 1000
  }
});
// Output: State changed: { newState: {...}, oldState: {...} }
// Output: Cart total: 1000

// UIの更新
store.setState({
  ui: {
    isLoading: true,
    theme: 'dark'
  }
});

// 購読解除
unsubscribe1();

// 再度更新（unsubscribe1は呼ばれない）
store.setState({
  ui: {
    isLoading: false,
    theme: 'dark'
  }
});
// Output: Cart total: 1000 (unsubscribe2のみ)

// 初期状態にリセット
store.reset();
// Output: Cart total: 0

// 状態の直接変更は防がれる
const state = store.getState();
state.user.name = 'Bob'; // エラーまたは無効
console.log(store.getState().user.name); // 'Guest'（変更されない）