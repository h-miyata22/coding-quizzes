function createNamespace(rootName) {
  const root = {};
  
  function ensurePath(obj, path) {
    const parts = path.split('.');
    let current = obj;
    
    for (let i = 0; i < parts.length - 1; i++) {
      const part = parts[i];
      if (!current[part]) {
        current[part] = {};
      }
      current = current[part];
    }
    
    return {
      parent: current,
      key: parts[parts.length - 1]
    };
  }
  
  function getByPath(obj, path) {
    const parts = path.split('.');
    let current = obj;
    
    for (const part of parts) {
      if (!current || typeof current !== 'object') {
        return undefined;
      }
      current = current[part];
    }
    
    return current;
  }
  
  const namespace = {
    define(path, module) {
      if (this.exists(path)) {
        throw new Error(`Module ${path} already exists`);
      }
      
      const { parent, key } = ensurePath(root, path);
      parent[key] = module;
      
      // 親パスにもアクセスできるようにする
      const parts = path.split('.');
      let current = root;
      for (let i = 0; i < parts.length; i++) {
        const subPath = parts.slice(0, i + 1).join('.');
        const subObj = getByPath(root, subPath);
        if (subObj && typeof subObj === 'object') {
          // 各レベルで子要素にアクセスできるようにする
          Object.keys(subObj).forEach(key => {
            if (typeof subObj[key] === 'object' && !Array.isArray(subObj[key])) {
              // 子オブジェクトへの参照を維持
            }
          });
        }
      }
    },
    
    get(path) {
      if (!path) {
        return root;
      }
      return getByPath(root, path);
    },
    
    exists(path) {
      return getByPath(root, path) !== undefined;
    }
  };
  
  // ルート名前空間を設定
  if (rootName && typeof window !== 'undefined') {
    window[rootName] = namespace;
  }
  
  return namespace;
}