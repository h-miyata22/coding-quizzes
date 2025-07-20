# 出題意図

この問題は以下の能力を測定することを目的としています：

## 1. Compound Component Patternの理解
- 親コンポーネントと子コンポーネント間での暗黙的な状態共有
- Context APIを使った内部通信の実装
- 柔軟なコンポーネント構成の実現

## 2. アクセシビリティの実装
- 適切なARIA属性（role="switch", aria-checked, aria-disabled）
- キーボード操作のサポート（Space/Enterキー）
- スクリーンリーダー向けのテキスト提供
- ラベルとフォーム要素の適切な関連付け

## 3. React Hooksの活用
- useStateによる状態管理
- useContextによるデータ共有
- useIdによるユニークIDの生成
- カスタムフックの作成（useToggleContext）

## 4. 制御/非制御コンポーネントの実装
- defaultCheckedとcheckedプロパティの使い分け
- 内部状態と外部状態の適切な管理
- onChange/onToggleコールバックの実装

## 5. 実践的なコンポーネント設計
- 再利用性の高いAPI設計
- エラーハンドリング（Context外での使用を防ぐ）
- スタイリングの柔軟性（className props）
- disabled状態の適切な処理

この実装は、実際のプロダクトで使用されるトグルスイッチコンポーネントの基本的な要件を満たしており、アクセシビリティとユーザビリティの両方を考慮した設計となっています。