class RemoveApprovedUsersTable < ActiveRecord::Migration
  def up
    drop_table :approved_users
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
