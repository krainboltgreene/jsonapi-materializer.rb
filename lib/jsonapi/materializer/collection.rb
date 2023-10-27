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
            first: (pagination_link_template.expand(offset: 1, limit: @pagination.in).to_s unless @pagination.pages.zero? || @pagination.prev.nil?),
            prev: (pagination_link_template.expand(offset: @pagination.prev, limit: @pagination.in).to_s unless @pagination.pages.zero? || @pagination.prev.nil?),
            self: (pagination_link_template.expand(offset: @pagination.page, limit: @pagination.in).to_s unless @pagination.pages.zero?),
            next: (pagination_link_template.expand(offset: @pagination.next, limit: @pagination.in).to_s unless @pagination.pages.zero? || @pagination.next.nil?),
            last: (pagination_link_template.expand(offset: @pagination.pages, limit: @pagination.in).to_s unless @pagination.pages.zero? || @pagination.next.nil?)
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
        end.uniq.compact.map(&:as_data)
      end
    end
  end
end
