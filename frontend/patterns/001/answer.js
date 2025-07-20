class EventEmitter {
  constructor() {
    this.events = {};
  }

  on(eventName, callback) {
    if (!this.events[eventName]) {
      this.events[eventName] = [];
    }
    this.events[eventName].push(callback);
  }

  off(eventName, callback) {
    if (!this.events[eventName]) {
      return;
    }
    
    this.events[eventName] = this.events[eventName].filter(
      cb => cb !== callback
    );
    
    if (this.events[eventName].length === 0) {
      delete this.events[eventName];
    }
  }

  emit(eventName, ...args) {
    if (!this.events[eventName]) {
      return;
    }
    
    this.events[eventName].forEach(callback => {
      callback(...args);
    });
  }
}