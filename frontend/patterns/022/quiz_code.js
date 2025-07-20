// 使用例
import React, { useState } from 'react';

// 基本的な使用方法
function BasicDropdown() {
  return (
    <Dropdown>
      <Dropdown.Trigger>
        <button>Options ▼</button>
      </Dropdown.Trigger>
      <Dropdown.Menu>
        <Dropdown.Item onSelect={() => console.log('Edit')}>
          Edit
        </Dropdown.Item>
        <Dropdown.Item onSelect={() => console.log('Duplicate')}>
          Duplicate
        </Dropdown.Item>
        <Dropdown.Item onSelect={() => console.log('Delete')}>
          Delete
        </Dropdown.Item>
      </Dropdown.Menu>
    </Dropdown>
  );
}

// ユーザーメニュー
function UserMenu() {
  const [user, setUser] = useState({ name: 'John Doe', role: 'Admin' });
  
  const handleLogout = () => {
    console.log('Logging out...');
    // Logout logic
  };
  
  return (
    <Dropdown>
      <Dropdown.Trigger>
        <button className="user-button">
          <span>👤</span>
          <span>{user.name}</span>
          <span>▼</span>
        </button>
      </Dropdown.Trigger>
      <Dropdown.Menu>
        <Dropdown.Item onSelect={() => console.log('Profile')}>
          My Profile
        </Dropdown.Item>
        <Dropdown.Item onSelect={() => console.log('Settings')}>
          Settings
        </Dropdown.Item>
        <Dropdown.Item disabled>
          Admin Panel (Coming Soon)
        </Dropdown.Item>
        <Dropdown.Item onSelect={handleLogout}>
          Sign Out
        </Dropdown.Item>
      </Dropdown.Menu>
    </Dropdown>
  );
}

// アイコン付きメニュー
function ActionMenu() {
  const actions = [
    { id: 'copy', label: 'Copy', icon: '📋' },
    { id: 'paste', label: 'Paste', icon: '📄' },
    { id: 'cut', label: 'Cut', icon: '✂️' },
    { id: 'share', label: 'Share', icon: '🔗' }
  ];
  
  const handleAction = (actionId) => {
    console.log(`Action performed: ${actionId}`);
  };
  
  return (
    <Dropdown>
      <Dropdown.Trigger>
        <button>Actions</button>
      </Dropdown.Trigger>
      <Dropdown.Menu>
        {actions.map(action => (
          <Dropdown.Item 
            key={action.id}
            onSelect={() => handleAction(action.id)}
          >
            <span>{action.icon}</span>
            <span>{action.label}</span>
          </Dropdown.Item>
        ))}
      </Dropdown.Menu>
    </Dropdown>
  );
}

// ネストされたコンテンツ
function RichDropdown() {
  return (
    <Dropdown>
      <Dropdown.Trigger>
        <button>View Options</button>
      </Dropdown.Trigger>
      <Dropdown.Menu>
        <div style={{ padding: '8px 12px', fontWeight: 'bold' }}>
          Display Settings
        </div>
        <Dropdown.Item onSelect={() => console.log('Grid')}>
          <input type="radio" name="view" /> Grid View
        </Dropdown.Item>
        <Dropdown.Item onSelect={() => console.log('List')}>
          <input type="radio" name="view" /> List View
        </Dropdown.Item>
        <hr style={{ margin: '8px 0' }} />
        <div style={{ padding: '8px 12px', fontWeight: 'bold' }}>
          Sort By
        </div>
        <Dropdown.Item onSelect={() => console.log('Name')}>
          Name
        </Dropdown.Item>
        <Dropdown.Item onSelect={() => console.log('Date')}>
          Date Modified
        </Dropdown.Item>
        <Dropdown.Item onSelect={() => console.log('Size')}>
          Size
        </Dropdown.Item>
      </Dropdown.Menu>
    </Dropdown>
  );
}

// 制御されたドロップダウン
function ControlledDropdown() {
  const [isOpen, setIsOpen] = useState(false);
  const [selectedItem, setSelectedItem] = useState(null);
  
  const items = ['Small', 'Medium', 'Large', 'Extra Large'];
  
  return (
    <div>
      <Dropdown open={isOpen} onOpenChange={setIsOpen}>
        <Dropdown.Trigger>
          <button>
            Size: {selectedItem || 'Select'} ▼
          </button>
        </Dropdown.Trigger>
        <Dropdown.Menu>
          {items.map(item => (
            <Dropdown.Item
              key={item}
              onSelect={() => {
                setSelectedItem(item);
                setIsOpen(false);
              }}
            >
              {item}
            </Dropdown.Item>
          ))}
        </Dropdown.Menu>
      </Dropdown>
      
      <p>Selected: {selectedItem || 'None'}</p>
    </div>
  );
}

// カスタムスタイリング
function StyledDropdown() {
  return (
    <Dropdown className="custom-dropdown">
      <Dropdown.Trigger>
        <button className="styled-trigger">
          Theme Options
        </button>
      </Dropdown.Trigger>
      <Dropdown.Menu className="styled-menu">
        <Dropdown.Item className="styled-item" onSelect={() => {}}>
          🌞 Light Mode
        </Dropdown.Item>
        <Dropdown.Item className="styled-item" onSelect={() => {}}>
          🌙 Dark Mode
        </Dropdown.Item>
        <Dropdown.Item className="styled-item" onSelect={() => {}}>
          🎨 Auto
        </Dropdown.Item>
      </Dropdown.Menu>
    </Dropdown>
  );
}

// 長いリストのドロップダウン
function CountrySelector() {
  const countries = [
    'United States', 'Canada', 'Mexico', 'Brazil', 'Argentina',
    'United Kingdom', 'France', 'Germany', 'Italy', 'Spain',
    'Japan', 'China', 'India', 'Australia', 'New Zealand'
  ];
  
  return (
    <Dropdown>
      <Dropdown.Trigger>
        <button>Select Country ▼</button>
      </Dropdown.Trigger>
      <Dropdown.Menu style={{ maxHeight: '200px', overflowY: 'auto' }}>
        {countries.map(country => (
          <Dropdown.Item 
            key={country}
            onSelect={() => console.log(`Selected: ${country}`)}
          >
            {country}
          </Dropdown.Item>
        ))}
      </Dropdown.Menu>
    </Dropdown>
  );
}