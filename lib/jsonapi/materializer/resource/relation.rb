module JSONAPI
  module Materializer
    module Resource
      class Relation
        include(ActiveModel::Model)

        attr_accessor(:name)
        attr_accessor(:type)
        attr_accessor(:from)
        attr_accessor(:class_name)
        attr_accessor(:visible)

        validates_presence_of(:name)
        validates_presence_of(:type)
        validates_presence_of(:from)
        validates_presence_of(:class_name)
        validates_inclusion_of(:visible, :in => [true, false])

        def initialize(**keyword_arguments)
          super(**keyword_arguments)

          validate!
        end

        def for(object)
          case type
          when :many then object.public_send(from).map {|related_object| materializer_class.new(:object => related_object)}
          when :one then if object.public_send(from).present? then materializer_class.new(:object => object.public_send(from)) end
          end
        end

        def using(parent)
          Resource::Relationship.new(:related => self, :parent => parent)
        end

        def many?
          type == :many
        end

        def one?
          type == :one
        end

        private def materializer_class
          class_name.constantize
        end
      end
    end
  end
end
