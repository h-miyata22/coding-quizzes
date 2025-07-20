// 使用例
import React from 'react';

// モーダルコンポーネントでの使用
function ModalExample() {
  const [isOpen, { toggle, setOn, setOff }] = useToggle(false);
  
  return (
    <div>
      <button onClick={setOn}>Open Modal</button>
      {isOpen && (
        <div className="modal">
          <h2>Modal Content</h2>
          <button onClick={setOff}>Close</button>
          <button onClick={toggle}>Toggle</button>
        </div>
      )}
    </div>
  );
}

// メニューコンポーネントでの使用
function MenuExample() {
  const [isMenuOpen, { toggle: toggleMenu }] = useToggle();
  
  return (
    <nav>
      <button onClick={toggleMenu}>
        {isMenuOpen ? '✕' : '☰'} Menu
      </button>
      {isMenuOpen && (
        <ul>
          <li>Home</li>
          <li>About</li>
          <li>Contact</li>
        </ul>
      )}
    </nav>
  );
}

// ダークモードでの使用
function ThemeToggle() {
  const [isDarkMode, { toggle, setValue }] = useToggle(
    localStorage.getItem('darkMode') === 'true'
  );
  
  React.useEffect(() => {
    localStorage.setItem('darkMode', isDarkMode);
    document.body.classList.toggle('dark-mode', isDarkMode);
  }, [isDarkMode]);
  
  return (
    <div>
      <button onClick={toggle}>
        {isDarkMode ? '🌙' : '☀️'} Toggle Theme
      </button>
      <button onClick={() => setValue(true)}>Force Dark</button>
      <button onClick={() => setValue(false)}>Force Light</button>
    </div>
  );
}

// 複数のトグルを組み合わせた使用
function SettingsPanel() {
  const [showAdvanced, advancedControls] = useToggle();
  const [autoSave, autoSaveControls] = useToggle(true);
  const [notifications, notifControls] = useToggle(true);
  
  return (
    <div>
      <h3>Settings</h3>
      
      <label>
        <input
          type="checkbox"
          checked={autoSave}
          onChange={autoSaveControls.toggle}
        />
        Auto-save
      </label>
      
      <label>
        <input
          type="checkbox"
          checked={notifications}
          onChange={notifControls.toggle}
        />
        Enable notifications
      </label>
      
      <button onClick={advancedControls.toggle}>
        {showAdvanced ? 'Hide' : 'Show'} Advanced Options
      </button>
      
      {showAdvanced && (
        <div>
          <button onClick={() => {
            autoSaveControls.setOff();
            notifControls.setOff();
          }}>
            Disable All
          </button>
        </div>
      )}
    </div>
  );
}