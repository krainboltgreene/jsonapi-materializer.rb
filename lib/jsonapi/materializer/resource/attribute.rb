module JSONAPI
  module Materializer
    module Resource
      class Attribute
        include(ActiveModel::Model)

        attr_accessor(:owner)
        attr_accessor(:name)
        attr_accessor(:from)
        attr_accessor(:visible)

        validates_presence_of(:owner)
        validates_presence_of(:name)
        validates_presence_of(:from)
        validate(:visible_callable)

        def initialize(**keyword_arguments)
          super(**keyword_arguments)

          validate!
        end

        def for(subject)
          subject.object.public_send(from)
        end

        private def materializer_class
          class_name.constantize
        end

        private def visible_callable
          return if [true, false].include?(visible)
          return if visible.is_a?(Symbol)
          return if visible.respond_to?(:call)

          errors.add(:visible, "not callable or boolean")
        end
      end
    end
  end
end
