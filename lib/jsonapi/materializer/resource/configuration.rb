# frozen_string_literal: true

module JSONAPI
  module Materializer
    module Resource
      class Configuration
        include(ActiveModel::Model)

        attr_accessor(:owner)
        attr_accessor(:type)
        attr_accessor(:origin)
        attr_accessor(:identifier)
        attr_accessor(:attributes)
        attr_accessor(:relations)

        validates_presence_of(:owner)
        validates_presence_of(:type)
        validates_presence_of(:origin)
        validates_presence_of(:identifier)

        def initialize(**keyword_arguments)
          super(**keyword_arguments)

          validate!
        end
      end
    end
  end
end
