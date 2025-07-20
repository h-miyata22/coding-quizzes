class CustomEventSystem {
  constructor() {
    this.listeners = new WeakMap();
  }

  addEventListener(element, eventType, handler, useCapture = false) {
    if (!this.listeners.has(element)) {
      this.listeners.set(element, {});
    }
    
    const elementListeners = this.listeners.get(element);
    const phase = useCapture ? 'capture' : 'bubble';
    const key = `${eventType}_${phase}`;
    
    if (!elementListeners[key]) {
      elementListeners[key] = [];
    }
    
    elementListeners[key].push(handler);
  }

  removeEventListener(element, eventType, handler, useCapture = false) {
    const elementListeners = this.listeners.get(element);
    if (!elementListeners) {
      return;
    }
    
    const phase = useCapture ? 'capture' : 'bubble';
    const key = `${eventType}_${phase}`;
    
    if (elementListeners[key]) {
      elementListeners[key] = elementListeners[key].filter(h => h !== handler);
      
      if (elementListeners[key].length === 0) {
        delete elementListeners[key];
      }
    }
  }

  dispatchEvent(element, event) {
    const path = this._getEventPath(element);
    
    // キャプチャフェーズ（実装は省略）
    
    // バブリングフェーズ
    for (const currentElement of path) {
      if (event._propagationStopped) {
        break;
      }
      
      event.currentTarget = currentElement;
      
      const elementListeners = this.listeners.get(currentElement);
      if (elementListeners) {
        const key = `${event.type}_bubble`;
        const handlers = elementListeners[key];
        
        if (handlers) {
          handlers.forEach(handler => {
            if (!event._propagationStopped) {
              handler(event);
            }
          });
        }
      }
    }
  }

  _getEventPath(element) {
    const path = [];
    let current = element;
    
    while (current) {
      path.push(current);
      current = current.parent;
    }
    
    return path;
  }
}