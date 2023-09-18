# frozen_string_literal: true

module JSONAPI
  module Materializer
    module Resource
      class Relationship
        include(ActiveModel::Model)

        attr_accessor(:related)
        attr_accessor(:parent)

        validates_presence_of(:related)
        validates_presence_of(:parent)

        def initialize(**keyword_arguments)
          super(**keyword_arguments)

          validate!
        end

        def as_json(*)
          {
            data:,
            links: {
              self: links_self,
              related: links_related
            }
          }.transform_values(&:presence).compact
        end

        private def links_self
          Addressable::Template.new(
            "#{parent.links_self}/relationships/#{related.name}"
          ).pattern
        end

        def links_related
          Addressable::Template.new(
            "#{parent.links_self}/#{related.name}"
          ).pattern
        end

        def data
          return if related_parent_materializer.blank?

          @data ||= if related.many?
                      related_parent_materializer.map do |child|
                        {
                          id: child.attribute("id").for(child).to_s,
                          type: child.type.to_s
                        }
                      end
                    else
                      {
                        id: related_parent_materializer.attribute("id").for(related_parent_materializer).to_s,
                        type: related_parent_materializer.type.to_s
                      }
                    end
        end
        # rubocop:enable Metrics/AbcSize

        def related_parent_materializer
          related.for(parent)
        end
      end
    end
  end
end
