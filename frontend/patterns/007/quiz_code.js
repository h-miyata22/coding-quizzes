// 使用例
const gameScore = createScoreTracker();

// 基本的なスコア追加
gameScore.addPoints(100);
console.log(gameScore.getScore()); // 100

// コンボを増やしてスコア追加
gameScore.increaseCombo(); // コンボ1
gameScore.addPoints(100); // 100 * 1.2 = 120
console.log(gameScore.getScore()); // 220

gameScore.increaseCombo(); // コンボ2
gameScore.addPoints(100); // 100 * 1.5 = 150
console.log(gameScore.getScore()); // 370

// コンボをさらに増やす
gameScore.increaseCombo(); // コンボ3
gameScore.increaseCombo(); // コンボ4
gameScore.increaseCombo(); // コンボ5（最大）
gameScore.increaseCombo(); // コンボ5のまま（最大値で制限）
gameScore.addPoints(100); // 100 * 3 = 300
console.log(gameScore.getScore()); // 670

// コンボリセット
gameScore.resetCombo();
gameScore.addPoints(100); // コンボなしなので100
console.log(gameScore.getScore()); // 770

// 最高スコアの確認
console.log(gameScore.getHighScore()); // 770

// スコアリセット
gameScore.reset();
console.log(gameScore.getScore()); // 0
console.log(gameScore.getHighScore()); // 770（最高スコアは保持）

// プライベート変数にはアクセスできない
console.log(gameScore.score); // undefined
console.log(gameScore.combo); // undefined