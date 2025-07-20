class AnimationQueue {
  constructor() {
    this.commands = [];
    this.currentIndex = 0;
    this.isPlaying = false;
    this.isPaused = false;
    this.currentPromise = null;
    this.completeCallback = null;
  }
  
  add(command) {
    this.commands.push(command);
    return this;
  }
  
  async play() {
    if (this.isPlaying && !this.isPaused) {
      return; // 既に実行中
    }
    
    if (this.isPaused) {
      this.isPaused = false;
      return; // 一時停止からの再開は現在のコマンドが完了するのを待つ
    }
    
    this.isPlaying = true;
    this.isPaused = false;
    
    while (this.currentIndex < this.commands.length && this.isPlaying) {
      if (this.isPaused) {
        // 一時停止中は待機
        await new Promise(resolve => {
          const checkInterval = setInterval(() => {
            if (!this.isPaused || !this.isPlaying) {
              clearInterval(checkInterval);
              resolve();
            }
          }, 100);
        });
        
        if (!this.isPlaying) {
          break;
        }
      }
      
      const command = this.commands[this.currentIndex];
      
      try {
        // コマンドを実行し、Promiseを保存
        this.currentPromise = command.execute();
        await this.currentPromise;
      } catch (error) {
        console.error('Command execution failed:', error);
      }
      
      this.currentIndex++;
    }
    
    // すべて完了
    if (this.currentIndex >= this.commands.length) {
      this.isPlaying = false;
      this.currentIndex = 0;
      
      if (this.completeCallback) {
        this.completeCallback();
      }
    }
  }
  
  pause() {
    if (this.isPlaying && !this.isPaused) {
      this.isPaused = true;
    }
  }
  
  stop() {
    this.isPlaying = false;
    this.isPaused = false;
    this.currentIndex = 0;
    this.currentPromise = null;
  }
  
  skip() {
    if (this.isPlaying && this.currentPromise) {
      // 現在のコマンドをスキップするフラグを立てる
      // 実際の実装では、コマンドに中断メカニズムが必要
      this.currentIndex++;
      
      // 強制的に次のコマンドへ
      if (this.currentIndex >= this.commands.length) {
        this.stop();
        if (this.completeCallback) {
          this.completeCallback();
        }
      }
    }
  }
  
  clear() {
    this.stop();
    this.commands = [];
  }
  
  onComplete(callback) {
    this.completeCallback = callback;
  }
}