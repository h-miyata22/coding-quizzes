# 出題意図

この問題は以下の能力を測定することを目的としています：

## 1. Compound Component Patternの実装
- Context APIを使った親子コンポーネント間の状態共有
- 柔軟なコンポーネント構成の実現
- 子コンポーネントへのprops伝播（React.cloneElement）

## 2. 高度なユーザーインタラクション
- クリックイベントの適切な処理
- 外部クリック検知（useEffect + document.addEventListener）
- イベントバブリングの制御（stopPropagation）

## 3. キーボードナビゲーション
- 矢印キーによるメニュー項目の移動
- Home/Endキーのサポート
- Escapeキーでのメニュー閉じ
- フォーカス管理とtabIndex

## 4. アクセシビリティの実装
- 適切なARIA属性（aria-haspopup, aria-expanded, aria-controls）
- role属性の設定（menu, menuitem）
- キーボードとマウス両方でのフル操作対応
- disabled状態の適切な処理

## 5. React Hooksの実践的な使用
- useRef（DOM要素への参照）
- useEffect（副作用の管理）
- useState（内部状態管理）
- useId（ユニークID生成）
- カスタムフック（useDropdownContext）

## 6. 実践的なコンポーネント設計
- 制御/非制御コンポーネントの両対応
- イベントハンドラーの適切な実装
- スタイリングの柔軟性
- パフォーマンスを考慮したイベントリスナー管理

この実装は、実際のWebアプリケーションで頻繁に使用されるドロップダウンメニューの基本機能を網羅しており、プロダクションレベルのコンポーネント開発に必要なスキルを測定します。