# == Schema Information
#
# Table name: view_definitions
#
#  id            :integer          not null, primary key
#  name          :string
#  description   :text
#  content       :jsonb
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  duck_db_query :text
#  analysis_id   :integer          not null
#  session_id    :integer
#
# Indexes
#
#  index_view_definitions_on_analysis_id  (analysis_id)
#  index_view_definitions_on_session_id   (session_id)
#

class ViewDefinition < ApplicationRecord
  belongs_to :analysis
  belongs_to :session, optional: true
end
