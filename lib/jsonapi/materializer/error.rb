# frozen_string_literal: true

module JSONAPI
  module Materializer
    class Error < StandardError
      include(ActiveModel::Model)

      require_relative("error/invalid_accept_header")
      require_relative("error/missing_accept_header")
      require_relative("error/resource_attribute_not_found")
      require_relative("error/resource_relationship_not_found")
    end
  end
end
