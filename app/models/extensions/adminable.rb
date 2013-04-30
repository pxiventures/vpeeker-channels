# Public: A Model Concern that gives admins the ability to edit all fields
# of a model in RailsAdmin.
module Extensions
  module Adminable
    extend ActiveSupport::Concern

    included do
      send(:attr_accessible, *(column_names + [{as: :admin}])) if table_exists?
    end
  end
end
