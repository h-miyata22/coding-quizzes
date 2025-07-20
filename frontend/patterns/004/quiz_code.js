// 使用例
const userSchema = {
  name: {
    validate: (value) => typeof value === 'string' && value.length >= 2,
    message: '名前は2文字以上の文字列である必要があります'
  },
  age: {
    validate: (value) => typeof value === 'number' && value >= 0 && value <= 150,
    message: '年齢は0-150の数値である必要があります'
  },
  email: {
    validate: (value) => typeof value === 'string' && /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value),
    message: '有効なメールアドレスを入力してください'
  }
};

const user = createValidatedObject(userSchema);

// 正常な値の設定
user.name = 'Alice';
user.age = 25;
user.email = 'alice@example.com';
console.log(user.name); // 'Alice'

// バリデーションエラー
try {
  user.name = 'A'; // 短すぎる
} catch (error) {
  console.error(error.message); // '名前は2文字以上の文字列である必要があります'
}

try {
  user.age = -5; // 負の値
} catch (error) {
  console.error(error.message); // '年齢は0-150の数値である必要があります'
}

try {
  user.email = 'invalid-email'; // 不正なフォーマット
} catch (error) {
  console.error(error.message); // '有効なメールアドレスを入力してください'
}

try {
  user.unknownField = 'value'; // 存在しないプロパティ
} catch (error) {
  console.error(error.message); // 'プロパティ unknownField は定義されていません'
}