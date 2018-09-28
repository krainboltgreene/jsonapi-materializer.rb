module JSONAPI
  module Materializer
    module Collection
      SELF_TEMPLATE = "{origin}/{type}".freeze

      extend(ActiveSupport::Concern)

      included do
        include(ActiveModel::Model)

        attr_accessor(:objects)
        attr_writer(:selects)
        attr_writer(:includes)
      end

      delegate(:first_page?, :to => :objects)
      delegate(:prev_page, :to => :objects)
      delegate(:total_pages, :to => :objects)
      delegate(:next_page, :to => :objects)
      delegate(:last_page?, :to => :objects)
      delegate(:limit_value, :to => :objects)

      def as_json(*)
        {
          :links => {
            :first => unless first_page? then links_pagination.expand(:offset => 1, :per => limit_value).to_s end,
            :prev => unless first_page? then links_pagination.expand(:offset => prev_page, :per => limit_value).to_s end,
            :self => links_self,
            :next => unless last_page? then links_pagination.expand(:offset => next_page, :per => limit_value).to_s end,
            :last => unless last_page? then links_pagination.expand(:offset => total_pages, :per => limit_value).to_s end
          }.compact,
          :data => resources,
          :included => included
        }.transform_values {|value| value.presence || value}.compact
      end

      private def materializers
        objects.map {|object| self.class.parent.new(:object => object)}
      end

      private def links_pagination
        Addressable::Template.new(
          "#{origin}/#{type}?page[offset]={offset}&page[per]={per}"
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
        materializers.map(&:as_data)
      end

      private def selects
        @selects || self.class.parent.selectables.keys
      end

      private def includes
        @includes || []
      end

      private def included
        materializers.flat_map do |materializer|
          includes.flat_map do |path|
            path.reduce(materializer) do |subject, key|
              if subject.is_a?(Array)
                subject.map {|related_subjet| related_subjet.relation(key)}
              else
                subject.relation(key)
              end
            end
          end
        end.uniq.map(&:as_data)
      end
    end
  end
end
