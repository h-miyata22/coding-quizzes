class UserService
  def initialize(user_repository = UserRepository.new)
    @user_repository = user_repository
  end

  def get_user_info(user_id)
    user = @user_repository.find_by_id(user_id)
    return nil unless user

    UserPresenter.new(user).detailed_info
  end

  def search_users(keyword, page = 1)
    users = @user_repository.search(keyword: keyword, page: page)
    users.map { |user| UserPresenter.new(user).summary }
  end
end

class UserRepository
  DEFAULT_PAGE_SIZE = 20
  LATEST_POSTS_LIMIT = 5

  def find_by_id(user_id)
    result = Database.execute(
      'SELECT * FROM users WHERE id = ?',
      user_id
    ).first

    return nil unless result

    User.new(result)
  end

  def search(keyword:, page: 1)
    query = build_search_query(keyword)
    params = build_search_params(keyword, page)

    results = Database.execute(query, *params)
    results.map { |row| User.new(row) }
  end

  private

  def build_search_query(keyword)
    base_query = 'SELECT * FROM users'

    if keyword.nil? || keyword.empty?
      "#{base_query} ORDER BY created_at DESC LIMIT ? OFFSET ?"
    else
      "#{base_query} WHERE name LIKE ? OR email LIKE ? ORDER BY created_at DESC LIMIT ? OFFSET ?"
    end
  end

  def build_search_params(keyword, page)
    limit = DEFAULT_PAGE_SIZE
    offset = (page - 1) * limit

    if keyword.nil? || keyword.empty?
      [limit, offset]
    else
      search_pattern = "%#{keyword}%"
      [search_pattern, search_pattern, limit, offset]
    end
  end
end

class User
  attr_reader :id, :name, :email

  def initialize(attributes)
    @id = attributes['id']
    @name = attributes['name']
    @email = attributes['email']
  end

  def posts_count
    @posts_count ||= count_records('posts', 'user_id')
  end

  def followers_count
    @followers_count ||= count_records('follows', 'followed_id')
  end

  def following_count
    @following_count ||= count_records('follows', 'follower_id')
  end

  def latest_posts(limit = UserRepository::LATEST_POSTS_LIMIT)
    @latest_posts ||= fetch_latest_posts(limit)
  end

  private

  def count_records(table, column)
    result = Database.execute(
      "SELECT COUNT(*) as count FROM #{table} WHERE #{column} = ?",
      @id
    ).first

    result['count']
  end

  def fetch_latest_posts(limit)
    Database.execute(
      'SELECT * FROM posts WHERE user_id = ? ORDER BY created_at DESC LIMIT ?',
      @id,
      limit
    )
  end
end

class UserPresenter
  def initialize(user)
    @user = user
  end

  def detailed_info
    {
      id: @user.id,
      name: @user.name,
      email: @user.email,
      posts_count: @user.posts_count,
      followers_count: @user.followers_count,
      following_count: @user.following_count,
      latest_posts: @user.latest_posts
    }
  end

  def summary
    {
      id: @user.id,
      name: @user.name,
      email: @user.email,
      posts_count: @user.posts_count
    }
  end
end

# データベースアクセスのラッパー
module Database
  def self.execute(query, *params)
    # パラメータバインディングを使用したSQL実行
    # 実際の実装ではActiveRecordやSequelなどのORMを使用
  end
end
