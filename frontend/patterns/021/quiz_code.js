// 使用例
import React, { useState } from 'react';

// 基本的な使用方法
function BasicToggle() {
  return (
    <Toggle defaultChecked={false}>
      <Toggle.Label>Enable notifications</Toggle.Label>
      <Toggle.Switch />
    </Toggle>
  );
}

// ラベルとスイッチの配置をカスタマイズ
function CustomLayoutToggle() {
  return (
    <Toggle defaultChecked={true}>
      <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
        <Toggle.Switch />
        <Toggle.Label>Dark mode</Toggle.Label>
      </div>
    </Toggle>
  );
}

// 制御されたコンポーネント
function ControlledToggle() {
  const [isEnabled, setIsEnabled] = useState(false);
  
  return (
    <div>
      <Toggle checked={isEnabled} onChange={setIsEnabled}>
        <Toggle.Label>
          Wi-Fi {isEnabled ? 'enabled' : 'disabled'}
        </Toggle.Label>
        <Toggle.Switch />
      </Toggle>
      
      <p>Current state: {isEnabled ? 'ON' : 'OFF'}</p>
      <button onClick={() => setIsEnabled(!isEnabled)}>
        Toggle programmatically
      </button>
    </div>
  );
}

// 複数のトグルを管理
function SettingsPanel() {
  const [settings, setSettings] = useState({
    notifications: true,
    darkMode: false,
    autoSave: true,
    analytics: false
  });
  
  const handleToggle = (setting) => (value) => {
    setSettings(prev => ({ ...prev, [setting]: value }));
  };
  
  return (
    <div className="settings-panel">
      <h2>Preferences</h2>
      
      <Toggle 
        checked={settings.notifications} 
        onChange={handleToggle('notifications')}
      >
        <Toggle.Label>Push Notifications</Toggle.Label>
        <Toggle.Switch />
      </Toggle>
      
      <Toggle 
        checked={settings.darkMode} 
        onChange={handleToggle('darkMode')}
      >
        <Toggle.Label>Dark Theme</Toggle.Label>
        <Toggle.Switch />
      </Toggle>
      
      <Toggle 
        checked={settings.autoSave} 
        onChange={handleToggle('autoSave')}
      >
        <Toggle.Label>Auto-save</Toggle.Label>
        <Toggle.Switch />
      </Toggle>
      
      <Toggle 
        checked={settings.analytics} 
        onChange={handleToggle('analytics')}
      >
        <Toggle.Label>Analytics</Toggle.Label>
        <Toggle.Switch />
      </Toggle>
    </div>
  );
}

// カスタムスタイリング
function StyledToggle() {
  return (
    <Toggle defaultChecked={false} className="custom-toggle">
      <Toggle.Label className="toggle-label">
        <span className="label-text">Airplane Mode</span>
        <span className="label-icon">✈️</span>
      </Toggle.Label>
      <Toggle.Switch className="toggle-switch" />
    </Toggle>
  );
}

// Disabled状態
function DisabledToggle() {
  const [isLocked, setIsLocked] = useState(true);
  
  return (
    <div>
      <Toggle defaultChecked={true} disabled={isLocked}>
        <Toggle.Label>System settings (locked)</Toggle.Label>
        <Toggle.Switch />
      </Toggle>
      
      <button onClick={() => setIsLocked(!isLocked)}>
        {isLocked ? 'Unlock' : 'Lock'} settings
      </button>
    </div>
  );
}

// onToggleコールバックでのロギング
function LoggingToggle() {
  const handleToggle = (isChecked) => {
    console.log(`Toggle changed to: ${isChecked ? 'ON' : 'OFF'}`);
    // Analytics tracking, API calls, etc.
  };
  
  return (
    <Toggle defaultChecked={false} onToggle={handleToggle}>
      <Toggle.Label>Enable experimental features</Toggle.Label>
      <Toggle.Switch />
    </Toggle>
  );
}

// 説明テキスト付きトグル
function DescriptiveToggle() {
  return (
    <Toggle defaultChecked={false}>
      <div>
        <Toggle.Label>Location Services</Toggle.Label>
        <p style={{ margin: '4px 0', fontSize: '0.875rem', color: '#666' }}>
          Allow apps to access your location
        </p>
      </div>
      <Toggle.Switch />
    </Toggle>
  );
}