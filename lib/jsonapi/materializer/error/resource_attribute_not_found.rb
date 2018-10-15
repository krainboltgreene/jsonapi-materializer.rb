module JSONAPI
  module Materializer
    class Error
      class ResourceAttributeNotFound < Error
        attr_accessor(:name)
        attr_accessor(:materializer)

        def message
          "#{materializer} doesn't define the attribute #{name}"
        end
      end
    end
  end
end
