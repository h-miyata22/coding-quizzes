import React, { createContext, useContext, useState, useEffect, useRef } from 'react';

// Tabsコンテキスト
const TabsContext = createContext();

// メインのTabsコンポーネント
function Tabs({ 
  children, 
  defaultValue, 
  value, 
  onChange,
  orientation = 'horizontal'
}) {
  const [selectedValue, setSelectedValue] = useState(
    value !== undefined ? value : defaultValue
  );
  
  // 制御/非制御の切り替え
  const isControlled = value !== undefined;
  const currentValue = isControlled ? value : selectedValue;
  
  const handleChange = (newValue) => {
    if (!isControlled) {
      setSelectedValue(newValue);
    }
    if (onChange) {
      onChange(newValue);
    }
  };
  
  const contextValue = {
    selectedValue: currentValue,
    onChange: handleChange,
    orientation
  };
  
  return (
    <TabsContext.Provider value={contextValue}>
      <div className="tabs" data-orientation={orientation}>
        {children}
      </div>
    </TabsContext.Provider>
  );
}

// Tabs.List コンポーネント
Tabs.List = function TabsList({ children, className = '', ...props }) {
  const { orientation } = useContext(TabsContext);
  const listRef = useRef(null);
  
  // キーボードナビゲーション
  const handleKeyDown = (e) => {
    const tabs = Array.from(
      listRef.current.querySelectorAll('[role="tab"]:not([disabled])')
    );
    const currentIndex = tabs.findIndex(tab => tab === document.activeElement);
    
    let nextIndex;
    
    if (orientation === 'horizontal') {
      if (e.key === 'ArrowRight') {
        nextIndex = (currentIndex + 1) % tabs.length;
      } else if (e.key === 'ArrowLeft') {
        nextIndex = (currentIndex - 1 + tabs.length) % tabs.length;
      }
    } else {
      if (e.key === 'ArrowDown') {
        nextIndex = (currentIndex + 1) % tabs.length;
      } else if (e.key === 'ArrowUp') {
        nextIndex = (currentIndex - 1 + tabs.length) % tabs.length;
      }
    }
    
    if (nextIndex !== undefined) {
      e.preventDefault();
      tabs[nextIndex].focus();
      tabs[nextIndex].click();
    }
  };
  
  return (
    <div
      ref={listRef}
      role="tablist"
      className={`tabs-list ${className}`}
      onKeyDown={handleKeyDown}
      aria-orientation={orientation}
      {...props}
    >
      {children}
    </div>
  );
};

// Tabs.Tab コンポーネント
Tabs.Tab = function TabsTab({ 
  children, 
  value, 
  disabled = false,
  className = '',
  ...props 
}) {
  const { selectedValue, onChange } = useContext(TabsContext);
  const isSelected = selectedValue === value;
  
  const handleClick = () => {
    if (!disabled) {
      onChange(value);
    }
  };
  
  return (
    <button
      role="tab"
      className={`tabs-tab ${className}`}
      aria-selected={isSelected}
      aria-controls={`panel-${value}`}
      tabIndex={isSelected ? 0 : -1}
      onClick={handleClick}
      disabled={disabled}
      data-state={isSelected ? 'active' : 'inactive'}
      {...props}
    >
      {children}
    </button>
  );
};

// Tabs.Panels コンポーネント
Tabs.Panels = function TabsPanels({ children, className = '', ...props }) {
  return (
    <div className={`tabs-panels ${className}`} {...props}>
      {children}
    </div>
  );
};

// Tabs.Panel コンポーネント
Tabs.Panel = function TabsPanel({ 
  children, 
  value,
  className = '',
  ...props 
}) {
  const { selectedValue } = useContext(TabsContext);
  const isSelected = selectedValue === value;
  
  return (
    <div
      role="tabpanel"
      id={`panel-${value}`}
      className={`tabs-panel ${className}`}
      hidden={!isSelected}
      data-state={isSelected ? 'active' : 'inactive'}
      tabIndex={0}
      {...props}
    >
      {isSelected && children}
    </div>
  );
};

export default Tabs;