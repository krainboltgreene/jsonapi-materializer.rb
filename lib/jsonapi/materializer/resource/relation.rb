module JSONAPI
  module Materializer
    module Resource
      class Relation
        include(ActiveModel::Model)

        attr_accessor(:owner)
        attr_accessor(:name)
        attr_accessor(:type)
        attr_accessor(:from)
        attr_accessor(:class_name)

        validates_presence_of(:owner)
        validates_presence_of(:name)
        validates_presence_of(:type)
        validates_presence_of(:from)
        validates_presence_of(:class_name)

        def initialize(**keyword_arguments)
          super(**keyword_arguments)

          validate!
        end

        def for(subject)
          @for ||= {}
          @for[checksum(subject)] ||= case type
          when :many then
            unlessing(fetch_relation(subject), -> {subject.includes.any? {|included| included.include?(from.to_s)} || fetch_relation(subject).loaded?}) do |subject|
              subject.select(:id)
            end.map do |related_object|
              materializer_class.new(
                **subject.raw,
                :object => related_object
              )
            end
          when :one then
            if fetch_relation(subject).present?
              materializer_class.new(
                **subject.raw,
                :object => fetch_relation(subject)
              )
            end
          end
        end

        private def fetch_relation(subject)
          @fetch_relationship ||= {}
          @fetch_relationship[checksum(subject)] ||= subject.object.public_send(from)
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

        private def unlessing(object, proc)
          unless proc.call()
            yield(object)
          else
            object
          end
        end

        private def checksum(subject)
          [
            from,
            materializer_class,
            name,
            owner,
            subject,
            type
          ].hash
        end
      end
    end
  end
end
