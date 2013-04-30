class MigrateBetaUsersAndDeactivateExcessChannels < ActiveRecord::Migration
  def up
    
    beta = Plan.find_by_name "Beta"
    free = Plan.find_by_name "Free"
    
    if beta && free
      
      # move beta users to free
      beta.users.map {|u| 
        puts "Migrating user #{u.email} from beta to free"
        u.plan = free
        u.save!
      }
      
      puts "Destroying beta plan"
      beta.destroy
      
      puts "Deactivating all excess channels"
      # update users to comply with plan restrictions
      User.all.each{|u| u.deactivate_excess_channels! rescue nil}
    end
    
  end

  def down
  end
end
