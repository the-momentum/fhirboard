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

class Session < ApplicationRecord
  validates :token, presence: true, uniqueness: true
  
  before_validation :generate_token, on: :create

  has_many :analyses, dependent: :destroy
  has_many :view_definitions, through: :analyses

  private

  def generate_token
    self.token = SecureRandom.urlsafe_base64(32)
  end
end
