# == Schema Information
#
# Table name: analyses
#
#  id              :integer          not null, primary key
#  name            :string           not null
#  description     :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  export_path_url :text
#  session_id      :integer
#
# Indexes
#
#  index_analyses_on_session_id  (session_id)
#

class Analysis < ApplicationRecord
  validates :name, :export_path_url,
            presence: true

  has_many :view_definitions, dependent: :destroy
  belongs_to :session, optional: true
end
