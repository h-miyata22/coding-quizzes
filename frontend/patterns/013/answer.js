// TextEditorクラス
class TextEditor {
  constructor(initialText = '') {
    this.text = initialText;
    this.history = [];
  }
  
  execute(command) {
    command.execute(this);
    this.history.push(command);
  }
  
  undo() {
    if (!this.canUndo()) {
      return false;
    }
    
    const command = this.history.pop();
    command.undo(this);
    return true;
  }
  
  canUndo() {
    return this.history.length > 0;
  }
  
  getText() {
    return this.text;
  }
  
  setText(text) {
    this.text = text;
  }
}

// InsertCommandクラス
class InsertCommand {
  constructor(position, text) {
    this.position = position;
    this.text = text;
  }
  
  execute(editor) {
    const currentText = editor.getText();
    const newText = 
      currentText.slice(0, this.position) + 
      this.text + 
      currentText.slice(this.position);
    editor.setText(newText);
  }
  
  undo(editor) {
    const currentText = editor.getText();
    const newText = 
      currentText.slice(0, this.position) + 
      currentText.slice(this.position + this.text.length);
    editor.setText(newText);
  }
}

// DeleteCommandクラス
class DeleteCommand {
  constructor(position, length) {
    this.position = position;
    this.length = length;
    this.deletedText = null; // 削除されたテキストを保存
  }
  
  execute(editor) {
    const currentText = editor.getText();
    this.deletedText = currentText.slice(this.position, this.position + this.length);
    const newText = 
      currentText.slice(0, this.position) + 
      currentText.slice(this.position + this.length);
    editor.setText(newText);
  }
  
  undo(editor) {
    const currentText = editor.getText();
    const newText = 
      currentText.slice(0, this.position) + 
      this.deletedText + 
      currentText.slice(this.position);
    editor.setText(newText);
  }
}

// ReplaceCommandクラス
class ReplaceCommand {
  constructor(position, length, newText) {
    this.position = position;
    this.length = length;
    this.newText = newText;
    this.oldText = null; // 置換前のテキストを保存
  }
  
  execute(editor) {
    const currentText = editor.getText();
    this.oldText = currentText.slice(this.position, this.position + this.length);
    const newText = 
      currentText.slice(0, this.position) + 
      this.newText + 
      currentText.slice(this.position + this.length);
    editor.setText(newText);
  }
  
  undo(editor) {
    const currentText = editor.getText();
    const newText = 
      currentText.slice(0, this.position) + 
      this.oldText + 
      currentText.slice(this.position + this.newText.length);
    editor.setText(newText);
  }
}