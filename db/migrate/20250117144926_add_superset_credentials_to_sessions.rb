class AddSupersetCredentialsToSessions < ActiveRecord::Migration[8.0]
  def change
    # TODO add not null constraint after deploy
    add_column :sessions, :superset_username, :string
    add_column :sessions, :superset_password, :string
    add_column :sessions, :superset_email, :string
  end
end
