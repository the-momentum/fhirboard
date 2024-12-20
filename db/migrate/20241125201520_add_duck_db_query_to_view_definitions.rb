class AddDuckDbQueryToViewDefinitions < ActiveRecord::Migration[7.2]
  def change
    add_column :view_definitions, :duck_db_query, :text
  end
end
