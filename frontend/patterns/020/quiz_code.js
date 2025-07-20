// 使用例
import React from 'react';

// 基本的な使用方法
function BasicTabs() {
  return (
    <Tabs defaultValue="tab1">
      <Tabs.List>
        <Tabs.Tab value="tab1">Profile</Tabs.Tab>
        <Tabs.Tab value="tab2">Settings</Tabs.Tab>
        <Tabs.Tab value="tab3">Notifications</Tabs.Tab>
      </Tabs.List>
      
      <Tabs.Panels>
        <Tabs.Panel value="tab1">
          <h2>Profile Content</h2>
          <p>Your profile information goes here.</p>
        </Tabs.Panel>
        <Tabs.Panel value="tab2">
          <h2>Settings Content</h2>
          <p>Application settings and preferences.</p>
        </Tabs.Panel>
        <Tabs.Panel value="tab3">
          <h2>Notifications</h2>
          <p>Manage your notification preferences.</p>
        </Tabs.Panel>
      </Tabs.Panels>
    </Tabs>
  );
}

// カスタムスタイリング
function StyledTabs() {
  return (
    <Tabs defaultValue="design" className="custom-tabs">
      <Tabs.List className="tab-list-horizontal">
        <Tabs.Tab value="design" className="tab-button">
          🎨 Design
        </Tabs.Tab>
        <Tabs.Tab value="code" className="tab-button">
          💻 Code
        </Tabs.Tab>
        <Tabs.Tab value="preview" className="tab-button">
          👁️ Preview
        </Tabs.Tab>
      </Tabs.List>
      
      <Tabs.Panels className="tab-panels-container">
        <Tabs.Panel value="design" className="tab-panel">
          <div>Design workspace</div>
        </Tabs.Panel>
        <Tabs.Panel value="code" className="tab-panel">
          <div>Code editor</div>
        </Tabs.Panel>
        <Tabs.Panel value="preview" className="tab-panel">
          <div>Live preview</div>
        </Tabs.Panel>
      </Tabs.Panels>
    </Tabs>
  );
}

// 制御されたコンポーネント
function ControlledTabs() {
  const [activeTab, setActiveTab] = useState('overview');
  
  return (
    <div>
      <p>Current tab: {activeTab}</p>
      
      <Tabs value={activeTab} onChange={setActiveTab}>
        <Tabs.List>
          <Tabs.Tab value="overview">Overview</Tabs.Tab>
          <Tabs.Tab value="analytics">Analytics</Tabs.Tab>
          <Tabs.Tab value="reports">Reports</Tabs.Tab>
        </Tabs.List>
        
        <Tabs.Panels>
          <Tabs.Panel value="overview">
            <h3>Overview Dashboard</h3>
          </Tabs.Panel>
          <Tabs.Panel value="analytics">
            <h3>Analytics Data</h3>
          </Tabs.Panel>
          <Tabs.Panel value="reports">
            <h3>Generated Reports</h3>
          </Tabs.Panel>
        </Tabs.Panels>
      </Tabs>
      
      <button onClick={() => setActiveTab('analytics')}>
        Go to Analytics
      </button>
    </div>
  );
}

// 垂直タブレイアウト
function VerticalTabs() {
  return (
    <Tabs defaultValue="general" orientation="vertical">
      <div style={{ display: 'flex' }}>
        <Tabs.List style={{ flexDirection: 'column' }}>
          <Tabs.Tab value="general">General</Tabs.Tab>
          <Tabs.Tab value="security">Security</Tabs.Tab>
          <Tabs.Tab value="privacy">Privacy</Tabs.Tab>
          <Tabs.Tab value="advanced">Advanced</Tabs.Tab>
        </Tabs.List>
        
        <Tabs.Panels style={{ marginLeft: '20px' }}>
          <Tabs.Panel value="general">
            <h3>General Settings</h3>
          </Tabs.Panel>
          <Tabs.Panel value="security">
            <h3>Security Settings</h3>
          </Tabs.Panel>
          <Tabs.Panel value="privacy">
            <h3>Privacy Settings</h3>
          </Tabs.Panel>
          <Tabs.Panel value="advanced">
            <h3>Advanced Settings</h3>
          </Tabs.Panel>
        </Tabs.Panels>
      </div>
    </Tabs>
  );
}

// 動的タブ
function DynamicTabs() {
  const [tabs, setTabs] = useState([
    { id: 'tab1', label: 'Tab 1', content: 'Content 1' },
    { id: 'tab2', label: 'Tab 2', content: 'Content 2' }
  ]);
  
  const addTab = () => {
    const newId = `tab${tabs.length + 1}`;
    setTabs([...tabs, {
      id: newId,
      label: `Tab ${tabs.length + 1}`,
      content: `Content ${tabs.length + 1}`
    }]);
  };
  
  return (
    <div>
      <button onClick={addTab}>Add Tab</button>
      
      <Tabs defaultValue={tabs[0]?.id}>
        <Tabs.List>
          {tabs.map(tab => (
            <Tabs.Tab key={tab.id} value={tab.id}>
              {tab.label}
            </Tabs.Tab>
          ))}
        </Tabs.List>
        
        <Tabs.Panels>
          {tabs.map(tab => (
            <Tabs.Panel key={tab.id} value={tab.id}>
              <div>{tab.content}</div>
            </Tabs.Panel>
          ))}
        </Tabs.Panels>
      </Tabs>
    </div>
  );
}

// アイコン付きタブ
function IconTabs() {
  return (
    <Tabs defaultValue="home">
      <Tabs.List aria-label="Navigation tabs">
        <Tabs.Tab value="home" aria-label="Home">
          <span>🏠</span>
          <span>Home</span>
        </Tabs.Tab>
        <Tabs.Tab value="search" aria-label="Search">
          <span>🔍</span>
          <span>Search</span>
        </Tabs.Tab>
        <Tabs.Tab value="favorites" aria-label="Favorites">
          <span>⭐</span>
          <span>Favorites</span>
        </Tabs.Tab>
        <Tabs.Tab value="profile" aria-label="Profile">
          <span>👤</span>
          <span>Profile</span>
        </Tabs.Tab>
      </Tabs.List>
      
      <Tabs.Panels>
        <Tabs.Panel value="home">Home content</Tabs.Panel>
        <Tabs.Panel value="search">Search interface</Tabs.Panel>
        <Tabs.Panel value="favorites">Favorite items</Tabs.Panel>
        <Tabs.Panel value="profile">User profile</Tabs.Panel>
      </Tabs.Panels>
    </Tabs>
  );
}