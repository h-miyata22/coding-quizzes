// 使用例
import React from 'react';

// 基本的な使用方法 - render prop
function BasicExample() {
  return (
    <MouseTracker
      render={({ x, y }) => (
        <div>
          Mouse position: ({x}, {y})
        </div>
      )}
    />
  );
}

// children as function パターン
function ChildrenExample() {
  return (
    <MouseTracker>
      {({ x, y, isMoving }) => (
        <div>
          <p>X: {x}, Y: {y}</p>
          <p>{isMoving ? 'Mouse is moving' : 'Mouse is still'}</p>
        </div>
      )}
    </MouseTracker>
  );
}

// カーソル追従要素
function FollowCursor() {
  return (
    <MouseTracker>
      {({ x, y }) => (
        <div
          style={{
            position: 'fixed',
            left: x + 10,
            top: y + 10,
            width: '20px',
            height: '20px',
            borderRadius: '50%',
            backgroundColor: 'red',
            pointerEvents: 'none',
            transform: 'translate(-50%, -50%)'
          }}
        />
      )}
    </MouseTracker>
  );
}

// ヒートマップ可視化
function HeatmapVisualization() {
  return (
    <div style={{ position: 'relative', width: '100%', height: '400px' }}>
      <MouseTracker trackingArea="parent">
        {({ x, y, clickPositions }) => (
          <>
            <div style={{ 
              position: 'absolute', 
              left: x, 
              top: y,
              width: '10px',
              height: '10px',
              backgroundColor: 'rgba(255, 0, 0, 0.5)',
              borderRadius: '50%',
              transform: 'translate(-50%, -50%)'
            }} />
            
            {clickPositions.map((pos, index) => (
              <div
                key={index}
                style={{
                  position: 'absolute',
                  left: pos.x,
                  top: pos.y,
                  width: '20px',
                  height: '20px',
                  backgroundColor: 'rgba(0, 0, 255, 0.3)',
                  borderRadius: '50%',
                  transform: 'translate(-50%, -50%)'
                }}
              />
            ))}
          </>
        )}
      </MouseTracker>
    </div>
  );
}

// 速度インジケーター
function SpeedIndicator() {
  return (
    <MouseTracker calculateSpeed>
      {({ speed, direction }) => (
        <div className="speed-indicator">
          <div>Speed: {Math.round(speed)} px/s</div>
          <div>Direction: {direction}°</div>
          <div 
            className="speed-bar"
            style={{
              width: `${Math.min(speed / 10, 100)}%`,
              height: '10px',
              backgroundColor: speed > 500 ? 'red' : 'green',
              transition: 'width 0.1s'
            }}
          />
        </div>
      )}
    </MouseTracker>
  );
}

// インタラクティブなキャンバス
function DrawingCanvas() {
  const [isDrawing, setIsDrawing] = useState(false);
  const [points, setPoints] = useState([]);
  
  return (
    <div 
      style={{ border: '1px solid black', width: '500px', height: '300px' }}
      onMouseDown={() => setIsDrawing(true)}
      onMouseUp={() => setIsDrawing(false)}
    >
      <MouseTracker>
        {({ x, y, isInside }) => {
          if (isDrawing && isInside) {
            setPoints(prev => [...prev, { x, y }]);
          }
          
          return (
            <svg width="500" height="300">
              <polyline
                points={points.map(p => `${p.x},${p.y}`).join(' ')}
                fill="none"
                stroke="black"
                strokeWidth="2"
              />
              {isInside && (
                <circle cx={x} cy={y} r="5" fill="red" />
              )}
            </svg>
          );
        }}
      </MouseTracker>
    </div>
  );
}

// ツールチップ表示
function TooltipExample() {
  const items = [
    { id: 1, name: 'Item 1', description: 'This is item 1' },
    { id: 2, name: 'Item 2', description: 'This is item 2' },
    { id: 3, name: 'Item 3', description: 'This is item 3' }
  ];
  
  return (
    <MouseTracker>
      {({ x, y, hoveredElement }) => (
        <div>
          {items.map(item => (
            <div
              key={item.id}
              data-tooltip={item.description}
              style={{ padding: '10px', border: '1px solid #ccc', margin: '5px' }}
            >
              {item.name}
            </div>
          ))}
          
          {hoveredElement?.dataset.tooltip && (
            <div
              style={{
                position: 'fixed',
                left: x + 10,
                top: y - 30,
                backgroundColor: 'black',
                color: 'white',
                padding: '5px 10px',
                borderRadius: '4px',
                fontSize: '12px',
                pointerEvents: 'none'
              }}
            >
              {hoveredElement.dataset.tooltip}
            </div>
          )}
        </div>
      )}
    </MouseTracker>
  );
}

// パフォーマンス最適化版
function OptimizedTracker() {
  return (
    <MouseTracker throttleMs={16} debounceMs={100}>
      {({ x, y, deltaX, deltaY }) => (
        <div>
          <p>Position: ({x}, {y})</p>
          <p>Delta: ({deltaX}, {deltaY})</p>
        </div>
      )}
    </MouseTracker>
  );
}

// 複数の視覚効果
function MouseEffects() {
  return (
    <div style={{ height: '100vh', background: '#f0f0f0' }}>
      <MouseTracker>
        {({ x, y, isMoving, speed }) => (
          <>
            {/* Cursor trail */}
            <div
              className="cursor-trail"
              style={{
                position: 'fixed',
                left: x,
                top: y,
                width: '30px',
                height: '30px',
                borderRadius: '50%',
                backgroundColor: `rgba(100, 100, 255, ${Math.min(speed / 1000, 0.8)})`,
                transform: 'translate(-50%, -50%)',
                transition: 'all 0.3s ease-out',
                pointerEvents: 'none'
              }}
            />
            
            {/* Parallax effect */}
            <div
              style={{
                position: 'absolute',
                left: '50%',
                top: '50%',
                transform: `translate(${(x - window.innerWidth / 2) * 0.1}px, ${(y - window.innerHeight / 2) * 0.1}px)`,
                fontSize: '48px'
              }}
            >
              🎯
            </div>
          </>
        )}
      </MouseTracker>
    </div>
  );
}