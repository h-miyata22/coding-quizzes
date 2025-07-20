// 使用例
const apiResponse = {
  user: {
    id: 1,
    name: 'Alice',
    roles: ['admin', 'user'],
    settings: {
      theme: 'dark',
      notifications: {
        email: true,
        push: false
      }
    }
  },
  metadata: {
    timestamp: Date.now(),
    version: '1.0.0'
  }
};

const immutableData = createImmutable(apiResponse);

// 読み取りは正常に動作
console.log(immutableData.user.name); // 'Alice'
console.log(immutableData.user.roles[0]); // 'admin'
console.log(immutableData.user.settings.theme); // 'dark'

// 書き込みはエラー
try {
  immutableData.user.name = 'Bob';
} catch (error) {
  console.error(error.message); // 'Cannot modify property name. Object is immutable.'
}

// ネストしたプロパティの変更もエラー
try {
  immutableData.user.settings.theme = 'light';
} catch (error) {
  console.error(error.message); // 'Cannot modify property theme. Object is immutable.'
}

// 配列の破壊的メソッドもエラー
try {
  immutableData.user.roles.push('moderator');
} catch (error) {
  console.error(error.message); // 'Cannot call method push. Array is immutable.'
}

// プロパティの削除もエラー
try {
  delete immutableData.metadata.version;
} catch (error) {
  console.error(error.message); // 'Cannot delete property version. Object is immutable.'
}

// 新しいプロパティの追加もエラー
try {
  immutableData.newProperty = 'value';
} catch (error) {
  console.error(error.message); // 'Cannot add property newProperty. Object is immutable.'
}