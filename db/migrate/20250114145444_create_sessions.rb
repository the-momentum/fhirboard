class CreateSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :sessions do |t|
      t.string :token, null: false, index: { unique: true }
      t.timestamps
    end
  end
end
