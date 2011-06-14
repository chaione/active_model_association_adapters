require 'active_support/concern'
require 'active_support/dependencies/autoload'

module ActiveRecord
  module Adapters
    module Mongoid
      extend ActiveSupport::Autoload
      autoload :Associations
    end
  end
end

module ActiveModelAssociationAdapters
  extend ActiveSupport::Autoload
  autoload :Verion
end