import React, { useState, useEffect } from 'react';

// 優先度と遅延時間のマッピング
const PRIORITY_DELAYS = {
  critical: 0,      // 即座に表示
  high: 100,        // 100ms後
  normal: 200,      // 200ms後
  low: 300          // 300ms後
};

function PriorityRenderer({ 
  priority = 'normal',
  children,
  placeholder
}) {
  const [isVisible, setIsVisible] = useState(priority === 'critical');
  const [hasStartedLoading, setHasStartedLoading] = useState(false);
  
  useEffect(() => {
    // criticalの場合は即座に表示されているのでスキップ
    if (priority === 'critical') {
      setHasStartedLoading(true);
      return;
    }

    // 指定された遅延後に表示
    const delay = PRIORITY_DELAYS[priority] || PRIORITY_DELAYS.normal;
    const timer = setTimeout(() => {
      setHasStartedLoading(true);
      setIsVisible(true);
    }, delay);

    return () => clearTimeout(timer);
  }, [priority]);

  // まだロードが開始されていない場合はプレースホルダーを表示
  if (!hasStartedLoading && placeholder) {
    return <>{placeholder}</>;
  }

  return (
    <div
      style={{
        opacity: isVisible ? 1 : 0,
        transform: isVisible ? 'translateY(0)' : 'translateY(20px)',
        transition: 'opacity 0.5s ease-out, transform 0.5s ease-out'
      }}
    >
      {children}
    </div>
  );
}

// より高度な実装（IntersectionObserverと組み合わせ）
function AdvancedPriorityRenderer({ 
  priority = 'normal',
  children,
  placeholder,
  observerOptions = { rootMargin: '50px' }
}) {
  const [isVisible, setIsVisible] = useState(false);
  const [isInViewport, setIsInViewport] = useState(false);
  const [hasStartedLoading, setHasStartedLoading] = useState(false);
  const containerRef = React.useRef(null);

  // IntersectionObserverで可視性を監視
  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            setIsInViewport(true);
            observer.unobserve(entry.target);
          }
        });
      },
      observerOptions
    );

    if (containerRef.current) {
      observer.observe(containerRef.current);
    }

    return () => {
      if (containerRef.current) {
        observer.unobserve(containerRef.current);
      }
    };
  }, [observerOptions]);

  // 優先度と可視性に基づいて表示タイミングを制御
  useEffect(() => {
    // criticalは可視性に関係なく即座に表示
    if (priority === 'critical') {
      setHasStartedLoading(true);
      setIsVisible(true);
      return;
    }

    // その他は可視領域に入ってから優先度に応じて遅延表示
    if (isInViewport) {
      const delay = PRIORITY_DELAYS[priority] || PRIORITY_DELAYS.normal;
      const timer = setTimeout(() => {
        setHasStartedLoading(true);
        setIsVisible(true);
      }, delay);

      return () => clearTimeout(timer);
    }
  }, [priority, isInViewport]);

  return (
    <div ref={containerRef}>
      {!hasStartedLoading && placeholder ? (
        <>{placeholder}</>
      ) : (
        <div
          style={{
            opacity: isVisible ? 1 : 0,
            transform: isVisible ? 'translateY(0)' : 'translateY(20px)',
            transition: 'opacity 0.5s ease-out, transform 0.5s ease-out'
          }}
        >
          {children}
        </div>
      )}
    </div>
  );
}

// カスタムフック版（再利用可能）
function usePriorityRender(priority = 'normal', dependencies = []) {
  const [shouldRender, setShouldRender] = useState(priority === 'critical');
  const [isAnimated, setIsAnimated] = useState(priority === 'critical');

  useEffect(() => {
    if (priority === 'critical') {
      return;
    }

    const delay = PRIORITY_DELAYS[priority] || PRIORITY_DELAYS.normal;
    const renderTimer = setTimeout(() => {
      setShouldRender(true);
    }, delay);

    const animationTimer = setTimeout(() => {
      setIsAnimated(true);
    }, delay + 50); // アニメーション用に少し遅延

    return () => {
      clearTimeout(renderTimer);
      clearTimeout(animationTimer);
    };
  }, [priority, ...dependencies]);

  return { shouldRender, isAnimated };
}

// カスタムフックを使用した実装例
function PriorityRendererWithHook({ priority, children, placeholder }) {
  const { shouldRender, isAnimated } = usePriorityRender(priority);

  if (!shouldRender && placeholder) {
    return <>{placeholder}</>;
  }

  return (
    <div
      style={{
        opacity: isAnimated ? 1 : 0,
        transform: isAnimated ? 'translateY(0)' : 'translateY(20px)',
        transition: 'opacity 0.5s ease-out, transform 0.5s ease-out'
      }}
    >
      {children}
    </div>
  );
}

export default PriorityRenderer;