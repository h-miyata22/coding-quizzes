class CacheManager {
  constructor() {
    // 既存のインスタンスがあればそれを返す
    if (CacheManager.instance) {
      return CacheManager.instance;
    }
    
    // 初回作成時の処理
    this.cache = new Map();
    this.maxSize = Infinity;
    
    // インスタンスを保存
    CacheManager.instance = this;
  }
  
  get(key) {
    const item = this.cache.get(key);
    
    if (!item) {
      return undefined;
    }
    
    // TTLチェック
    if (item.expiry && Date.now() > item.expiry) {
      this.cache.delete(key);
      return undefined;
    }
    
    // LRUのためアクセス時刻を更新
    item.lastAccessed = Date.now();
    
    // MapはJavaScriptでは挿入順序を保持するので、
    // 削除して再追加することで最後に移動
    this.cache.delete(key);
    this.cache.set(key, item);
    
    return item.value;
  }
  
  set(key, value, ttl = null) {
    // 既存のキーがある場合は削除
    if (this.cache.has(key)) {
      this.cache.delete(key);
    }
    
    // 最大サイズチェック
    if (this.cache.size >= this.maxSize) {
      // 最も古いアイテムを削除（MapのIteratorは挿入順）
      const firstKey = this.cache.keys().next().value;
      this.cache.delete(firstKey);
    }
    
    // 新しいアイテムを追加
    const item = {
      value,
      lastAccessed: Date.now(),
      expiry: ttl ? Date.now() + ttl * 1000 : null
    };
    
    this.cache.set(key, item);
  }
  
  has(key) {
    const item = this.cache.get(key);
    
    if (!item) {
      return false;
    }
    
    // TTLチェック
    if (item.expiry && Date.now() > item.expiry) {
      this.cache.delete(key);
      return false;
    }
    
    return true;
  }
  
  delete(key) {
    return this.cache.delete(key);
  }
  
  clear() {
    this.cache.clear();
  }
  
  size() {
    // 期限切れのアイテムを削除してから正確なサイズを返す
    const keysToDelete = [];
    
    for (const [key, item] of this.cache) {
      if (item.expiry && Date.now() > item.expiry) {
        keysToDelete.push(key);
      }
    }
    
    keysToDelete.forEach(key => this.cache.delete(key));
    
    return this.cache.size;
  }
  
  setMaxSize(size) {
    this.maxSize = size;
    
    // 現在のサイズが最大サイズを超えている場合は古いものから削除
    while (this.cache.size > this.maxSize) {
      const firstKey = this.cache.keys().next().value;
      this.cache.delete(firstKey);
    }
  }
  
  // インスタンスをリセットする静的メソッド（テスト用）
  static resetInstance() {
    CacheManager.instance = null;
  }
}