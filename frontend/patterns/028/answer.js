import React, { Component } from 'react';

// Default error fallback component
const DefaultErrorFallback = ({ error, resetError, errorInfo }) => {
  const isDevelopment = process.env.NODE_ENV === 'development';
  
  return (
    <div style={{
      padding: '20px',
      backgroundColor: '#fee',
      border: '1px solid #fcc',
      borderRadius: '4px',
      margin: '20px'
    }}>
      <h2 style={{ color: '#c00', marginTop: 0 }}>Something went wrong</h2>
      <p style={{ color: '#666' }}>
        We're sorry for the inconvenience. Please try refreshing the page.
      </p>
      
      {isDevelopment && (
        <details style={{ marginTop: '20px' }}>
          <summary style={{ cursor: 'pointer' }}>Error details (Development only)</summary>
          <pre style={{
            marginTop: '10px',
            padding: '10px',
            backgroundColor: '#f5f5f5',
            overflow: 'auto'
          }}>
            <code>
              {error.toString()}
              {errorInfo && errorInfo.componentStack}
            </code>
          </pre>
        </details>
      )}
      
      {resetError && (
        <button
          onClick={resetError}
          style={{
            marginTop: '10px',
            padding: '8px 16px',
            backgroundColor: '#007bff',
            color: 'white',
            border: 'none',
            borderRadius: '4px',
            cursor: 'pointer'
          }}
        >
          Try Again
        </button>
      )}
    </div>
  );
};

// Error Boundary class component
class ErrorBoundary extends Component {
  constructor(props) {
    super(props);
    this.state = {
      hasError: false,
      error: null,
      errorInfo: null,
      errorCount: 0
    };
    
    this.resetError = this.resetError.bind(this);
  }
  
  static getDerivedStateFromError(error) {
    // Update state so the next render will show the fallback UI
    return {
      hasError: true,
      error
    };
  }
  
  componentDidCatch(error, errorInfo) {
    const { onError, maxRetries = 3 } = this.props;
    const { errorCount } = this.state;
    
    // Log error details
    console.error('Error caught by boundary:', error, errorInfo);
    
    // Update state with error info
    this.setState({
      errorInfo,
      errorCount: errorCount + 1
    });
    
    // Call custom error handler if provided
    if (onError && typeof onError === 'function') {
      onError(error, errorInfo);
    }
    
    // Check if we've exceeded max retries
    if (errorCount >= maxRetries) {
      console.error(`Maximum retry attempts (${maxRetries}) exceeded`);
    }
  }
  
  resetError() {
    const { onReset } = this.props;
    
    // Call custom reset handler if provided
    if (onReset && typeof onReset === 'function') {
      onReset();
    }
    
    // Reset error state
    this.setState({
      hasError: false,
      error: null,
      errorInfo: null
    });
  }
  
  render() {
    const { hasError, error, errorInfo, errorCount } = this.state;
    const { 
      children, 
      FallbackComponent = DefaultErrorFallback,
      maxRetries = 3,
      showDetails
    } = this.props;
    
    if (hasError) {
      // Check if we should show the reset button
      const canReset = errorCount < maxRetries;
      
      return (
        <FallbackComponent
          error={error}
          errorInfo={errorInfo}
          resetError={canReset ? this.resetError : null}
          errorCount={errorCount}
          showDetails={showDetails}
        />
      );
    }
    
    return children;
  }
}

// HOC implementation
function withErrorBoundary(WrappedComponent, options = {}) {
  const {
    FallbackComponent,
    onError,
    onReset,
    showDetails,
    maxRetries,
    isolate = true
  } = options;
  
  // Create the wrapped component
  const WithErrorBoundaryComponent = (props) => {
    // If isolate is false, don't wrap in error boundary
    // (useful for components that already have error handling)
    if (!isolate) {
      return <WrappedComponent {...props} />;
    }
    
    return (
      <ErrorBoundary
        FallbackComponent={FallbackComponent}
        onError={onError}
        onReset={onReset}
        showDetails={showDetails}
        maxRetries={maxRetries}
      >
        <WrappedComponent {...props} />
      </ErrorBoundary>
    );
  };
  
  // Set display name for debugging
  WithErrorBoundaryComponent.displayName = 
    `withErrorBoundary(${WrappedComponent.displayName || WrappedComponent.name || 'Component'})`;
  
  // Copy static properties
  Object.keys(WrappedComponent).forEach(key => {
    if (key !== 'propTypes' && key !== 'defaultProps') {
      try {
        WithErrorBoundaryComponent[key] = WrappedComponent[key];
      } catch (e) {
        // Ignore errors when copying
      }
    }
  });
  
  return WithErrorBoundaryComponent;
}

// Utility function to create error boundary wrapper
export function createErrorBoundary(options = {}) {
  return function wrapWithErrorBoundary(WrappedComponent) {
    return withErrorBoundary(WrappedComponent, options);
  };
}

// Hook for error handling (for functional components)
export function useErrorHandler() {
  const [error, setError] = React.useState(null);
  
  React.useEffect(() => {
    if (error) {
      throw error;
    }
  }, [error]);
  
  const resetError = () => setError(null);
  const captureError = (error) => setError(error);
  
  return { resetError, captureError };
}

// Async error boundary (experimental)
export function AsyncErrorBoundary({ children, fallback }) {
  const [hasError, setHasError] = React.useState(false);
  
  React.useEffect(() => {
    const handleUnhandledRejection = (event) => {
      console.error('Unhandled promise rejection:', event.reason);
      setHasError(true);
    };
    
    window.addEventListener('unhandledrejection', handleUnhandledRejection);
    
    return () => {
      window.removeEventListener('unhandledrejection', handleUnhandledRejection);
    };
  }, []);
  
  if (hasError) {
    return fallback || <DefaultErrorFallback error={new Error('Async error')} />;
  }
  
  return children;
}

export default withErrorBoundary;