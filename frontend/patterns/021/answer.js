import React, { createContext, useContext, useState, useId } from 'react';

// Toggle Context
const ToggleContext = createContext();

// Custom hook to use Toggle context
const useToggleContext = () => {
  const context = useContext(ToggleContext);
  if (!context) {
    throw new Error('Toggle components must be used within a Toggle');
  }
  return context;
};

// Parent Toggle component
function Toggle({ 
  children, 
  defaultChecked = false, 
  checked: controlledChecked,
  onChange,
  onToggle,
  disabled = false,
  className = ''
}) {
  const [internalChecked, setInternalChecked] = useState(defaultChecked);
  const id = useId();
  
  // Determine if component is controlled
  const isControlled = controlledChecked !== undefined;
  const checked = isControlled ? controlledChecked : internalChecked;
  
  const handleToggle = (newValue) => {
    if (disabled) return;
    
    if (!isControlled) {
      setInternalChecked(newValue);
    }
    
    // Call callbacks
    onChange?.(newValue);
    onToggle?.(newValue);
  };
  
  const contextValue = {
    checked,
    disabled,
    id,
    toggle: () => handleToggle(!checked),
    setChecked: handleToggle
  };
  
  return (
    <ToggleContext.Provider value={contextValue}>
      <div className={`toggle-container ${className}`}>
        {children}
      </div>
    </ToggleContext.Provider>
  );
}

// Switch component
Toggle.Switch = function ToggleSwitch({ className = '' }) {
  const { checked, disabled, id, toggle } = useToggleContext();
  
  const handleKeyDown = (e) => {
    if (disabled) return;
    
    // Handle Space and Enter keys
    if (e.key === ' ' || e.key === 'Enter') {
      e.preventDefault();
      toggle();
    }
  };
  
  return (
    <button
      id={id}
      role="switch"
      aria-checked={checked}
      aria-disabled={disabled}
      disabled={disabled}
      onClick={toggle}
      onKeyDown={handleKeyDown}
      className={`toggle-switch ${checked ? 'toggle-switch--checked' : ''} ${disabled ? 'toggle-switch--disabled' : ''} ${className}`}
      type="button"
      style={{
        position: 'relative',
        display: 'inline-block',
        width: '44px',
        height: '24px',
        backgroundColor: checked ? '#4CAF50' : '#ccc',
        borderRadius: '24px',
        border: 'none',
        cursor: disabled ? 'not-allowed' : 'pointer',
        transition: 'background-color 0.2s',
        padding: 0
      }}
    >
      <span
        className="toggle-switch__thumb"
        style={{
          position: 'absolute',
          top: '2px',
          left: checked ? '22px' : '2px',
          width: '20px',
          height: '20px',
          backgroundColor: 'white',
          borderRadius: '50%',
          transition: 'left 0.2s',
          boxShadow: '0 2px 4px rgba(0,0,0,0.2)'
        }}
      />
      <span className="sr-only">
        {checked ? 'On' : 'Off'}
      </span>
    </button>
  );
};

// Label component
Toggle.Label = function ToggleLabel({ children, className = '' }) {
  const { id, disabled } = useToggleContext();
  
  return (
    <label
      htmlFor={id}
      className={`toggle-label ${disabled ? 'toggle-label--disabled' : ''} ${className}`}
      style={{
        cursor: disabled ? 'not-allowed' : 'pointer',
        opacity: disabled ? 0.6 : 1,
        userSelect: 'none'
      }}
    >
      {children}
    </label>
  );
};

// Helper CSS classes for screen readers
const srOnlyStyles = `
.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border-width: 0;
}
`;

// Add styles to document if not already present
if (typeof document !== 'undefined' && !document.getElementById('toggle-sr-styles')) {
  const style = document.createElement('style');
  style.id = 'toggle-sr-styles';
  style.textContent = srOnlyStyles;
  document.head.appendChild(style);
}

export default Toggle;