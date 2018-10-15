module JSONAPI
  module Materializer
    module Controller
      private def reject_missing_accept_header
        raise(JSONAPI::Materializer.configuration.default_missing_accept_exception) unless request.headers.key?("Accept")
      end

      private def reject_invalid_accept_header
        raise(JSONAPI::Materializer.configuration.default_invalid_accept_exception) unless request.headers.fetch("Accept").include?(JSONAPI::MEDIA_TYPE)
      end
    end
  end
end
