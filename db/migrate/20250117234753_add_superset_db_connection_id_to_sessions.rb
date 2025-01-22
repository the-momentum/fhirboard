class AddSupersetDbConnectionIdToSessions < ActiveRecord::Migration[8.0]
  def change
    add_column :sessions, :superset_db_connection_id, :integer
  end
end
