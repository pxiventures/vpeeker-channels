class FixPlanDefault < ActiveRecord::Migration
  def up
    
    # who was the n00b who allowed this in the first place?
    Plan.all.each do |p|
      p.channels = 0 unless p.channels
      p.save
    end
    
    change_column :plans, :channels, :integer, :null => false, :default => 0
  end

  def down
    change_column :plans, :channels, :integer
  end
end
