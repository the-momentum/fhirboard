class Setting < ApplicationRecord
  validates :key, presence: true, uniqueness: true

  def self.get(key, default = nil)
    setting = find_by(key: key)
    return default if setting.nil?
    
    case setting.value_type
    when "integer"
      setting.value.to_i
    when "float"
      setting.value.to_f
    when "boolean"
      setting.value == "true"
    when "array"
      JSON.parse(setting.value)
    when "hash"
      JSON.parse(setting.value)
    else
      setting.value
    end
  end
  
  def self.set(key, value, type = "string")
    value = value.to_json if ["array", "hash"].include?(type)
    
    setting = find_or_initialize_by(key: key)
    setting.update!(
      value: value.to_s,
      value_type: type
    )
  end
end
