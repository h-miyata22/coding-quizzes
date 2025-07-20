const watchers = new WeakMap();

function createReactiveObject(initialData) {
  function makeReactive(obj) {
    if (typeof obj !== 'object' || obj === null) {
      return obj;
    }
    
    // 既にProxyでラップされている場合はそのまま返す
    if (watchers.has(obj)) {
      return obj;
    }
    
    const proxy = new Proxy(obj, {
      get(target, property) {
        const value = target[property];
        
        // ネストしたオブジェクトもリアクティブにする
        if (typeof value === 'object' && value !== null) {
          return makeReactive(value);
        }
        
        return value;
      },
      
      set(target, property, newValue) {
        const oldValue = target[property];
        
        // 値が変更されていない場合は何もしない
        if (oldValue === newValue) {
          return true;
        }
        
        // 値を更新
        target[property] = newValue;
        
        // ウォッチャーに通知
        const objectWatchers = watchers.get(proxy);
        if (objectWatchers && objectWatchers[property]) {
          objectWatchers[property].forEach(callback => {
            callback(newValue, oldValue, property);
          });
        }
        
        return true;
      }
    });
    
    // このオブジェクトのウォッチャーを初期化
    watchers.set(proxy, {});
    
    return proxy;
  }
  
  return makeReactive(initialData);
}

function watch(object, property, callback) {
  if (!watchers.has(object)) {
    throw new Error('オブジェクトはリアクティブではありません');
  }
  
  const objectWatchers = watchers.get(object);
  
  if (!objectWatchers[property]) {
    objectWatchers[property] = [];
  }
  
  objectWatchers[property].push(callback);
}

function unwatch(object, property, callback) {
  const objectWatchers = watchers.get(object);
  
  if (!objectWatchers || !objectWatchers[property]) {
    return;
  }
  
  objectWatchers[property] = objectWatchers[property].filter(
    cb => cb !== callback
  );
  
  if (objectWatchers[property].length === 0) {
    delete objectWatchers[property];
  }
}