import React, { createContext, useContext, useState, useRef, useEffect, useId } from 'react';

// Dropdown Context
const DropdownContext = createContext();

// Custom hook to use Dropdown context
const useDropdownContext = () => {
  const context = useContext(DropdownContext);
  if (!context) {
    throw new Error('Dropdown components must be used within a Dropdown');
  }
  return context;
};

// Parent Dropdown component
function Dropdown({ 
  children, 
  open: controlledOpen,
  onOpenChange,
  className = ''
}) {
  const [internalOpen, setInternalOpen] = useState(false);
  const dropdownRef = useRef(null);
  const triggerId = useId();
  const menuId = useId();
  
  // Determine if component is controlled
  const isControlled = controlledOpen !== undefined;
  const isOpen = isControlled ? controlledOpen : internalOpen;
  
  const setOpen = (newOpen) => {
    if (!isControlled) {
      setInternalOpen(newOpen);
    }
    onOpenChange?.(newOpen);
  };
  
  // Close dropdown when clicking outside
  useEffect(() => {
    if (!isOpen) return;
    
    const handleClickOutside = (event) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target)) {
        setOpen(false);
      }
    };
    
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, [isOpen]);
  
  const contextValue = {
    isOpen,
    setOpen,
    toggle: () => setOpen(!isOpen),
    triggerId,
    menuId
  };
  
  return (
    <DropdownContext.Provider value={contextValue}>
      <div ref={dropdownRef} className={`dropdown ${className}`} style={{ position: 'relative' }}>
        {children}
      </div>
    </DropdownContext.Provider>
  );
}

// Trigger component
Dropdown.Trigger = function DropdownTrigger({ children, className = '' }) {
  const { isOpen, toggle, triggerId, menuId } = useDropdownContext();
  
  const handleClick = (e) => {
    e.stopPropagation();
    toggle();
  };
  
  const handleKeyDown = (e) => {
    if (e.key === 'Enter' || e.key === ' ') {
      e.preventDefault();
      toggle();
    } else if (e.key === 'ArrowDown' && !isOpen) {
      e.preventDefault();
      toggle();
    }
  };
  
  // Clone element to add props
  const child = React.Children.only(children);
  return React.cloneElement(child, {
    id: triggerId,
    'aria-haspopup': 'true',
    'aria-expanded': isOpen,
    'aria-controls': menuId,
    onClick: handleClick,
    onKeyDown: handleKeyDown,
    className: `${child.props.className || ''} ${className}`.trim()
  });
};

// Menu component
Dropdown.Menu = function DropdownMenu({ children, className = '', style = {} }) {
  const { isOpen, setOpen, menuId, triggerId } = useDropdownContext();
  const menuRef = useRef(null);
  const [focusedIndex, setFocusedIndex] = useState(-1);
  
  // Get all focusable items
  const getItems = () => {
    if (!menuRef.current) return [];
    return Array.from(menuRef.current.querySelectorAll('[role="menuitem"]:not([aria-disabled="true"])'));
  };
  
  // Handle keyboard navigation
  useEffect(() => {
    if (!isOpen) {
      setFocusedIndex(-1);
      return;
    }
    
    const handleKeyDown = (e) => {
      const items = getItems();
      const itemCount = items.length;
      
      switch (e.key) {
        case 'ArrowDown':
          e.preventDefault();
          setFocusedIndex(prev => {
            const next = prev < itemCount - 1 ? prev + 1 : 0;
            items[next]?.focus();
            return next;
          });
          break;
          
        case 'ArrowUp':
          e.preventDefault();
          setFocusedIndex(prev => {
            const next = prev > 0 ? prev - 1 : itemCount - 1;
            items[next]?.focus();
            return next;
          });
          break;
          
        case 'Home':
          e.preventDefault();
          setFocusedIndex(0);
          items[0]?.focus();
          break;
          
        case 'End':
          e.preventDefault();
          setFocusedIndex(itemCount - 1);
          items[itemCount - 1]?.focus();
          break;
          
        case 'Escape':
          e.preventDefault();
          setOpen(false);
          document.getElementById(triggerId)?.focus();
          break;
          
        case 'Tab':
          setOpen(false);
          break;
      }
    };
    
    document.addEventListener('keydown', handleKeyDown);
    return () => document.removeEventListener('keydown', handleKeyDown);
  }, [isOpen, focusedIndex, setOpen, triggerId]);
  
  if (!isOpen) return null;
  
  return (
    <div
      ref={menuRef}
      id={menuId}
      role="menu"
      aria-labelledby={triggerId}
      className={`dropdown-menu ${className}`}
      style={{
        position: 'absolute',
        top: '100%',
        left: 0,
        marginTop: '4px',
        minWidth: '150px',
        backgroundColor: 'white',
        border: '1px solid #ddd',
        borderRadius: '4px',
        boxShadow: '0 2px 8px rgba(0,0,0,0.15)',
        zIndex: 1000,
        ...style
      }}
    >
      {children}
    </div>
  );
};

// Item component
Dropdown.Item = function DropdownItem({ 
  children, 
  onSelect, 
  disabled = false,
  className = ''
}) {
  const { setOpen } = useDropdownContext();
  
  const handleClick = (e) => {
    if (disabled) return;
    
    e.preventDefault();
    onSelect?.();
    setOpen(false);
  };
  
  const handleKeyDown = (e) => {
    if (disabled) return;
    
    if (e.key === 'Enter' || e.key === ' ') {
      e.preventDefault();
      onSelect?.();
      setOpen(false);
    }
  };
  
  return (
    <div
      role="menuitem"
      tabIndex={disabled ? -1 : 0}
      aria-disabled={disabled}
      onClick={handleClick}
      onKeyDown={handleKeyDown}
      className={`dropdown-item ${disabled ? 'dropdown-item--disabled' : ''} ${className}`}
      style={{
        padding: '8px 12px',
        cursor: disabled ? 'not-allowed' : 'pointer',
        opacity: disabled ? 0.5 : 1,
        userSelect: 'none',
        display: 'flex',
        alignItems: 'center',
        gap: '8px',
        transition: 'background-color 0.2s',
        ':hover': !disabled ? { backgroundColor: '#f5f5f5' } : {}
      }}
      onMouseEnter={(e) => {
        if (!disabled) {
          e.currentTarget.style.backgroundColor = '#f5f5f5';
        }
      }}
      onMouseLeave={(e) => {
        e.currentTarget.style.backgroundColor = 'transparent';
      }}
    >
      {children}
    </div>
  );
};

export default Dropdown;