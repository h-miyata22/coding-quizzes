import React, { Component, useEffect, useState } from 'react';

// Default loading component
const DefaultLoadingComponent = () => (
  <div style={{ 
    display: 'flex', 
    justifyContent: 'center', 
    alignItems: 'center', 
    padding: '20px' 
  }}>
    <div>Loading...</div>
  </div>
);

// Default error component
const DefaultErrorComponent = ({ error, errorMessage }) => (
  <div style={{ 
    color: 'red', 
    padding: '20px', 
    textAlign: 'center' 
  }}>
    {errorMessage || error?.message || 'An error occurred'}
  </div>
);

// Main HOC implementation
function withLoading(WrappedComponent, options = {}) {
  const {
    LoadingComponent = DefaultLoadingComponent,
    ErrorComponent = DefaultErrorComponent,
    loadingProps = ['isLoading'],
    errorProps = ['error'],
    showLoadingIf,
    errorMessage,
    delay = 0,
    fetchData,
    mapDataToProps
  } = options;
  
  // Create the HOC
  const WithLoadingComponent = (props) => {
    // State for async data fetching
    const [fetchedData, setFetchedData] = useState(null);
    const [fetchLoading, setFetchLoading] = useState(false);
    const [fetchError, setFetchError] = useState(null);
    const [showDelayedLoading, setShowDelayedLoading] = useState(false);
    
    // Determine loading state
    const isLoading = (() => {
      // Check custom loading condition
      if (showLoadingIf && typeof showLoadingIf === 'function') {
        return showLoadingIf(props);
      }
      
      // Check if any loading prop is true
      for (const prop of loadingProps) {
        if (props[prop] === true) return true;
      }
      
      // Check if HOC is fetching data
      if (fetchLoading) return true;
      
      // Check if required props are missing/null
      const requiredProps = Object.keys(props).filter(
        key => !['isLoading', 'error', 'loading'].includes(key)
      );
      
      for (const prop of requiredProps) {
        if (props[prop] === null || props[prop] === undefined) {
          // Only consider it loading if it's explicitly expected
          if (loadingProps.includes(prop)) {
            return true;
          }
        }
      }
      
      return false;
    })();
    
    // Determine error state
    const error = (() => {
      // Check error props
      for (const prop of errorProps) {
        if (props[prop]) return props[prop];
      }
      
      // Check fetch error
      if (fetchError) return fetchError;
      
      return null;
    })();
    
    // Handle delayed loading display
    useEffect(() => {
      let timer;
      
      if (isLoading && delay > 0) {
        timer = setTimeout(() => {
          setShowDelayedLoading(true);
        }, delay);
      } else if (!isLoading) {
        setShowDelayedLoading(false);
      } else {
        setShowDelayedLoading(true);
      }
      
      return () => clearTimeout(timer);
    }, [isLoading]);
    
    // Fetch data if fetchData function is provided
    useEffect(() => {
      if (!fetchData) return;
      
      const loadData = async () => {
        setFetchLoading(true);
        setFetchError(null);
        
        try {
          const data = await fetchData(props);
          setFetchedData(data);
        } catch (err) {
          setFetchError(err);
        } finally {
          setFetchLoading(false);
        }
      };
      
      loadData();
    }, [props.postId, props.userId]); // Add relevant prop dependencies
    
    // Show error component if there's an error
    if (error) {
      return <ErrorComponent error={error} errorMessage={errorMessage} />;
    }
    
    // Show loading component if loading
    if (isLoading && (delay === 0 || showDelayedLoading)) {
      return <LoadingComponent />;
    }
    
    // Prepare props for wrapped component
    const finalProps = { ...props };
    
    // Remove loading and error props
    [...loadingProps, ...errorProps].forEach(prop => {
      delete finalProps[prop];
    });
    
    // Add fetched data to props
    if (fetchedData && mapDataToProps) {
      const mappedData = mapDataToProps(fetchedData);
      Object.assign(finalProps, mappedData);
    } else if (fetchedData) {
      finalProps.data = fetchedData;
    }
    
    // Render wrapped component
    return <WrappedComponent {...finalProps} />;
  };
  
  // Copy static properties
  WithLoadingComponent.displayName = `withLoading(${WrappedComponent.displayName || WrappedComponent.name || 'Component'})`;
  
  // Hoist non-react statics (simplified version)
  Object.keys(WrappedComponent).forEach(key => {
    if (!['propTypes', 'contextTypes', 'defaultProps'].includes(key)) {
      try {
        WithLoadingComponent[key] = WrappedComponent[key];
      } catch (e) {
        // Ignore errors
      }
    }
  });
  
  return WithLoadingComponent;
}

// Alternative implementation using hooks (modern approach)
export function useLoading(initialLoading = false) {
  const [isLoading, setIsLoading] = useState(initialLoading);
  const [error, setError] = useState(null);
  
  const withLoadingHandling = async (asyncFunction) => {
    setIsLoading(true);
    setError(null);
    
    try {
      const result = await asyncFunction();
      return result;
    } catch (err) {
      setError(err);
      throw err;
    } finally {
      setIsLoading(false);
    }
  };
  
  return {
    isLoading,
    error,
    setIsLoading,
    setError,
    withLoadingHandling
  };
}

// Utility HOC for simple cases
export function withSimpleLoading(WrappedComponent) {
  return function WithSimpleLoadingComponent(props) {
    if (props.isLoading) {
      return <DefaultLoadingComponent />;
    }
    
    if (props.error) {
      return <DefaultErrorComponent error={props.error} />;
    }
    
    return <WrappedComponent {...props} />;
  };
}

// TypeScript support (as comments for JavaScript file)
/*
// TypeScript version
interface WithLoadingOptions<P> {
  LoadingComponent?: React.ComponentType;
  ErrorComponent?: React.ComponentType<{ error: Error; errorMessage?: string }>;
  loadingProps?: (keyof P)[];
  errorProps?: (keyof P)[];
  showLoadingIf?: (props: P) => boolean;
  errorMessage?: string;
  delay?: number;
  fetchData?: (props: P) => Promise<any>;
  mapDataToProps?: (data: any) => Partial<P>;
}

function withLoading<P extends object>(
  WrappedComponent: React.ComponentType<P>,
  options?: WithLoadingOptions<P>
): React.ComponentType<P & { isLoading?: boolean; error?: Error }>;
*/

export default withLoading;