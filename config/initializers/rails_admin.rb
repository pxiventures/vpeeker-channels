# RailsAdmin config file. Generated on February 11, 2013 15:36
# See github.com/sferik/rails_admin for more informations

RailsAdmin.config do |config|


  ################  Global configuration  ################

  # Set the admin name here (optional second array element will appear in red). For example:
  config.main_app_name = [AppConfig.app_name, 'Admin']
  # or for a more dynamic name:
  # config.main_app_name = Proc.new { |controller| [Rails.application.engine_name.titleize, controller.params['action'].titleize] }

  config.authorize_with :cancan

  config.attr_accessible_role { :admin }

  config.yell_for_non_accessible_fields = false

  config.label_methods << :nickname

  ################  Model configuration  ################

  config.model 'User' do
    list do
      field :nickname
      field :uid
      field :super_admin
      field :channels
      field :created_at
    end

    edit do
      field :nickname
      field :uid
      field :access_token
      field :access_token_secret
      field :super_admin
      field :email
      field :plan
      field :channels
    end
  end

  config.model 'Video' do
    list do
      field :id
      field :channel
      field :vine_url
      field :caption
    end
  end
  
  config.model 'Plan' do
    list do
      field :id
      field :name
      field :description
      
      field :users do
        pretty_value do
          value.count.to_s
        end
      end
      
      field :subscribable
      field :price
      field :usage
      field :channels
      field :custom_subdomain
      field :branding
      field :moderation
      field :password_channel
      field :your_own_domain
      field :feature_prioritisation
      field :mobile_optimised
      
      field :fastspring_reference
      field :billing_period
      field :created_at
    end
  end

end
