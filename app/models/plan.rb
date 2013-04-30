class Plan < ActiveRecord::Base
  include Extensions::Adminable

  validates :fastspring_reference, uniqueness: true
  validates :channels, presence: true, numericality: true

  scope :subscribable, where(subscribable: true).order(:position)

  has_many :users

  # Public: Return the default plan. If it doesn't exist, create a blank plan
  # with the same name as the 'default' plan (useful for test environment).
  def self.default_plan
    where(name: AppConfig.default_plan).first_or_create!
  end
end
