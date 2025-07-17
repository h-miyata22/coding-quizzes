require 'set'

class Image
  attr_reader :width, :height, :pixels

  def initialize(width, height, initial_value = 0)
    @width = width
    @height = height
    @pixels = Array.new(height) { Array.new(width, initial_value) }
  end

  def set_pixels(pixel_array)
    raise 'Invalid dimensions' if pixel_array.size != @height ||
                                  pixel_array.any? { |row| row.size != @width }

    @pixels = pixel_array.map(&:dup)
  end

  def get_pixel(x, y)
    return nil if out_of_bounds?(x, y)

    @pixels[y][x]
  end

  def set_pixel(x, y, value)
    return false if out_of_bounds?(x, y)

    @pixels[y][x] = value
    true
  end

  def clone
    new_image = Image.new(@width, @height)
    new_image.set_pixels(@pixels.map(&:dup))
    new_image
  end

  def to_s
    @pixels.map { |row| row.map { |pixel| pixel.to_s.rjust(3) }.join }.join("\n")
  end

  def out_of_bounds?(x, y)
    x < 0 || x >= @width || y < 0 || y >= @height
  end
end

class Region
  attr_reader :label, :pixels, :bounds

  def initialize(label)
    @label = label
    @pixels = Set.new
    @bounds = { min_x: Float::INFINITY, max_x: -Float::INFINITY,
                min_y: Float::INFINITY, max_y: -Float::INFINITY }
  end

  def add_pixel(x, y)
    @pixels.add([x, y])
    update_bounds(x, y)
  end

  def area
    @pixels.size
  end

  def centroid
    return [0, 0] if @pixels.empty?

    sum_x = sum_y = 0
    @pixels.each do |x, y|
      sum_x += x
      sum_y += y
    end

    [sum_x.to_f / @pixels.size, sum_y.to_f / @pixels.size]
  end

  def perimeter
    perimeter_pixels = 0

    @pixels.each do |x, y|
      # 4方向の隣接をチェック
      [[0, 1], [1, 0], [0, -1], [-1, 0]].each do |dx, dy|
        nx = x + dx
        ny = y + dy
        perimeter_pixels += 1 unless @pixels.include?([nx, ny])
      end
    end

    perimeter_pixels
  end

  def bounding_box
    [@bounds[:min_x], @bounds[:min_y], @bounds[:max_x], @bounds[:max_y]]
  end

  def contains?(x, y)
    @pixels.include?([x, y])
  end

  private

  def update_bounds(x, y)
    @bounds[:min_x] = [@bounds[:min_x], x].min
    @bounds[:max_x] = [@bounds[:max_x], x].max
    @bounds[:min_y] = [@bounds[:min_y], y].min
    @bounds[:max_y] = [@bounds[:max_y], y].max
  end
end

class ImageProcessor
  def initialize(image)
    @image = image
  end

  def flood_fill(start_x, start_y, new_value)
    return false if @image.out_of_bounds?(start_x, start_y)

    original_value = @image.get_pixel(start_x, start_y)
    return false if original_value == new_value

    # BFSを使った塗りつぶし
    queue = [[start_x, start_y]]
    filled_pixels = 0

    until queue.empty?
      x, y = queue.shift

      next if @image.get_pixel(x, y) != original_value

      @image.set_pixel(x, y, new_value)
      filled_pixels += 1

      # 4方向の隣接ピクセルをキューに追加
      [[0, 1], [1, 0], [0, -1], [-1, 0]].each do |dx, dy|
        nx = x + dx
        ny = y + dy
        queue.push([nx, ny]) if !@image.out_of_bounds?(nx, ny) && @image.get_pixel(nx, ny) == original_value
      end
    end

    filled_pixels
  end

  def find_connected_components
    visited = Array.new(@image.height) { Array.new(@image.width, false) }
    regions = []
    label = 0

    @image.height.times do |y|
      @image.width.times do |x|
        next if visited[y][x] || @image.get_pixel(x, y) == 0

        # 新しい連結成分を見つけた
        label += 1
        region = Region.new(label)

        # DFSで連結成分を探索
        explore_component(x, y, @image.get_pixel(x, y), visited, region)

        regions << region if region.area > 0
      end
    end

    regions
  end

  def detect_edges
    edge_image = Image.new(@image.width, @image.height, 0)

    # Sobelフィルタの係数
    sobel_x = [[-1, 0, 1], [-2, 0, 2], [-1, 0, 1]]
    sobel_y = [[-1, -2, -1], [0, 0, 0], [1, 2, 1]]

    (1...@image.height - 1).each do |y|
      (1...@image.width - 1).each do |x|
        gx = apply_kernel(x, y, sobel_x)
        gy = apply_kernel(x, y, sobel_y)

        # エッジの強度
        magnitude = Math.sqrt(gx * gx + gy * gy)
        edge_image.set_pixel(x, y, magnitude > 128 ? 255 : 0)
      end
    end

    edge_image
  end

  def apply_blur(kernel_size = 3)
    blurred_image = @image.clone
    kernel = create_gaussian_kernel(kernel_size)

    offset = kernel_size / 2

    (offset...@image.height - offset).each do |y|
      (offset...@image.width - offset).each do |x|
        value = apply_kernel(x, y, kernel)
        blurred_image.set_pixel(x, y, value.round)
      end
    end

    blurred_image
  end

  def detect_shapes
    regions = find_connected_components
    shapes = []

    regions.each do |region|
      shape_type = classify_shape(region)
      shapes << { region: region, type: shape_type }
    end

    shapes
  end

  def histogram
    hist = Hash.new(0)

    @image.height.times do |y|
      @image.width.times do |x|
        hist[@image.get_pixel(x, y)] += 1
      end
    end

    hist
  end

  private

  def explore_component(x, y, value, visited, region)
    return if @image.out_of_bounds?(x, y) || visited[y][x]
    return if @image.get_pixel(x, y) != value

    visited[y][x] = true
    region.add_pixel(x, y)

    # 8方向の隣接を探索
    [[-1, -1], [0, -1], [1, -1],
     [-1,  0],          [1, 0],
     [-1,  1], [0, 1], [1,  1]].each do |dx, dy|
      explore_component(x + dx, y + dy, value, visited, region)
    end
  end

  def apply_kernel(center_x, center_y, kernel)
    sum = 0.0
    kernel_sum = 0.0
    offset = kernel.size / 2

    kernel.each_with_index do |row, ky|
      row.each_with_index do |weight, kx|
        x = center_x + kx - offset
        y = center_y + ky - offset

        unless @image.out_of_bounds?(x, y)
          sum += @image.get_pixel(x, y) * weight
          kernel_sum += weight.abs
        end
      end
    end

    kernel_sum == 0 ? 0 : sum / kernel_sum
  end

  def create_gaussian_kernel(size)
    kernel = Array.new(size) { Array.new(size) }
    sigma = size / 3.0
    sum = 0.0

    size.times do |y|
      size.times do |x|
        dx = x - size / 2
        dy = y - size / 2
        value = Math.exp(-(dx * dx + dy * dy) / (2 * sigma * sigma))
        kernel[y][x] = value
        sum += value
      end
    end

    # 正規化
    kernel.map { |row| row.map { |v| v / sum } }
  end

  def classify_shape(region)
    # 簡易的な形状分類
    area = region.area
    perimeter = region.perimeter
    bbox = region.bounding_box
    width = bbox[2] - bbox[0] + 1
    height = bbox[3] - bbox[1] + 1

    # 円形度（4π × 面積 / 周囲長²）
    circularity = 4 * Math::PI * area / (perimeter * perimeter)

    # アスペクト比
    aspect_ratio = width.to_f / height

    # 充填率（バウンディングボックスに対する面積の割合）
    fill_ratio = area.to_f / (width * height)

    if circularity > 0.7 && (aspect_ratio - 1).abs < 0.3
      :circle
    elsif fill_ratio > 0.8 && (aspect_ratio - 1).abs < 0.3
      :square
    elsif fill_ratio > 0.7 && aspect_ratio > 1.5
      :rectangle
    else
      :irregular
    end
  end
end

# テスト
if __FILE__ == $0
  # テスト画像の作成
  image = Image.new(10, 10)
  pixels = [
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 1, 1, 1, 0, 0, 2, 2, 2, 0],
    [0, 1, 0, 1, 0, 0, 2, 0, 2, 0],
    [0, 1, 1, 1, 0, 0, 2, 2, 2, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 3, 3, 3, 3, 3, 0, 0, 0, 0],
    [0, 3, 3, 3, 3, 3, 0, 4, 4, 0],
    [0, 3, 3, 3, 3, 3, 0, 4, 4, 0],
    [0, 0, 0, 0, 0, 0, 0, 4, 4, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  ]
  image.set_pixels(pixels)

  puts '=== Original Image ==='
  puts image

  processor = ImageProcessor.new(image)

  puts "\n=== Flood Fill Test ==="
  test_image = image.clone
  test_processor = ImageProcessor.new(test_image)
  filled = test_processor.flood_fill(0, 0, 5)
  puts "Filled #{filled} pixels"
  puts test_image

  puts "\n=== Connected Components ==="
  regions = processor.find_connected_components
  regions.each do |region|
    centroid = region.centroid
    puts "Region #{region.label}: Area=#{region.area}, Centroid=(#{'%.1f' % centroid[0]}, #{'%.1f' % centroid[1]}), Perimeter=#{region.perimeter}"
  end

  puts "\n=== Shape Detection ==="
  shapes = processor.detect_shapes
  shapes.each do |shape_info|
    region = shape_info[:region]
    puts "Region #{region.label}: #{shape_info[:type]}"
  end

  puts "\n=== Histogram ==="
  hist = processor.histogram
  hist.sort.each { |value, count| puts "Value #{value}: #{count} pixels" }

  puts "\n=== Edge Detection ==="
  edge_image = processor.detect_edges
  puts "Edge detection completed (#{edge_image.width}x#{edge_image.height})"
end
