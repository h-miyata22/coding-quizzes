require 'set'

class User
  attr_reader :name, :following, :followers

  def initialize(name)
    @name = name
    @following = Set.new
    @followers = Set.new
  end

  def follow(other_user)
    @following.add(other_user)
    other_user.followers.add(self)
  end

  def unfollow(other_user)
    @following.delete(other_user)
    other_user.followers.delete(self)
  end

  def follows?(other_user)
    @following.include?(other_user)
  end

  def followed_by?(other_user)
    @followers.include?(other_user)
  end

  def mutual_follow?(other_user)
    follows?(other_user) && followed_by?(other_user)
  end

  def follower_count
    @followers.size
  end

  def following_count
    @following.size
  end
end

class SocialNetwork
  def initialize
    @users = {}
  end

  def add_user(name)
    return if @users.key?(name)

    @users[name] = User.new(name)
  end

  def follow(follower_name, followee_name)
    follower = @users[follower_name]
    followee = @users[followee_name]

    return unless follower && followee

    follower.follow(followee)
  end

  def unfollow(follower_name, followee_name)
    follower = @users[follower_name]
    followee = @users[followee_name]

    return unless follower && followee

    follower.unfollow(followee)
  end

  def find_mutual_follows(user_name)
    user = @users[user_name]
    return [] unless user

    mutual = []
    user.following.each do |other_user|
      mutual << other_user.name if user.mutual_follow?(other_user)
    end

    mutual.sort
  end

  def find_connections(user_name, depth: 2)
    user = @users[user_name]
    return {} unless user

    connections = {}
    visited = Set.new([user])
    current_level = [user]

    (1..depth).each do |level|
      next_level = []

      current_level.each do |current_user|
        current_user.following.each do |followed|
          unless visited.include?(followed)
            visited.add(followed)
            next_level << followed
          end
        end
      end

      connections[level] = next_level.map(&:name).sort unless next_level.empty?
      current_level = next_level
    end

    connections
  end

  def most_influential_users(limit: 5)
    @users.values
          .sort_by { |user| [-user.follower_count, user.name] }
          .first(limit)
          .map { |user| { name: user.name, followers: user.follower_count } }
  end

  def shortest_path(start_name, end_name)
    start_user = @users[start_name]
    end_user = @users[end_name]

    return nil unless start_user && end_user
    return [start_name] if start_name == end_name

    # BFS（幅優先探索）で最短経路を探索
    queue = [[start_user]]
    visited = Set.new([start_user])

    until queue.empty?
      path = queue.shift
      current = path.last

      current.following.each do |next_user|
        return (path + [next_user]).map(&:name) if next_user == end_user

        unless visited.include?(next_user)
          visited.add(next_user)
          queue.push(path + [next_user])
        end
      end
    end

    nil # 経路が存在しない
  end

  def find_closed_communities(min_size: 3)
    communities = []

    # 各ユーザーを起点として探索
    @users.values.each do |user|
      # そのユーザーとその全フォロー先で構成される集合を確認
      potential_community = Set.new([user]) + user.following

      next if potential_community.size < min_size

      # 全員が相互フォローしているか確認
      is_closed = true
      potential_community.each do |member|
        others = potential_community - [member]
        unless others.all? { |other| member.mutual_follow?(other) }
          is_closed = false
          break
        end
      end

      if is_closed
        community_names = potential_community.map(&:name).sort
        communities << community_names unless communities.any? { |c| c.sort == community_names }
      end
    end

    communities.uniq
  end

  def user_stats(user_name)
    user = @users[user_name]
    return nil unless user

    {
      name: user.name,
      followers: user.follower_count,
      following: user.following_count,
      mutual_follows: find_mutual_follows(user_name).count,
      influence_score: calculate_influence_score(user)
    }
  end

  private

  def calculate_influence_score(user)
    # シンプルな影響力スコア：フォロワー数 + 相互フォロー数 * 2
    mutual_count = user.following.count { |other| user.mutual_follow?(other) }
    user.follower_count + mutual_count * 2
  end
end

# テスト
if __FILE__ == $0
  network = SocialNetwork.new

  # ユーザーの追加
  users = %w[Alice Bob Charlie David Eve Frank]
  users.each { |name| network.add_user(name) }

  # フォロー関係の構築
  network.follow('Alice', 'Bob')
  network.follow('Bob', 'Alice')
  network.follow('Bob', 'Charlie')
  network.follow('Charlie', 'Bob')
  network.follow('Charlie', 'David')
  network.follow('David', 'Eve')
  network.follow('Eve', 'David')
  network.follow('Frank', 'Alice')
  network.follow('Frank', 'Bob')
  network.follow('Alice', 'Frank')
  network.follow('Bob', 'Frank')

  puts '=== 相互フォロー ==='
  users.each do |user|
    mutual = network.find_mutual_follows(user)
    puts "#{user}: #{mutual.join(', ')}" unless mutual.empty?
  end

  puts "\n=== N次の繋がり（Aliceから） ==="
  connections = network.find_connections('Alice', depth: 3)
  connections.each do |depth, users|
    puts "#{depth}次: #{users.join(', ')}"
  end

  puts "\n=== 最も影響力のあるユーザー ==="
  influential = network.most_influential_users(limit: 3)
  influential.each do |user|
    puts "#{user[:name]}: #{user[:followers]} followers"
  end

  puts "\n=== 最短経路 ==="
  path = network.shortest_path('Alice', 'Eve')
  puts "Alice → Eve: #{path ? path.join(' → ') : 'No path'}"

  puts "\n=== 閉じたコミュニティ ==="
  communities = network.find_closed_communities(min_size: 2)
  communities.each_with_index do |community, i|
    puts "Community #{i + 1}: #{community.join(', ')}"
  end

  puts "\n=== ユーザー統計 ==="
  stats = network.user_stats('Bob')
  if stats
    puts "User: #{stats[:name]}"
    puts "  Followers: #{stats[:followers]}"
    puts "  Following: #{stats[:following]}"
    puts "  Mutual follows: #{stats[:mutual_follows]}"
    puts "  Influence score: #{stats[:influence_score]}"
  end
end
