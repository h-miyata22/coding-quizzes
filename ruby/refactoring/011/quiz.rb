class ImageProcessor
  def get_thumbnail(image_path, width, height)
    # キャッシュをチェック
    cache_key = "#{image_path}_#{width}x#{height}"
    cached = nil

    if File.exist?("/tmp/cache/#{cache_key}")
      # キャッシュの有効期限をチェック
      cache_time = File.mtime("/tmp/cache/#{cache_key}")
      cached = File.read("/tmp/cache/#{cache_key}") if Time.now - cache_time < 3600 # 1時間
    end

    return cached if cached

    # 画像を読み込み
    original = load_image(image_path)

    # リサイズ
    resized = if width && height
                resize_image(original, width, height)
              else
                original
              end

    # キャッシュに保存
    Dir.mkdir('/tmp/cache') unless Dir.exist?('/tmp/cache')
    File.write("/tmp/cache/#{cache_key}", resized)

    resized
  end

  def get_multiple_thumbnails(image_paths, sizes)
    results = {}

    for i in 0..image_paths.length - 1
      image_path = image_paths[i]
      results[image_path] = {}

      for j in 0..sizes.length - 1
        size = sizes[j]
        width = size[:width]
        height = size[:height]

        # 各サイズのサムネイルを生成
        thumbnail = get_thumbnail(image_path, width, height)
        results[image_path]["#{width}x#{height}"] = thumbnail
      end
    end

    results
  end

  def clean_old_cache
    return unless Dir.exist?('/tmp/cache')

    Dir.foreach('/tmp/cache') do |file|
      next if ['.', '..'].include?(file)

      file_path = "/tmp/cache/#{file}"
      file_time = File.mtime(file_path)

      # 24時間以上古いファイルを削除
      File.delete(file_path) if Time.now - file_time > 86_400
    end
  end

  private

  def load_image(path)
    # 画像読み込みのダミー実装
    "image_data_#{path}"
  end

  def resize_image(image, width, height)
    # リサイズのダミー実装
    "resized_#{image}_#{width}x#{height}"
  end
end
