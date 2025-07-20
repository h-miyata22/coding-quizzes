import React, { useState, useEffect, useRef, useCallback } from 'react';

// Throttle utility
function throttle(func, delay) {
  let lastCall = 0;
  return function (...args) {
    const now = Date.now();
    if (now - lastCall >= delay) {
      lastCall = now;
      return func(...args);
    }
  };
}

// Debounce utility
function debounce(func, delay) {
  let timeoutId;
  return function (...args) {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => func(...args), delay);
  };
}

// MouseTracker component
function MouseTracker({ 
  children, 
  render,
  trackingArea = 'window', // 'window' | 'parent' | HTMLElement
  calculateSpeed = false,
  throttleMs = 0,
  debounceMs = 0,
  maxClickHistory = 10
}) {
  // Mouse position state
  const [mouseData, setMouseData] = useState({
    x: 0,
    y: 0,
    deltaX: 0,
    deltaY: 0,
    isMoving: false,
    isInside: false,
    speed: 0,
    direction: 0,
    clickPositions: [],
    hoveredElement: null
  });
  
  // Refs for tracking
  const containerRef = useRef(null);
  const lastPositionRef = useRef({ x: 0, y: 0 });
  const lastTimeRef = useRef(Date.now());
  const movementTimeoutRef = useRef(null);
  
  // Update mouse data
  const updateMouseData = useCallback((clientX, clientY, target) => {
    const now = Date.now();
    const timeDelta = now - lastTimeRef.current;
    const lastPosition = lastPositionRef.current;
    
    // Calculate position relative to tracking area
    let x = clientX;
    let y = clientY;
    let isInside = true;
    
    if (trackingArea === 'parent' && containerRef.current) {
      const rect = containerRef.current.getBoundingClientRect();
      x = clientX - rect.left;
      y = clientY - rect.top;
      isInside = x >= 0 && x <= rect.width && y >= 0 && y <= rect.height;
    } else if (trackingArea instanceof HTMLElement) {
      const rect = trackingArea.getBoundingClientRect();
      x = clientX - rect.left;
      y = clientY - rect.top;
      isInside = x >= 0 && x <= rect.width && y >= 0 && y <= rect.height;
    }
    
    // Calculate deltas
    const deltaX = x - lastPosition.x;
    const deltaY = y - lastPosition.y;
    
    // Calculate speed and direction if needed
    let speed = 0;
    let direction = 0;
    
    if (calculateSpeed && timeDelta > 0) {
      const distance = Math.sqrt(deltaX ** 2 + deltaY ** 2);
      speed = (distance / timeDelta) * 1000; // pixels per second
      direction = Math.atan2(deltaY, deltaX) * (180 / Math.PI);
    }
    
    // Update state
    setMouseData(prev => ({
      ...prev,
      x,
      y,
      deltaX,
      deltaY,
      isMoving: true,
      isInside,
      speed,
      direction,
      hoveredElement: target
    }));
    
    // Update refs
    lastPositionRef.current = { x, y };
    lastTimeRef.current = now;
    
    // Reset movement flag after delay
    clearTimeout(movementTimeoutRef.current);
    movementTimeoutRef.current = setTimeout(() => {
      setMouseData(prev => ({ ...prev, isMoving: false }));
    }, 100);
  }, [trackingArea, calculateSpeed]);
  
  // Create throttled/debounced handler
  const handleMouseMove = useCallback(
    (e) => {
      const handler = () => updateMouseData(e.clientX, e.clientY, e.target);
      
      if (throttleMs > 0 && debounceMs > 0) {
        // Both throttle and debounce
        const throttled = throttle(handler, throttleMs);
        const debounced = debounce(handler, debounceMs);
        throttled();
        debounced();
      } else if (throttleMs > 0) {
        // Only throttle
        throttle(handler, throttleMs)();
      } else if (debounceMs > 0) {
        // Only debounce
        debounce(handler, debounceMs)();
      } else {
        // No optimization
        handler();
      }
    },
    [updateMouseData, throttleMs, debounceMs]
  );
  
  // Handle mouse click
  const handleMouseClick = useCallback((e) => {
    let x = e.clientX;
    let y = e.clientY;
    
    if (trackingArea === 'parent' && containerRef.current) {
      const rect = containerRef.current.getBoundingClientRect();
      x = e.clientX - rect.left;
      y = e.clientY - rect.top;
    }
    
    setMouseData(prev => ({
      ...prev,
      clickPositions: [...prev.clickPositions, { x, y, timestamp: Date.now() }]
        .slice(-maxClickHistory)
    }));
  }, [trackingArea, maxClickHistory]);
  
  // Handle touch events
  const handleTouchMove = useCallback((e) => {
    if (e.touches.length > 0) {
      const touch = e.touches[0];
      handleMouseMove({
        clientX: touch.clientX,
        clientY: touch.clientY,
        target: e.target
      });
    }
  }, [handleMouseMove]);
  
  const handleTouchStart = useCallback((e) => {
    if (e.touches.length > 0) {
      const touch = e.touches[0];
      handleMouseClick({
        clientX: touch.clientX,
        clientY: touch.clientY
      });
    }
  }, [handleMouseClick]);
  
  // Set up event listeners
  useEffect(() => {
    let element = window;
    
    if (trackingArea === 'parent' && containerRef.current) {
      element = containerRef.current;
    } else if (trackingArea instanceof HTMLElement) {
      element = trackingArea;
    }
    
    // Mouse events
    element.addEventListener('mousemove', handleMouseMove);
    element.addEventListener('click', handleMouseClick);
    
    // Touch events
    element.addEventListener('touchmove', handleTouchMove);
    element.addEventListener('touchstart', handleTouchStart);
    
    // Mouse leave/enter for tracking area
    if (element !== window) {
      const handleMouseEnter = () => {
        setMouseData(prev => ({ ...prev, isInside: true }));
      };
      
      const handleMouseLeave = () => {
        setMouseData(prev => ({ ...prev, isInside: false }));
      };
      
      element.addEventListener('mouseenter', handleMouseEnter);
      element.addEventListener('mouseleave', handleMouseLeave);
      
      return () => {
        element.removeEventListener('mousemove', handleMouseMove);
        element.removeEventListener('click', handleMouseClick);
        element.removeEventListener('touchmove', handleTouchMove);
        element.removeEventListener('touchstart', handleTouchStart);
        element.removeEventListener('mouseenter', handleMouseEnter);
        element.removeEventListener('mouseleave', handleMouseLeave);
      };
    }
    
    return () => {
      element.removeEventListener('mousemove', handleMouseMove);
      element.removeEventListener('click', handleMouseClick);
      element.removeEventListener('touchmove', handleTouchMove);
      element.removeEventListener('touchstart', handleTouchStart);
    };
  }, [trackingArea, handleMouseMove, handleMouseClick, handleTouchMove, handleTouchStart]);
  
  // Render
  const renderProps = {
    ...mouseData,
    containerRef
  };
  
  // Support both render prop and children as function
  if (trackingArea === 'parent') {
    return (
      <div ref={containerRef} style={{ position: 'relative', width: '100%', height: '100%' }}>
        {render ? render(renderProps) : children(renderProps)}
      </div>
    );
  }
  
  return render ? render(renderProps) : children(renderProps);
}

// Export utilities for external use
export { throttle, debounce };

export default MouseTracker;