require 'securerandom'

class AuthenticationService
  def initialize(
    password_verifier: PasswordVerifier.new,
    account_locker: AccountLocker.new,
    session_manager: SessionManager.new
  )
    @password_verifier = password_verifier
    @account_locker = account_locker
    @session_manager = session_manager
  end

  def login(username, password)
    user = User.find_by(username: username)
    return authentication_error unless user

    lock_status = @account_locker.check_and_update(user)
    return lock_status unless lock_status[:success]

    unless @password_verifier.verify(user, password)
      @account_locker.record_failure(user)
      return authentication_error
    end

    record_successful_login(user)
    token = @session_manager.create_session(user)

    { success: true, token: token, user: user }
  end

  def logout(token)
    @session_manager.destroy_session(token)
  end

  def verify_token(token)
    @session_manager.verify_token(token)
  end

  private

  def authentication_error
    { success: false, error: 'Invalid credentials' }
  end

  def record_successful_login(user)
    user.update(
      failed_attempts: 0,
      last_login_at: Time.now
    )
  end
end

class PasswordVerifier
  def verify(user, password)
    # 実際の実装ではbcryptなどを使用
    user.password == password
  end
end

class AccountLocker
  MAX_FAILED_ATTEMPTS = 5
  LOCK_DURATION = 30 * 60 # 30分

  def check_and_update(user)
    return { success: true } unless user.locked?

    if lock_expired?(user)
      unlock_account(user)
      { success: true }
    else
      { success: false, error: 'Account locked' }
    end
  end

  def record_failure(user)
    user.increment!(:failed_attempts)
    user.update(last_failed_at: Time.now)

    lock_account(user) if should_lock?(user)
  end

  private

  def lock_expired?(user)
    user.locked_at && (Time.now - user.locked_at > LOCK_DURATION)
  end

  def unlock_account(user)
    user.update(
      locked: false,
      failed_attempts: 0,
      locked_at: nil
    )
  end

  def should_lock?(user)
    user.failed_attempts >= MAX_FAILED_ATTEMPTS
  end

  def lock_account(user)
    user.update(
      locked: true,
      locked_at: Time.now
    )
  end
end

class SessionManager
  SESSION_DURATION = 24 * 60 * 60 # 24時間

  def create_session(user)
    token = generate_secure_token

    Session.create!(
      user_id: user.id,
      token: token,
      expires_at: Time.now + SESSION_DURATION
    )

    token
  end

  def destroy_session(token)
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
    return { valid: false } unless session

    if session_expired?(session)
      session.destroy
      { valid: false }
    else
      { valid: true, user_id: session.user_id }
    end
  end

  private

  def generate_secure_token
    SecureRandom.urlsafe_base64(24)
  end

  def session_expired?(session)
    Time.now > session.expires_at
  end
end

# Userモデルの拡張
class User < ActiveRecord::Base
  def locked?
    locked == true
  end
end
