class ImageProcessor
  def initialize(cache_manager: CacheManager.new)
    @cache_manager = cache_manager
  end

  def get_thumbnail(image_path, width, height)
    cache_key = build_cache_key(image_path, width, height)

    @cache_manager.fetch(cache_key) do
      generate_thumbnail(image_path, width, height)
    end
  end

  def get_multiple_thumbnails(image_paths, sizes)
    ThumbnailBatchProcessor.new(self).process(image_paths, sizes)
  end

  def clean_old_cache
    @cache_manager.clean_expired
  end

  private

  def build_cache_key(image_path, width, height)
    "#{image_path}_#{width}x#{height}"
  end

  def generate_thumbnail(image_path, width, height)
    original = load_image(image_path)

    if width && height
      resize_image(original, width, height)
    else
      original
    end
  end

  def load_image(path)
    # 画像読み込みのダミー実装
    "image_data_#{path}"
  end

  def resize_image(image, width, height)
    # リサイズのダミー実装
    "resized_#{image}_#{width}x#{height}"
  end
end

class CacheManager
  DEFAULT_TTL = 3600 # 1時間
  DEFAULT_CLEANUP_TTL = 86_400 # 24時間

  def initialize(cache_dir: '/tmp/cache', ttl: DEFAULT_TTL)
    @cache_dir = cache_dir
    @ttl = ttl
    ensure_cache_directory
  end

  def fetch(key)
    cached_value = read_cache(key)
    return cached_value if cached_value

    value = yield
    write_cache(key, value)
    value
  end

  def clean_expired(ttl: DEFAULT_CLEANUP_TTL)
    return unless Dir.exist?(@cache_dir)

    expired_files.each { |file| delete_file(file) }
  end

  private

  def ensure_cache_directory
    Dir.mkdir(@cache_dir) unless Dir.exist?(@cache_dir)
  end

  def cache_file_path(key)
    File.join(@cache_dir, key)
  end

  def read_cache(key)
    file_path = cache_file_path(key)
    return nil unless File.exist?(file_path)
    return nil if cache_expired?(file_path)

    File.read(file_path)
  end

  def write_cache(key, value)
    File.write(cache_file_path(key), value)
  end

  def cache_expired?(file_path)
    Time.now - File.mtime(file_path) > @ttl
  end

  def expired_files
    Dir.glob(File.join(@cache_dir, '*')).select do |file|
      File.file?(file) && file_expired?(file)
    end
  end

  def file_expired?(file_path, ttl = DEFAULT_CLEANUP_TTL)
    Time.now - File.mtime(file_path) > ttl
  end

  def delete_file(file_path)
    File.delete(file_path)
  rescue Errno::ENOENT
    # ファイルが既に削除されている場合は無視
  end
end

class ThumbnailBatchProcessor
  def initialize(image_processor)
    @image_processor = image_processor
  end

  def process(image_paths, sizes)
    image_paths.each_with_object({}) do |image_path, results|
      results[image_path] = process_sizes_for_image(image_path, sizes)
    end
  end

  private

  def process_sizes_for_image(image_path, sizes)
    sizes.each_with_object({}) do |size, thumbnails|
      size_key = "#{size[:width]}x#{size[:height]}"
      thumbnails[size_key] = @image_processor.get_thumbnail(
        image_path,
        size[:width],
        size[:height]
      )
    end
  end
end
