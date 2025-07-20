import React, { createContext, useContext, useState, useEffect, useCallback } from 'react';

// Language Context
const LanguageContext = createContext();

// Translation data structure
const translations = {
  en: {
    app: {
      title: 'My Application'
    },
    welcome: {
      message: 'Welcome to our application!'
    },
    greeting: {
      hello: 'Hello, {{name}}!'
    },
    messages: {
      count: 'You have {{count}} messages'
    },
    nav: {
      home: 'Home',
      products: 'Products',
      about: 'About',
      contact: 'Contact'
    },
    contact: {
      title: 'Contact Us',
      form: {
        name: 'Name',
        namePlaceholder: 'Enter your name',
        email: 'Email',
        emailPlaceholder: 'Enter your email',
        message: 'Message',
        messagePlaceholder: 'Enter your message',
        submit: 'Send'
      }
    },
    errors: {
      title: 'Error',
      notFound: 'Page not found',
      forbidden: 'Access denied',
      serverError: 'Server error',
      generic: 'Something went wrong'
    },
    items: {
      count_zero: 'No items',
      count_one: '1 item',
      count_other: '{{count}} items'
    },
    date: {
      label: 'Date'
    },
    lastLogin: 'Last login: {{date}}'
  },
  ja: {
    app: {
      title: 'マイアプリケーション'
    },
    welcome: {
      message: 'アプリケーションへようこそ！'
    },
    greeting: {
      hello: 'こんにちは、{{name}}さん！'
    },
    messages: {
      count: '{{count}}件のメッセージがあります'
    },
    nav: {
      home: 'ホーム',
      products: '製品',
      about: '私たちについて',
      contact: 'お問い合わせ'
    },
    contact: {
      title: 'お問い合わせ',
      form: {
        name: 'お名前',
        namePlaceholder: 'お名前を入力してください',
        email: 'メールアドレス',
        emailPlaceholder: 'メールアドレスを入力してください',
        message: 'メッセージ',
        messagePlaceholder: 'メッセージを入力してください',
        submit: '送信'
      }
    },
    errors: {
      title: 'エラー',
      notFound: 'ページが見つかりません',
      forbidden: 'アクセスが拒否されました',
      serverError: 'サーバーエラー',
      generic: '何か問題が発生しました'
    },
    items: {
      count_zero: 'アイテムなし',
      count_other: '{{count}}個のアイテム'
    },
    date: {
      label: '日付'
    },
    lastLogin: '最終ログイン: {{date}}'
  }
};

// Available languages configuration
const availableLanguages = [
  { code: 'en', name: 'English', flag: '🇺🇸' },
  { code: 'ja', name: '日本語', flag: '🇯🇵' }
];

// Custom hook to use translation
export const useTranslation = () => {
  const context = useContext(LanguageContext);
  if (!context) {
    throw new Error('useTranslation must be used within a LanguageProvider');
  }
  return context;
};

// Helper function to get nested value from object
const getNestedValue = (obj, path, defaultValue = '') => {
  const keys = path.split('.');
  let value = obj;
  
  for (const key of keys) {
    if (value && typeof value === 'object' && key in value) {
      value = value[key];
    } else {
      return defaultValue;
    }
  }
  
  return value || defaultValue;
};

// Helper function to replace placeholders
const interpolate = (template, values = {}) => {
  if (typeof template !== 'string') return template;
  
  return template.replace(/\{\{(\w+)\}\}/g, (match, key) => {
    return values[key] !== undefined ? values[key] : match;
  });
};

// Helper function for pluralization
const getPluralKey = (key, count) => {
  if (count === 0 && translations.en[key + '_zero']) {
    return key + '_zero';
  } else if (count === 1 && translations.en[key + '_one']) {
    return key + '_one';
  } else {
    return key + '_other';
  }
};

// Language Provider component
export function LanguageProvider({ children, defaultLanguage = 'en' }) {
  const [language, setLanguage] = useState(() => {
    // Get saved language from localStorage
    if (typeof window !== 'undefined') {
      const saved = localStorage.getItem('language');
      if (saved && translations[saved]) {
        return saved;
      }
      
      // Try to detect browser language
      const browserLang = navigator.language.slice(0, 2);
      if (translations[browserLang]) {
        return browserLang;
      }
    }
    return defaultLanguage;
  });
  
  // Get current translations
  const currentTranslations = translations[language] || translations[defaultLanguage];
  
  // Save language preference
  useEffect(() => {
    if (typeof window !== 'undefined') {
      localStorage.setItem('language', language);
    }
  }, [language]);
  
  // Translation function
  const t = useCallback((key, params = {}) => {
    // Handle pluralization
    let translationKey = key;
    if ('count' in params) {
      const baseKey = key.replace(/_zero$|_one$|_other$/, '');
      const pluralKey = getPluralKey(baseKey, params.count);
      
      // Check if plural form exists
      if (getNestedValue(currentTranslations, pluralKey)) {
        translationKey = pluralKey;
      }
    }
    
    // Get translation
    let translation = getNestedValue(currentTranslations, translationKey);
    
    // Fallback to default language
    if (!translation && language !== defaultLanguage) {
      translation = getNestedValue(translations[defaultLanguage], translationKey);
    }
    
    // Fallback to key
    if (!translation) {
      console.warn(`Translation missing for key: ${translationKey}`);
      return key;
    }
    
    // Interpolate values
    return interpolate(translation, params);
  }, [currentTranslations, language, defaultLanguage]);
  
  // Language setter with validation
  const setLanguageWithValidation = useCallback((newLanguage) => {
    if (translations[newLanguage]) {
      setLanguage(newLanguage);
    } else {
      console.error(`Language '${newLanguage}' is not available`);
    }
  }, []);
  
  // Get all translation keys (useful for development)
  const getTranslationKeys = useCallback(() => {
    const keys = [];
    const extractKeys = (obj, prefix = '') => {
      Object.keys(obj).forEach(key => {
        const fullKey = prefix ? `${prefix}.${key}` : key;
        if (typeof obj[key] === 'object' && !Array.isArray(obj[key])) {
          extractKeys(obj[key], fullKey);
        } else {
          keys.push(fullKey);
        }
      });
    };
    extractKeys(currentTranslations);
    return keys;
  }, [currentTranslations]);
  
  // Check if translation exists
  const hasTranslation = useCallback((key) => {
    return !!getNestedValue(currentTranslations, key);
  }, [currentTranslations]);
  
  // Context value
  const contextValue = {
    language,
    setLanguage: setLanguageWithValidation,
    t,
    availableLanguages,
    getTranslationKeys,
    hasTranslation
  };
  
  return (
    <LanguageContext.Provider value={contextValue}>
      {children}
    </LanguageContext.Provider>
  );
}

// Optional: Language detector component
export function LanguageDetector({ children }) {
  const { setLanguage } = useTranslation();
  
  useEffect(() => {
    // Detect language from URL parameter
    const params = new URLSearchParams(window.location.search);
    const langParam = params.get('lang');
    if (langParam && translations[langParam]) {
      setLanguage(langParam);
    }
  }, [setLanguage]);
  
  return children;
}

// Optional: Translation component for inline translations
export function Trans({ i18nKey, values, children }) {
  const { t } = useTranslation();
  
  if (i18nKey) {
    return <>{t(i18nKey, values)}</>;
  }
  
  return <>{children}</>;
}