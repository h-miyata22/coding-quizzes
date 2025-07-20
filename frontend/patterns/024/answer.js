import React, { createContext, useContext, useState, useEffect, useCallback } from 'react';

// Theme Context
const ThemeContext = createContext();

// Custom hook to use theme
export const useTheme = () => {
  const context = useContext(ThemeContext);
  if (!context) {
    throw new Error('useTheme must be used within a ThemeProvider');
  }
  return context;
};

// Theme Provider component
export function ThemeProvider({ children, defaultTheme = 'light', defaultPrimaryColor = '#3b82f6' }) {
  // State management
  const [theme, setThemeState] = useState(() => {
    // Check localStorage first
    if (typeof window !== 'undefined') {
      const saved = localStorage.getItem('theme');
      if (saved === 'light' || saved === 'dark') {
        return saved;
      }
    }
    return defaultTheme;
  });
  
  const [primaryColor, setPrimaryColorState] = useState(() => {
    if (typeof window !== 'undefined') {
      const saved = localStorage.getItem('primaryColor');
      if (saved) {
        return saved;
      }
    }
    return defaultPrimaryColor;
  });
  
  const [followSystem, setFollowSystemState] = useState(() => {
    if (typeof window !== 'undefined') {
      const saved = localStorage.getItem('followSystem');
      return saved === 'true';
    }
    return false;
  });
  
  // Media query for system theme
  useEffect(() => {
    if (!followSystem || typeof window === 'undefined') return;
    
    const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
    
    const handleChange = (e) => {
      setThemeState(e.matches ? 'dark' : 'light');
    };
    
    // Set initial theme based on system
    handleChange(mediaQuery);
    
    // Listen for changes
    mediaQuery.addEventListener('change', handleChange);
    return () => mediaQuery.removeEventListener('change', handleChange);
  }, [followSystem]);
  
  // Persist theme to localStorage
  useEffect(() => {
    if (typeof window !== 'undefined') {
      localStorage.setItem('theme', theme);
      localStorage.setItem('followSystem', followSystem.toString());
    }
  }, [theme, followSystem]);
  
  // Persist primary color to localStorage
  useEffect(() => {
    if (typeof window !== 'undefined') {
      localStorage.setItem('primaryColor', primaryColor);
    }
  }, [primaryColor]);
  
  // Apply theme to document root
  useEffect(() => {
    if (typeof document !== 'undefined') {
      const root = document.documentElement;
      
      // Remove previous theme class
      root.classList.remove('theme-light', 'theme-dark');
      
      // Add current theme class
      root.classList.add(`theme-${theme}`);
      
      // Set CSS variables
      root.style.setProperty('--primary-color', primaryColor);
      
      // Set theme-specific CSS variables
      if (theme === 'light') {
        root.style.setProperty('--bg-primary', '#ffffff');
        root.style.setProperty('--bg-secondary', '#f3f4f6');
        root.style.setProperty('--text-primary', '#111827');
        root.style.setProperty('--text-secondary', '#6b7280');
        root.style.setProperty('--border-color', '#e5e7eb');
      } else {
        root.style.setProperty('--bg-primary', '#111827');
        root.style.setProperty('--bg-secondary', '#1f2937');
        root.style.setProperty('--text-primary', '#f9fafb');
        root.style.setProperty('--text-secondary', '#d1d5db');
        root.style.setProperty('--border-color', '#374151');
      }
    }
  }, [theme, primaryColor]);
  
  // Theme setter with validation
  const setTheme = useCallback((newTheme) => {
    if (newTheme === 'light' || newTheme === 'dark') {
      setThemeState(newTheme);
      setFollowSystemState(false);
    }
  }, []);
  
  // Toggle theme
  const toggleTheme = useCallback(() => {
    setTheme(theme === 'light' ? 'dark' : 'light');
  }, [theme, setTheme]);
  
  // Primary color setter with validation
  const setPrimaryColor = useCallback((color) => {
    // Basic color validation
    if (/^#[0-9A-F]{6}$/i.test(color)) {
      setPrimaryColorState(color);
    }
  }, []);
  
  // Follow system setter
  const setFollowSystem = useCallback((follow) => {
    setFollowSystemState(follow);
  }, []);
  
  // Context value
  const contextValue = {
    theme,
    setTheme,
    toggleTheme,
    primaryColor,
    setPrimaryColor,
    followSystem,
    setFollowSystem
  };
  
  // Prevent flash of wrong theme on initial load
  const [mounted, setMounted] = useState(false);
  
  useEffect(() => {
    setMounted(true);
  }, []);
  
  // Server-side rendering support
  if (!mounted && typeof window === 'undefined') {
    return (
      <ThemeContext.Provider value={contextValue}>
        <div className={`theme-${defaultTheme}`} style={{ '--primary-color': defaultPrimaryColor }}>
          {children}
        </div>
      </ThemeContext.Provider>
    );
  }
  
  return (
    <ThemeContext.Provider value={contextValue}>
      {children}
    </ThemeContext.Provider>
  );
}

// Optional: Theme-aware components
export function ThemedButton({ children, variant = 'primary', ...props }) {
  const { primaryColor } = useTheme();
  
  const styles = {
    primary: {
      backgroundColor: primaryColor,
      color: 'white',
      border: 'none'
    },
    secondary: {
      backgroundColor: 'transparent',
      color: primaryColor,
      border: `2px solid ${primaryColor}`
    }
  };
  
  return (
    <button
      style={{
        padding: '8px 16px',
        borderRadius: '4px',
        cursor: 'pointer',
        transition: 'all 0.2s',
        ...styles[variant]
      }}
      {...props}
    >
      {children}
    </button>
  );
}

// Global styles helper
export const globalThemeStyles = `
  :root {
    --transition-theme: background-color 0.3s ease, color 0.3s ease;
  }
  
  * {
    transition: var(--transition-theme);
  }
  
  .theme-light {
    color-scheme: light;
  }
  
  .theme-dark {
    color-scheme: dark;
  }
  
  body {
    background-color: var(--bg-primary);
    color: var(--text-primary);
  }
  
  a {
    color: var(--primary-color);
  }
  
  /* Prevent theme flash */
  html {
    visibility: hidden;
    opacity: 0;
  }
  
  html.ready {
    visibility: visible;
    opacity: 1;
    transition: opacity 0.3s;
  }
`;

// Initialize script to prevent flash (add to document head)
export const themeInitScript = `
  (function() {
    try {
      const theme = localStorage.getItem('theme') || 'light';
      const primaryColor = localStorage.getItem('primaryColor') || '#3b82f6';
      const followSystem = localStorage.getItem('followSystem') === 'true';
      
      if (followSystem) {
        const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
        document.documentElement.classList.add('theme-' + (prefersDark ? 'dark' : 'light'));
      } else {
        document.documentElement.classList.add('theme-' + theme);
      }
      
      document.documentElement.style.setProperty('--primary-color', primaryColor);
      document.documentElement.classList.add('ready');
    } catch (e) {
      document.documentElement.classList.add('theme-light');
      document.documentElement.classList.add('ready');
    }
  })();
`;