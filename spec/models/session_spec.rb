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

require 'rails_helper'

RSpec.describe Session, type: :model do
  describe 'before_validation' do
    it 'generates a token on create' do
      session = Session.new
      session.valid?
      expect(session.token).to be_present
    end
  end
end
