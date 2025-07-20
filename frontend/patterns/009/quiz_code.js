// 使用例
const APP = createNamespace('APP');

// ユーティリティモジュールの定義
APP.define('utils.string', {
  capitalize: (str) => str.charAt(0).toUpperCase() + str.slice(1),
  truncate: (str, length) => str.length > length ? str.slice(0, length) + '...' : str
});

APP.define('utils.date', {
  format: (date) => date.toISOString().split('T')[0],
  addDays: (date, days) => new Date(date.getTime() + days * 24 * 60 * 60 * 1000)
});

// サービスモジュールの定義
APP.define('services.api', {
  baseURL: 'https://api.example.com',
  get: (endpoint) => console.log(`GET ${endpoint}`),
  post: (endpoint, data) => console.log(`POST ${endpoint}`, data)
});

APP.define('services.auth', {
  login: (username, password) => console.log('Logging in...'),
  logout: () => console.log('Logging out...'),
  isAuthenticated: () => true
});

// コンポーネントモジュールの定義
APP.define('components.header', {
  render: () => '<header>App Header</header>',
  update: (props) => console.log('Updating header', props)
});

// モジュールの使用
const stringUtils = APP.get('utils.string');
console.log(stringUtils.capitalize('hello')); // 'Hello'

const authService = APP.get('services.auth');
authService.login('user', 'pass'); // 'Logging in...'

// 存在確認
console.log(APP.exists('utils.string')); // true
console.log(APP.exists('utils.array')); // false

// ネストしたアクセス
const utils = APP.get('utils');
console.log(utils.string.truncate('Long text here', 8)); // 'Long tex...'

// 既存モジュールの上書き防止
try {
  APP.define('utils.string', { /* 新しい実装 */ });
} catch (error) {
  console.error(error.message); // 'Module utils.string already exists'
}

// 深い階層の名前空間
APP.define('components.forms.input', {
  type: 'text',
  validate: (value) => value.length > 0
});

const inputComponent = APP.get('components.forms.input');
console.log(inputComponent.validate('test')); // true