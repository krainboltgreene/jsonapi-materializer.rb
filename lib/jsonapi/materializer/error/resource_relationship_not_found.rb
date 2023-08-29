# frozen_string_literal: true

module JSONAPI
  module Materializer
    class Error
      class ResourceRelationshipNotFound < Error
        attr_accessor(:name)
        attr_accessor(:materializer)

        def message
          "#{materializer} doesn't define the relationship #{name}"
        end
      end
    end
  end
end
