class AddPlanIdToUsers < ActiveRecord::Migration
  def up
    default_plan = Plan.where(name: AppConfig.default_plan).first_or_create! do |plan|
      plan.name = AppConfig.default_plan
      plan.embed = false
      plan.channels = 1
    end
    add_column :users, :plan_id, :integer
    add_index :users, :plan_id

    # Avoid Rails validates. I think validate: false might work too...
    execute "UPDATE users SET plan_id=#{default_plan.id} WHERE true"
  end

  def down
    remove_index :users, :plan_id
    remove_column :users, :plan_id
  end

end
