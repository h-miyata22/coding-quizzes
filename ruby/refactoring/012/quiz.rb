class AuthenticationService
  def login(username, password)
    # ユーザーを検索
    user = User.find_by(username: username)

    return { success: false, error: 'Invalid credentials' } if user.nil?

    # パスワードをチェック
    if user.password != password
      # 失敗回数を記録
      user.failed_attempts = 0 if user.failed_attempts.nil?
      user.failed_attempts = user.failed_attempts + 1
      user.last_failed_at = Time.now
      user.save

      # アカウントロックチェック
      if user.failed_attempts >= 5
        user.locked = true
        user.locked_at = Time.now
        user.save
        return { success: false, error: 'Account locked' }
      end

      return { success: false, error: 'Invalid credentials' }
    end

    # アカウントがロックされているかチェック
    if user.locked == true
      # 30分経過していたらロック解除
      return { success: false, error: 'Account locked' } unless Time.now - user.locked_at > 1800

      user.locked = false
      user.failed_attempts = 0
      user.save

    end

    # ログイン成功
    user.failed_attempts = 0
    user.last_login_at = Time.now
    user.save

    # セッショントークンを生成
    token = ''
    chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    32.times do
      token += chars[rand(chars.length)]
    end

    # セッションを保存
    session = Session.new
    session.user_id = user.id
    session.token = token
    session.expires_at = Time.now + 86_400 # 24時間
    session.save

    { success: true, token: token, user: user }
  end

  def logout(token)
    session = Session.find_by(token: token)
    if session
      session.destroy
      { success: true }
    else
      { success: false, error: 'Invalid session' }
    end
  end

  def verify_token(token)
    session = Session.find_by(token: token)

    return { valid: false } if session.nil?

    if Time.now > session.expires_at
      session.destroy
      return { valid: false }
    end

    { valid: true, user_id: session.user_id }
  end
end
