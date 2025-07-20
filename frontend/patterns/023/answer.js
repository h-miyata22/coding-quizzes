import React, { createContext, useContext, useState, useRef, useEffect, useId } from 'react';
import { createPortal } from 'react-dom';

// Modal Context
const ModalContext = createContext();

// Custom hook to use Modal context
const useModalContext = () => {
  const context = useContext(ModalContext);
  if (!context) {
    throw new Error('Modal components must be used within a Modal');
  }
  return context;
};

// Focus trap hook
const useFocusTrap = (ref, isActive) => {
  useEffect(() => {
    if (!isActive || !ref.current) return;
    
    const modalElement = ref.current;
    const focusableElements = modalElement.querySelectorAll(
      'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
    );
    const firstElement = focusableElements[0];
    const lastElement = focusableElements[focusableElements.length - 1];
    
    // Focus first element
    firstElement?.focus();
    
    const handleTabKey = (e) => {
      if (e.key !== 'Tab') return;
      
      if (e.shiftKey) {
        if (document.activeElement === firstElement) {
          e.preventDefault();
          lastElement?.focus();
        }
      } else {
        if (document.activeElement === lastElement) {
          e.preventDefault();
          firstElement?.focus();
        }
      }
    };
    
    modalElement.addEventListener('keydown', handleTabKey);
    return () => modalElement.removeEventListener('keydown', handleTabKey);
  }, [ref, isActive]);
};

// Scroll lock hook
const useScrollLock = (isLocked) => {
  useEffect(() => {
    if (!isLocked) return;
    
    const originalOverflow = document.body.style.overflow;
    const originalPaddingRight = document.body.style.paddingRight;
    const scrollbarWidth = window.innerWidth - document.documentElement.clientWidth;
    
    document.body.style.overflow = 'hidden';
    if (scrollbarWidth > 0) {
      document.body.style.paddingRight = `${scrollbarWidth}px`;
    }
    
    return () => {
      document.body.style.overflow = originalOverflow;
      document.body.style.paddingRight = originalPaddingRight;
    };
  }, [isLocked]);
};

// Parent Modal component
function Modal({ 
  children, 
  open: controlledOpen,
  onOpenChange,
  className = ''
}) {
  const [internalOpen, setInternalOpen] = useState(false);
  const modalId = useId();
  const titleId = useId();
  const previousActiveElement = useRef(null);
  
  // Determine if component is controlled
  const isControlled = controlledOpen !== undefined;
  const isOpen = isControlled ? controlledOpen : internalOpen;
  
  const setOpen = (newOpen) => {
    if (!isControlled) {
      setInternalOpen(newOpen);
    }
    onOpenChange?.(newOpen);
  };
  
  // Store and restore focus
  useEffect(() => {
    if (isOpen) {
      previousActiveElement.current = document.activeElement;
    } else if (previousActiveElement.current) {
      previousActiveElement.current.focus();
    }
  }, [isOpen]);
  
  const contextValue = {
    isOpen,
    setOpen,
    modalId,
    titleId
  };
  
  return (
    <ModalContext.Provider value={contextValue}>
      <div className={`modal-root ${className}`}>
        {children}
      </div>
    </ModalContext.Provider>
  );
}

// Trigger component
Modal.Trigger = function ModalTrigger({ children }) {
  const { setOpen } = useModalContext();
  
  const handleClick = () => {
    setOpen(true);
  };
  
  // Clone element to add onClick
  const child = React.Children.only(children);
  return React.cloneElement(child, {
    onClick: handleClick
  });
};

// Content component
Modal.Content = function ModalContent({ children, className = '', style = {} }) {
  const { isOpen, setOpen, modalId, titleId } = useModalContext();
  const contentRef = useRef(null);
  
  // Use hooks
  useFocusTrap(contentRef, isOpen);
  useScrollLock(isOpen);
  
  // Handle Escape key
  useEffect(() => {
    if (!isOpen) return;
    
    const handleKeyDown = (e) => {
      if (e.key === 'Escape') {
        setOpen(false);
      }
    };
    
    document.addEventListener('keydown', handleKeyDown);
    return () => document.removeEventListener('keydown', handleKeyDown);
  }, [isOpen, setOpen]);
  
  if (!isOpen) return null;
  
  return createPortal(
    <>
      {/* Overlay */}
      <div
        className="modal-overlay"
        onClick={() => setOpen(false)}
        style={{
          position: 'fixed',
          inset: 0,
          backgroundColor: 'rgba(0, 0, 0, 0.5)',
          zIndex: 9999,
          animation: 'fadeIn 0.2s ease-out'
        }}
      />
      
      {/* Modal */}
      <div
        ref={contentRef}
        id={modalId}
        role="dialog"
        aria-modal="true"
        aria-labelledby={titleId}
        className={`modal-content ${className}`}
        style={{
          position: 'fixed',
          top: '50%',
          left: '50%',
          transform: 'translate(-50%, -50%)',
          backgroundColor: 'white',
          borderRadius: '8px',
          boxShadow: '0 4px 24px rgba(0, 0, 0, 0.15)',
          maxWidth: '500px',
          width: '90%',
          maxHeight: '90vh',
          display: 'flex',
          flexDirection: 'column',
          zIndex: 10000,
          animation: 'slideIn 0.2s ease-out',
          ...style
        }}
        onClick={(e) => e.stopPropagation()}
      >
        {children}
      </div>
    </>,
    document.body
  );
};

// Header component
Modal.Header = function ModalHeader({ children, className = '' }) {
  const { titleId } = useModalContext();
  
  return (
    <div 
      className={`modal-header ${className}`}
      style={{
        padding: '20px',
        borderBottom: '1px solid #e9ecef',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between'
      }}
    >
      <div id={titleId} style={{ margin: 0 }}>
        {children}
      </div>
    </div>
  );
};

// Body component
Modal.Body = function ModalBody({ children, className = '' }) {
  return (
    <div 
      className={`modal-body ${className}`}
      style={{
        padding: '20px',
        overflowY: 'auto',
        flex: 1
      }}
    >
      {children}
    </div>
  );
};

// Footer component
Modal.Footer = function ModalFooter({ children, className = '' }) {
  return (
    <div 
      className={`modal-footer ${className}`}
      style={{
        padding: '20px',
        borderTop: '1px solid #e9ecef',
        display: 'flex',
        gap: '8px',
        justifyContent: 'flex-end'
      }}
    >
      {children}
    </div>
  );
};

// Close component
Modal.Close = function ModalClose({ children }) {
  const { setOpen } = useModalContext();
  
  const handleClick = () => {
    setOpen(false);
  };
  
  // If children is provided, clone and add onClick
  if (children) {
    const child = React.Children.only(children);
    return React.cloneElement(child, {
      onClick: handleClick
    });
  }
  
  // Default close button
  return (
    <button
      onClick={handleClick}
      aria-label="Close modal"
      style={{
        background: 'none',
        border: 'none',
        fontSize: '24px',
        cursor: 'pointer',
        padding: '4px 8px',
        lineHeight: 1
      }}
    >
      ×
    </button>
  );
};

// Add animations to document
if (typeof document !== 'undefined' && !document.getElementById('modal-animations')) {
  const style = document.createElement('style');
  style.id = 'modal-animations';
  style.textContent = `
    @keyframes fadeIn {
      from { opacity: 0; }
      to { opacity: 1; }
    }
    
    @keyframes slideIn {
      from {
        opacity: 0;
        transform: translate(-50%, -48%) scale(0.95);
      }
      to {
        opacity: 1;
        transform: translate(-50%, -50%) scale(1);
      }
    }
  `;
  document.head.appendChild(style);
}

export default Modal;