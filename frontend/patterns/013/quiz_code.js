// 使用例

const editor = new TextEditor('Hello World');

// 初期状態
console.log(editor.getText()); // 'Hello World'

// 文字を挿入
const insertCmd = new InsertCommand(5, ' Beautiful');
editor.execute(insertCmd);
console.log(editor.getText()); // 'Hello Beautiful World'

// 文字を削除
const deleteCmd = new DeleteCommand(5, 10); // ' Beautiful'を削除
editor.execute(deleteCmd);
console.log(editor.getText()); // 'Hello World'

// 文字を置換
const replaceCmd = new ReplaceCommand(6, 5, 'JavaScript'); // 'World'を'JavaScript'に
editor.execute(replaceCmd);
console.log(editor.getText()); // 'Hello JavaScript'

// Undo操作
console.log(editor.canUndo()); // true
editor.undo();
console.log(editor.getText()); // 'Hello World' (置換を取り消し)

editor.undo();
console.log(editor.getText()); // 'Hello Beautiful World' (削除を取り消し)

editor.undo();
console.log(editor.getText()); // 'Hello World' (挿入を取り消し)

console.log(editor.canUndo()); // false (これ以上Undoできない)

// 複雑な編集
editor.execute(new InsertCommand(0, '🌟 '));
console.log(editor.getText()); // '🌟 Hello World'

editor.execute(new ReplaceCommand(3, 5, 'Hi'));
console.log(editor.getText()); // '🌟 Hi World'

editor.execute(new InsertCommand(10, '!'));
console.log(editor.getText()); // '🌟 Hi World!'

// 連続Undo
editor.undo();
editor.undo();
console.log(editor.getText()); // '🌟 Hello World'