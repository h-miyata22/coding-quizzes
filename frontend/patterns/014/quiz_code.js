// 使用例

// アニメーションキューの作成
const queue = new AnimationQueue();

// アニメーションコマンドの定義
class MoveCommand {
  constructor(element, x, y, duration) {
    this.element = element;
    this.x = x;
    this.y = y;
    this.duration = duration;
  }
  
  async execute() {
    console.log(`Moving ${this.element} to (${this.x}, ${this.y}) over ${this.duration}ms`);
    // 実際のアニメーション処理をシミュレート
    return new Promise(resolve => setTimeout(resolve, this.duration));
  }
}

class FadeCommand {
  constructor(element, opacity, duration) {
    this.element = element;
    this.opacity = opacity;
    this.duration = duration;
  }
  
  async execute() {
    console.log(`Fading ${this.element} to opacity ${this.opacity} over ${this.duration}ms`);
    return new Promise(resolve => setTimeout(resolve, this.duration));
  }
}

class ScaleCommand {
  constructor(element, scale, duration) {
    this.element = element;
    this.scale = scale;
    this.duration = duration;
  }
  
  async execute() {
    console.log(`Scaling ${this.element} to ${this.scale}x over ${this.duration}ms`);
    return new Promise(resolve => setTimeout(resolve, this.duration));
  }
}

// コマンドをキューに追加
queue.add(new MoveCommand('box1', 100, 100, 1000));
queue.add(new FadeCommand('box1', 0.5, 500));
queue.add(new ScaleCommand('box1', 2, 800));
queue.add(new MoveCommand('box2', 200, 50, 1200));
queue.add(new FadeCommand('box2', 0, 600));

// 完了時のコールバック設定
queue.onComplete(() => {
  console.log('All animations completed!');
});

// アニメーション開始
queue.play();
// Output:
// Moving box1 to (100, 100) over 1000ms
// ...1秒後...
// Fading box1 to opacity 0.5 over 500ms
// ...0.5秒後...
// Scaling box1 to 2x over 800ms
// ...以下続く...

// 実行中に一時停止（2秒後）
setTimeout(() => {
  queue.pause();
  console.log('Queue paused');
}, 2000);

// 再開（4秒後）
setTimeout(() => {
  queue.play();
  console.log('Queue resumed');
}, 4000);

// 現在のコマンドをスキップ（5秒後）
setTimeout(() => {
  queue.skip();
  console.log('Current command skipped');
}, 5000);

// 別のキューを作成
const queue2 = new AnimationQueue();
queue2.add(new FadeCommand('modal', 1, 300));
queue2.add(new ScaleCommand('modal', 1.1, 200));

// 実行して途中で停止
queue2.play();
setTimeout(() => {
  queue2.stop();
  console.log('Queue stopped and reset');
  // 再度最初から実行可能
  queue2.play();
}, 250);