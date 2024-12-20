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
#  analysis_id   :integer
#
# Indexes
#
#  index_view_definitions_on_analysis_id  (analysis_id)
#

class ViewDefinition < ApplicationRecord
  belongs_to :analysis, optional: true
end
