class AddSessionReferenceToViewDefinitions < ActiveRecord::Migration[8.0]
  def change
    add_reference :view_definitions, :session, foreign_key: true
  end
end
