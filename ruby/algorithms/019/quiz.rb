
# 画像処理システムを実装してください。
# ペイントツールの塗りつぶし機能や、
# 画像の領域分析を行います。
#
# 要件：
# 1. フラッドフィル（塗りつぶし）アルゴリズム
# 2. 連結成分の検出とラベリング
# 3. 画像フィルタ（ぼかし、エッジ検出）
# 4. 領域の統計情報（面積、重心、境界）
# 5. 形状認識（円、四角形の検出）
# 6. 効率的なメモリ使用

# Image, ImageProcessor, Region クラスを実装してください。

# 使用例:
# # 5x5の画像を作成
# image = Image.new(5, 5)
# image.set_pixels([
#   [1, 1, 0, 0, 0],
#   [1, 1, 0, 1, 1],
#   [0, 0, 0, 1, 1],
#   [0, 2, 2, 0, 0],
#   [0, 2, 2, 0, 0]
# ])
# 
# processor = ImageProcessor.new(image)
# 
# # 塗りつぶし
# processor.flood_fill(0, 0, 3)
# # => (0,0)から始まる領域が3で塗りつぶされる
# 
# # 連結成分の検出
# regions = processor.find_connected_components
# # => [Region(label: 1, pixels: 4), Region(label: 2, pixels: 4), ...]
# 
# # エッジ検出
# edges = processor.detect_edges
# # => エッジ画像
