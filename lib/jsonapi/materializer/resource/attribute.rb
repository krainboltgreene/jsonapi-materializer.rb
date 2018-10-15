module JSONAPI
  module Materializer
    module Resource
      class Attribute
        include(ActiveModel::Model)

        attr_accessor(:name)
        attr_accessor(:from)
        attr_accessor(:visible)

        validates_presence_of(:name)
        validates_presence_of(:from)
        validates_inclusion_of(:visible, :in => [true, false])

        def initialize(**keyword_arguments)
          super(**keyword_arguments)

          validate!
        end

        def for(object)
          object.public_send(from)
        end

        private def materializer_class
          class_name.constantize
        end
      end
    end
  end
end
