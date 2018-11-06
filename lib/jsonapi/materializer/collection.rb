module JSONAPI
  module Materializer
    module Collection
      SELF_TEMPLATE = "{origin}/{type}".freeze

      extend(ActiveSupport::Concern)
      include(ActiveModel::Model)

      attr_accessor(:object)
      attr_writer(:selects)
      attr_writer(:includes)
      attr_writer(:pagination)
      attr_accessor(:context)

      delegate(:first_page?, :to => :object)
      delegate(:prev_page, :to => :object)
      delegate(:total_pages, :to => :object)
      delegate(:next_page, :to => :object)
      delegate(:last_page?, :to => :object)
      delegate(:limit_value, :to => :object)

      def as_json(*)
        {
          :links => {
            :first => unless total_pages.zero? || first_page? then links_pagination.expand(:offset => 1, :limit => limit_value).to_s end,
            :prev => unless total_pages.zero? || first_page? then links_pagination.expand(:offset => prev_page, :limit => limit_value).to_s end,
            :self => unless total_pages.zero? then links_self end,
            :next => unless total_pages.zero? || last_page? then links_pagination.expand(:offset => next_page, :limit => limit_value).to_s end,
            :last => unless total_pages.zero? || last_page? then links_pagination.expand(:offset => total_pages, :limit => limit_value).to_s end
          }.compact,
          :data => resources,
          :included => included
        }.transform_values(&:presence).compact
      end

      private def materializers
        @materializers ||= object.map {|subobject| self.class.parent.new(:object => subobject, :selects => selects, :includes => includes, :context => context)}
      end

      private def links_pagination
        Addressable::Template.new(
          "#{origin}/#{type}?page[offset]={offset}&page[limit]={limit}"
        )
      end

      private def links_self
        Addressable::Template.new(
          "#{origin}/#{type}"
        ).pattern
      end

      private def origin
        self.class.parent.instance_variable_get(:@origin)
      end

      private def type
        self.class.parent.instance_variable_get(:@type)
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

      private def included
        @included ||= materializers.flat_map do |materializer|
          includes.flat_map do |path|
            path.reduce(materializer) do |subject, key|
              if subject.is_a?(Array)
                subject.map {|related_subject| related_subject.relation(key).for(related_subject)}
              else
                subject.relation(key).for(subject)
              end
            end
          end
        end.uniq.map(&:as_data)
      end
    end
  end
end
