# == Schema Information
#
# Table name: sessions
#
#  id         :integer          not null, primary key
#  token      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_sessions_on_token  (token) UNIQUE
#

FactoryBot.define do
  factory :session do
    
  end
end
