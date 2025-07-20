class AppConfig {
  constructor(defaultConfig = {}) {
    // 既存のインスタンスがあればそれを返す
    if (AppConfig.instance) {
      return AppConfig.instance;
    }
    
    // 初回作成時の処理
    this.defaultConfig = { ...defaultConfig };
    this.config = { ...defaultConfig };
    this.listeners = [];
    this.isFrozen = false;
    
    // インスタンスを保存
    AppConfig.instance = this;
    
    // インスタンスをフリーズして変更を防ぐ
    Object.freeze(this);
  }
  
  get(key) {
    return this.config[key];
  }
  
  set(key, value) {
    if (this.isFrozen) {
      throw new Error('Configuration is frozen and cannot be modified');
    }
    
    const oldValue = this.config[key];
    if (oldValue === value) {
      return;
    }
    
    this.config[key] = value;
    this._notifyListeners(key, value, oldValue);
  }
  
  update(newConfig) {
    if (this.isFrozen) {
      throw new Error('Configuration is frozen and cannot be modified');
    }
    
    Object.entries(newConfig).forEach(([key, value]) => {
      const oldValue = this.config[key];
      if (oldValue !== value) {
        this.config[key] = value;
        this._notifyListeners(key, value, oldValue);
      }
    });
  }
  
  onChange(callback) {
    this.listeners.push(callback);
    
    // 購読解除関数を返す
    return () => {
      const index = this.listeners.indexOf(callback);
      if (index > -1) {
        this.listeners.splice(index, 1);
      }
    };
  }
  
  freeze() {
    this.isFrozen = true;
  }
  
  reset() {
    this.isFrozen = false;
    const oldConfig = { ...this.config };
    this.config = { ...this.defaultConfig };
    
    // すべての変更を通知
    Object.entries(this.config).forEach(([key, value]) => {
      const oldValue = oldConfig[key];
      if (oldValue !== value) {
        this._notifyListeners(key, value, oldValue);
      }
    });
  }
  
  _notifyListeners(key, newValue, oldValue) {
    this.listeners.forEach(callback => {
      callback(key, newValue, oldValue);
    });
  }
  
  // インスタンスをリセットする静的メソッド（テスト用）
  static resetInstance() {
    AppConfig.instance = null;
  }
}

// ES6モジュールとしてエクスポート
export { AppConfig };