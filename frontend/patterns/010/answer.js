function createUIComponent(type, config) {
  // ボタンコンポーネントクラス
  class Button {
    constructor(config) {
      this.config = {
        text: '',
        variant: 'default',
        size: 'medium',
        onClick: null,
        ...config
      };
      this.listeners = [];
    }
    
    render() {
      const classes = ['btn', `btn-${this.config.variant}`, `btn-${this.config.size}`];
      return `<button class="${classes.join(' ')}">${this.config.text}</button>`;
    }
    
    update(newConfig) {
      this.config = { ...this.config, ...newConfig };
    }
    
    destroy() {
      this.listeners.forEach(({ element, event, handler }) => {
        element.removeEventListener(event, handler);
      });
      this.listeners = [];
    }
  }
  
  // カードコンポーネントクラス
  class Card {
    constructor(config) {
      this.config = {
        title: '',
        content: '',
        footer: '',
        variant: 'default',
        ...config
      };
    }
    
    render() {
      const classes = ['card', `card-${this.config.variant}`];
      let html = `<div class="${classes.join(' ')}">`;
      
      if (this.config.title) {
        html += `<div class="card-header">${this.config.title}</div>`;
      }
      if (this.config.content) {
        html += `<div class="card-body">${this.config.content}</div>`;
      }
      if (this.config.footer) {
        html += `<div class="card-footer">${this.config.footer}</div>`;
      }
      
      html += '</div>';
      return html;
    }
    
    update(newConfig) {
      this.config = { ...this.config, ...newConfig };
    }
    
    destroy() {
      // カードの場合は特別なクリーンアップは不要
    }
  }
  
  // モーダルコンポーネントクラス
  class Modal {
    constructor(config) {
      this.config = {
        title: '',
        content: '',
        isOpen: false,
        onConfirm: null,
        onCancel: null,
        ...config
      };
    }
    
    render() {
      const display = this.config.isOpen ? 'block' : 'none';
      return `<div class="modal" style="display: ${display};">
        <div class="modal-dialog">
          <div class="modal-content">
            <div class="modal-header">
              <h5 class="modal-title">${this.config.title}</h5>
            </div>
            <div class="modal-body">${this.config.content}</div>
            <div class="modal-footer">
              <button class="btn btn-secondary">Cancel</button>
              <button class="btn btn-primary">Confirm</button>
            </div>
          </div>
        </div>
      </div>`;
    }
    
    update(newConfig) {
      this.config = { ...this.config, ...newConfig };
    }
    
    destroy() {
      // モーダルのイベントリスナーをクリーンアップ
    }
  }
  
  // ファクトリーマップ
  const componentFactories = {
    button: Button,
    card: Card,
    modal: Modal
  };
  
  // コンポーネントタイプの検証
  if (!componentFactories[type]) {
    throw new Error(`Unknown component type: ${type}`);
  }
  
  // 適切なコンポーネントを生成して返す
  const ComponentClass = componentFactories[type];
  return new ComponentClass(config);
}