module JSONAPI
  module Materializer
    module Context
      extend(ActiveSupport::Concern)
      include(ActiveModel::Model)
    end
  end
end
