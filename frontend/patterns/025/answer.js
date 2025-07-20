import React, { createContext, useContext, useState, useEffect, useCallback } from 'react';

// Auth Context
const AuthContext = createContext();

// Custom hook to use auth
export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};

// Mock API functions (replace with real API calls)
const api = {
  login: async (email, password) => {
    // Simulate API delay
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    // Mock validation
    if (email === 'admin@example.com' && password === 'admin123') {
      return {
        user: {
          id: '1',
          name: 'Admin User',
          email: 'admin@example.com',
          role: 'admin'
        },
        token: 'mock-jwt-token-admin'
      };
    } else if (email === 'user@example.com' && password === 'user123') {
      return {
        user: {
          id: '2',
          name: 'Regular User',
          email: 'user@example.com',
          role: 'user'
        },
        token: 'mock-jwt-token-user'
      };
    }
    
    throw new Error('Invalid credentials');
  },
  
  validateToken: async (token) => {
    await new Promise(resolve => setTimeout(resolve, 500));
    
    // Mock token validation
    if (token === 'mock-jwt-token-admin') {
      return {
        id: '1',
        name: 'Admin User',
        email: 'admin@example.com',
        role: 'admin'
      };
    } else if (token === 'mock-jwt-token-user') {
      return {
        id: '2',
        name: 'Regular User',
        email: 'user@example.com',
        role: 'user'
      };
    }
    
    throw new Error('Invalid token');
  },
  
  updateUser: async (userId, updates) => {
    await new Promise(resolve => setTimeout(resolve, 500));
    return { ...updates, id: userId };
  }
};

// Auth Provider component
export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [token, setToken] = useState(() => {
    // Get token from localStorage on init
    if (typeof window !== 'undefined') {
      return localStorage.getItem('authToken');
    }
    return null;
  });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  
  // Validate token on mount and token change
  useEffect(() => {
    const validateToken = async () => {
      if (!token) {
        setLoading(false);
        return;
      }
      
      try {
        const validatedUser = await api.validateToken(token);
        setUser(validatedUser);
        setError(null);
      } catch (err) {
        console.error('Token validation failed:', err);
        // Clear invalid token
        setToken(null);
        setUser(null);
        localStorage.removeItem('authToken');
      } finally {
        setLoading(false);
      }
    };
    
    validateToken();
  }, [token]);
  
  // Login function
  const login = useCallback(async (email, password) => {
    setLoading(true);
    setError(null);
    
    try {
      const { user: loggedInUser, token: authToken } = await api.login(email, password);
      
      // Store token
      setToken(authToken);
      setUser(loggedInUser);
      
      // Persist token
      if (typeof window !== 'undefined') {
        localStorage.setItem('authToken', authToken);
      }
      
      return { success: true };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setLoading(false);
    }
  }, []);
  
  // Logout function
  const logout = useCallback(() => {
    setUser(null);
    setToken(null);
    setError(null);
    
    // Clear persisted data
    if (typeof window !== 'undefined') {
      localStorage.removeItem('authToken');
    }
  }, []);
  
  // Update user function
  const updateUser = useCallback(async (updates) => {
    if (!user) return;
    
    setLoading(true);
    setError(null);
    
    try {
      const updatedUser = await api.updateUser(user.id, updates);
      setUser(prevUser => ({ ...prevUser, ...updatedUser }));
      return { success: true };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setLoading(false);
    }
  }, [user]);
  
  // Check if user has specific role
  const hasRole = useCallback((role) => {
    return user?.role === role;
  }, [user]);
  
  // Check if user has any of the specified roles
  const hasAnyRole = useCallback((roles) => {
    return roles.includes(user?.role);
  }, [user]);
  
  // Auto logout on token expiration (optional feature)
  useEffect(() => {
    if (!token) return;
    
    // Mock token expiration after 1 hour
    const expirationTime = 60 * 60 * 1000; // 1 hour
    const timer = setTimeout(() => {
      console.log('Token expired, logging out...');
      logout();
    }, expirationTime);
    
    return () => clearTimeout(timer);
  }, [token, logout]);
  
  // Context value
  const contextValue = {
    user,
    token,
    loading,
    error,
    isAuthenticated: !!user,
    login,
    logout,
    updateUser,
    hasRole,
    hasAnyRole
  };
  
  return (
    <AuthContext.Provider value={contextValue}>
      {children}
    </AuthContext.Provider>
  );
}

// Higher-order component for protected routes
export function withAuth(Component, options = {}) {
  return function AuthenticatedComponent(props) {
    const { isAuthenticated, loading, hasRole } = useAuth();
    const { requireAuth = true, requireRole = null, fallback = null } = options;
    
    if (loading) {
      return <div>Loading...</div>;
    }
    
    if (requireAuth && !isAuthenticated) {
      return fallback || <div>Please login to access this page.</div>;
    }
    
    if (requireRole && !hasRole(requireRole)) {
      return fallback || <div>You don't have permission to access this page.</div>;
    }
    
    return <Component {...props} />;
  };
}

// Utility component for conditional rendering based on auth
export function AuthGuard({ children, requireAuth = true, requireRole = null, fallback = null }) {
  const { isAuthenticated, loading, hasRole } = useAuth();
  
  if (loading) {
    return <div>Loading...</div>;
  }
  
  if (requireAuth && !isAuthenticated) {
    return fallback || null;
  }
  
  if (requireRole && !hasRole(requireRole)) {
    return fallback || null;
  }
  
  return children;
}