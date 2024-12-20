class CreateSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :settings do |t|
      t.string :key, null: false
      t.text :value
      t.string :value_type, default: "string"

      t.timestamps

      t.index :key, unique: true
    end
  end
end
