# frozen_string_literal: true

module JSONAPI
  module Materializer
    module Collection
      SELF_TEMPLATE = "{origin}/{type}"

      extend(ActiveSupport::Concern)
      include(ActiveModel::Model)

      attr_accessor(:object)
      attr_writer(:selects)
      attr_writer(:includes)
      attr_writer(:pagination)

      delegate(:first_page?, to: :object)
      delegate(:prev_page, to: :object)
      delegate(:total_pages, to: :object)
      delegate(:next_page, to: :object)
      delegate(:last_page?, to: :object)
      delegate(:limit_value, to: :object)

      def as_json(*)
        {
          links: pagination,
          included:,
          meta:
        }.transform_values(&:presence).compact.merge(data: resources)
      end

      private def materializers
        @materializers ||= object.map { |subobject| self.class.module_parent.new(object: subobject, selects:, includes:) }
      end

      private def origin
        self.class.module_parent.instance_variable_get(:@origin)
      end

      private def type
        self.class.module_parent.instance_variable_get(:@type)
      end

      private def resources
        @resources ||= materializers.map(&:as_data)
      end

      private def selects
        @selects
      end

      private def includes
        @includes || []
      end

      private def pagination
        if @pagination
          {
            first: (pagination_link_template.expand(offset: 1, limit: limit_value).to_s unless total_pages.zero? || first_page?),
            prev: (pagination_link_template.expand(offset: prev_page, limit: limit_value).to_s unless total_pages.zero? || first_page?),
            self: (self_link_template unless total_pages.zero?),
            next: (pagination_link_template.expand(offset: next_page, limit: limit_value).to_s unless total_pages.zero? || last_page?),
            last: (pagination_link_template.expand(offset: total_pages, limit: limit_value).to_s unless total_pages.zero? || last_page?)
          }.compact
        else
          {}
        end
      end

      private def pagination_link_template
        Addressable::Template.new(
          "#{origin}/#{type}?page[offset]={offset}&page[limit]={limit}"
        )
      end

      private def self_link_template
        Addressable::Template.new(
          "#{origin}/#{type}"
        ).pattern
      end

      private def meta
        {}
      end

      private def included
        @included ||= materializers.flat_map do |materializer|
          includes.flat_map do |path|
            path.reduce(materializer) do |subject, key|
              if subject.is_a?(Array)
                subject.map { |related_subject| related_subject.relation(key).for(related_subject) }
              else
                subject.relation(key).for(subject)
              end
            end
          end
        end.uniq.map(&:as_data)
      end
      # rubocop:enable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
    end
  end
end
