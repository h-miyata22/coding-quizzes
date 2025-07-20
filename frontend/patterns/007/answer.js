function createScoreTracker() {
  // プライベート変数
  let score = 0;
  let highScore = 0;
  let combo = 0;
  
  // コンボ倍率の定義
  const comboMultipliers = {
    0: 1,
    1: 1.2,
    2: 1.5,
    3: 2,
    4: 2.5,
    5: 3
  };
  
  // パブリックメソッドを返す
  return {
    addPoints(points) {
      const multiplier = comboMultipliers[combo];
      const earnedPoints = Math.floor(points * multiplier);
      score += earnedPoints;
      
      // 最高スコアの更新
      if (score > highScore) {
        highScore = score;
      }
      
      return earnedPoints;
    },
    
    increaseCombo() {
      if (combo < 5) {
        combo++;
      }
      return combo;
    },
    
    resetCombo() {
      combo = 0;
      return combo;
    },
    
    getScore() {
      return score;
    },
    
    getHighScore() {
      return highScore;
    },
    
    reset() {
      score = 0;
      combo = 0;
      // highScoreは保持
    }
  };
}