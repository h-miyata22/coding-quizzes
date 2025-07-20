// 使用例

// キャッシュマネージャーのインスタンス作成
const cache1 = new CacheManager();

// 最大キャッシュ数を設定
cache1.setMaxSize(3);

// APIレスポンスをキャッシュ（TTL: 5秒）
cache1.set('user:123', { id: 123, name: 'Alice' }, 5);
cache1.set('user:456', { id: 456, name: 'Bob' }, 10);

// キャッシュからデータ取得
console.log(cache1.get('user:123')); // { id: 123, name: 'Alice' }
console.log(cache1.get('user:789')); // undefined（存在しない）

// キャッシュの存在確認
console.log(cache1.has('user:123')); // true
console.log(cache1.has('user:789')); // false

// 別の場所でインスタンス化（同じインスタンスが返される）
const cache2 = new CacheManager();
console.log(cache2.get('user:123')); // { id: 123, name: 'Alice' }
console.log(cache1 === cache2); // true

// 追加のキャッシュ（LRU動作確認）
cache1.set('user:789', { id: 789, name: 'Charlie' }, 10);
cache1.set('user:101', { id: 101, name: 'David' }, 10); // 最大数超過

// user:456が最も使われていないので削除される
console.log(cache1.has('user:456')); // false
console.log(cache1.size()); // 3

// user:123にアクセスして使用時刻を更新
cache1.get('user:123');

// 新しいキャッシュを追加
cache1.set('user:202', { id: 202, name: 'Eve' }, 10);
// user:789が削除される（user:123はアクセスしたので残る）
console.log(cache1.has('user:789')); // false
console.log(cache1.has('user:123')); // true

// 5秒後（TTL期限切れ）
setTimeout(() => {
  console.log(cache1.get('user:123')); // undefined（期限切れ）
  console.log(cache1.has('user:123')); // false
  console.log(cache1.size()); // 2
}, 5000);

// 特定のキャッシュを削除
cache1.delete('user:101');
console.log(cache1.size()); // 1

// すべてクリア
cache1.clear();
console.log(cache1.size()); // 0