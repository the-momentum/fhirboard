class CreateViewDefinitions < ActiveRecord::Migration[7.2]
  def change
    create_table :view_definitions do |t|
      t.string :name
      t.text :description
      t.jsonb :content

      t.timestamps
    end
  end
end
