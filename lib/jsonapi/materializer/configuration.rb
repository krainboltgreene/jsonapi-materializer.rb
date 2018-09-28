module JSONAPI
  module Materializer
    class Configuration
      include(ActiveModel::Model)

      attr_accessor(:default_origin)
      attr_accessor(:default_identifier)
    end
  end
end
