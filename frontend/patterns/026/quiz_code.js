// 使用例
import React from 'react';

// 基本的な使用方法
function App() {
  return (
    <LanguageProvider>
      <MainLayout />
    </LanguageProvider>
  );
}

function MainLayout() {
  const { t, language, setLanguage } = useTranslation();
  
  return (
    <div>
      <header>
        <h1>{t('app.title')}</h1>
        <select value={language} onChange={(e) => setLanguage(e.target.value)}>
          <option value="en">English</option>
          <option value="ja">日本語</option>
        </select>
      </header>
      
      <main>
        <p>{t('welcome.message')}</p>
      </main>
    </div>
  );
}

// 動的な値の埋め込み
function UserGreeting({ userName, messageCount }) {
  const { t } = useTranslation();
  
  return (
    <div>
      <h2>{t('greeting.hello', { name: userName })}</h2>
      <p>{t('messages.count', { count: messageCount })}</p>
      <p>{t('lastLogin', { date: new Date().toLocaleDateString() })}</p>
    </div>
  );
}

// ネストされた翻訳キー
function Navigation() {
  const { t } = useTranslation();
  
  return (
    <nav>
      <a href="/">{t('nav.home')}</a>
      <a href="/products">{t('nav.products')}</a>
      <a href="/about">{t('nav.about')}</a>
      <a href="/contact">{t('nav.contact')}</a>
    </nav>
  );
}

// フォーム with 翻訳
function ContactForm() {
  const { t } = useTranslation();
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    message: ''
  });
  
  return (
    <form>
      <h2>{t('contact.title')}</h2>
      
      <label>
        {t('contact.form.name')}
        <input
          type="text"
          placeholder={t('contact.form.namePlaceholder')}
          value={formData.name}
          onChange={(e) => setFormData({ ...formData, name: e.target.value })}
        />
      </label>
      
      <label>
        {t('contact.form.email')}
        <input
          type="email"
          placeholder={t('contact.form.emailPlaceholder')}
          value={formData.email}
          onChange={(e) => setFormData({ ...formData, email: e.target.value })}
        />
      </label>
      
      <label>
        {t('contact.form.message')}
        <textarea
          placeholder={t('contact.form.messagePlaceholder')}
          value={formData.message}
          onChange={(e) => setFormData({ ...formData, message: e.target.value })}
        />
      </label>
      
      <button type="submit">{t('contact.form.submit')}</button>
    </form>
  );
}

// 言語切り替えコンポーネント
function LanguageSelector() {
  const { language, setLanguage, availableLanguages } = useTranslation();
  
  return (
    <div className="language-selector">
      {availableLanguages.map(lang => (
        <button
          key={lang.code}
          onClick={() => setLanguage(lang.code)}
          className={language === lang.code ? 'active' : ''}
        >
          <span>{lang.flag}</span>
          <span>{lang.name}</span>
        </button>
      ))}
    </div>
  );
}

// エラーメッセージの翻訳
function ErrorDisplay({ errorCode }) {
  const { t } = useTranslation();
  
  const errorMessages = {
    404: t('errors.notFound'),
    403: t('errors.forbidden'),
    500: t('errors.serverError'),
    default: t('errors.generic')
  };
  
  return (
    <div className="error-message">
      <h2>{t('errors.title')}</h2>
      <p>{errorMessages[errorCode] || errorMessages.default}</p>
    </div>
  );
}

// 複数形の処理
function ItemCounter({ count }) {
  const { t } = useTranslation();
  
  return (
    <div>
      <p>{t('items.count', { count })}</p>
      {/* 
        Expected behavior:
        - count = 0: "No items"
        - count = 1: "1 item"
        - count > 1: "X items"
      */}
    </div>
  );
}

// 日付のローカライズ
function DateDisplay({ date }) {
  const { t, language } = useTranslation();
  
  const formattedDate = new Date(date).toLocaleDateString(
    language === 'ja' ? 'ja-JP' : 'en-US',
    { year: 'numeric', month: 'long', day: 'numeric' }
  );
  
  return (
    <div>
      <p>{t('date.label')}: {formattedDate}</p>
    </div>
  );
}

// 翻訳データの例
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
      count: '{{count}} item(s)'
    },
    date: {
      label: 'Date'
    }
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
      count: '{{count}}個のアイテム'
    },
    date: {
      label: '日付'
    }
  }
};