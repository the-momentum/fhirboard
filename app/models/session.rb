# == Schema Information
#
# Table name: sessions
#
#  id                :integer          not null, primary key
#  token             :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  superset_username :string
#  superset_password :string
#  superset_email    :string
#
# Indexes
#
#  index_sessions_on_token  (token) UNIQUE
#

class Session < ApplicationRecord
  validates :token, presence: true, uniqueness: true
  validates :superset_username, presence: true, uniqueness: true
  validates :superset_password, presence: true
  validates :superset_email, presence: true, uniqueness: true
  
  before_validation :generate_token, on: :create
  before_validation :generate_superset_credentials, on: :create

  has_many :analyses, dependent: :destroy
  has_many :view_definitions, through: :analyses

  private

  def generate_token
    self.token = SecureRandom.urlsafe_base64(32)
  end

  def generate_superset_credentials
    self.superset_email    = "#{SecureRandom.hex(12)}@example.com"
    self.superset_username = SecureRandom.hex(12)
    self.superset_password = SecureRandom.hex(12)
  end
end
