class AddAnalysisToViewDefinitions < ActiveRecord::Migration[7.2]
  def change
    add_reference :view_definitions, :analysis, foreign_key: true
  end
end
