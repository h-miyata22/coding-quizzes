
# テキストデータの圧縮システムを実装してください。
# ハフマン符号化アルゴリズムを使用して、
# 効率的なデータ圧縮を実現します。
#
# 要件：
# 1. 文字の出現頻度を解析
# 2. ハフマン木の構築
# 3. 各文字の符号化テーブル生成
# 4. テキストの圧縮（エンコード）
# 5. 圧縮データの展開（デコード）
# 6. 圧縮率の計算と統計情報

# HuffmanNode, HuffmanCoding クラスを実装してください。

# 使用例:
# huffman = HuffmanCoding.new
# 
# text = "hello world"
# 
# # 圧縮
# compressed = huffman.compress(text)
# # => { data: "110111001...", tree: <HuffmanTree> }
# 
# # 展開
# decompressed = huffman.decompress(compressed[:data], compressed[:tree])
# # => "hello world"
# 
# # 符号化テーブルを取得
# table = huffman.get_encoding_table(text)
# # => { "h"=>"00", "e"=>"01", "l"=>"10", ... }
# 
# # 圧縮統計
# stats = huffman.compression_stats(text)
# # => { original_bits: 88, compressed_bits: 34, compression_ratio: 0.614 }
