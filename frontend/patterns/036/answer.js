import React, { useState, useEffect, useRef } from 'react';

function LazyImage({ 
  src, 
  alt, 
  placeholder = '#f0f0f0',
  errorSrc = '/error-image.png',
  ...props 
}) {
  const [imageSrc, setImageSrc] = useState(null);
  const [isLoading, setIsLoading] = useState(true);
  const [hasError, setHasError] = useState(false);
  const [isInView, setIsInView] = useState(false);
  const imgRef = useRef(null);

  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            setIsInView(true);
            // 一度表示されたら監視を停止
            observer.unobserve(entry.target);
          }
        });
      },
      {
        // 100px前から読み込み開始
        rootMargin: '100px',
        threshold: 0.01
      }
    );

    if (imgRef.current) {
      observer.observe(imgRef.current);
    }

    return () => {
      if (imgRef.current) {
        observer.unobserve(imgRef.current);
      }
    };
  }, []);

  useEffect(() => {
    if (!isInView) return;

    setIsLoading(true);
    setHasError(false);

    // 画像のプリロード
    const img = new Image();
    
    img.onload = () => {
      setImageSrc(src);
      setIsLoading(false);
    };

    img.onerror = () => {
      setHasError(true);
      setIsLoading(false);
      // エラー時は代替画像を設定
      setImageSrc(errorSrc);
    };

    img.src = src;

    // クリーンアップ
    return () => {
      img.onload = null;
      img.onerror = null;
    };
  }, [isInView, src, errorSrc]);

  // スタイルの定義
  const containerStyle = {
    position: 'relative',
    backgroundColor: placeholder,
    overflow: 'hidden',
    ...props.style
  };

  const imageStyle = {
    ...props.style,
    opacity: isLoading ? 0 : 1,
    transition: 'opacity 0.3s ease-in-out',
    display: 'block',
    width: '100%',
    height: '100%'
  };

  return (
    <div ref={imgRef} style={containerStyle}>
      {imageSrc && (
        <img
          src={imageSrc}
          alt={alt}
          {...props}
          style={imageStyle}
        />
      )}
      {isLoading && isInView && (
        <div style={{
          position: 'absolute',
          top: '50%',
          left: '50%',
          transform: 'translate(-50%, -50%)',
          color: '#999'
        }}>
          Loading...
        </div>
      )}
    </div>
  );
}

// より高度な実装（blur効果付き）
function LazyImageAdvanced({ 
  src, 
  alt, 
  placeholder = '#f0f0f0',
  errorSrc = '/error-image.png',
  lowResSrc,  // 低解像度のプレビュー画像
  ...props 
}) {
  const [currentSrc, setCurrentSrc] = useState(lowResSrc || null);
  const [isLoading, setIsLoading] = useState(true);
  const [hasError, setHasError] = useState(false);
  const [isInView, setIsInView] = useState(false);
  const [isHighResLoaded, setIsHighResLoaded] = useState(false);
  const imgRef = useRef(null);

  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            setIsInView(true);
            observer.unobserve(entry.target);
          }
        });
      },
      {
        rootMargin: '100px',
        threshold: 0.01
      }
    );

    if (imgRef.current) {
      observer.observe(imgRef.current);
    }

    return () => {
      if (imgRef.current) {
        observer.unobserve(imgRef.current);
      }
    };
  }, []);

  useEffect(() => {
    if (!isInView) return;

    setIsLoading(true);
    setHasError(false);

    const img = new Image();
    
    img.onload = () => {
      setCurrentSrc(src);
      setIsHighResLoaded(true);
      setIsLoading(false);
    };

    img.onerror = () => {
      setHasError(true);
      setIsLoading(false);
      setCurrentSrc(errorSrc);
    };

    img.src = src;

    return () => {
      img.onload = null;
      img.onerror = null;
    };
  }, [isInView, src, errorSrc]);

  const containerStyle = {
    position: 'relative',
    backgroundColor: placeholder,
    overflow: 'hidden',
    ...props.style
  };

  const imageStyle = {
    ...props.style,
    filter: isHighResLoaded ? 'none' : 'blur(20px)',
    opacity: currentSrc ? 1 : 0,
    transition: 'opacity 0.3s ease-in-out, filter 0.3s ease-in-out',
    display: 'block',
    width: '100%',
    height: '100%',
    transform: 'scale(1.1)' // blur効果のエッジを隠す
  };

  return (
    <div ref={imgRef} style={containerStyle}>
      {currentSrc && (
        <img
          src={currentSrc}
          alt={alt}
          {...props}
          style={imageStyle}
        />
      )}
    </div>
  );
}

export default LazyImage;