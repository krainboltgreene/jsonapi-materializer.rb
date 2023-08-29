# frozen_string_literal: true

module JSONAPI
  module Materializer
    module Resource
      class Attribute
        include(ActiveModel::Model)

        attr_accessor(:owner)
        attr_accessor(:name)
        attr_accessor(:from)

        validates_presence_of(:owner)
        validates_presence_of(:name)
        validates_presence_of(:from)

        def initialize(**keyword_arguments)
          super(**keyword_arguments)

          validate!
        end

        def for(subject)
          subject.object.public_send(from)
        end

        private

        def materializer_class
          class_name.constantize
        end
      end
    end
  end
end
