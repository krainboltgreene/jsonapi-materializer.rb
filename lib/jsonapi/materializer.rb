require("ostruct")
require("addressable")
require("active_model")
require("kaminari")
require("active_support/concern")
require("active_support/core_ext/enumerable")
require("active_support/core_ext/string")
require("active_support/core_ext/module")

module JSONAPI
  MEDIA_TYPE = "application/vnd.api+json".freeze unless const_defined?("MEDIA_TYPE")

  module Materializer
    require_relative("materializer/version")
    require_relative("materializer/error")
    require_relative("materializer/configuration")
    require_relative("materializer/controller")

    @configuration ||= Configuration.new(
      :default_invalid_accept_exception => JSONAPI::Materializer::Error::InvalidAcceptHeader,
      :default_missing_accept_exception => JSONAPI::Materializer::Error::MissingAcceptHeader,
      :default_identifier => :id
    )
    require_relative("materializer/collection")
    require_relative("materializer/resource")

    def self.configuration
      if block_given?
        yield(@configuration)
      else
        @configuration
      end
    end
  end
end
