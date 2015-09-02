require 'digest/sha2'
require 'digest/md5'

class User < ActiveRecord::Base
  validates_uniqueness_of :email
  validates_presence_of :email
  validates_presence_of :name

  def self.hash_password(password, salt)
    Digest::SHA256.hexdigest("#{password}#{salt}")
  end

  def self.login(email, password)
    Rails.logger.debug("Logging in with #{email} and #{password}")
    u = User.find_by(email: email)
    Rails.logger.debug("Found #{u.inspect}, #{u.password_hash} = #{User.hash_password(password, u.password_salt)} ? #{u.password_hash == User.hash_password(password, u.password_salt)}")
    if u
      u = nil unless u.password_hash == User.hash_password(password, u.password_salt)
    end
    u
  end

  def password=(value)
    return if value.blank?
    self.token ||= SecureRandom.base64(20) # Here's as good a place as any, no password = no login anyway
    self.password_salt ||= SecureRandom.base64(15)
    self.password_hash = User.hash_password(value, password_salt)
  end

  def gravatar_url(size=128)
    hash = Digest::MD5.hexdigest(email.downcase)
    "http://www.gravatar.com/avatar/#{hash}?s=#{size}&d=monsterid"
  end
end
