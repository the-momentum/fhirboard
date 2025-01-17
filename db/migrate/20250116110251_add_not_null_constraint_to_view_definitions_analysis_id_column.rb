class AddNotNullConstraintToViewDefinitionsAnalysisIdColumn < ActiveRecord::Migration[8.0]
  def change
    change_column_null :view_definitions, :analysis_id, false
  end
end
