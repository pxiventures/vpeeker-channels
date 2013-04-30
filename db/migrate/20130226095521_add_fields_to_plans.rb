class AddFieldsToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :billing_period, :string
    add_column :plans, :price, :decimal, precision: 10, scale: 2, default: 0.0
    add_column :plans, :usage, :string
    add_column :plans, :support, :string
    add_column :plans, :custom_subdomain, :boolean
    add_column :plans, :branding, :boolean
    add_column :plans, :moderation, :boolean
    add_column :plans, :password_channel, :boolean
    add_column :plans, :your_own_domain, :boolean
    add_column :plans, :feature_prioritisation, :boolean
    add_column :plans, :mobile_optimised, :boolean
  end
end
