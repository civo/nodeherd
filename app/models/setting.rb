require 'securerandom'

class Setting < ActiveRecord::Base
  def self.method_missing(name, value=nil)
    setting = Setting.find_or_create_by(name: name.to_s.gsub(/=$/, ""))
    if value
      setting.value = value
      setting.save
    end
    setting.value
  end

  def self.api_token
    ret = method_missing("api_token")
    method_missing("api_token=", SecureRandom.uuid) unless ret
    ret
  end
end
