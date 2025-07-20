function createStore(initialState) {
  // プライベート変数
  let state = deepClone(initialState);
  const listeners = [];
  
  // 深いクローンを作成する関数
  function deepClone(obj) {
    if (obj === null || typeof obj !== 'object') {
      return obj;
    }
    
    if (obj instanceof Date) {
      return new Date(obj.getTime());
    }
    
    if (obj instanceof Array) {
      return obj.map(item => deepClone(item));
    }
    
    const clonedObj = {};
    for (const key in obj) {
      if (obj.hasOwnProperty(key)) {
        clonedObj[key] = deepClone(obj[key]);
      }
    }
    
    return clonedObj;
  }
  
  // 深いマージを行う関数
  function deepMerge(target, source) {
    const result = deepClone(target);
    
    for (const key in source) {
      if (source.hasOwnProperty(key)) {
        if (typeof source[key] === 'object' && source[key] !== null && !Array.isArray(source[key])) {
          result[key] = deepMerge(result[key] || {}, source[key]);
        } else {
          result[key] = deepClone(source[key]);
        }
      }
    }
    
    return result;
  }
  
  // 状態を不変にする関数（簡易版）
  function freeze(obj) {
    Object.freeze(obj);
    Object.getOwnPropertyNames(obj).forEach(prop => {
      if (obj[prop] !== null && (typeof obj[prop] === 'object' || typeof obj[prop] === 'function')) {
        freeze(obj[prop]);
      }
    });
    return obj;
  }
  
  return {
    getState() {
      // 深いクローンを返して直接変更を防ぐ
      return freeze(deepClone(state));
    },
    
    setState(updates) {
      const oldState = state;
      state = deepMerge(state, updates);
      
      // すべてのリスナーに通知
      listeners.forEach(listener => {
        listener(deepClone(state), deepClone(oldState));
      });
    },
    
    subscribe(listener) {
      listeners.push(listener);
      
      // 購読解除関数を返す
      return () => {
        const index = listeners.indexOf(listener);
        if (index > -1) {
          listeners.splice(index, 1);
        }
      };
    },
    
    reset() {
      const oldState = state;
      state = deepClone(initialState);
      
      // リセット時もリスナーに通知
      listeners.forEach(listener => {
        listener(deepClone(state), deepClone(oldState));
      });
    }
  };
}