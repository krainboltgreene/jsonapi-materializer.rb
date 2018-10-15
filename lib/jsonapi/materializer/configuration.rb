module JSONAPI
  module Materializer
    class Configuration
      include(ActiveModel::Model)

      attr_accessor(:default_origin)
      attr_accessor(:default_identifier)
      attr_accessor(:default_missing_accept_exception)
      attr_accessor(:default_invalid_accept_exception)

      validates_presence_of(:default_missing_accept_exception)
      validates_presence_of(:default_invalid_accept_exception)

      def initialize(**keyword_arguments)
        super(**keyword_arguments)

        validate!
      end
    end
  end
end
