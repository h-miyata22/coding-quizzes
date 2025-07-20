class EventManager {
  constructor() {
    this.events = {};
    this.subscriberMap = new WeakMap();
  }

  subscribe(subscriber, eventName, callback) {
    // イベントごとのリスナー管理
    if (!this.events[eventName]) {
      this.events[eventName] = [];
    }
    
    // 購読者ごとのリスナー管理
    if (!this.subscriberMap.has(subscriber)) {
      this.subscriberMap.set(subscriber, {});
    }
    
    const subscriberEvents = this.subscriberMap.get(subscriber);
    if (!subscriberEvents[eventName]) {
      subscriberEvents[eventName] = [];
    }
    
    // リスナー情報を保存
    const listenerInfo = { subscriber, callback };
    this.events[eventName].push(listenerInfo);
    subscriberEvents[eventName].push(callback);
  }

  unsubscribe(subscriber, eventName, callback) {
    if (!this.events[eventName]) {
      return;
    }
    
    // イベントリスナーから削除
    this.events[eventName] = this.events[eventName].filter(
      info => !(info.subscriber === subscriber && info.callback === callback)
    );
    
    // 購読者のマップからも削除
    const subscriberEvents = this.subscriberMap.get(subscriber);
    if (subscriberEvents && subscriberEvents[eventName]) {
      subscriberEvents[eventName] = subscriberEvents[eventName].filter(
        cb => cb !== callback
      );
      
      if (subscriberEvents[eventName].length === 0) {
        delete subscriberEvents[eventName];
      }
    }
    
    // イベントリスナーが空になったら削除
    if (this.events[eventName].length === 0) {
      delete this.events[eventName];
    }
  }

  unsubscribeAll(subscriber) {
    const subscriberEvents = this.subscriberMap.get(subscriber);
    if (!subscriberEvents) {
      return;
    }
    
    // 購読者のすべてのイベントをクリーンアップ
    Object.keys(subscriberEvents).forEach(eventName => {
      if (this.events[eventName]) {
        this.events[eventName] = this.events[eventName].filter(
          info => info.subscriber !== subscriber
        );
        
        if (this.events[eventName].length === 0) {
          delete this.events[eventName];
        }
      }
    });
    
    // 購読者をマップから削除
    this.subscriberMap.delete(subscriber);
  }

  emit(eventName, ...args) {
    if (!this.events[eventName]) {
      return;
    }
    
    this.events[eventName].forEach(({ callback }) => {
      callback(...args);
    });
  }
}