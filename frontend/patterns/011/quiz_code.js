// 使用例

// 初回のインスタンス作成
const config1 = new AppConfig({
  apiUrl: 'https://api.example.com',
  theme: 'light',
  language: 'ja',
  debug: false
});

// 設定の取得
console.log(config1.get('apiUrl')); // 'https://api.example.com'
console.log(config1.get('theme')); // 'light'

// 変更の監視
const unsubscribe = config1.onChange((key, newValue, oldValue) => {
  console.log(`Config changed: ${key} from ${oldValue} to ${newValue}`);
});

// 設定の更新
config1.set('theme', 'dark');
// Output: Config changed: theme from light to dark

// 別の場所でインスタンス化（同じインスタンスが返される）
const config2 = new AppConfig();
console.log(config2.get('theme')); // 'dark' (config1で変更済み)
console.log(config1 === config2); // true

// 一括更新
config1.update({
  apiUrl: 'https://api-v2.example.com',
  language: 'en'
});
// Output: Config changed: apiUrl from https://api.example.com to https://api-v2.example.com
// Output: Config changed: language from ja to en

// ES6モジュールからのインポートでも同じインスタンス
import { AppConfig as ImportedConfig } from './config.js';
const config3 = new ImportedConfig();
console.log(config3 === config1); // true

// 設定の凍結
config1.freeze();
try {
  config1.set('debug', true); // エラー
} catch (error) {
  console.error(error.message); // 'Configuration is frozen and cannot be modified'
}

// 監視の解除
unsubscribe();

// リセット（凍結状態も解除される）
config1.reset();
console.log(config1.get('theme')); // 'light' (初期値に戻る)