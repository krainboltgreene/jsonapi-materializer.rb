module JSONAPI
  module Materializer
    class Attribute
      include(ActiveModel::Model)

      attr_accessor(:name)
      attr_accessor(:from)
      attr_accessor(:selectable)

      def for(object)
        object.public_send(from)
      end

      private def materializer_class
        class_name.constantize
      end
    end
  end
end
