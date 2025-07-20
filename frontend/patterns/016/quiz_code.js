// 使用例
import React, { useState, useEffect } from 'react';

// 検索コンポーネントでの使用
function SearchBox() {
  const [searchTerm, setSearchTerm] = useState('');
  const debouncedSearchTerm = useDebounce(searchTerm, 500);
  const [results, setResults] = useState([]);
  const [isSearching, setIsSearching] = useState(false);
  
  // デバウンスされた値が変更されたときのみAPIを呼ぶ
  useEffect(() => {
    if (debouncedSearchTerm) {
      setIsSearching(true);
      searchAPI(debouncedSearchTerm).then(data => {
        setResults(data);
        setIsSearching(false);
      });
    } else {
      setResults([]);
    }
  }, [debouncedSearchTerm]);
  
  return (
    <div>
      <input
        type="text"
        placeholder="Search..."
        value={searchTerm}
        onChange={(e) => setSearchTerm(e.target.value)}
      />
      {isSearching && <div>Searching...</div>}
      <ul>
        {results.map(item => (
          <li key={item.id}>{item.name}</li>
        ))}
      </ul>
    </div>
  );
}

// 自動保存での使用
function AutoSaveEditor() {
  const [content, setContent] = useState('');
  const debouncedContent = useDebounce(content, 1000);
  const [saveStatus, setSaveStatus] = useState('saved');
  
  useEffect(() => {
    if (debouncedContent) {
      setSaveStatus('saving...');
      saveContent(debouncedContent).then(() => {
        setSaveStatus('saved');
      });
    }
  }, [debouncedContent]);
  
  return (
    <div>
      <textarea
        value={content}
        onChange={(e) => {
          setContent(e.target.value);
          setSaveStatus('typing...');
        }}
      />
      <div>Status: {saveStatus}</div>
    </div>
  );
}

// 動的な遅延時間での使用
function DynamicDelayExample() {
  const [value, setValue] = useState('');
  const [delay, setDelay] = useState(300);
  const debouncedValue = useDebounce(value, delay);
  
  return (
    <div>
      <input
        type="text"
        value={value}
        onChange={(e) => setValue(e.target.value)}
      />
      <input
        type="range"
        min="0"
        max="2000"
        value={delay}
        onChange={(e) => setDelay(Number(e.target.value))}
      />
      <div>Delay: {delay}ms</div>
      <div>Input: {value}</div>
      <div>Debounced: {debouncedValue}</div>
    </div>
  );
}

// フォームバリデーションでの使用
function ValidationForm() {
  const [email, setEmail] = useState('');
  const debouncedEmail = useDebounce(email, 800);
  const [validationMessage, setValidationMessage] = useState('');
  
  useEffect(() => {
    if (debouncedEmail) {
      // 複雑なバリデーションや重複チェック
      validateEmail(debouncedEmail).then(result => {
        setValidationMessage(result.message);
      });
    }
  }, [debouncedEmail]);
  
  return (
    <div>
      <input
        type="email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        placeholder="Enter email"
      />
      {validationMessage && <div>{validationMessage}</div>}
    </div>
  );
}

// API関数のモック
async function searchAPI(term) {
  // 実際のAPI呼び出しをシミュレート
  await new Promise(resolve => setTimeout(resolve, 200));
  return [
    { id: 1, name: `Result for ${term} 1` },
    { id: 2, name: `Result for ${term} 2` }
  ];
}

async function saveContent(content) {
  await new Promise(resolve => setTimeout(resolve, 300));
  return { success: true };
}

async function validateEmail(email) {
  await new Promise(resolve => setTimeout(resolve, 100));
  const isValid = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
  return {
    message: isValid ? '✓ Valid email' : '✗ Invalid email format'
  };
}