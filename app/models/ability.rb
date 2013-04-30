class Ability
  include CanCan::Ability

  def initialize(user)
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities
    can :read, Channel
    can :index, Video
    if user and user.super_admin?
      can :manage, :all
      can :access, :rails_admin
      can [:embed, :moderate, :brand], Channel
      can [:approve, :deny], Video
    elsif user
      can [:edit, :update, :destroy], Channel, user_id: user.id
      can :create, Channel if user.channels.count < user.plan.channels
      can :embed, Channel if user.plan.embed?
      if user.plan.moderation?
        can :moderate, Channel, user_id: user.id
        can [:approve, :deny], Video, channel: {user_id: user.id}
      end
      can :brand, Channel if user.plan.branding?
    end
  end
end
