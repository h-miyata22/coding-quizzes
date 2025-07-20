// 使用例
import React from 'react';

// 基本的な使用方法
function App() {
  return (
    <ThemeProvider>
      <Layout />
    </ThemeProvider>
  );
}

function Layout() {
  const { theme, toggleTheme } = useTheme();
  
  return (
    <div className="app-container">
      <header>
        <h1>My Application</h1>
        <button onClick={toggleTheme}>
          {theme === 'light' ? '🌙' : '☀️'} Switch to {theme === 'light' ? 'Dark' : 'Light'} Mode
        </button>
      </header>
      <main>
        <p>Current theme: {theme}</p>
      </main>
    </div>
  );
}

// カスタムカラー設定
function ColorCustomizer() {
  const { primaryColor, setPrimaryColor, theme } = useTheme();
  
  const colors = [
    { name: 'Blue', value: '#3b82f6' },
    { name: 'Green', value: '#10b981' },
    { name: 'Purple', value: '#8b5cf6' },
    { name: 'Red', value: '#ef4444' },
    { name: 'Orange', value: '#f97316' }
  ];
  
  return (
    <div className="color-customizer">
      <h2>Customize Theme</h2>
      <p>Current theme: {theme}</p>
      <div className="color-options">
        {colors.map(color => (
          <button
            key={color.name}
            onClick={() => setPrimaryColor(color.value)}
            style={{
              backgroundColor: color.value,
              border: primaryColor === color.value ? '3px solid black' : 'none'
            }}
            aria-label={`Set primary color to ${color.name}`}
          >
            {primaryColor === color.value && '✓'}
          </button>
        ))}
      </div>
    </div>
  );
}

// テーマ依存のスタイリング
function ThemedCard({ title, content }) {
  const { theme, primaryColor } = useTheme();
  
  return (
    <div
      className={`card card--${theme}`}
      style={{
        '--primary-color': primaryColor,
        backgroundColor: theme === 'light' ? '#ffffff' : '#1f2937',
        color: theme === 'light' ? '#000000' : '#ffffff',
        borderColor: primaryColor
      }}
    >
      <h3 style={{ color: primaryColor }}>{title}</h3>
      <p>{content}</p>
    </div>
  );
}

// 高度な設定パネル
function ThemeSettings() {
  const { 
    theme, 
    setTheme, 
    primaryColor, 
    setPrimaryColor,
    followSystem,
    setFollowSystem 
  } = useTheme();
  
  return (
    <div className="theme-settings">
      <h2>Theme Settings</h2>
      
      <div className="setting-group">
        <label>
          <input
            type="checkbox"
            checked={followSystem}
            onChange={(e) => setFollowSystem(e.target.checked)}
          />
          Follow system theme
        </label>
      </div>
      
      {!followSystem && (
        <div className="setting-group">
          <label>Theme Mode</label>
          <select value={theme} onChange={(e) => setTheme(e.target.value)}>
            <option value="light">Light</option>
            <option value="dark">Dark</option>
          </select>
        </div>
      )}
      
      <div className="setting-group">
        <label>Primary Color</label>
        <input
          type="color"
          value={primaryColor}
          onChange={(e) => setPrimaryColor(e.target.value)}
        />
      </div>
    </div>
  );
}

// ネストされたコンポーネントでのテーマ使用
function Dashboard() {
  return (
    <ThemeProvider>
      <DashboardHeader />
      <DashboardContent />
      <DashboardFooter />
    </ThemeProvider>
  );
}

function DashboardHeader() {
  const { theme, toggleTheme } = useTheme();
  
  return (
    <header className={`dashboard-header dashboard-header--${theme}`}>
      <h1>Dashboard</h1>
      <nav>
        <a href="#home">Home</a>
        <a href="#analytics">Analytics</a>
        <a href="#settings">Settings</a>
      </nav>
      <button onClick={toggleTheme} className="theme-toggle">
        {theme === 'light' ? '🌙' : '☀️'}
      </button>
    </header>
  );
}

// テーマに応じたチャート表示
function ThemedChart() {
  const { theme, primaryColor } = useTheme();
  
  const chartColors = {
    light: {
      background: '#f3f4f6',
      grid: '#e5e7eb',
      text: '#374151'
    },
    dark: {
      background: '#1f2937',
      grid: '#374151',
      text: '#d1d5db'
    }
  };
  
  return (
    <div className="chart-container">
      <canvas
        id="myChart"
        style={{
          backgroundColor: chartColors[theme].background,
          '--grid-color': chartColors[theme].grid,
          '--text-color': chartColors[theme].text,
          '--primary-color': primaryColor
        }}
      />
      <p style={{ color: chartColors[theme].text }}>
        Chart data visualization with theme support
      </p>
    </div>
  );
}

// CSS変数を使ったグローバルスタイリング
function GlobalThemedApp() {
  return (
    <ThemeProvider>
      <ThemedRoot />
    </ThemeProvider>
  );
}

function ThemedRoot() {
  const { theme, primaryColor } = useTheme();
  
  // CSS変数をルート要素に適用
  React.useEffect(() => {
    const root = document.documentElement;
    root.setAttribute('data-theme', theme);
    root.style.setProperty('--primary-color', primaryColor);
  }, [theme, primaryColor]);
  
  return (
    <div className="app">
      <nav>Navigation</nav>
      <main>
        <h1>Welcome</h1>
        <p>This app automatically adapts to your theme preferences.</p>
      </main>
      <footer>Footer</footer>
    </div>
  );
}