import { useState, useCallback } from 'react';

function useToggle(initialValue = false) {
  const [value, setValue] = useState(initialValue);
  
  const toggle = useCallback(() => {
    setValue(prev => !prev);
  }, []);
  
  const setOn = useCallback(() => {
    setValue(true);
  }, []);
  
  const setOff = useCallback(() => {
    setValue(false);
  }, []);
  
  const setValueWrapper = useCallback((newValue) => {
    setValue(newValue);
  }, []);
  
  return [
    value,
    {
      toggle,
      setOn,
      setOff,
      setValue: setValueWrapper
    }
  ];
}

// TypeScript版の型定義
/*
type UseToggleReturn = [
  boolean,
  {
    toggle: () => void;
    setOn: () => void;
    setOff: () => void;
    setValue: (value: boolean) => void;
  }
];

function useToggle(initialValue: boolean = false): UseToggleReturn {
  // 実装は同じ
}
*/

export default useToggle;