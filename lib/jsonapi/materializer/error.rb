module JSONAPI
  module Materializer
    class Error < StandardError
      require_relative("error/invalid_accept_header")
      require_relative("error/missing_accept_header")
    end
  end
end
